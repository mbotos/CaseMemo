//
//  RootViewController.h
//  CaseMemo
//
//  Created by Matthew Botos on 5/17/11.
//  Copyright 2011 Mavens Consulting, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface RootViewController : UITableViewController {
}

		
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) NSMutableArray *dataRows;

- (void) loadData;
- (id)findCaseById:(NSString*)caseId;

@end
