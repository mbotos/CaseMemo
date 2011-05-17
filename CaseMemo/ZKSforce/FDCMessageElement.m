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


#import "FDCMessageElement.h"
#import "ZKSObject.h"

@interface FDCMessageElement (Private)

- (NSString *)_stripTagsFromString:(NSString *)inputString;
- (NSString *)_attributesAsString;
- (NSString *)_startTag;
- (NSString *)_endTag;

- (void) startElement:(NSString *)elemName string:(NSMutableString *)string;
- (void) endElement:(NSString *)elemName string:(NSMutableString *)string;
- (void) addElement:(NSString *)elemName elemValue:(id)elemValue string:(NSMutableString *)string;
- (void) addElementArray:(NSString *)elemName elemValue:(NSArray *)elemValues string:(NSMutableString *)string; 
- (void) addElementString:(NSString *)elemName elemValue:(NSString *)elemValue string:(NSMutableString *)string;
- (void) addSObjectFields: (ZKSObject *) sobject  string:(NSMutableString *)string;
- (void) addElementSObject:(NSString *)elemName elemValue:(ZKSObject *)sobject string:(NSMutableString *)string;


@end


@implementation FDCMessageElement

@synthesize name;
@synthesize value;
@synthesize type;

+ (FDCMessageElement *)elementWithName:(NSString *)aName value:(id)aValue
{
    return [[[FDCMessageElement alloc] initWithName:aName value:aValue] autorelease];
}

- (id)initWithName:(NSString *)aName value:(id)aValue
{
    if (self = [super init])
    {
        attributes = [[NSMutableDictionary dictionary] retain];
        childElements = [[NSMutableArray array] retain];
        self.name = aName;
        self.value = aValue;
    }
    return self;
}

- (id)init
{
    if (self = [super init])
    {
        attributes = [[NSMutableDictionary dictionary] retain];
        childElements = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc
{
    [name release];
    [value release];
    [attributes release];
    [childElements release];
    [super dealloc];
}

#pragma mark Properties

- (NSArray *)childElements
{
    return [NSArray arrayWithArray:childElements];
}

- (void)addAttribute:(NSString *)attributeName value:(NSString *)aValue
{
    [attributes setValue:aValue forKey:attributeName];
}

#pragma mark Methods

- (void)addChildElement:(FDCMessageElement *)element
{
    [childElements addObject:element];
}

- (NSString *)stringRepresentation
{
    NSMutableString *finalString = [NSMutableString stringWithCapacity:100];
    
    /*
     
     There are a couple scenarios to take into consideration:
     1) <name>value</name>
     2) <name><childelement></childelement></name>
     3) <name attribute="attrvalue">value</name>
     
     Assume you either have children, OR you have complex types, never both.
     */
    
    if ([childElements count] > 0)
    {
        // It has child elements.
        [finalString appendString:[self _startTag]];
        for (FDCMessageElement *childElement in childElements)
        {
            [finalString appendFormat:@"%@", [childElement stringRepresentation]];
        }
        [finalString appendString:[self _endTag]];
        return finalString;
    }
    else if (self.value)
    {
        // Use the original code path.
        [self addElement:self.name elemValue:self.value string:finalString];
    }
    else {
        // No children, no value, just that tag and attributes
        [finalString appendFormat:@"%@%@", [self _startTag], [self _endTag]];
    }
    
    return finalString;
}

#pragma mark Private

- (NSString *)_stripTagsFromString:(NSString *)inputString
{
    inputString = [inputString stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    inputString = [inputString stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    inputString = [inputString stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    return inputString;
}
         
 - (NSString *)_attributesAsString;
{
    NSMutableArray *attributeStrings = [NSMutableArray array];
    for (NSString *key in [attributes allKeys])
    {
        NSString *attrvalue = [attributes objectForKey:key];
        attrvalue = [self _stripTagsFromString:attrvalue];
        [attributeStrings addObject:[NSString stringWithFormat:@"%@=\"%@\"", key, attrvalue]];
    }
    NSString *finalAttributesString = [attributeStrings componentsJoinedByString:@" "];
    return finalAttributesString;
}

- (NSString *)_startTag
{
    NSString *attributesString = [self _attributesAsString];
    if ([attributesString length] > 0)
        return [NSString stringWithFormat:@"<%@ %@>", self.name, attributesString];
    else 
        return [NSString stringWithFormat:@"<%@>", self.name];
    
}

- (NSString *)_endTag
{
    return [NSString stringWithFormat:@"</%@>", self.name];
}

// ---- OLD

- (void) addElement:(NSString *)elemName elemValue:(id)elemValue string:(NSMutableString *)string
{
	if ([elemValue isKindOfClass:[NSString class]])      	
        [self addElementString:elemName elemValue:elemValue string:string];
    else if ([elemValue isKindOfClass:[NSNumber class]])
        [self addElementString:elemName elemValue:[elemValue stringValue] string:string];
	else if ([elemValue isKindOfClass:[NSArray class]]) 	
        [self addElementArray:elemName elemValue:elemValue string:string];
	else if ([elemValue isKindOfClass:[NSSet class]]) 	
        [self addElementArray:elemName elemValue: [elemValue allObjects] string:string];
	else if ([elemValue isKindOfClass:[ZKSObject class]]) 	
        [self addElementSObject:elemName elemValue:elemValue string:string];
	else if ([elemValue isKindOfClass:[NSNull class]]) ;
	else 
        [self addElementString:elemName elemValue:[elemValue stringRepresentation] string:string];
}

- (void) addElementArray:(NSString *)elemName elemValue:(NSArray *)elemValues string:(NSMutableString *)string
{
    for (id o in elemValues)
    {
        [self addElement:elemName elemValue:o string:string];
    }
}

- (void) addElementString:(NSString *)elemName elemValue:(NSString *)elemValue string:(NSMutableString *)string
{
	[self startElement:elemName string:string];
    NSString *tagStrippedValue = [self _stripTagsFromString: elemValue];
    if (tagStrippedValue)
        [string appendString:tagStrippedValue];
	[self endElement:elemName string:string];
}

- (void) addSObjectFields: (ZKSObject *) sobject  string:(NSMutableString *)string
{
    NSEnumerator *e = [[sobject fields] keyEnumerator];
	NSString *key;
	while(key = [e nextObject]) 
    {
        // Make sure not to re-add the Id field.
        if (![key isEqualToString:@"Id"])
            [self addElement:key elemValue:[[sobject fields] valueForKey:key] string:string];
	}
}

- (void) addElementSObject:(NSString *)elemName elemValue:(ZKSObject *)sobject string:(NSMutableString *)string
{
	[self startElement:elemName string:string];
    if (self.type == FDCMessageElementTypePartner)
    {
        [self addElement:@"type" elemValue:[sobject type] string:string];
    }
	if ([sobject Id]) 
        [self addElement:@"Id" elemValue: [sobject Id] string:string];
	[self addElement:@"fieldsToNull" elemValue:[sobject fieldsToNull] string:string];
    
	[self addSObjectFields: sobject string:string];
    
	[self endElement:elemName string:string];
}

- (void) startElement:(NSString *)elemName string:(NSMutableString *)string
{
    [string appendFormat:@"<%@>", elemName];
}

- (void) endElement:(NSString *)elemName string:(NSMutableString *)string
{
    [string appendFormat:@"</%@>", elemName];
}

@end
