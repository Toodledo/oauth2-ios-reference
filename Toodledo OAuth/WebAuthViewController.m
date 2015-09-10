//
//  WebAuthViewController.m
//  Toodledo OAuth

#import "WebAuthViewController.h"

@interface WebAuthViewController ()

@property (strong, nonatomic) NSMutableString *state;

@property (strong, nonatomic) NSString *authorizationCode;

@end

@implementation WebAuthViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.authorizationCode = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    /**
     *  Generate a random alpha string for our state value to check on against the response.
     */
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    self.state = [NSMutableString stringWithCapacity: 16];
    
    for (int i=0; i < 16; i++) {
        [self.state appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    /**
     *  Set up our request and include the state.
     */
    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.toodledo.com/3/account/authorize.php?response_type=code&client_id=%@&state=%@&scope=basic%%20tasks", self.appId, self.state]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
    [self.authWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIWebView delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    /**
     *  If we're receiving a request response from the Toodledo api host..
     */
    if([request.URL.absoluteString rangeOfString:[NSString stringWithFormat:@"state=%@", self.state]].location != NSNotFound) {
        
        /**
         *  And the response contains a code..
         */
        if([request.URL.absoluteString rangeOfString:@"code="].location != NSNotFound) {
            NSError *regularExpressionError = nil;

            /**
             *  Find the authorization code using a regular expression..
             */
            NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"code=.*(;|&)" options:NSRegularExpressionCaseInsensitive error:&regularExpressionError];

            NSArray *regularExpressionMatches = [regularExpression matchesInString:request.URL.absoluteString options:0 range:NSMakeRange(0, [request.URL.absoluteString length])];

            if([regularExpressionMatches count]){
                NSTextCheckingResult *match = [regularExpressionMatches firstObject];

                self.authorizationCode = [NSString stringWithString:[request.URL.absoluteString substringWithRange:NSMakeRange(match.range.location+5, match.range.length-6)]];
            }
            return NO;
        }
        else if([request.URL.absoluteString rangeOfString:@"error="].location != NSNotFound) {
            return NO;
        }
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.delegate setAuthorizationCode:self.authorizationCode sender:self];
}

- (IBAction)tappedCancelButton:(id)sender
{
    [self.delegate setAuthorizationCode:nil sender:self];
}

@end
