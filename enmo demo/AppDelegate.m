//
//  AppDelegate.m
//  enmo demo
//


#import "AppDelegate.h"
#import  "MainViewController.h"

//#import "GimbalsManager.h"
//#import "EddystoneManager.h"

//For Production server
//#define ADVERTISER_ID 77

//For test Enmo Server
#define ADVERTISER_ID 1022

//For Development server
//#define ADVERTISER_ID 1022

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define SERVER_URL_ADD_TOKEN_TESTENMO				@"http://testenmo.cloudapp.net/rules/RulesService.asmx/AddSubscriberToken?token=%@&advertiserId=%@&isDebug=%d"
#define SERVER_URL_REMOVE_TOKEN_TESTENMO			@"http://testenmo.cloudapp.net/rules/RulesService.asmx/RemoveSubscriberToken?token=%@&advertiserId=%@&isDebug=%d"


NSString * pushNotificationsToken;

@implementation AppDelegate

//==============================================================================
- ( void ) registerForPushNotifications
{
//    [ RulesManager showTestLocalNotificationWithText: @"Registering for Push" ];

//	return;

	UIApplication * application = [ UIApplication sharedApplication ];

	if( [ application respondsToSelector: @selector( isRegisteredForRemoteNotifications ) ] )
	{
		UIUserNotificationType types =	//UIUserNotificationTypeBadge |
										//UIUserNotificationTypeSound |
										UIUserNotificationTypeAlert;
		UIUserNotificationSettings * mySettings = [ UIUserNotificationSettings settingsForTypes: types categories: nil ];

		[ application registerUserNotificationSettings: mySettings ];
		[ application registerForRemoteNotifications ];
	}
}

#pragma mark - Implementing delegate methods

-(void) enmostop3rdPartyRanging{
    [self stop3rdPartyRanging];
}


#pragma mark - UIApplicationDelegate

//==============================================================================
- ( BOOL ) application: ( UIApplication * ) application
didFinishLaunchingWithOptions: ( NSDictionary * ) launchOptions
{
//	[ RulesManager showTestLocalNotificationWithText: @"APP FINISH LAUNCH" ];
//	[ [ UIApplication sharedApplication ] setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalMinimum ];
	[ [ UIApplication sharedApplication ] setMinimumBackgroundFetchInterval: (3600.0 * 6.0) ];

//	NSString *language = [ objectAtIndex:0];

	NSLog(@"PREFERRED LOCALISATIONS APP: %@", [[NSBundle mainBundle] preferredLocalizations] );
	NSLog(@"PREFERRED LOCALISATIONS LOC: %@", [NSLocale preferredLanguages]);

	return YES;
}


//==============================================================================
- ( void ) performInitialSetup: ( NSString * ) oldEmail
{
   // [ RulesManager shared ].delegate = self.mainViewController; //Coomented FL
	//[ RulesManager shared ].advertiserId = [ [ [ NSUserDefaults standardUserDefaults ] objectForKey: @"advertiserId" ] integerValue ]; Commented FL
    
    [[EnmoManager shared] setRulesManagerDelegate:self.mainViewController];
    [[EnmoManager shared] setAdvertiserId:(int)[ [ [ NSUserDefaults standardUserDefaults ] objectForKey: @"advertiserId" ] integerValue ]];
    
        
	[ self registerForPushNotifications ];
    

#ifdef AUTOLOCK
	//[ RulesManager shared ].advertiserId = ADVERTISER_ID; //Commented FL
    [[EnmoManager shared] setAdvertiserId: ADVERTISER_ID];

#endif

//	if( oldEmail )
//	{
//		[ self start3rdPartyRanging ];
//	}

    // 1. Check if we launched app first time or it is new version
    NSString * bundleVersionCurrent = [ [ NSBundle mainBundle ] objectForInfoDictionaryKey: ( NSString * ) kCFBundleVersionKey ];
    NSString * bundleVersionSaved = [ [ NSUserDefaults standardUserDefaults ] objectForKey: @"AppVersion" ];

#ifdef AUTOLOCK

	NSString * emailCurrent = [ [ NSUserDefaults standardUserDefaults ] objectForKey: @"email" ];

#endif

    BOOL newAppVersion = ( bundleVersionSaved == nil ) || ![ bundleVersionCurrent isEqualToString: bundleVersionSaved ];

//    if( [ RulesManager shared ].advertiserId == 0 ) //Commneted FL
    if( [[EnmoManager shared] getAdvertiserId] == 0 )

    {
        [ [ NSUserDefaults standardUserDefaults ] setObject: @"NO" forKey: @"reStart" ];
//		[ [ NSUserDefaults standardUserDefaults ] setObject: @"NO" forKey: @"pushDone" ];
//        [ Logger logToConsole: @"In advertiser id" ]; commented FL
        [[EnmoManager shared] logToConsoleWithData:@"In advertiser id"];
		//[ [ RulesManager shared ] getUsersAdvertiserIDWithCompletionBlock: ^{} ]; // Commented FL
        [[EnmoManager shared] getUsersAdvertiserIDWithCompletionBlock:^{}];
        
    }
    else
    {
        // 2. If app is launched first time or it is some other version
        // or we received push notification in not running mode (so badge count is bigger than 0)
        // - request rules from server:
        if(	  newAppVersion
		   || ( [ UIApplication sharedApplication ].applicationIconBadgeNumber > 0 )
#ifdef AUTOLOCK
		   || ![ emailCurrent isEqualToString: oldEmail ]
#endif
		   )
		{
            [ [ NSUserDefaults standardUserDefaults ] setObject: @"NO" forKey: @"reStart" ];
            [ [ NSUserDefaults standardUserDefaults ] setObject: @"NO" forKey: @"pushDone" ];

			if( [ UIApplication sharedApplication ].applicationIconBadgeNumber > 0 )
			{
                [ [ NSUserDefaults standardUserDefaults ] setObject: @"YES" forKey: @"pushDone" ];
//                NSUserDefaults * settings = [ NSUserDefaults standardUserDefaults ];
//                NSString * pushDone = [ settings objectForKey: @"pushDone" ];
//                NSLog( @"push done in deleget %@", pushDone );
            }
        
//            [ Logger logToConsole: @"Fetch rule from server" ]; //Commented FL
            
            [[EnmoManager shared] logToConsoleWithData:@"Fetch rule from server" ];
            
            
//            [ [ RulesManager shared ] getRulesFromServer: NO ];
            [[EnmoManager shared] getRulesFromServer:NO];
        }
        else
		{
            [ [ NSUserDefaults standardUserDefaults ] setObject: @"YES" forKey: @"reStart" ];
//			[ [ NSUserDefaults standardUserDefaults ] setObject: @"NO" forKey: @"pushDone"];
//            [ Logger logToConsole: @"Fetch rule from local storage" ]; Commented FL
            
            [[EnmoManager shared] logToConsoleWithData:@"Fetch rule from local storage"];
            

         //   [ [ RulesManager shared ] loadLocalRules ]; Commented FL
        }
    }

    // 3. In any case save current app version to settings
    [ [ NSUserDefaults standardUserDefaults ] setObject: bundleVersionCurrent forKey: @"AppVersion" ];
	[ [ NSUserDefaults standardUserDefaults ] synchronize ];
	
    [ UIApplication sharedApplication ].applicationIconBadgeNumber = 0;

//	[ self performSelectorOnMainThread: @selector( start3rdPartyRanging ) withObject: nil waitUntilDone: YES ];
}


//==============================================================================
- ( void ) start3rdPartyRanging
{
    /*
	[ [ GimbalsManager shared ] startMonitoring ];
//#ifndef AUTOLOCK
	[ [ EddystoneManager shared ] startScanning ];
//#endif
     */ //  Commented  FL
    
    [[EnmoManager shared] start3rdPartyRanging];
    
    
}


//==============================================================================
- ( void ) stop3rdPartyRanging
{
    /*
	[ [ GimbalsManager shared ] stopMonitoring ];
//#ifndef AUTOLOCK
	[ [ EddystoneManager shared ] stopScanning ];
//#endif
     */ //Commented FL
    
    [[EnmoManager shared] stop3rdPartyRanging];
}



#pragma mark - Background Mode

//==============================================================================
- ( void ) applicationWillResignActive: ( UIApplication * ) application
{
//	[ RulesManager showTestLocalNotificationWithText: @"applicationWillResignActive" ];
}


//==============================================================================
- ( void ) applicationDidEnterBackground: ( UIApplication * ) application
{
//    [ Logger logToConsole: [ NSString stringWithFormat: @"applicationDidEnterBackground" ]];  //Commented FL
    
    [[EnmoManager shared] logToConsoleWithData:[ NSString stringWithFormat: @"applicationDidEnterBackground" ]];
}


//==============================================================================
- ( void ) applicationWillEnterForeground: ( UIApplication * ) application
{
//    [ Logger logToConsole: [ NSString stringWithFormat: @"applicationWillEnterForeground" ]]; //Commented FL
    
    [[EnmoManager shared] logToConsoleWithData:[ NSString stringWithFormat: @"applicationWillEnterForeground" ]];

}


//==============================================================================
- ( void ) applicationDidBecomeActive: ( UIApplication * ) application
{
//	[ RulesManager showTestLocalNotificationWithText: @"applicationDidBecomeActive" ];
    application.applicationIconBadgeNumber = 0;

// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	NSUserDefaults * settings = [ NSUserDefaults standardUserDefaults ];
	NSString * urlString = [ settings objectForKey: KEY_URL_TO_SHOW_UPON_FOREGROUND ];

	if( urlString )
	{
		NSRange rangeParams = [ urlString rangeOfString: @"?" ];
		BOOL alreadyHasParams = rangeParams.location != NSNotFound;

		if( alreadyHasParams )
			urlString = [ urlString stringByAppendingFormat: @"%@BG2FG=1", alreadyHasParams ? @"&" : @"" ];

		if( [ [ settings objectForKey: @"shouldLoadRulesUponForeground" ] boolValue ] )
		{
			[ settings setObject: nil forKey: @"shouldLoadRulesUponForeground" ];
//            [ [ RulesManager shared ] getRulesFromServer: NO ];
            [ [ EnmoManager shared ] getRulesFromServer: NO ];

		}

//        [ Logger logToConsole: [ NSString stringWithFormat: @"In APPDelegate with the leatest url %@", urlString ] ]; //Commented FL
        
        [[EnmoManager shared] logToConsoleWithData:[ NSString stringWithFormat: @"In APPDelegate with the leatest url %@", urlString ]];
        
		[ self.mainViewController loadModifiedRequestFromURLString: urlString andResetHistory: NO ];
	}
	else
	{
		// NOTE: Konstantin - as I removed rule call when app loads rules json locally - we need to load last called page if any
		NSString * urlString2 = [ settings objectForKey: @"lastURL" ];
		if(urlString2)
			[ self.mainViewController loadModifiedRequestFromURLString: urlString2 andResetHistory: NO ];
	}
}


//==============================================================================
- ( void ) application: ( UIApplication * ) application
performFetchWithCompletionHandler: ( void ( ^ ) ( UIBackgroundFetchResult ) ) completionHandler
{
//    [ RulesManager showTestLocalNotificationWithText: @"BG FETCH" ]; Commented FL
    
    [[EnmoManager shared] showTestLocalNotificationWithText:@"BG FETCH"];

//	completionHandler( UIBackgroundFetchResultNoData );

	NSLog(@"BG FETCH TIMER = %ld", (long)[[EnmoManager shared] appIdTimer]);

	if( [[EnmoManager shared] appIdTimer] == 0 )
	{
		completionHandler( UIBackgroundFetchResultNoData );
		return;
	}

//	[ RulesManager showTestLocalNotificationWithText: @"Perform BG Fetch" ];

//	self.fetchCompletionHandler = completionHandler; //Commented FL
    
    [EnmoManager shared].fetchCompletionHandler = completionHandler;

	NSLog(@"performing background fetch of rules now");

//    [ RulesManager showTestLocalNotificationWithText: @"FETCHING RULES" ]; Commented FL
    
    [[EnmoManager shared] showTestLocalNotificationWithText:@"FETCHING RULES"];
    

//    if( ![ [ RulesManager shared ] checkForNewRules ] ) { Commented FL
    
    if( ![ [ EnmoManager shared ] checkNewRules] ) {

		completionHandler( UIBackgroundFetchResultNewData );
//        self.fetchCompletionHandler = nil; //Eommented FL
        [EnmoManager shared].fetchCompletionHandler  = nil;
	}
}


#pragma mark - Terminate

//==============================================================================
- ( void ) applicationWillTerminate: ( UIApplication * ) application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    [ Logger logToConsole: [ NSString stringWithFormat: @"App end" ] ];  Commented FL
    
    [[EnmoManager shared] logToConsoleWithData:[ NSString stringWithFormat: @"App end" ]];
    
    


	// NOTE: Konstantin - probably this causes bug with wrong url shown when app returns back from deep sleep
//    NSUserDefaults * settings = [ NSUserDefaults standardUserDefaults ];
//    [ settings setObject: nil forKey: KEY_URL_TO_SHOW_UPON_FOREGROUND ];

//    [ [ RulesManager shared ] saveMonitoredRegions ]; //Commented FL
    
    [[EnmoManager shared] prepareForAppTerminate]; //save monitor regions
}


#ifdef USE_PUSH_NOTIFICATIONS

#pragma mark - Push Notifications

//==============================================================================
- ( void ) postTokenForPushNotificationsFromData: ( NSData * ) deviceTokenData
{
	return;

	BOOL isDebug = NO;

#ifdef DEBUG
//	isDebug = YES;
#endif

	NSString * tokenString = [ NSString stringWithFormat: @"%@", deviceTokenData ];
	tokenString = [ tokenString stringByReplacingOccurrencesOfString: @"<" withString: @"" ];
	tokenString = [ tokenString stringByReplacingOccurrencesOfString: @">" withString: @"" ];
	tokenString = [ tokenString stringByReplacingOccurrencesOfString: @" " withString: @"" ];

	NSLog( @"TOKEN: %@", tokenString );
	pushNotificationsToken = tokenString;
//    [ RulesManager showTestLocalNotificationWithText: [ NSString stringWithFormat: @"TOKEN: %@", pushNotificationsToken ] ]; //Commented FL
    
    [[EnmoManager shared] showTestLocalNotificationWithTe:[ NSString stringWithFormat: @"TOKEN: %@", pushNotificationsToken ]];

//	pushNotificationsToken = [ pushNotificationsToken stringByReplacingOccurrencesOfString: @"5" withString: @"1" ];

	NSString * oldToken = [ [ NSUserDefaults standardUserDefaults ] objectForKey: KEY_PUSH_TOKEN ];
	if( oldToken && ![ oldToken isEqualToString: pushNotificationsToken ] )
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSURL * postURL = [ NSURL URLWithString: [ NSString stringWithFormat: SERVER_URL_REMOVE_TOKEN_TESTENMO, oldToken,
//                                                      [ NSString stringWithFormat: @"%ld", (long)[RulesManager shared].advertiserId ], isDebug ] ]; Commented FL
            
            
            NSURL * postURL = [ NSURL URLWithString: [ NSString stringWithFormat: SERVER_URL_REMOVE_TOKEN_TESTENMO, oldToken,
                                                      [ NSString stringWithFormat: @"%ld", (long)[[EnmoManager shared] getAdvertiserId], isDebug ] ];

            
            
			NSLog( @"TOKEN REMOVE URL: %@", postURL );
			NSMutableURLRequest * request = [ NSMutableURLRequest requestWithURL: postURL cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 30.0 ];
			NSURLConnection * connection = [ [ NSURLConnection alloc ] initWithRequest: request delegate: self ];
		});
	}

	[ [ NSUserDefaults standardUserDefaults ] setObject: pushNotificationsToken forKey: KEY_PUSH_TOKEN ];
	[ [ NSUserDefaults standardUserDefaults ] synchronize ];

//    NSURL * postURL = [ NSURL URLWithString: [ NSString stringWithFormat: SERVER_URL_ADD_TOKEN_TESTENMO, pushNotificationsToken,
//                                              [ NSString stringWithFormat: @"%ld", (long)[RulesManager shared].advertiserId ], isDebug ] ]; //Commented FL
                               
    NSURL * postURL = [ NSURL URLWithString: [ NSString stringWithFormat: SERVER_URL_ADD_TOKEN_TESTENMO, pushNotificationsToken,
                                                                         [ NSString stringWithFormat: @"%ld", (long) [[EnmoManager shared] getAdvertiserId], isDebug ] ];

                               
	NSLog( @"TOKEN ADD URL: %@", postURL );

	NSMutableURLRequest * request = [ NSMutableURLRequest requestWithURL: postURL cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 30.0 ];
	NSURLConnection * connection = [ [ NSURLConnection alloc ] initWithRequest: request delegate: self ];
#pragma unused( connection )
}


//==============================================================================
- ( void ) application: ( UIApplication * ) app
didRegisterForRemoteNotificationsWithDeviceToken: ( NSData * ) deviceToken
{
	[ self postTokenForPushNotificationsFromData: deviceToken ];
}


//==============================================================================
- ( void ) application: ( UIApplication * ) app
didFailToRegisterForRemoteNotificationsWithError: ( NSError * ) err
{
//	[ RulesManager showTestLocalNotificationWithText: [ NSString stringWithFormat: @"PUSH ERROR: %@", err.localizedDescription ] ];
	NSString * str = [ NSString stringWithFormat: @"Error: %@", err ];
	NSLog(@"PUSH ERROR: %@", str);
	pushNotificationsToken = nil;
}


//==============================================================================
- ( void ) application: ( UIApplication * ) application
didReceiveRemoteNotification: ( NSDictionary * ) userInfo
fetchCompletionHandler: ( void ( ^ ) ( UIBackgroundFetchResult result) ) completionHandler
{
//    [ RulesManager showTestLocalNotificationWithText: @"PUSH: DID RECEIVE" ]; //Commented FL
    
    [[EnmoManager shared] showTestLocalNotificationWithText:@"PUSH: DID RECEIVE"];

	NSDictionary * dictAPS = [ userInfo objectForKey: @"aps" ];

	NSString * string = [ dictAPS objectForKey: @"alert" ];

	if( [ string isEqualToString: @"Get New Rules" ] )
	{
		NSLog(@"GET NEW RULES");
//        [ RulesManager showTestLocalNotificationWithText: @"PUSH: GET NEW RULES" ];
        
        [[EnmoManager shared] showTestLocalNotificationWithText:@"PUSH: GET NEW RULES"];

		application.applicationIconBadgeNumber = 0;
        
//        [ RulesManager shared ].currentAppId.timestamp = nil; //Commented FL
        
        [[EnmoManager shared] appIdTimer] = nil;

    
//        [ [ RulesManager shared ] getRulesFromServer: YES ]; Commented FL
        [[EnmoManager shared] getRulesFromServer:YES];
		completionHandler( UIBackgroundFetchResultNewData );
		return;
	}

	completionHandler( UIBackgroundFetchResultNoData );
}

#endif

- (void)rulesManagerDidStop3rdPartyRanging
{
    [self stop3rdPartyRanging];
 }
                       
                       @end
