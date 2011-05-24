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

#import "FDCServerSwitchboard+Utility.h"
#import "FDCServerSwitchboard+Private.h"
#import "FDCMessageEnvelope.h"
#import "FDCMessageElement.h"
#import "ZKParser.h"
#import "ZKDescribeGlobalSObject.h"
#import "ZKDescribeSObject.h"
#import "ZKDescribeLayoutResult.h"

@interface FDCServerSwitchboard (DescribeWrappers)

- (NSArray *)_processDescribeGlobalResponse:(ZKElement *)describeGlobalResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (ZKDescribeSObject *)_processDescribeSObjectResponse:(ZKElement *)describeSObjectResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (NSArray *)_processDescribeSObjectsResponse:(ZKElement *)describeSObjectsResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (ZKDescribeLayoutResult *)_processDescribeLayoutResponse:(ZKElement *)describeLayoutResponseElement error:(NSError *)error context:(NSDictionary *)context;

@end


@implementation FDCServerSwitchboard (Describe)

- (void)describeGlobalWithTarget:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    [envelope addBodyElement:[FDCMessageElement elementWithName:@"describeGlobal" value:nil]];
    NSString *xml = [envelope stringRepresentation];  
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processDescribeGlobalResponse:error:context:) context: wrapperContext];
}

- (void)describeSObject:(NSString *)sObjectType target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    [envelope addBodyElementNamed:@"describeSObject" withChildNamed:@"sObjectType" value:sObjectType];
    NSString *xml = [envelope stringRepresentation];  
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processDescribeSObjectResponse:error:context:) context: wrapperContext];
}

- (void)describeSObjects:(NSArray *)sObjectTypes target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    [envelope addBodyElementNamed:@"describeSObjects" withChildNamed:@"sObjectType" value:sObjectTypes];
    NSString *xml = [envelope stringRepresentation];  
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processDescribeSObjectsResponse:error:context:) context: wrapperContext];
}

- (void)describeLayout:(NSString *)sObjectType target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    [envelope addBodyElementNamed:@"describeLayout" withChildNamed:@"sObjectType" value:sObjectType];
    NSString *xml = [envelope stringRepresentation];  
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processDescribeLayoutResponse:error:context:) context: wrapperContext];
}

@end


@implementation FDCServerSwitchboard (DescribeWrappers)

- (NSArray *)_processDescribeGlobalResponse:(ZKElement *)describeGlobalResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    NSMutableArray *types = [NSMutableArray array]; 
	NSArray *results = [[describeGlobalResponseElement childElement:@"result"] childElements:@"sobjects"];
    for (ZKElement *object in results)
    {
        ZKDescribeGlobalSObject * describe = [[[ZKDescribeGlobalSObject alloc] initWithXmlElement:object] autorelease];
		[types addObject:describe];
    }
    [self unwrapContext:context andCallSelectorWithResponse:types error:error];
	return types;
}

- (ZKDescribeSObject *)_processDescribeSObjectResponse:(ZKElement *)describeSObjectResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    ZKElement *result = [describeSObjectResponseElement childElement:@"result"];
	ZKDescribeSObject *describe = [[[ZKDescribeSObject alloc] initWithXmlElement:result] autorelease];
    [self unwrapContext:context andCallSelectorWithResponse:describe error:error];
	return describe;
}

- (NSArray *)_processDescribeSObjectsResponse:(ZKElement *)describeSObjectsResponseElement error:(NSError *)error context:(NSDictionary *)context;
{
    NSMutableArray *describes = [NSMutableArray array]; 
	NSArray *results = [describeSObjectsResponseElement childElements:@"result"];
    for (ZKElement *result in results)
    {
        ZKDescribeSObject *describe = [[[ZKDescribeSObject alloc] initWithXmlElement:result] autorelease];
		[describes addObject:describe];
    }
    [self unwrapContext:context andCallSelectorWithResponse:describes error:error];
	return describes;
}

- (ZKDescribeLayoutResult *)_processDescribeLayoutResponse:(ZKElement *)describeLayoutResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    ZKElement *result = [describeLayoutResponseElement childElement:@"result"];
	ZKDescribeLayoutResult *describe = [[[ZKDescribeLayoutResult alloc] initWithXmlElement:result] autorelease];
    [self unwrapContext:context andCallSelectorWithResponse:describe error:error];
	return describe;	
}

@end

