//
//  DetailViewController.m
//  CaseMemo
//
//  Created by Matthew Botos on 5/17/11.
//  Copyright 2011 Mavens Consulting, Inc. All rights reserved.
//

#import "DetailViewController.h"

#import "RootViewController.h"
#import "ZKSObject.h"
#import "FDCServerSwitchboard.h"
#import "CaseMemoAppDelegate.h"

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize toolbar=_toolbar;

@synthesize detailItem=_detailItem;
@synthesize attachments=_attachments;

@synthesize numberLabel = _numberLabel;
@synthesize subjectLabel = _subjectLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize attachmentsTable = _attachmentsTable;

@synthesize popoverController=_myPopoverController;

#pragma mark - Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];
        
        
        NSString *queryString = [NSString stringWithFormat:@"Select Id, Name From Attachment Where ParentId = '%@'", [(ZKSObject*)_detailItem fieldValue:@"Id"]];
        [[FDCServerSwitchboard switchboard] query:queryString target:self selector:@selector(queryResult:error:context:) context:nil];
    
        [self configureView];
    }

    if (self.popoverController != nil) {
        [self.popoverController dismissPopoverAnimated:YES];
    }        
}

- (void)queryResult:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (result && !error)
    {
        self.attachments = [result records];
        [self.attachmentsTable reloadData];
    }
    else if (error)
    {
        [CaseMemoAppDelegate errorWithError:error];
    }
}

- (void)configureView
{    
    // cast to ZKSObject to avoid warnings
    ZKSObject *caseSobject = (ZKSObject*)self.detailItem;
    
    self.numberLabel.text = [NSString stringWithFormat:@"Case Number %@", [caseSobject fieldValue:@"CaseNumber"]];
    self.subjectLabel.text = [caseSobject fieldValue:@"Subject"];
    self.descriptionLabel.text = [caseSobject fieldValue:@"Description"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.subjectLabel.numberOfLines = 2;
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Split view support

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
    barButtonItem.title = @"Cases";
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [self.toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [self.toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}

#pragma mark - View load/unload

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.attachmentsTable.backgroundView = [[[UIImageView alloc] init] autorelease];
}

- (void)viewDidUnload
{
    [self setNumberLabel:nil];
    [self setSubjectLabel:nil];
    [self setDescriptionLabel:nil];
    [self setAttachmentsTable:nil];
	[super viewDidUnload];

	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.popoverController = nil;
}

#pragma mark - Attachments table data

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Attachments cellForRowAtIndexPath %d", indexPath.row);
    
    static NSString *CellIndentifer = @"AttachmentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifer];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIndentifer] autorelease];
    }
    
    ZKSObject *attachment = [self.attachments objectAtIndex:indexPath.row];
    cell.textLabel.text = [attachment fieldValue:@"Name"];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.attachments count] > 0 ? 1 : 0;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Attachments numberOfRowsInSection %d", [self.attachments count]);
    return [self.attachments count];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Attachments";
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_myPopoverController release];
    [_toolbar release];
    [_detailItem release];
    [_numberLabel release];
    [_subjectLabel release];
    [_descriptionLabel release];
    [_attachmentsTable release];
    [super dealloc];
}

@end
