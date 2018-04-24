//
//  AppDelegate.h
//  enmo demo
//


 
#import <UIKit/UIKit.h>
//#import "EnmoSDK/EnmoSDK.h"

@class MainViewController;


@interface AppDelegate : UIResponder < UIApplicationDelegate, NSURLConnectionDelegate >
{

}

@property ( strong, nonatomic ) UIWindow * window;
@property ( readwrite, retain ) MainViewController * mainViewController;
//@property ( strong, nonatomic ) void (^fetchCompletionHandler)(UIBackgroundFetchResult); //Commneted FL


- ( void ) registerForPushNotifications;
- ( void ) performInitialSetup: ( NSString * ) oldEmail;

//- ( void ) start3rdPartyRanging; //Commented FL
//- ( void ) stop3rdPartyRanging; //Commented FL

@end
