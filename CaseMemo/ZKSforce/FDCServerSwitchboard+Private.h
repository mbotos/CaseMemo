

#import <Foundation/Foundation.h>
#import "FDCServerSwitchboard.h"

@class ZKElement;
@class ZKLoginResult;

@interface FDCServerSwitchboard (Private)

- (void)_sendRequestWithData:(NSString *)payload
                      target:(id)target
                    selector:(SEL)sel;
- (void)_sendRequestWithData:(NSString *)payload
                      target:(id)target
                    selector:(SEL)sel
                     context:(id)context;
- (void)_sendRequest:(NSURLRequest *)aRequest
              target:(id)target
            selector:(SEL)sel
             context:(id)context;
- (void)_returnResponseForConnection:(NSURLConnection *)connection;

- (ZKElement *)_processHttpResponse:(NSHTTPURLResponse *)resp data:(NSData *)responseData;
- (void)_checkSession;
- (void)_sessionResumed:(ZKLoginResult *)loginResult error:(NSError *)error;
- (void)_oauthRefreshAccessToken:(NSTimer *)timer;


// NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection; 

@end
