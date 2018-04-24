//
//  RegisterViewController.h
//  enmo autolock
//


#import <UIKit/UIKit.h>
#import "MainViewController.h"


@interface RegisterViewController : UIViewController
{
	IBOutlet UITextField * _txtEmail;
//	IBOutlet UITextField * _txtFirstName;
//	IBOutlet UITextField * _txtLastName;

	IBOutlet MainViewController * _mainViewController;
}

@end
