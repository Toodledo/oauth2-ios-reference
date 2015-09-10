//
//  WebAuthViewDelegate.h
//  Toodledo OAuth

@protocol WebAuthViewControllerDelegateProtocol <NSObject>

- (void)setAuthorizationCode:(NSString *)authorizationCode sender:(id)sender;

@end
