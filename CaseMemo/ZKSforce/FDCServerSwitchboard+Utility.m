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
#import "ZKParser.h"
//#import "ZKEnvelope.h"
//#import "ZKPartnerEnvelope.h"
#import "ZKSoapException.h"
#import "NSObject+Additions.h"
#import "NSDate+Additions.h"
#import "ZKSaveResult.h"
#import "FDCEmailMessage.h"
#import "FDCMessageEnvelope.h"
#import "FDCMessageElement.h"
#import "ZKUserInfo.h"

@interface FDCServerSwitchboard (UtilityWrappers)

- (NSNumber *)_processSetPasswordResponse:(ZKElement *)setPasswordResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (NSDate *)_processGetServerTimestampResponse:(ZKElement *)getServerTimestampResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (ZKUserInfo *)_processGetUserInfoResponse:(ZKElement *)getUserInfoResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (NSArray *)_processEmptyRecycleBinResponse:(ZKElement *)emptyRecycleBinResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (NSNumber *)_processSendEmailResponse:(ZKElement *)sendEmailResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (NSString *)_processResetPasswordResponse:(ZKElement *)resetPasswordResponseElement error:(NSError *)error context:(NSDictionary *)context;

@end


@implementation FDCServerSwitchboard (Utility)

- (void)emptyRecycleBin:(NSArray *)objectIDs target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    /*ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionId:sessionId updateMru:self.updatesMostRecentlyUsed clientId:clientId] autorelease];
	[env startElement:@"emptyRecycleBin"];
	[env addElement:@"ids" elemValue:objectIDs];
	[env endElement:@"emptyRecycleBin"];
	[env endElement:@"s:Body"];
    NSString *xml = [env end]; */
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    [envelope addBodyElementNamed:@"emptyRecycleBin" withChildNamed:@"ids" value:objectIDs];
    NSString *xml = [envelope stringRepresentation];  
	
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processEmptyRecycleBinResponse:error:context:) context: wrapperContext];
}

- (void)getServerTimestampWithTarget:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    /*ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionHeader:self.sessionId clientId:self.clientId] autorelease];
	[env startElement:@"getServerTimestamp"];
	[env endElement:@"getServerTimestamp"];
	[env endElement:@"s:Body"];
    NSString *xml = [env end]; */
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    [envelope addBodyElement:[FDCMessageElement elementWithName:@"getServerTimestamp" value:nil]];
    NSString *xml = [envelope stringRepresentation];  
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processGetServerTimestampResponse:error:context:) context: wrapperContext];
}

- (void)getUserInfoWithTarget:(id)target selector:(SEL)selector context:(id)context
{
    
    [self _checkSession];
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    [envelope addBodyElement:[FDCMessageElement elementWithName:@"getUserInfo" value:nil]];
    NSString *xml = [envelope stringRepresentation];  
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processGetUserInfoResponse:error:context:) context: wrapperContext];
}

- (void)resetPasswordForUserId:(NSString *)userId triggerUserEmail:(BOOL)triggerUserEmail target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    /*ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionHeader:self.sessionId clientId:self.clientId triggerUserEmail:triggerUserEmail] autorelease];
	[env startElement:@"resetPassword"];
    [env addElement:@"userId" elemValue:userId];
	[env endElement:@"resetPassword"];
	[env endElement:@"s:Body"];
    NSString *xml = [env end]; */
    
   
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    if (triggerUserEmail)
        [envelope addEmailHeader];
    [envelope addBodyElementNamed:@"resetPassword" withChildNamed:@"userId" value:userId];
    NSString *xml = [envelope stringRepresentation];  
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processResetPasswordResponse:error:context:) context: wrapperContext];
}

- (void)sendEmail:(NSArray *)emails target:(id)target selector:(SEL)selector context:(id)context
{
    NSLog(@"Warning sendEmail doesn't seem to work just yet.");
    [self _checkSession];
    
    /*
	ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionId:sessionId updateMru:self.updatesMostRecentlyUsed clientId:clientId] autorelease];
    NSDictionary *messageElementParameters = [NSDictionary dictionaryWithObject:@"urn:SingleEmailMessage" forKey:@"type"];
	[env startElement:@"sendEmail"];
	for (ZKSObject *message in emails)
    {
        [env startElement:@"messages" withParameters:messageElementParameters];
        [env addSObjectFields: message];
        [env endElement:@"messages"];
    }
	[env endElement:@"sendEmail"];
	[env endElement:@"s:Body"];
    NSString *xml = [env end]; */
    
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:self.sessionId clientId:self.clientId];
    FDCMessageElement *sendEmailElement = [FDCMessageElement elementWithName:@"sendEmail" value:nil];
    for (ZKSObject *message in emails)
    {
        FDCMessageElement *messageElement = [FDCMessageElement elementWithName:@"messages" value:nil];
        [messageElement addAttribute:@"urn:SingleEmailMessage" value:@"type"];
        for (NSString *key in [[message fields] allKeys])
        {
            id value = [[message fields] valueForKey:key];
            [messageElement addChildElement:[FDCMessageElement elementWithName:key value:value]];
        }
        [sendEmailElement addChildElement:messageElement];
    }
    [envelope addBodyElement:sendEmailElement];
    NSString *xml = [envelope stringRepresentation]; 
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processSendEmailResponse:error:context:) context: wrapperContext];
}

- (void)setPassword:(NSString *)password forUserId:(NSString *)userId target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    /*ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionHeader:self.sessionId clientId:self.clientId] autorelease];
	[env startElement:@"setPassword"];
	[env addElement:@"userId" elemValue:userId];
	[env addElement:@"password" elemValue:password];
	[env endElement:@"setPassword"];
	[env endElement:@"s:Body"];
    NSString *xml = [env end]; */
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:self.sessionId clientId:self.clientId];
    FDCMessageElement *setPasswordElement = [FDCMessageElement elementWithName:@"setPassword" value:nil];
    [setPasswordElement addChildElement:[FDCMessageElement elementWithName:@"userId" value:userId]];
    [setPasswordElement addChildElement:[FDCMessageElement elementWithName:@"password" value:password]];
    [envelope addBodyElement:setPasswordElement];
    NSString *xml = [envelope stringRepresentation];  
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processSetPasswordResponse:error:context:) context: wrapperContext];
}


@end


@implementation FDCServerSwitchboard (UtilityWrappers)

- (NSNumber *)_processSetPasswordResponse:(ZKElement *)setPasswordResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    // A fault would happen (and an error prepped) if it wasn't successful.
    NSNumber *response = [NSNumber numberWithBool: (error ? NO : YES)];
    [self unwrapContext:context andCallSelectorWithResponse:response error:error];
	return response;
}

- (NSDate *)_processGetServerTimestampResponse:(ZKElement *)getServerTimestampResponseElement error:(NSError *)error context:(NSDictionary *)context
{
	ZKElement *result = [getServerTimestampResponseElement childElement:@"result"];
    ZKElement *timestampElement = [result childElement:@"timestamp"];
    NSString *timestampString = [timestampElement stringValue];
    NSDate *timestamp = [NSDate dateWithLongFormatString:timestampString];
    [self unwrapContext:context andCallSelectorWithResponse:timestamp error:error];
	return timestamp;
}

- (ZKUserInfo *)_processGetUserInfoResponse:(ZKElement *)getUserInfoResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    ZKElement *result = [getUserInfoResponseElement childElement:@"result"];
    ZKUserInfo *info = [[[ZKUserInfo alloc] initWithXmlElement:result] autorelease];
    [self unwrapContext:context andCallSelectorWithResponse:info error:error];
	return info;
}

- (NSArray *)_processEmptyRecycleBinResponse:(ZKElement *)emptyRecycleBinResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    NSArray *resArr = [emptyRecycleBinResponseElement childElements:@"result"];
	NSMutableArray *results = [NSMutableArray arrayWithCapacity:[resArr count]];
	for (ZKElement *saveResultElement in resArr) {
		ZKSaveResult *sr = [[[ZKSaveResult alloc] initWithXmlElement:saveResultElement] autorelease];
		[results addObject:sr];
	} 
    [self unwrapContext:context andCallSelectorWithResponse:results error:error];
	return results;
}

- (NSNumber *)_processSendEmailResponse:(ZKElement *)sendEmailResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    // A fault would happen (and an error prepped) if it wasn't successful.
    NSNumber *response = [NSNumber numberWithBool: (error ? NO : YES)];
    [self unwrapContext:context andCallSelectorWithResponse:response error:error];
	return response;
}

- (NSString *)_processResetPasswordResponse:(ZKElement *)resetPasswordResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    ZKElement *result = [resetPasswordResponseElement childElement:@"result"];
    ZKElement *passwordElement = [result childElement:@"password"];
    NSString *password = [passwordElement stringValue];
    [self unwrapContext:context andCallSelectorWithResponse:password error:error];
	return password;
}

@end

