// Copyright (c) 2006 Simon Fell
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


#import "ZKQueryResult.h"
#import "ZKSObject.h"
#import "ZKParser.h"

@implementation ZKQueryResult

@synthesize size;
@synthesize done;
@synthesize queryLocator;
@synthesize records;

- (id)initFromXmlNode:(ZKElement *)node 
{
	if (self = [super init])
    {
        int i = 0;
        size = [[[node childElement:@"size"] stringValue] intValue];
        NSString * strDone = [[node childElement:@"done"] stringValue]; 
        done = [strDone isEqualToString:@"true"];
        if (done == NO)
            queryLocator = [[[node childElement:@"queryLocator"] stringValue] copy];
		
        NSArray * nodes = [node childElements:@"records"];
        NSMutableArray * recArray = [NSMutableArray arrayWithCapacity:[nodes count]];
        ZKSObject * o;
        for (i = 0; i < [nodes count]; i++)
        {
            ZKElement * n = [nodes objectAtIndex:i];
            NSString *xsiNil = [n attributeValue:@"nil" ns:NS_URI_XSI];
            if (xsiNil != nil && [xsiNil isEqualToString:@"true"]) 
                continue;
            o = [[ZKSObject alloc] initFromXmlNode:n];
            [recArray addObject:o];
            [o release];
        }	
        records = [recArray retain];
    }

	return self;
}

- (id)initWithRecords:(NSArray *)_records size:(int)_size done:(BOOL)_done queryLocator:(NSString *)_queryLocator 
{
	if (self = [super init])
    {
        records = [_records copy];
        done = _done;
        size = _size;
        queryLocator = [_queryLocator copy];
    }

	return self;
}

- (id)copyWithZone:(NSZone *)zone 
{
	return [[ZKQueryResult alloc] initWithRecords:records size:size done:done queryLocator:queryLocator];
}

- (void)dealloc 
{
	[queryLocator release];
	[records release];
	[super dealloc];
}

@end
