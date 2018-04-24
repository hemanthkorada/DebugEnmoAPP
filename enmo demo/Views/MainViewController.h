//
//  MainViewController.h
//  enmo autolock
//


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
//#import "EnmoSDK/EnmoSDK.h"


@interface MainViewController : UIViewController < UIWebViewDelegate , EnmoManagerDelegate
//, MFMailComposeViewControllerDelegate
>
{
	NSString * _lastLoadedRequest;
	NSMutableArray * _arrayHistory;
}

+ ( MainViewController * ) shared;

//- ( void ) loadInitialPage;
- ( void ) loadModifiedRequestFromURLString: ( NSString * ) urlString
							andResetHistory: ( BOOL ) shouldResetHistory;

@end
