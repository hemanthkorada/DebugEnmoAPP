//
//  RegisterViewController.m
//  enmo autolock
//


#import "RegisterViewController.h"
#import "AppDelegate.h"
//#import "EnmoSDK/EnmoSDK.h"

//Konstantin's server
#define SERVER_URL_ADD_SUBUSER_KONSTANTIN       @"http://192.168.1.7:26457/AutoLock/AutoLockService.asmx/AddSubuser?email=%@"
#define SERVER_URL_CHECK_USER_KONSTANTIN		@"http://192.168.1.7:26457/rules/RulesService.asmx/CheckUser?email=%@"
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*//Developer's server
#define SERVER_URL_ADD_SUBUSER_ATMIO			@"http://kaushik.ideationts.com//AutoLock/AutoLockService.asmx/AddSubuser?email=%@"

#define SERVER_URL_ADD_SUBUSER_TESTENMO         @"http://testenmo.cloudapp.net/AutoLock/AutoLockService.asmx/AddSubuser?email=%@"

#define SERVER_URL_CHECK_USER_ATMIO				@"http://kaushik.ideationts.com/rules/RulesService.asmx/CheckUser?email=%@"

#define SERVER_URL_CHECK_USER_TESTENMO			@"http://testenmo.cloudapp.net/rules/RulesService.asmx/CheckUser?email=%@"
 
 #define ADVERTISER_ID 1022
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/
//Production server
#define SERVER_URL_ADD_SUBUSER_ENMO				@"http://platform.enmo.mobi/AutoLock/AutoLockService.asmx/AddSubuser?email=%@"
#define SERVER_URL_ADD_SUBUSER_TESTENMO         @"http://testenmo.cloudapp.net/AutoLock/AutoLockService.asmx/AddSubuser?email=%@"

#define SERVER_URL_CHECK_USER_ENMO				@"http://platform.enmo.mobi/rules/RulesService.asmx/CheckUser?email=%@"
#define SERVER_URL_CHECK_USER_TESTENMO			@"http://testenmo.cloudapp.net/rules/RulesService.asmx/CheckUser?email=%@"

//For test
#define ADVERTISER_ID 1022

//For Production
//#define ADVERTISER_ID 77
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation RegisterViewController

//==============================================================================
- ( void ) awakeFromNib
{
	[ super awakeFromNib ];

#ifdef AUTOLOCK
	UIStoryboard * sb = [ UIStoryboard storyboardWithName: @"Main-AutoLock" bundle: nil ];
#endif

#ifdef ATMIO
	UIStoryboard * sb = [ UIStoryboard storyboardWithName: @"Main-Enmo" bundle: nil ];
#endif

	_mainViewController = ( MainViewController * ) [ sb instantiateViewControllerWithIdentifier: @"MainViewController" ];
	_mainViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}


//==============================================================================
- ( void ) viewDidLoad
{
    [ super viewDidLoad ];
    
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString * versionBuildString = [NSString stringWithFormat:@"%@.%@", appVersionString, appBuildString];
    
    [[ NSUserDefaults standardUserDefaults ] setObject:versionBuildString forKey:@"CFBundleShortVersionString"];

	NSString * email = [ [ NSUserDefaults standardUserDefaults ] objectForKey: @"email" ];
//	NSString * firstName = [ [ PreferencesManager shared ] objectForKey: KEY_SETTINGS_FIRST_NAME ];
//	NSString * lastName = [ [ PreferencesManager shared ] objectForKey: KEY_SETTINGS_LAST_NAME ];

	_txtEmail.text = email.length ? email : @"";
//	_txtFirstName.text = firstName.length ? firstName : @"";
//	_txtLastName.text = lastName.length ? lastName : @"";

	if( email != nil
//	   && firstName != nil && lastName != nil
	   )
		[ self showMainViewWithOldEmail: email ];
}


//==============================================================================
- ( void ) viewWillAppear: ( BOOL ) animated
{
	[ super viewWillAppear: animated ];

	NSString * email = [ [ NSUserDefaults standardUserDefaults ] objectForKey: @"email" ];
	_txtEmail.text = email.length ? email : @"";
}


//==============================================================================
- ( IBAction ) submit: ( id ) sender
{
//	[ self.view endEditing: YES ];
	[ _txtEmail resignFirstResponder ];
	
	NSString * email = _txtEmail.text;

	if( email.length == 0 )
	{
//        [ UIAlerter showOKAlertWithTitle: @"Please enter your email address."
//                                 message: @""
//                          andResultBlock: ^{}
//         ]; Commented FL
        
        [[EnmoManager shared] showOKAlertWithTitle:@"Please enter your email address." message:@"" andResultBlock:^{
            
        }];

		return;
	}


//	NSString * firstName = _txtFirstName.text;
//
//	if( firstName.length == 0 )
//	{
//		[ UIAlerter showOKAlertWithTitle: @"Please enter your first name."
//								 message: @""
//						  andResultBlock:^{}
//		 ];
//		return;
//	}
//
//
//	NSString * lastName = _txtLastName.text;
//
//	if( lastName.length == 0 )
//	{
//		[ UIAlerter showOKAlertWithTitle: @"Please enter your last name."
//								 message: @""
//						  andResultBlock:^{}
//		 ];
//		return;
//	}

#ifdef USE_TESTENMO_SERVER
	BOOL useTestenmo = YES;
#else
	BOOL useTestenmo = NO;
#endif


	NSString * urlFormat = [ NSString stringWithFormat:

#ifdef AUTOLOCK
#ifdef LOCAL_TESTING
							SERVER_URL_ADD_SUBUSER_KONSTANTIN,
#else
							useTestenmo ? SERVER_URL_ADD_SUBUSER_TESTENMO : SERVER_URL_ADD_SUBUSER_ENMO,
#endif
#endif

#ifdef ATMIO
#ifdef LOCAL_TESTING
							SERVER_URL_CHECK_USER_KONSTANTIN,
#else
							useTestenmo ? SERVER_URL_CHECK_USER_TESTENMO : SERVER_URL_CHECK_USER_ENMO,
#endif
#endif
							email
//							, firstName, lastName
							];

//    urlFormat = [ [ RulesManager shared ] addExtraFieldsToURL: urlFormat withRule: nil andTriggeredRegion: nil ]; //commented FL
    
    urlFormat = [[EnmoManager shared] addExtraFieldsToURL:urlFormat withRule:nil andTriggeredRegion:nil];
    

	NSURL * url = [ NSURL URLWithString: urlFormat ];

	NSURLRequest * request = [ [ NSURLRequest alloc ] initWithURL: url ];

	NSURLResponse * response = nil;

	NSError * error = nil;

	// send it synchronous
	NSData * responseData = [ NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error ];
	NSString * responseString = [ [ NSString alloc ] initWithData: responseData encoding: NSUTF8StringEncoding ];

	// check for an error. If there is a network error, you should handle it here.
	if( !error && [ [ responseString lowercaseString ] rangeOfString: @"success" ].location!= NSNotFound )
	{
//		<?xml version="1.0" encoding="utf-8"?>
//		<string xmlns="http://enmo.cloudapp.net/autolock/">SUCCESS_1023</string>

		responseString = [ responseString stringByReplacingOccurrencesOfString: @"\n" withString: @"" ];
		responseString = [ responseString stringByReplacingOccurrencesOfString: @"\r" withString: @"" ];
		responseString = [ responseString stringByReplacingOccurrencesOfString:
						  @"<?xml version=\"1.0\" encoding=\"utf-8\"?><string xmlns=\"http://atmio.com/autolock/\">"
																	withString: @"" ];
		responseString = [ responseString stringByReplacingOccurrencesOfString:
						  @"<?xml version=\"1.0\" encoding=\"utf-8\"?><string xmlns=\"http://atmio.com/rules/\">"
																	withString: @"" ];
		responseString = [ responseString stringByReplacingOccurrencesOfString: @"</string>" withString: @"" ];

		NSInteger advId = [ [ responseString stringByReplacingOccurrencesOfString: @"SUCCESS_" withString: @"" ] integerValue ];

#ifdef AUTOLOCK
		if( advId != ADVERTISER_ID )
		{
            
            //    [ UIAlerter showOKAlertWithTitle: @"You are not authorized to use Auto-Lock."
            //     message: @"Please check the email address you entered or contact your organization’s IT group."
            // andResultBlock: ^{} ]; //Commented FL
            
            
            [[EnmoManager shared] showOKAlertWithTitle:@"You are not authorized to use Auto-Lock." message:@"Please check the email address you entered or contact your organization’s IT group." andResultBlock:^{
            }];

		

			return;
		}
#endif

//        [ RulesManager shared ].advertiserId = advId; //Commented FL
        
        [[EnmoManager shared] setAdvertiserId:(int)advId];

//        [ [ NSUserDefaults standardUserDefaults ] setObject: [ NSNumber numberWithInteger: [ RulesManager shared ].advertiserId ]
//                                                     forKey: @"advertiserId" ];  //Commented FL
        
        [ [ NSUserDefaults standardUserDefaults ] setObject: [ NSNumber numberWithInteger: [[EnmoManager shared] getAdvertiserId]]
                                                     forKey: @"advertiserId" ];

        
        

//		NSString * oldEmail = [ [ NSUserDefaults standardUserDefaults ] objectForKey: @"email" ];
		[ [ NSUserDefaults standardUserDefaults ] setObject: email forKey: @"email" ];
//		[ [ PreferencesManager shared ] setObject: firstName forKey: KEY_SETTINGS_FIRST_NAME ];
//		[ [ PreferencesManager shared ] setObject: lastName forKey: KEY_SETTINGS_LAST_NAME ];

		// NOTE: for now calling
		[ self showMainViewWithOldEmail: email ];
	}
	else
	{
		// handle error
		if( error )
//            [ UIAlerter showOKAlertWithTitle: @"ERROR"
//                                     message: error.localizedDescription
//                              andResultBlock: ^{} ]; //Commented FL
            
            [[EnmoManager shared] showOKAlertWithTitle:@"ERROR" message:error.localizedDescription andResultBlock:^{
            }];

		else
		{
#ifdef ATMIO
//            [ UIAlerter showOKAlertWithTitle: @"You are not authorized to use enmo Development App."
//                                     message: @"Please contact enmo Tech for assistance."
//                              andResultBlock: ^{} ];
            
            [[EnmoManager shared] showOKAlertWithTitle:@"You are not authorized to use enmo Development App." message:@"Please contact enmo Tech for assistance." andResultBlock:^{
            }];

            
            
            
#endif

#ifdef AUTOLOCK
//            [ UIAlerter showOKAlertWithTitle: @"You are not authorized to use Auto-Lock."
//                                     message: @"Please check the email address you entered or contact your organization’s IT group."
//                              andResultBlock: ^{} ]; //Commented FL
            
            [[EnmoManager shared] showOKAlertWithTitle:@"You are not authorized to use Auto-Lock." message:@"Please check the email address you entered or contact your organization’s IT group." andResultBlock:^{
            }];

#endif
		}
	}
}


//==============================================================================
- ( void ) showMainViewWithOldEmail: ( NSString * ) oldEmail
{
	[ self.navigationController pushViewController: _mainViewController animated: YES ];

	AppDelegate * appDelegate = ( AppDelegate * ) [ [ UIApplication sharedApplication ] delegate ];

	[ appDelegate performSelectorOnMainThread: @selector( start3rdPartyRanging )
								   withObject: nil
								waitUntilDone: YES ];

	[ appDelegate performSelectorOnMainThread: @selector( performInitialSetup: )
								   withObject: oldEmail
								waitUntilDone: NO ];
}

@end
