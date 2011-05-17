// Copyright (c) 2010 Ron Hess
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

#import "ZKRelatedList.h"
#import "ZKDescribeLayout.h"
#import "ZKRelatedListColumn.h"
#import "ZKDescribeLayoutSection.h"
#import "ZKDescribeLayoutButtonSection.h"
#import "ZKParser.h"

/*
 * sample code to dump layouts to debug window
 *
 *
for ( ZKDescribeLayout *layout in layouts ) {
	NSLog(@"layout ID %@",[layout Id]);
	
	ZKDescribeLayoutButtonSection *lbs = [layout buttonLayoutSection];
	for (ZKDescribeLayoutButton *bl in [lbs detailButtons]) {
		NSLog(@"button  %@ %@ %@",[bl name],[bl label],[bl custom]?@"true":@"false");
	}
	
	for (ZKDescribeLayoutSection *section in [layout detailLayoutSections]) {
		
		NSLog(@"detail section %@",[section heading]);
		NSLog(@"columns %d, rows %d",[section columns], [section rows]);
		
		for( ZKDescribeLayoutRow *dlr in [section layoutRows]) {
			NSLog(@"num items %d",[dlr numItems]);
			for ( ZKDescribeLayoutItem *item in [dlr layoutItems] ) {
				
				BOOL ph = [item placeholder];
				NSLog(@"placeholder %@", ph?@"true":@"false");
				
				if ( !ph ) { // no label on placeholders
					NSLog(@"label %@",[item label]);
				}
				// may have a list of layout components
				for (ZKDescribeLayoutComponent *comp in [item layoutComponents]) {
					if ( [[comp type] isEqualToString:@"Field"] ){
						NSLog(@"field : ",[comp value]);
					}
				}	
			}
		}
	}
	
	for (ZKDescribeLayoutSection *edit in [layout editLayoutSections]) {
		NSLog(@"edit layout section %@",[edit heading]);
	}
	
}*/



@implementation ZKDescribeLayout

-(void)dealloc 
{
	[detailLayoutSections release];
	[editLayoutSections release];
	[relatedLists release];
	[super dealloc];
}

-(NSString *) Id 
{
	return [self string:@"id"];
}

// this is a single section, not a list, it holds a list of buttons
- (ZKDescribeLayoutButtonSection *) buttonLayoutSectionCopy 
{
	ZKElement *bNode = [node childElement:@"buttonLayout"];
	ZKDescribeLayoutButtonSection *bs = [[ZKDescribeLayoutButtonSection alloc]	initWithXmlElement:bNode];

	return bs;
	[bs release]; // TODO : figure out if bs should have been autoreleased before returning.
}

- (NSArray *) detailLayoutSections 
{
	if (detailLayoutSections == nil) 
    {
		NSArray *rti = [node childElements:@"detailLayoutSections"];
		NSMutableArray *res = [NSMutableArray arrayWithCapacity:[rti count]];
		for (ZKElement *rnode in rti) 
        {
			ZKDescribeLayoutSection *r = [[ZKDescribeLayoutSection alloc] initWithXmlElement:rnode];
			[res addObject:r];
			[r release];
		}
		detailLayoutSections = [res retain];
	} 
	return detailLayoutSections;	
}

- (NSArray *) editLayoutSections 
{
	if (editLayoutSections == nil) 
    {
		NSArray *rti = [node childElements:@"editLayoutSections"];
		NSMutableArray *res = [NSMutableArray arrayWithCapacity:[rti count]];
		for (ZKElement *rnode in rti) 
        {
			ZKDescribeLayoutSection *r = [[ZKDescribeLayoutSection alloc] initWithXmlElement:rnode];
			[res addObject:r];
			[r release];
		}
		editLayoutSections = [res retain];
	} 
	return editLayoutSections;	
}
- (NSArray *) relatedLists 
{
	if (relatedLists == nil) 
    {
		NSArray *rti = [node childElements:@"relatedLists"];
		NSMutableArray *res = [NSMutableArray arrayWithCapacity:[rti count]];
		for (ZKElement *rnode in rti) 
        {
			ZKRelatedList *r = [[ZKRelatedList alloc] initWithXmlElement:rnode];
			[res addObject:r];
			[r release];
		}
		relatedLists = [res retain];
	} 
	return relatedLists;	
}

@end