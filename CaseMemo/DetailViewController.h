//
//  DetailViewController.h
//  CaseMemo
//
//  Created by Matthew Botos on 5/17/11.
//  Copyright 2011 Mavens Consulting, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {

    UILabel *_numberLabel;
    UILabel *_subjectLabel;
    UILabel *_descriptionLabel;
}


@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) id detailItem;

@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutlet UILabel *subjectLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

@end
