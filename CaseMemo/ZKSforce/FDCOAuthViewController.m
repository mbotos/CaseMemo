// Copyright (c) 2010 Rick Fillion
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
// THE SOFTWARE.
//

#import "FDCOAuthViewController.h"
#import "NSURL+Additions.h"

@interface FDCOAuthViewController (Private)

- (NSURL *)loginURL;
- (void)sendActionToTarget:(NSError *)error;

@end


@implementation FDCOAuthViewController

@synthesize accessToken;
@synthesize refreshToken;
@synthesize display;
@synthesize redirectUri;
@synthesize instanceUrl;

- (id)initWithTarget:(id)aTarget selector:(SEL)aSelector clientId:(NSString *)aClientId
{
    if (self = [super initWithNibName:nil bundle:nil])
    {
        target = [aTarget retain];
        action = aSelector;
        clientId = [aClientId retain];
        self.display = @"touch";
        self.redirectUri = @"https://login.salesforce.com/services/oauth2/success";
    }
    return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
    UIView *rootView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,320,460)] autorelease];
    
    webView = [[UIWebView alloc] initWithFrame:[rootView bounds]];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
    webView.delegate = self;
    [rootView addSubview:webView];
        
    [self setView:rootView];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[self loginURL]];
    [webView loadRequest:request];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [target release];
    [clientId release];
    [webView release];
    [display release];
    [accessToken release];
    [instanceUrl release];
    [refreshToken release];
    [super dealloc];
}

#pragma mark -
#pragma mark Properties


#pragma mark -
#pragma mark Private

- (NSURL *)loginURL
{
    NSString *urlTemplate = @"https://login.salesforce.com/services/oauth2/authorize?response_type=token&client_id=%@&redirect_uri=%@&display=%@";
    NSString *urlString = [NSString stringWithFormat:urlTemplate, clientId, redirectUri, display];
    NSURL *url = [NSURL URLWithString:urlString];
    //NSLog(@"loginURL = %@", url);
    return url;
}

- (void)sendActionToTarget:(NSError *)error
{
    [target performSelector:action withObject:self withObject:error];
}

#pragma mark -
#pragma mark UIWebViewDelegate


- (BOOL)webView:(UIWebView *)myWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType 
{
    NSString *urlString = [[request URL] absoluteString];

    NSRange range = [urlString rangeOfString:self.redirectUri];
    
    if (range.length > 0 && range.location == 0) 
    {
        NSString * newInstanceURL = [[request URL] parameterWithName:@"instance_url"];
        if (newInstanceURL)
        {
            [instanceUrl release];
            instanceUrl = [newInstanceURL retain];
        }
        
        NSString *newRefreshToken = [[request URL] parameterWithName:@"refresh_token"];
        if (newRefreshToken)
        {
            [refreshToken release];
            refreshToken = [newRefreshToken retain];
        }
        
        NSString *newAccessToken = [[request URL] parameterWithName:@"access_token"];
        if (newAccessToken)
        {
            [accessToken release];
            accessToken = [newAccessToken retain];
            [self sendActionToTarget:nil];
        }
        return NO;
    }
    return YES;
}

@end
