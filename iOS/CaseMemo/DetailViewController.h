//
//  DetailViewController.h
//  CaseMemo
//
//  Created by Matthew Botos on 5/17/11.
//  Copyright 2011 Mavens Consulting, Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "ZKSforce.h"
#import "DetailTable.h"

@interface DetailViewController : UIViewController <
    UIPopoverControllerDelegate, UISplitViewControllerDelegate, 
    UITableViewDelegate, UITableViewDataSource,
    UIAlertViewDelegate,
    AVAudioPlayerDelegate
> {

    UILabel *_numberLabel;
    UILabel *_subjectLabel;
    UILabel *_descriptionLabel;
    UITableView *_detailTable;
    UITableView *_attachmentsTable;
    UIView *_attachmentsHeaderView;

    BOOL hasAttachments;

    AVAudioRecorder *audioRecorder;
	AVAudioPlayer *audioPlayer;
	NSURL *audioURL;
    NSIndexPath *audioIndexPath;

    UIButton *_recordButton;
}


@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) id detailItem;

// STEP 5 a - Store attachments in an array
@property (nonatomic, retain) NSMutableArray *attachments;

// STEP 4 a - Create layout in DetailView.xib and link outlets
@property (nonatomic, retain) IBOutlet UITableView *detailTable;
@property (nonatomic, retain) DetailTable *detailTableData;

// STEP 5 b - Create attachments table in DetailView.xib and link outlet and delegates
@property (nonatomic, retain) IBOutlet UITableView *attachmentsTable;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *attachmentsLoadingIndicator;
@property (nonatomic, retain) IBOutlet UIView *attachmentsHeaderView;

// STEP 7 a - Create record button in DetailView.xib and link TouchUpInside event
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
- (IBAction)record:(id)sender;

- (void) loadAudio:(ZKSObject *) attachment;
- (void) attachmentBodyQueryResult:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) playAudioAttachment:(ZKSObject *) attachment;

- (void) deleteSoundFile;
- (void) initializeAudio;
- (void) showRecordDialog;
- (void) startRecording;
- (void) stopRecording;

@end
