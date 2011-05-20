//
//  CaseMemoAppDelegate.m
//  CaseMemo
//
//  Created by Matthew Botos on 5/17/11.
//  Copyright 2011 Mavens Consulting, Inc. All rights reserved.
//

#import "CaseMemoAppDelegate.h"
#import "RootViewController.h"
#import "FDCOAuthViewController.h"
#import "FDCServerSwitchboard.h"

// STEP 1 a - Consumer Key from Salesforce Setup > Develop > Remote Access
#define kSFOAuthConsumerKey @"3MVG9y6x0357HleejikYgTgKSQy7Ba8e7zCk_NwT6fye_OKUEmRjgZxgZ8OQCywvuw7WaW_g5VAJpijHWt9kC"

@implementation CaseMemoAppDelegate


@synthesize window=_window;

@synthesize splitViewController=_splitViewController;

@synthesize rootViewController=_rootViewController;

@synthesize detailViewController=_detailViewController;

@synthesize oAuthViewController=_oAuthViewController;

#pragma mark -
#pragma mark Error Handling

+ (void)error:(NSException*)exception {
	[self errorWithMessage:[exception reason]];
}

+ (void)errorWithError:(NSError*)error {
	[self errorWithMessage:[NSString stringWithFormat:@"%@", error]];
}

+ (void)errorWithMessage:(NSString*)message {
	NSLog(@"Error: %@", message);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark App

// STEP 1 c - Handle OAuth login callback
- (void)loginOAuth:(FDCOAuthViewController *)oAuthViewController error:(NSError *)error
{
    if ([oAuthViewController accessToken] && !error)
    {
        NSLog(@"Hey, we logged in!");
        [[FDCServerSwitchboard switchboard] setClientId:kSFOAuthConsumerKey];
        [[FDCServerSwitchboard switchboard] setApiUrlFromOAuthInstanceUrl:[oAuthViewController instanceUrl]];
        [[FDCServerSwitchboard switchboard] setSessionId:[oAuthViewController accessToken]];
        [[FDCServerSwitchboard switchboard] setOAuthRefreshToken:[oAuthViewController refreshToken]];
        
    	[self.splitViewController dismissModalViewControllerAnimated:YES];
        [self.oAuthViewController autorelease];
        
        // STEP 2 a - Load data after login
        [self.rootViewController loadData];
    }
    else if (error)
    {
        [CaseMemoAppDelegate errorWithError:error];
    }
}

#pragma mark -
#pragma AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // STEP 1 b - Show OAuth login
    [[FDCServerSwitchboard switchboard] setClientId:kSFOAuthConsumerKey];
    self.oAuthViewController = [[FDCOAuthViewController alloc] initWithTarget:self selector:@selector(loginOAuth:error:) clientId:kSFOAuthConsumerKey];
    
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];

    self.oAuthViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.window.rootViewController presentModalViewController:self.oAuthViewController animated:YES];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_splitViewController release];
    [_rootViewController release];
    [_detailViewController release];
    [super dealloc];
}

@end
