//
//  MainViewController.m
//  Toodledo OAuth


#import "MainViewController.h"
#import "WebAuthViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) WebAuthViewController *webAuthViewController;

@property (strong, nonatomic) NSURLConnection *accessCodeRequestConnection;

@property (strong, nonatomic) NSMutableData *accessCodeRequestData;

@property (strong, nonatomic) NSURLConnection *userInfoRequestConnection;

@property (strong, nonatomic) NSMutableData *userInfoRequestData;

@property (strong, nonatomic) NSString *authorizationCode;

@property (strong, nonatomic) NSString *accessCode;

@property (strong, nonatomic) NSString *refreshCode;

@end

@implementation MainViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.accessCodeRequestConnection = nil;
        self.accessCodeRequestData = [[NSMutableData alloc] init];
        self.userInfoRequestConnection = nil;
        self.userInfoRequestData = [[NSMutableData alloc] init];
        self.webAuthViewController = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.authorizeButton setEnabled:YES];
    [self.accessCodeButton setEnabled:NO];
    [self.refreshButton setEnabled:NO];
    [self.userInfoButton setEnabled:NO];
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    if([standardDefaults objectForKey:@"appId"] != nil) {
        [self.appIdTextField setText:[standardDefaults objectForKey:@"appId"]];
    }
    if([standardDefaults objectForKey:@"secret"] != nil) {
        [self.secretTextField setText:[standardDefaults objectForKey:@"secret"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showWebAuthViewController"]) {
        self.webAuthViewController = (WebAuthViewController *)segue.destinationViewController;
        [self.webAuthViewController setAppId:self.appIdTextField.text];
        [self.webAuthViewController setDelegate:self];
    }
}

- (NSString *)authorizationCode
{
    return self.authorizationCodeTextField.text;
}

- (void)setAuthorizationCode:(NSString *)authorizationCode
{
    [self.authorizationCodeTextField setText:authorizationCode];
    
    [self setAccessCode:nil];
    [self setRefreshCode:nil];
    [self.userEmailTextField setText:nil];
    [self.userInfoButton setEnabled:NO];

    if(authorizationCode) {
        [self.accessCodeButton setEnabled:YES];
    }
}

- (void)setAuthorizationCode:(NSString *)authorizationCode sender:(id)sender
{
    [self setAuthorizationCode:authorizationCode];
    
    if([sender isEqual:self.webAuthViewController]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString *)accessCode
{
    return self.accessCodeTextField.text;
}

- (void)setAccessCode:(NSString *)accessCode
{
    [self.accessCodeTextField setText:accessCode];

    if(accessCode != nil && [accessCode length]) {
        [self.accessCodeButton setEnabled:NO];
        [self.userInfoButton setEnabled:YES];
    }
    else {
        [self.accessCodeButton setEnabled:YES];
        [self.userInfoButton setEnabled:NO];
    }
}

- (NSString *)refreshCode
{
    return self.refreshCodeTextField.text;
}

- (void)setRefreshCode:(NSString *)refreshCode
{
    [self.refreshCodeTextField setText:refreshCode];
    
    if(refreshCode != nil && [refreshCode length]) {
        [self.refreshButton setEnabled:YES];
    }
    else {
        [self.refreshButton setEnabled:NO];
    }
}

- (IBAction)tappedAuthorizeButton:(id)sender
{
    [self.authorizationCodeTextField setText:nil];
    [self.accessCodeTextField setText:nil];
    [self.refreshCodeTextField setText:nil];
}

- (IBAction)tappedAccessCodeButton:(id)sender
{
    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.toodledo.com/3/account/token.php"]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    if([sender isEqual:self.accessCodeButton]) {
        [request setHTTPBody:[[NSString stringWithFormat:@"grant_type=authorization_code&code=%@", self.authorizationCodeTextField.text] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else if([sender isEqual:self.refreshButton]) {
        [request setHTTPBody:[[NSString stringWithFormat:@"grant_type=refresh_token&refresh_token=%@", self.refreshCodeTextField.text] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", self.appIdTextField.text, self.secretTextField.text];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength]];
    
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"POST"];
    
    self.accessCodeRequestConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.accessCodeRequestConnection start];
}

- (IBAction)tappedUserInfoButton:(id)sender
{
    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.toodledo.com/3/account/get.php?access_token=%@", self.accessCodeTextField.text]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    self.userInfoRequestConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.userInfoRequestConnection start];
}

#pragma mark UITextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([textField isEqual:self.appIdTextField] || [textField isEqual:self.secretTextField] || [textField isEqual:self.authorizationCodeTextField]) {
        [self setAuthorizationCode:nil];
    }
    if([textField isEqual:self.authorizationCodeTextField]) {
        [self setAccessCode:nil];
        [self setRefreshCode:nil];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if([textField isEqual:self.appIdTextField] || [textField isEqual:self.secretTextField]) {
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        if([textField isEqual:self.appIdTextField]) {
            [standardDefaults setObject:textField.text forKey:@"appId"];
        }
        else if([textField isEqual:self.secretTextField]) {
            [standardDefaults setObject:self.secretTextField.text forKey:@"secret"];
        }
        [standardDefaults synchronize];
    }
    
    return YES;
}

#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if([connection isEqual:self.accessCodeRequestConnection]) {
        [self.accessCodeRequestData setLength:0];
    }
    else if([connection isEqual:self.userInfoRequestConnection]) {
        [self.userInfoRequestData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if([connection isEqual:self.accessCodeRequestConnection]) {
        [self.accessCodeRequestData appendData:data];
    }
    else if([connection isEqual:self.userInfoRequestConnection]) {
        [self.userInfoRequestData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if([connection isEqual:self.accessCodeRequestConnection]) {
        NSError *error = nil;
        NSDictionary *requestData = [NSJSONSerialization JSONObjectWithData:self.accessCodeRequestData options:0 error:&error];
        if(!error) {
            if([requestData objectForKey:@"errorCode"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error %@", [requestData objectForKey:@"errorCode"]]
                                                                message:[requestData objectForKey:@"errorDesc"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else if([requestData objectForKey:@"access_token"] && [requestData objectForKey:@"refresh_token"]) {
                [self setAccessCode:[requestData objectForKey:@"access_token"]];
                [self setRefreshCode:[requestData objectForKey:@"refresh_token"]];
            }
        }
        
        self.accessCodeRequestConnection = nil;
    }
    else if([connection isEqual:self.userInfoRequestConnection]) {
        NSError *error = nil;
        NSDictionary *requestData = [NSJSONSerialization JSONObjectWithData:self.userInfoRequestData options:0 error:&error];
        if(!error) {
            [self.userEmailTextField setText:[requestData objectForKey:@"email"]];
        }
        
        self.userInfoRequestConnection = nil;
    }
}

@end
