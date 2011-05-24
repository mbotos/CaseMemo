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

#import "FDCGetDeletedResult.h"
#import "ZKSObject.h"
#import "ZKParser.h"
#import "NSDate+Additions.h"
#import "FDCDeletedObject.h"

@implementation FDCGetDeletedResult

@synthesize earliestDateAvailable;



- (id)initFromXmlNode:(ZKElement *)node
{
    if (self = [super init])
    {
        NSString *earliestDateString = [[node childElement:@"earliestDateAvailable"] stringValue];
        NSString *latestDateString = [[node childElement:@"latestDateCovered"] stringValue];
        earliestDateAvailable = [[NSDate dateWithLongFormatString:earliestDateString] retain];
        latestDateCovered = [[NSDate dateWithLongFormatString:latestDateString] retain];
        
		
        NSArray * deletedRecordNodes = [node childElements:@"deletedRecords"];
        NSMutableArray * recArray = [NSMutableArray arrayWithCapacity:[deletedRecordNodes count]];
       
        for (ZKElement * deletedRecordNode in deletedRecordNodes)
        {
            NSString *objectId = [[deletedRecordNode childElement:@"id"] stringValue];
            NSString *deletedDateString = [[deletedRecordNode childElement:@"deletedDate"] stringValue];
            NSDate *deletedDate = [NSDate dateWithLongFormatString:deletedDateString];
            FDCDeletedObject * object = [[[FDCDeletedObject alloc] initWithId:objectId deletedDate:deletedDate] autorelease];
            [recArray addObject:object];
        }	
        records = [recArray retain];
    }
    
	return self;
}

- (id)initWithRecords:(NSArray *)someRecords earliestDateAvailable:(NSDate *)earliestDate latestDateCovered:(NSDate *)latestDate
{
    if (self = [super init])
    {
        records = [someRecords copy];
        earliestDateAvailable = [earliestDate retain];
        latestDateCovered = [latestDate retain];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone 
{
	return [[FDCGetDeletedResult alloc] initWithRecords:records earliestDateAvailable:earliestDateAvailable latestDateCovered:latestDateCovered];
}

- (void)dealloc 
{
	[earliestDateAvailable release];
	[super dealloc];
}


@end
