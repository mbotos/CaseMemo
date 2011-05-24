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

#import "FDCGetUpdatedResult.h"
#import "ZKSObject.h"
#import "ZKParser.h"
#import "NSDate+Additions.h"
#import "FDCDeletedObject.h"

@implementation FDCGetUpdatedResult

@synthesize latestDateCovered;
@synthesize records;

- (id)initFromXmlNode:(ZKElement *)node
{
    if (self = [super init])
    {
        NSString *latestDateString = [[node childElement:@"latestDateCovered"] stringValue];
        latestDateCovered = [[NSDate dateWithLongFormatString:latestDateString] retain];
        
        NSArray * updatedRecordIds = [node childElements:@"ids"];
        NSMutableArray * recArray = [NSMutableArray arrayWithCapacity:[updatedRecordIds count]];
        
        for (ZKElement * updatedRecordId in updatedRecordIds)
        {
            NSString *objectId = [updatedRecordId stringValue];
            [recArray addObject:objectId];
        }	
        records = [recArray retain];
    }
    
	return self;
}

- (id)initWithRecords:(NSArray *)someRecords latestDateCovered:(NSDate *)latestDate
{
    if (self = [super init])
    {
        records = [someRecords copy];
        latestDateCovered = [latestDate retain];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone 
{
	return [[FDCGetUpdatedResult alloc] initWithRecords:records latestDateCovered:latestDateCovered];
}


- (void)dealloc 
{
    [latestDateCovered release];
	[records release];
	[super dealloc];
}


@end
