//
//  DetailTable.m
//  CaseMemo
//
//  Created by Matthew Botos on 8/26/11.
//  Copyright 2011 Mavens Consulting, Inc. All rights reserved.
//

#import "DetailTable.h"
#import "ZKSObject.h"

@implementation DetailTable

@synthesize detailItem=_detailItem;

#pragma mark - Details table data

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIndentifer = @"DetailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifer];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIndentifer] autorelease];
    }
    
    // STEP 4 b - Assign data to layout
    switch ([indexPath row]) {
        case 0:
            cell.textLabel.text = @"Number";
            cell.detailTextLabel.text = [self.detailItem fieldValue:@"CaseNumber"];
            break;
        case 1:
            cell.textLabel.text = @"Subject";
            cell.detailTextLabel.text = [self.detailItem fieldValue:@"Subject"];
            break;
        case 2:
            cell.textLabel.text = @"Status";
            cell.detailTextLabel.text = [self.detailItem fieldValue:@"Status"];
            break;
        case 3:
            cell.textLabel.text = @"Description";
            cell.detailTextLabel.text = [self.detailItem fieldValue:@"Description"];
            //cell.detailTextLabel.numberOfLines = 0;
            break;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


@end
