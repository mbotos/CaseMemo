//
//  DetailViewController.h
//  CaseMemo
//
//  Created by Matthew Botos on 5/17/11.
//  Copyright 2011 Mavens Consulting, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITableViewDelegate, UITableViewDataSource> {

    UILabel *_numberLabel;
    UILabel *_subjectLabel;
    UILabel *_descriptionLabel;
    UITableView *_attachmentsTable;
}


@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) id detailItem;

// STEP 5 a - Store attachments in an array
@property (nonatomic, retain) NSArray *attachments;

// STEP 4 a - Create layout in DetailView.xib and link outlets
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutlet UILabel *subjectLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

// STEP 5 b - Create attachments table in DetailView.xib and link outlet and delegates
@property (nonatomic, retain) IBOutlet UITableView *attachmentsTable;

@end
