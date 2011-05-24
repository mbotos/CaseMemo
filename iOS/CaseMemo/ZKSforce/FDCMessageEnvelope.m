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

#import "FDCMessageEnvelope.h"
#import "FDCMessageElement.h"

#define DEFAULT_NAMESPACE_URI @"urn:partner.soap.sforce.com"

@implementation FDCMessageEnvelope

@synthesize primaryNamespaceUri;

+ (FDCMessageEnvelope *)envelopeWithSessionId:(NSString *)sessionId clientId:(NSString *)clientId;
{
    FDCMessageEnvelope *envelope = [[[FDCMessageEnvelope alloc] init] autorelease];
    if (sessionId)
    {
        [envelope addSessionHeader:sessionId];
    }
    if (clientId)
    {
        [envelope addCallOptions:clientId];
    }
         
    return envelope;
}

- (id)initWithPrimaryNamespaceUri:(NSString *)uri
{
    if (self = [self init])
    {
        self.primaryNamespaceUri = uri;
    }
    return self;
}

- (id)init
{
    if (self = [super init])
    {
        headerElements = [[NSMutableArray array] retain];
        bodyElements = [[NSMutableArray array] retain];
        self.primaryNamespaceUri = DEFAULT_NAMESPACE_URI;
    }
    return self;
}

- (void)dealloc
{
    [headerElements release];
    [bodyElements release];
    [super dealloc];
}

#pragma mark Properties

- (NSArray *)headerElements
{
    return [NSArray arrayWithArray:headerElements];
}

- (NSArray *)bodyElements
{
    return [NSArray arrayWithArray:bodyElements];
}

#pragma mark  Methods

- (void)addSessionHeader:(NSString *)sessionId
{
    FDCMessageElement *sessionHeaderElement = [FDCMessageElement elementWithName:@"SessionHeader" value:nil];
    [sessionHeaderElement addChildElement:[FDCMessageElement elementWithName:@"sessionId" value:sessionId]];
    [self addHeaderElement:sessionHeaderElement];
}

- (void)addCallOptions:(NSString *)clientId
{
    FDCMessageElement *sessionHeaderElement = [FDCMessageElement elementWithName:@"CallOptions" value:nil];
    [sessionHeaderElement addChildElement:[FDCMessageElement elementWithName:@"client" value:clientId]];
    [self addHeaderElement:sessionHeaderElement];
}

- (void)addEmailHeader
{
    FDCMessageElement *sessionHeaderElement = [FDCMessageElement elementWithName:@"EmailHeader" value:nil];
    [sessionHeaderElement addChildElement:[FDCMessageElement elementWithName:@"triggerUserEmail" value:@"true"]];
    [self addHeaderElement:sessionHeaderElement];
}

- (void)addHeaderElement:(FDCMessageElement *)element
{
    [headerElements addObject:element];
}

- (void)addBodyElement:(FDCMessageElement *)element
{
    [bodyElements addObject:element];
}

- (void)addBodyElementNamed:(NSString *)elementName withChildNamed:(NSString *)childElementName value:(id)childValue
{
    FDCMessageElement *childElement = [FDCMessageElement elementWithName:childElementName value:childValue];
    FDCMessageElement *bodyElement = [FDCMessageElement elementWithName:elementName value:nil];
    [bodyElement addChildElement:childElement];
    [self addBodyElement:bodyElement];
}

- (void)addUpdatesMostRecentlyUsedHeader
{
    FDCMessageElement *sessionMruHeaderElement = [FDCMessageElement elementWithName:@"MruHeader" value:nil];
    [sessionMruHeaderElement addChildElement:[FDCMessageElement elementWithName:@"updateMru" value:@"true"]];
    [self addHeaderElement:sessionMruHeaderElement];
}

- (NSString *)stringRepresentation
{
    NSMutableString *finalString = [NSMutableString stringWithCapacity:100];
    [finalString appendFormat:@"<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' xmlns='%@'>\n", self.primaryNamespaceUri];
    
    // Let's get the headers in here.
    [finalString appendFormat:@"\t<s:Header>\n"];
    for (FDCMessageElement *element in headerElements)
    {
        [finalString appendFormat:@"\t%@\n", [element stringRepresentation]];
    }
    [finalString appendFormat:@"\t</s:Header>\n"];
    
    // Time for some body action.
    [finalString appendFormat:@"\t<s:Body>\n"];
    for (FDCMessageElement *element in bodyElements)
    {
        [finalString appendFormat:@"\t%@\n", [element stringRepresentation]];
    }
    [finalString appendFormat:@"\t</s:Body>\n"];
    
    [finalString appendFormat:@"</s:Envelope>\n"];
    
    return finalString;
}




@end
