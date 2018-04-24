//
//  SettingsViewController.m
//  enmo autolock
//


#import "SettingsViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
//#import "GimbalsManager.h"
//#import <EnmoSDK/EnmoManager.h>
//#import <EnmoSDK/EnmoSDK.h>


@interface SettingsViewController () < UITextFieldDelegate > // < MFMailComposeViewControllerDelegate >

@property ( readwrite, retain ) IBOutlet UIScrollView * scrollView;

@property ( readwrite, retain ) IBOutlet UILabel * lblAdvertiserId;
@property ( readwrite, retain ) IBOutlet UIButton * btnAdvertiserId;
@property ( readwrite, retain ) IBOutlet UILabel * lblShowDebugNotifications;
@property ( readwrite, retain ) IBOutlet UIButton * btnShowDebugNotifications;
@property ( readwrite, retain ) IBOutlet UILabel * lblUseTestenmoServer;
@property ( readwrite, retain ) IBOutlet UISwitch * switchUseTestenmoServer;
@property ( readwrite, retain ) IBOutlet UILabel * lblAppVersion;
@property ( readwrite, retain ) IBOutlet UIButton * btnForceGetRules;
@property ( readwrite, retain ) IBOutlet UIButton * btnSendManualLock;
@property ( readwrite, retain ) IBOutlet UILabel * lblEmail;
@property ( readwrite, retain ) IBOutlet UIButton * btnLogout;

@property ( readwrite, retain ) IBOutlet UISegmentedControl * btnRoomType;
@property ( readwrite, retain ) IBOutlet UITextField * txtEnterSignalStrength;
@property ( readwrite, retain ) IBOutlet UITextField * txtDwellTimeInterval;
@property ( readwrite, retain ) IBOutlet UITextField * txtExitTimeInterval;
@property ( readwrite, retain ) IBOutlet UITextField * txtExitTimeIntervalBG;
@property ( readwrite, retain ) IBOutlet UITextField * txtExitSignalStrength;
@property ( readwrite, retain ) IBOutlet UIButton * btnSave;
@property ( readwrite, retain ) IBOutlet UIView * viewGimbalSettings;

@end



@implementation SettingsViewController

//==============================================================================
- ( void ) viewDidLoad
{
    [ super viewDidLoad ];

	self.btnSave.hidden = YES;
	
#ifdef AUTOLOCK

	self.btnAdvertiserId.hidden = YES;
	self.lblAdvertiserId.hidden = YES;
	self.lblShowDebugNotifications.hidden = YES;
	self.btnShowDebugNotifications.hidden = YES;
	self.lblUseTestenmoServer.hidden = YES;
	self.switchUseTestenmoServer.hidden = YES;
	self.btnForceGetRules.hidden = YES;

#endif

#ifdef ATMIO

	self.btnAdvertiserId.hidden = YES;
	self.lblAdvertiserId.hidden = YES;
	self.btnSendManualLock.hidden = YES;

	UIBarButtonItem * barButton = [ [ UIBarButtonItem alloc ] initWithTitle: @"Save"
																	  style: UIBarButtonItemStylePlain
																	 target: self
																	 action: @selector( onBtnSave: ) ];
	[ self navigationItem ].rightBarButtonItem = barButton;

#endif

	_btnRoomType.hidden = YES;
	_txtEnterSignalStrength.delegate = self;
	_txtDwellTimeInterval.delegate = self;
	_txtExitTimeInterval.delegate = self;
	_txtExitTimeIntervalBG.delegate = self;
	_txtExitSignalStrength.delegate = self;

	self.scrollView.contentSize = CGSizeMake( CGRectGetWidth(self.view.bounds), 475 + 30 );
}


//==============================================================================
- ( void ) viewWillAppear: ( BOOL ) animated
{
	[ super viewWillAppear: animated ];
	
	[ [ NSNotificationCenter defaultCenter ] addObserver: self
												selector: @selector( keyboardWillShow: )
													name: UIKeyboardWillShowNotification
												  object: nil ];
	
	[ [ NSNotificationCenter defaultCenter ] addObserver: self
												selector: @selector( keyboardWillHide: )
													name: UIKeyboardWillHideNotification
												  object: nil ];

//    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
//    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    
 //   NSString * versionBuildString = [NSString stringWithFormat:@"%@.%@", appVersionString, appBuildString];

	//NSDictionary * dictInfo = ( __bridge NSDictionary * ) CFBundleGetInfoDictionary( CFBundleGetMainBundle() );
//	self.lblAppVersion.text = [ NSString stringWithFormat: @"Build: %@", [ dictInfo objectForKey: @"CFBundleShortVersionString" ] ];

	NSString * email = [ [ NSUserDefaults standardUserDefaults ] objectForKey: @"email" ];
	self.lblEmail.text = email.length ? email : @"";

    //[[ NSUserDefaults standardUserDefaults ] setObject:versionBuildString forKey:@"CFBundleShortVersionString"];
    self.lblAppVersion.text=[ NSString stringWithFormat: @"Build: %@",[[ NSUserDefaults standardUserDefaults ] objectForKey: @"CFBundleShortVersionString" ]];

	NSNumber * advId = [ [ NSUserDefaults standardUserDefaults ] objectForKey: @"advertiserId" ];
	self.lblAdvertiserId.text = advId ? [ NSString stringWithFormat: @"%d", advId.intValue ] : @"0";

	[ self.btnShowDebugNotifications setTitle: [ [ [ NSUserDefaults standardUserDefaults ] objectForKey: @"showDebugNotifications" ] boolValue ] ? @"ON" : @"OFF"
									 forState: UIControlStateNormal ];

	self.switchUseTestenmoServer.on = NO;
    //[ [ [ PreferencesManager shared ] objectForKey: KEY_SETTINGS_USE_TESTENMO_SERVER ] boolValue ];

	_btnRoomType.selectedSegmentIndex = [ [ NSUserDefaults standardUserDefaults ] integerForKey: KEY_ROOM_TYPE ];

#ifdef GIMBAL_SDK_VERSION_1
	self.viewGimbalSettings.hidden = NO;
#else
	self.viewGimbalSettings.hidden = YES;
#endif
/*
	[ _txtEnterSignalStrength setText: [ NSString stringWithFormat: @"%ld", ( long ) [ GimbalsManager shared ].enterSignalStrength ] ];
	[ _txtDwellTimeInterval setText: [ NSString stringWithFormat: @"%ld", ( long ) [ GimbalsManager shared ].dwellTimeTimeout ] ];
	[ _txtExitSignalStrength setText: [ NSString stringWithFormat: @"%ld", ( long ) [ GimbalsManager shared ].exitSignalStrength ] ];
	[ _txtExitTimeInterval setText: [ NSString stringWithFormat: @"%ld", ( long ) [ GimbalsManager shared ].stayAwayTimeout ] ];
	[ _txtExitTimeIntervalBG setText: [ NSString stringWithFormat: @"%ld", ( long ) [ GimbalsManager shared ].stayAwayTimeoutBG ] ];
*/  //Commented  FL
    
    [ _txtEnterSignalStrength setText: [ NSString stringWithFormat: @"%ld", ( long ) [[EnmoManager shared] getSignalStrength]]];
    [ _txtDwellTimeInterval setText: [ NSString stringWithFormat: @"%ld", ( long ) [[EnmoManager shared] getDwellTimeTimeout]]];
    [ _txtExitSignalStrength setText: [ NSString stringWithFormat: @"%ld", ( long ) [[EnmoManager shared] getExitSignalStrength]]];
    [ _txtExitTimeInterval setText: [ NSString stringWithFormat: @"%ld", ( long ) [[EnmoManager shared] getStayAwayTimeout]] ];
    [ _txtExitTimeIntervalBG setText: [ NSString stringWithFormat: @"%ld", ( long ) [[EnmoManager shared] getStayAwayTimeoutBG]]];

    
    
    
	[ _txtEnterSignalStrength resignFirstResponder ];
	[ _txtDwellTimeInterval resignFirstResponder ];
	[ _txtExitSignalStrength resignFirstResponder ];
	[ _txtExitTimeInterval resignFirstResponder ];
	[ _txtExitTimeIntervalBG resignFirstResponder ];

	self.scrollView.contentOffset = CGPointZero;
	self.scrollView.contentInset = UIEdgeInsetsZero;
}


//==============================================================================
- ( void ) viewWillDisappear:(BOOL)animated
{
    [ super viewWillDisappear: animated ];

//	[ [ NSNotificationCenter defaultCenter ] removeObserver: self ];
}


//==============================================================================
- ( IBAction ) onBtnAdvertiserId: ( id ) sender
{
//    [ [ RulesManager shared ] getUsersAdvertiserIDWithCompletionBlock:
//        ^
//        {
//            NSNumber * advId = [ [ NSUserDefaults standardUserDefaults ] objectForKey: @"advertiserId" ];
//            self.lblAdvertiserId.text = advId ? [ NSString stringWithFormat: @"%d", advId.intValue ] : @"0";
//        }
//     ]; //Commented FL
    
    
    [[EnmoManager shared] getUsersAdvertiserIDWithCompletionBlock:^{
        NSNumber * advId = [ [ NSUserDefaults standardUserDefaults ] objectForKey: @"advertiserId" ];
        self.lblAdvertiserId.text = advId ? [ NSString stringWithFormat: @"%d", advId.intValue ] : @"0";
    }];
}


//==============================================================================
- ( IBAction ) onBtnShowDebugNotifications: ( id ) sender
{
	if([self.btnShowDebugNotifications.titleLabel.text isEqualToString: @"ON"])
	{
		// set to off
		[ self.btnShowDebugNotifications setTitle: @"OFF" forState: UIControlStateNormal ];
		[ [ NSUserDefaults standardUserDefaults ] setObject: [ NSNumber numberWithBool: NO ] forKey: @"showDebugNotifications" ];
	}
	else
	{
		// set to off
		[ self.btnShowDebugNotifications setTitle: @"ON" forState: UIControlStateNormal ];
		[ [ NSUserDefaults standardUserDefaults ] setObject: [ NSNumber numberWithBool: YES ] forKey: @"showDebugNotifications" ];
	}

	[ [ NSUserDefaults standardUserDefaults ] synchronize ];
}


//==============================================================================
- ( IBAction ) onBtnUseTestEnmoServer: ( id ) sender
{
//	[ [ PreferencesManager shared ] setObject: [ NSNumber numberWithBool: self.switchUseTestenmoServer.on ]
//									   forKey: KEY_SETTINGS_USE_TESTENMO_SERVER ];

//	[ UIAlerter showYesNoAlertWithTitle: @"Server changed."
//								message: @"Do you want to update rules?"
//							resultBlock:
//								^
//								{
//									[ [ RulesManager shared ] postTokenIfAny ];
//									[ [ RulesManager shared ] getRulesFromServer ];
//								}
//						 andCancelBlock: ^{}
//	 ];
}


//==============================================================================
- ( IBAction ) onBtnGetRules: ( id ) sender
{
//    [ [ RulesManager shared ] resetFrequencyCaps ];  Commented FL
    
    [[EnmoManager shared] resetFrequencyCaps]; //Commented FL
    
    
    
//	[ RulesManager shared ].currentAppId.timestamp = nil; //commented FL
    
    [[EnmoManager shared] setcurrentAppIdTimeStamp:nil]; //Need to implement
    
    
	
//    [ Logger logToConsole: @"Get Rule Button" ]; //Commented FL
    
    [[EnmoManager shared] logToConsoleWithData:@"Get Rule Button"];
    

//	[ [ RulesManager shared ] getRulesFromServer: YES ]; //commented FL
    
    [[EnmoManager shared] getRulesFromServer:YES];
    

//	NSTimeInterval now = [ NSDate timeIntervalSinceReferenceDate ];
//	[ [ NSUserDefaults standardUserDefaults ] setDouble: now forKey: KEY_FETCH_TIMESTAMP ];
//	[ [ NSUserDefaults standardUserDefaults ] synchronize ];

	[ self.navigationController popViewControllerAnimated: YES ];
}


//==============================================================================
- ( IBAction ) onBtnRoomType: ( id ) sender
{
//    [ Logger logToConsole: @"Room Type Button" ]; //Commented FL
    
    [[EnmoManager shared] logToConsoleWithData:@"Room Type Button"];
    

	NSInteger index = self.btnRoomType.selectedSegmentIndex;
	[ [ NSUserDefaults standardUserDefaults ] setInteger: index forKey: KEY_ROOM_TYPE ];
	[ [ NSUserDefaults standardUserDefaults ] synchronize ];

	NSInteger newEnterSignalStrength    = index == 0 ? -70 : -70;
	NSInteger newExitSignalStrength     = index == 0 ? -80 : -85;

	BOOL preferencesChanged = NO;
/*
	if( newEnterSignalStrength != [ GimbalsManager shared ].enterSignalStrength )
	{
		[ GimbalsManager shared ].enterSignalStrength = newEnterSignalStrength;
		preferencesChanged = YES;
	}

	if( newExitSignalStrength != [ GimbalsManager shared ].exitSignalStrength )
	{
		[ GimbalsManager shared ].exitSignalStrength = newExitSignalStrength;
		preferencesChanged = YES;
	}
 */
    //Commented FL
    
    if( newEnterSignalStrength != [[EnmoManager shared] getSignalStrength] )
    {
    [[EnmoManager shared] setSignalStrength:newEnterSignalStrength];
        preferencesChanged = YES;
    }
    
    if( newExitSignalStrength != [[EnmoManager shared] getExitSignalStrength]  )
    {
        [[EnmoManager shared] setExitSignalStrength:newExitSignalStrength];
        preferencesChanged = YES;
    }
    
    
    

#ifdef GIMBAL_SDK_VERSION_1
	[ [ GimbalsManager shared ] savePreferences ];

	if( preferencesChanged )
		[ [ GimbalsManager shared ] initVisitManager ];
#endif
}


//==============================================================================
- ( IBAction ) onBtnLogout: ( id ) sender
{
//    [ [ RulesManager shared ] prepareForLogout ]; //commented FL
    
    [[EnmoManager shared] prepareForLogout];
    
    
    
    

	[ self.navigationController popToRootViewControllerAnimated: YES ];
}


//==============================================================================
- ( IBAction ) onBtnSendManualLock: ( id ) sender
{
//    [ Logger logToConsole: @"Send Manual Lock Button" ]; //Commented FL
    
    [[EnmoManager shared] logToConsoleWithData:@"Send Manual Lock Button"];
    
//    [ [ RulesManager shared ] sendManualLockMessage ]; //Commented FL
    
    [ [ EnmoManager shared ] sendManualLockMessage ];

}


//==============================================================================
- ( IBAction ) onBtnEmailLogs: ( id ) sender
{
//    [ Logger logToConsole: @"Sending Logs via Email" ]; //commented FL
    
    [[EnmoManager shared] logToConsoleWithData:@"Sending Logs via Email"];
    
//    [ [ EmailManager shared ] sendEmailWithViewController: self ]; //commented FL
    
    [ [ EnmoManager  shared ] sendEmailWithViewController: self ];

}


//==============================================================================
- ( IBAction ) onBtnBack: ( id ) sender
{
	[ self.navigationController popViewControllerAnimated: YES ];
}


//==============================================================================
- ( IBAction ) onBtnSave: ( id ) sender
{
	NSInteger newEnterSignalStrength    = _txtEnterSignalStrength.text.integerValue;
	NSInteger newDwellTimeInterval      = _txtDwellTimeInterval.text.integerValue;
	NSInteger newExitSignalStrength     = _txtExitSignalStrength.text.integerValue;
	NSInteger newExitTimeInterval       = _txtExitTimeInterval.text.integerValue;
	NSInteger newExitTimeIntervalBG     = _txtExitTimeIntervalBG.text.integerValue;
	
	BOOL preferencesChanged = NO;
	
    /*
	if( newEnterSignalStrength != [ GimbalsManager shared ].enterSignalStrength )
	{
		[ GimbalsManager shared ].enterSignalStrength = newEnterSignalStrength;
		preferencesChanged = YES;
	}
	
	if( newDwellTimeInterval != [ GimbalsManager shared ].dwellTimeTimeout )
	{
		[ GimbalsManager shared ].dwellTimeTimeout = newDwellTimeInterval;
		preferencesChanged = YES;
	}
	
	if( newExitSignalStrength != [ GimbalsManager shared ].exitSignalStrength )
	{
		[ GimbalsManager shared ].exitSignalStrength = newExitSignalStrength;
		preferencesChanged = YES;
	}
	
	if( newExitTimeInterval != [ GimbalsManager shared ].stayAwayTimeout )
	{
		[ GimbalsManager shared ].stayAwayTimeout = newExitTimeInterval;
		preferencesChanged = YES;
	}
	
	if( newExitTimeIntervalBG != [ GimbalsManager shared ].stayAwayTimeoutBG )
	{
		[ GimbalsManager shared ].stayAwayTimeoutBG = newExitTimeIntervalBG;
		preferencesChanged = YES;
	}
	*/ //Commented FL
    
    
    if( newEnterSignalStrength != [[EnmoManager shared] getSignalStrength] )
    {
        [[EnmoManager shared] setSignalStrength:newEnterSignalStrength];
        preferencesChanged = YES;
    }
    
    if( newDwellTimeInterval != [[EnmoManager shared] getDwellTimeTimeout] )
    {
        [[EnmoManager shared] setDwellTimeTimeout:newDwellTimeInterval];
        preferencesChanged = YES;
    }
    
    if( newExitSignalStrength !=[[EnmoManager shared] getExitSignalStrength] )
    {
        [[EnmoManager shared] setExitSignalStrength:newExitSignalStrength] ;
        preferencesChanged = YES;
    }
    
    if( newExitTimeInterval != [[EnmoManager shared] getStayAwayTimeout])
    {
        [[EnmoManager shared] setStayAwayTimeout:newExitTimeInterval];
        preferencesChanged = YES;
    }
    
    if( newExitTimeIntervalBG != [[EnmoManager shared] getStayAwayTimeoutBG])
    {
       [[EnmoManager shared] setStayAwayTimeoutBG:newExitTimeIntervalBG];
        preferencesChanged = YES;
    }
    
    
    
#ifdef GIMBAL_SDK_VERSION_1
	[ [ GimbalsManager shared ] savePreferences ];
	
	if( preferencesChanged )
		[ [ GimbalsManager shared ] initVisitManager ];
#endif
	
	[ _txtEnterSignalStrength resignFirstResponder ];
	[ _txtDwellTimeInterval resignFirstResponder ];
	[ _txtExitSignalStrength resignFirstResponder ];
	[ _txtExitTimeInterval resignFirstResponder ];
	[ _txtExitTimeIntervalBG resignFirstResponder ];
}

#pragma mark - UITextFieldDelegate

//==============================================================================
- ( BOOL ) textFieldShouldReturn: ( UITextField * ) textField
{
	[ textField resignFirstResponder ];
	return YES;
}


//==============================================================================
- ( void ) keyboardWillShow: ( NSNotification * ) note
{
	NSDictionary * userInfo = note.userInfo;
	NSTimeInterval duration = [ userInfo[ UIKeyboardAnimationDurationUserInfoKey ] doubleValue ];
	UIViewAnimationCurve curve = [ userInfo[ UIKeyboardAnimationCurveUserInfoKey ] integerValue ];
	
	CGRect keyboardFrameEnd = [ userInfo[ UIKeyboardFrameEndUserInfoKey ] CGRectValue ];
	keyboardFrameEnd = [ self.view convertRect: keyboardFrameEnd fromView: nil ];
	
	[ UIView animateWithDuration: duration
						   delay: 0
						 options: UIViewAnimationOptionBeginFromCurrentState | curve
					  animations:
	 ^
	 {
		 _scrollView.frame = CGRectMake(0, 0, keyboardFrameEnd.size.width, keyboardFrameEnd.origin.y);
	 }
					  completion: nil ];
}


//==============================================================================
- ( void ) keyboardWillHide: ( NSNotification * ) note
{
	NSDictionary * userInfo = note.userInfo;
	NSTimeInterval duration = [ userInfo[ UIKeyboardAnimationDurationUserInfoKey ] doubleValue ];
	UIViewAnimationCurve curve = [ userInfo[ UIKeyboardAnimationCurveUserInfoKey ] integerValue ];
	
	CGRect keyboardFrameEnd = [ userInfo[ UIKeyboardFrameEndUserInfoKey ] CGRectValue ];
	keyboardFrameEnd = [ self.view convertRect: keyboardFrameEnd fromView: nil ];
	
	[ UIView animateWithDuration: duration
						   delay: 0
						 options: UIViewAnimationOptionBeginFromCurrentState | curve
					  animations:
	 ^
	 {
		 _scrollView.frame = CGRectMake(0, 0, keyboardFrameEnd.size.width, CGRectGetHeight( _scrollView.superview.frame ) );
	 }
					  completion: nil ];
}


/*
//==============================================================================
- ( IBAction ) sendToMail: ( id ) sender
{
    NSString * documentsDirectory = [ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex: 0 ];
    NSString * fileName = [ documentsDirectory stringByAppendingPathComponent: @"myLogFile.txt" ];

//    NSString * content = [ NSString stringWithContentsOfFile: fileName encoding: NSUTF8StringEncoding error: nil ];
//    NSLog( @"content is %@", content );

	[ self showEmail: fileName ];
}


//===================================================================================
- ( void ) showEmail: ( NSString * ) file
{
	[ Logger logToConsole: [ NSString stringWithFormat: @"file is %@", file ] ];

	// Determine the file name and extension
	NSString * extension = file.pathExtension;

	// Determine the MIME type
	NSString * mimeType;

	if( [ extension isEqualToString: @"jpg" ] )
		mimeType = @"image/jpeg";

	else if( [ extension isEqualToString: @"png" ] )
		mimeType = @"image/png";

	else if( [ extension isEqualToString: @"doc" ] )
		mimeType = @"application/msword";

	else if( [ extension isEqualToString: @"ppt" ] )
		mimeType = @"application/vnd.ms-powerpoint";

	else if( [ extension isEqualToString: @"html" ] )
		mimeType = @"text/html";

	else if( [ extension isEqualToString: @"pdf" ] )
		mimeType = @"application/pdf";

	else if( [ extension isEqualToString: @"txt" ] )
		mimeType = @"text/plain";

//	[ Logger logToConsole: [ NSString stringWithFormat: @"mime type %@ and file data %@ and file name %@", mimeType, fileData, file ] ];


	if( [ MFMailComposeViewController canSendMail ] )
	{
		NSString * emailTitle = @"Log From iPhone";
		NSString * messageBody = @"Please download the log file";

		NSMutableArray * toRecipents = [ [ NSMutableArray alloc ] init ];
		[ toRecipents addObject: @"sisreeksha@ideationts.com" ];
		[ toRecipents addObject: @"sunil@enmo.mobi" ];
		[ toRecipents addObject: @"konstantin@enmo.mobi" ];

		// Get the resource path and read the file using NSData
		//  NSString * filePath = [ [ NSBundle mainBundle ] pathForResource: filename ofType: extension ];
		NSData * fileData = [ NSData dataWithContentsOfFile: file ];

//		[ Logger logToConsole: @"send email" ];

		MFMailComposeViewController * mc = [ [ MFMailComposeViewController alloc ] init ];
		mc.mailComposeDelegate = self;
		[ mc setSubject: emailTitle ];
		[ mc setMessageBody: messageBody isHTML: NO ];
		[ mc setToRecipients: toRecipents ];

//		[ Logger logToConsole: [ NSString stringWithFormat: @"1st mc is %@", mc ] ];

		// Add attachment
		[ mc addAttachmentData: fileData mimeType: mimeType fileName: file ];

//		[ Logger logToConsole: [ NSString stringWithFormat: @"mc is %@", mc ] ];

		// Present mail view controller on screen
		[ self presentViewController: mc animated: YES completion: ^{} ];

	} // if( [ MFMailComposeViewController canSendMail ] )
	else
	{
//		[ Logger logToConsole: [ NSString stringWithFormat: @"Device is unable to send email in its current state." ] ];
	}
}

*/

//===================================================================================
- ( void ) mailComposeController: ( MFMailComposeViewController * ) controller
			 didFinishWithResult: ( MFMailComposeResult ) result
						   error: ( NSError * ) error
{
//	[ Logger logToConsole: @"in didFinishWithResult" ];

	switch( result )
	{
		case MFMailComposeResultCancelled:
//			[ Logger logToConsole: @"Mail cancelled" ];
			break;

		case MFMailComposeResultSaved:
//			[ Logger logToConsole: @"Mail saved" ];
			break;

		case MFMailComposeResultSent:
//			[ Logger logToConsole: @"Mail sent" ];
			break;

		case MFMailComposeResultFailed:
//			[ Logger logToConsole: [ NSString stringWithFormat: @"Mail sent failure: %@", [ error localizedDescription ] ] ];
			break;

		default:
			break;
	}

	// Close the Mail Interface
	[ self dismissViewControllerAnimated: YES completion: NULL ];

//    [ [ EmailManager shared ] cleanup ]; // Commneted FL
    [[EnmoManager shared] cleanup];
	//[ [ EmailManager shared ] addString: @"Cleaned Up after the Email had been sent" ]; Commented FL
    [[EnmoManager shared] addString:@"Cleaned Up after the Email had been sent"];
}

@end
