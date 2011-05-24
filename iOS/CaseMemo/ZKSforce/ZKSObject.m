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


#import "ZKSObject.h"
#import "ZKQueryResult.h"
#import "ZKParser.h"

NSString * NS_URI_XSI = @"http://www.w3.org/2001/XMLSchema-instance";

static NSDateFormatter *dateFormatter, *dateTimeFormatter;
static NSNumberFormatter *percentFormatter, *currencyFormatter;

@implementation ZKSObject

+(void)initialize 
{
	dateTimeFormatter = [[NSDateFormatter alloc] init];
	[dateTimeFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSZ"];
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	
	percentFormatter = [[NSNumberFormatter alloc] init];
	[percentFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[percentFormatter setPercentSymbol:@"%"];
	[percentFormatter setNumberStyle: NSNumberFormatterPercentStyle];
	[percentFormatter setDecimalSeparator:@"."];
	[percentFormatter setGeneratesDecimalNumbers:TRUE];
	[percentFormatter setMinimumFractionDigits:0];  // or 2 ?
	[percentFormatter setRoundingMode: NSNumberFormatterRoundUp];
	NSNumber *rndInc = [[NSNumber alloc] initWithDouble:0.05];
	[percentFormatter setRoundingIncrement:rndInc];
	[rndInc release];
	
	currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[currencyFormatter setCurrencySymbol:@"$"];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
}

+ (id)withType:(NSString *)type 
{
	return [[[ZKSObject alloc] initWithType:type] autorelease];
}

+ (id)withTypeAndId:(NSString *)type sfId:(NSString *)sfId 
{
	ZKSObject *s = [ZKSObject withType:type];
	[s setId:sfId];
	return s;
}

+ (id) fromXmlNode:(ZKElement *)node 
{
	return [[[ZKSObject alloc] initFromXmlNode:node] autorelease];
}

- (id) initWithType:(NSString *)aType 
{
	if (self = [super init])
    {
        type = [aType retain];
        fieldsToNull = [[NSMutableSet alloc] init];
        fields = [[NSMutableDictionary alloc] init];
        fieldOrder = [[NSMutableArray alloc] init];
    }
	return self;
}

- (id) initFromXmlNode:(ZKElement *)node {
	if (self = [super init])
    {
        int i, childCount;
        int childrenToSkip = 0;
        Id = [[[node childElement:@"sf:Id"] stringValue] copy];
        if (!Id)
            Id = [[[node childElement:@"Id"] stringValue] copy];
        if (Id)
            childrenToSkip++;
        
        type = [[[node childElement:@"sf:type"] stringValue] copy];
        if (!type)
        {
            type = [[node attributeValue:@"type"] copy];
        }
        else {
            childrenToSkip++;
        }


        fields = [[NSMutableDictionary alloc] init];
        fieldOrder = [[NSMutableArray alloc] init];
        fieldsToNull = [[NSMutableSet alloc] init];
        NSArray *children = [node childElements];
        childCount = [children count];
        // start at childrenToSkip to skip Id & Type
        for (i = childrenToSkip; i < childCount; i++)
        {
            ZKElement *f = [children objectAtIndex:i];
            NSString *xsiNil = [f attributeValue:@"nil" ns:NS_URI_XSI];
            id fieldVal;
            if (xsiNil != nil && [xsiNil isEqualToString:@"true"]) 
                fieldVal = [NSNull null];
            else {
                NSString *xsiType = [f attributeValue:@"type" ns:NS_URI_XSI];
                if ([xsiType hasSuffix:@"QueryResult"]) 
                    fieldVal = [[[ZKQueryResult alloc] initFromXmlNode:f] autorelease];
                else if ([xsiType hasSuffix:@"sObject"])
                    fieldVal = [[[ZKSObject alloc] initFromXmlNode:f] autorelease];
                else {
                    fieldVal = [f stringValue];
                }
            }
            [fields setValue:fieldVal forKey:[f name]];
            [fieldOrder addObject:[f name]];
        }
    }
	return self;
}

-(id)initWithId:(NSString *)anId type:(NSString *)t fieldsToNull:(NSSet *)ftn fields:(NSDictionary *)f fieldOrder:(NSArray *)fo {
	if (self = [super init])
    {
        Id = [anId copy];
        type = [t copy];
        fieldsToNull = [[NSMutableSet setWithSet:ftn] retain];
        fields = [[NSMutableDictionary dictionaryWithDictionary:f] retain];
        fieldOrder = [[NSMutableArray arrayWithArray:fo] retain];
    }

	return self;
}

-(id)copyWithZone:(NSZone *)zone 
{
	return [[ZKSObject alloc] initWithId:Id type:type fieldsToNull:fieldsToNull fields:fields fieldOrder:fieldOrder];
}

- (void)dealloc 
{
	[Id release];
	[type release];
	[fieldsToNull release];
	[fields release];
	[fieldOrder release];
	[super dealloc];
}

- (id)description 
{
	return [NSString stringWithFormat:@"%@ %@ fields=%@ toNull=%@", type, Id, fields, fieldsToNull];
}

- (NSArray *)orderedFieldNames 
{
	return fieldOrder;
}

- (void)setId:(NSString *)theId 
{
    [theId retain];
    [Id release];
    Id = theId;
}

- (void)setType:(NSString *)t 
{
    [t retain];
    [type release];
    type = t;
}

- (void)setFieldToNull:(NSString *)field 
{
	[fieldsToNull addObject:field];
	[fields removeObjectForKey:field];
	[fieldOrder removeObject:field];
}

- (void)setFieldValue:(NSObject *)value field:(NSString *)field 
{
	if ((value == nil) || (value == [NSNull null]) || ([value isKindOfClass:[NSString class]] && [(NSString *)value length] == 0)) {
		[self setFieldToNull:field];
	} else {
		[fieldsToNull removeObject:field];
		[fields setObject:value forKey:field];
		if (![fieldOrder containsObject:field])
			[fieldOrder addObject:field];
	}
}

- (void)setFieldDateTimeValue:(NSDate *)value field:(NSString *)field 
{
	if (value == nil) {
		[self setFieldValue: @"" field: field];
		return;
	}
	NSMutableString *dt = [NSMutableString stringWithString:[dateTimeFormatter stringFromDate:value]];
	// meh, insert the : in the TZ offset, to make it xsd:dateTime
	[dt insertString:@":" atIndex:[dt length]-2];
	[self setFieldValue:dt field:field];
}

- (void)setFieldDateValue:(NSDate *)value field:(NSString *)field 
{
	[self setFieldValue:[dateFormatter stringFromDate:value] field:field];	
}	

- (id)fieldValue:(NSString *)field 
{
	id v = [fields objectForKey:field];
	return v == [NSNull null] ? nil : v;
}

- (BOOL)isFieldToNull:(NSString *)field 
{
	return [fieldsToNull containsObject:field];
}

- (BOOL)boolValue:(NSString *)field 
{
	return [[self fieldValue:field] isEqualToString:@"true"];
}

- (NSDate *)dateTimeValue:(NSString *)field 
{
	// ok, so a little hackish, but does the job
	// note to self, make sure API always returns GMT times ;)
	NSMutableString *dt = [NSMutableString stringWithString:[self fieldValue:field]];
	[dt deleteCharactersInRange:NSMakeRange([dt length] -1,1)];
	[dt appendString:@"+00"];
	return [dateTimeFormatter dateFromString:dt];
}

- (NSDate *)dateValue:(NSString *)field 
{
	return [dateFormatter dateFromString:[self fieldValue:field]];
}

- (int)intValue:(NSString *)field 
{
	return [[self fieldValue:field] intValue];
}

- (double)doubleValue:(NSString *)field 
{
	return [[self fieldValue:field] doubleValue];
}

- (ZKQueryResult *)queryResultValue:(NSString *)field 
{
	return [self fieldValue:field];
}

- (NSString *) Id 
{
	if (Id.length) return Id;
	return [self fieldValue:@"Id"];
}

- (NSString *) getId 
{
	if (Id.length) return Id;
	return [self fieldValue:@"Id"];
}

- (NSString *)type 
{
	return type;
}

- (NSArray *)fieldsToNull 
{
	return [fieldsToNull allObjects];
}

- (NSDictionary *)fields 
{
	return fields;
}

#pragma mark -
#pragma mark formatting helpers

// if the UI view wants a string, and you know the type, format that here
- (NSString *)fieldValueFormatted : (NSString *)field : (ZKDescribeField *)describe 
{
	NSString *ftype  = [describe type];
	NSString *ret = @"";
	
	if ( [ftype isEqualToString:@"currency" ] ) {
		NSNumber *c = [NSNumber numberWithFloat:[self doubleValue:field]];  
		ret = [currencyFormatter stringFromNumber:c];
		
	} else if ( [ftype isEqualToString:@"percent" ] ) {
		// need divide by 100 for data coming from force.com
		NSNumber *c = [NSNumber numberWithFloat:[self doubleValue:field]/100];  
		ret = [percentFormatter stringFromNumber:c];
		
	} else if ([ftype isEqualToString:@"reference"] ) {
		ZKSObject *relatedRecord = [self fieldValue:[describe relationshipName]];
		ret = [relatedRecord fieldValue:@"Name"];
		
	} else { // string type
		ret = [self fieldValue:field];
	}
	return ret;
}

@end
