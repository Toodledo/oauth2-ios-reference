//
//  WebAuthViewController.h
//  Toodledo OAuth

#import <UIKit/UIKit.h>
#import "WebAuthViewDelegate.h"

@interface WebAuthViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) IBOutlet UIWebView *authWebView;
@property (weak, nonatomic) id<WebAuthViewControllerDelegateProtocol> delegate;

@end
