//
//  MainViewController.h
//  Toodledo OAuth


#import <UIKit/UIKit.h>
#import "WebAuthViewDelegate.h"

@interface MainViewController : UITableViewController <UITextFieldDelegate, WebAuthViewControllerDelegateProtocol, NSURLConnectionDelegate>

@property (strong, nonatomic) IBOutlet UITextField *appIdTextField;
@property (strong, nonatomic) IBOutlet UITextField *secretTextField;
@property (strong, nonatomic) IBOutlet UITextField *authorizationCodeTextField;
@property (strong, nonatomic) IBOutlet UITextField *accessCodeTextField;
@property (strong, nonatomic) IBOutlet UITextField *refreshCodeTextField;
@property (strong, nonatomic) IBOutlet UITextField *userEmailTextField;

@property (strong, nonatomic) IBOutlet UIButton *authorizeButton;
@property (strong, nonatomic) IBOutlet UIButton *accessCodeButton;
@property (strong, nonatomic) IBOutlet UIButton *userInfoButton;
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;

- (IBAction)tappedAuthorizeButton:(id)sender;

- (IBAction)tappedAccessCodeButton:(id)sender;

- (IBAction)tappedUserInfoButton:(id)sender;

@end
