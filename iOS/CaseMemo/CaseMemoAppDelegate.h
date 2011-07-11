//
//  CaseMemoAppDelegate.h
//  CaseMemo
//
//  Created by Matthew Botos on 5/17/11.
//  Copyright 2011 Mavens Consulting, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDCOAuthViewController.h"

@class RootViewController;

@class DetailViewController;

@interface CaseMemoAppDelegate : NSObject <UIApplicationDelegate> {
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;

@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@property (nonatomic, retain) IBOutlet FDCOAuthViewController *oAuthViewController;

@property (nonatomic, retain) NSDictionary *notificationData;

+ (void)error:(NSException*)exception;
+ (void)errorWithError:(NSError*)error;
+ (void)errorWithMessage:(NSString*)message;

- (void) saveOAuthData: (FDCOAuthViewController *)oAuthViewController;
- (void) showCaseInNotification;

@end
