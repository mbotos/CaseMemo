

#import "FDCServerSwitchboard.h"
#import "FDCServerSwitchboard+Private.h"
#import "ZKParser.h"
//#import "ZKEnvelope.h"
//#import "ZKPartnerEnvelope.h"
#import "ZKQueryResult.h"
#import "ZKSObject.h"
#import "ZKSoapException.h"
#import "ZKLoginResult.h"
#import "NSObject+Additions.h"
#import "ZKSaveResult.h"
#import "FDCGetDeletedResult.h"
#import "FDCGetUpdatedResult.h"
#import "NSDate+Additions.h"
#import "FDCMessageEnvelope.h"
#import "FDCMessageElement.h"

static const int MAX_SESSION_AGE = 10 * 60; // 10 minutes.  15 minutes is the minimum length that you can set sessions to last to, so 10 should be safe.
static FDCServerSwitchboard * sharedSwitchboard =  nil;

@interface FDCServerSwitchboard (CoreWrappers)

- (ZKLoginResult *)_processLoginResponse:(ZKElement *)loginResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (ZKQueryResult *)_processQueryResponse:(ZKElement *)queryResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (NSArray *)_processSaveResponse:(ZKElement *)saveResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (NSArray *)_processDeleteResponse:(ZKElement *)saveResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (FDCGetDeletedResult *)_processGetDeletedResponse:(ZKElement *)getDeletedResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (FDCGetUpdatedResult *)_processGetUpdatedResponse:(ZKElement *)getUpdatedResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (NSArray *)_processSearchResponse:(ZKElement *)searchResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (NSArray *)_processUnDeleteResponse:(ZKElement *)saveResponseElement error:(NSError *)error context:(NSDictionary *)context;

@end

@implementation FDCServerSwitchboard

@synthesize apiUrl;
@synthesize clientId;
@synthesize sessionId;
@synthesize oAuthRefreshToken;
@synthesize userInfo;
@synthesize updatesMostRecentlyUsed;
@synthesize logXMLInOut;

+ (FDCServerSwitchboard *)switchboard
{
    if (sharedSwitchboard == nil)
    {
        sharedSwitchboard = [[super allocWithZone:NULL] init];
    }
    
    return sharedSwitchboard;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self switchboard] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    // Denotes an object that cannot be released
    return NSUIntegerMax;
}

- (void)release
{
    // Do nothing
}

- (id)autorelease
{
    return self;
}

- init
{
    if (!(self = [super init])) 
        return nil;
    
    connections = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,
                                            &kCFTypeDictionaryValueCallBacks);
    connectionsData = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,
                                                &kCFTypeDictionaryValueCallBacks);
    preferredApiVersion = 19;

    self.logXMLInOut = NO;
    
    return self;
}

- (void)dealloc
{
    CFRelease(connections);
    connections = NULL;
    CFRelease(connectionsData);
    connectionsData = NULL;
    
    // Properties
    [apiUrl release];
    [clientId release];	
	[sessionId release];
	[sessionExpiry release];
    [userInfo release];
    [oAuthRefreshToken release];
    
    // Private vars
    [_username release];
    [_password release];
    
    if (_oAuthRefreshTimer)
    {
        [_oAuthRefreshTimer invalidate];
        [_oAuthRefreshTimer release];
    }
    
    [super dealloc];
}

+ (NSString *)baseURL
{
    return @"https://www.salesforce.com";
}

#pragma mark Properties

- (NSString *)apiUrl
{
    if (apiUrl)
        return apiUrl;
    return [self authenticationUrl];
}

- (void)setOAuthRefreshToken:(NSString *)refreshToken
{
    NSString *copy = [refreshToken copy];
    [oAuthRefreshToken release];
    oAuthRefreshToken = copy;
    
    // Disable whatever timer existed before
    if (_oAuthRefreshTimer)
    {
        [_oAuthRefreshTimer invalidate];
        [_oAuthRefreshTimer release];
    }
    if (oAuthRefreshToken)
    {
    // Reschedule a new timer
        _oAuthRefreshTimer = [[NSTimer scheduledTimerWithTimeInterval:MAX_SESSION_AGE target:self selector:@selector(_oauthRefreshAccessToken:) userInfo:nil repeats:YES] retain];
    }
}

#pragma mark Methods

- (NSString *)authenticationUrl
{
    NSString *url = [NSString stringWithFormat:@"%@/services/Soap/u/%d.0", [[self class] baseURL] , preferredApiVersion];
    return url;
}


- (void)setApiUrlFromOAuthInstanceUrl:(NSString *)instanceUrl
{
    self.apiUrl = [instanceUrl stringByAppendingFormat:@"/services/Soap/u/%d.0", preferredApiVersion];
}

- (NSDictionary *)contextWrapperDictionaryForTarget:(id)target selector:(SEL)selector context:(id)context
{
    NSValue *selectorValue = [NSValue value: &selector withObjCType: @encode(SEL)];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            selectorValue, @"selector",
            target, @"target",
            context ? context: [NSNull null], @"context",
            nil];
}

- (void)unwrapContext:(NSDictionary *)wrapperContext andCallSelectorWithResponse:(id)response error:(NSError *)error
{
    SEL selector;
    [[wrapperContext valueForKey: @"selector"] getValue: &selector];
    id target = [wrapperContext valueForKey:@"target"];
    id context = [wrapperContext valueForKey:@"context"];
    if ([context isEqual:[NSNull null]])
        context = nil;
    
    [target performSelector:selector withObject:response withObject:error withObject: context];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password target:(id)target selector:(SEL)selector
{
    // Save Username and Password for session management stuff
    [username retain];
    [_username release];
    _username = username;
    [password retain];
    [_password release];
    _password = password;
    
    // Reset session management stuff
    [sessionExpiry release];
	sessionExpiry = [[NSDate dateWithTimeIntervalSinceNow:MAX_SESSION_AGE] retain];
	
    /*
	ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionHeader:nil clientId:clientId] autorelease];
	[env startElement:@"login"];
	[env addElement:@"username" elemValue:username];
	[env addElement:@"password" elemValue:password]; 
	[env endElement:@"login"];
	[env endElement:@"s:Body"];
	NSString *xml = [env end]; */
    
    FDCMessageEnvelope *envelop = [FDCMessageEnvelope envelopeWithSessionId:nil clientId:clientId];
    FDCMessageElement *loginElement = [FDCMessageElement elementWithName:@"login" value:nil];
    [loginElement addChildElement:[FDCMessageElement elementWithName:@"username" value:username]];
    [loginElement addChildElement:[FDCMessageElement elementWithName:@"password" value:password]];
    [envelop addBodyElement:loginElement];
    NSString *alternativeXML = [envelop stringRepresentation];    
	
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:nil];
    [self _sendRequestWithData:alternativeXML target:self selector:@selector(_processLoginResponse:error:context:) context: wrapperContext];
}

- (void)create:(NSArray *)objects target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    // if more than we can do in one go, break it up. DC - Ignoring this case.
    /*
	ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionId:sessionId updateMru:self.updatesMostRecentlyUsed clientId:clientId] autorelease];
	[env startElement:@"create"];
	for (ZKSObject *object in objects)
    {
        [env addElement:@"sobject" elemValue:object];
    }
	[env endElement:@"create"];
	[env endElement:@"s:Body"];
    NSString *xml = [env end]; */
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    if (self.updatesMostRecentlyUsed)
        [envelope addUpdatesMostRecentlyUsedHeader];
    [envelope addBodyElementNamed:@"create" withChildNamed:@"sobject" value:objects];
    NSString *xml = [envelope stringRepresentation]; 
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processSaveResponse:error:context:) context: wrapperContext];
}

- (void)delete:(NSArray *)objectIDs target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    /*
    ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionId:sessionId updateMru:self.updatesMostRecentlyUsed clientId:clientId] autorelease];
	[env startElement:@"delete"];
	[env addElement:@"ids" elemValue:objectIDs];
	[env endElement:@"delete"];
	[env endElement:@"s:Body"];
    NSString *xml = [env end]; */
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    if (self.updatesMostRecentlyUsed)
        [envelope addUpdatesMostRecentlyUsedHeader];
    [envelope addBodyElementNamed:@"delete" withChildNamed:@"ids" value:objectIDs];
    NSString *xml = [envelope stringRepresentation]; 
	
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processDeleteResponse:error:context:) context: wrapperContext];
}

- (void)getDeleted:(NSString *)sObjectType fromDate:(NSDate *)startDate toDate:(NSDate *)endDate target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    if (!startDate)
        startDate = [NSDate dateWithTimeIntervalSinceNow: - (29 * 60 * 60 * 24)];
    if (!endDate)
        endDate = [NSDate date];
    
    /*
    ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionId:sessionId updateMru:self.updatesMostRecentlyUsed clientId:clientId] autorelease];
	[env startElement:@"getDeleted"];
	[env addElement:@"sObjectType" elemValue:sObjectType];
    [env addElement:@"startDate" elemValue:[startDate longFormatString]];
	[env addElement:@"endDate" elemValue:[endDate longFormatString]];
	[env endElement:@"getDeleted"];
	[env endElement:@"s:Body"];
    NSString *xml = [env end]; */
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    if (self.updatesMostRecentlyUsed)
        [envelope addUpdatesMostRecentlyUsedHeader];
    FDCMessageElement *getDeletedElement = [FDCMessageElement elementWithName:@"getDeleted" value:nil];
    [getDeletedElement addChildElement:[FDCMessageElement elementWithName:@"sObjectType" value:sObjectType]];
    [getDeletedElement addChildElement:[FDCMessageElement elementWithName:@"startDate" value:[startDate longFormatString]]];
    [getDeletedElement addChildElement:[FDCMessageElement elementWithName:@"endDate" value:[endDate longFormatString]]];
    [envelope addBodyElement:getDeletedElement];
    NSString *xml = [envelope stringRepresentation]; 
	
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processGetDeletedResponse:error:context:) context: wrapperContext];
}

- (void)getUpdated:(NSString *)sObjectType fromDate:(NSDate *)startDate toDate:(NSDate *)endDate target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    if (!startDate)
        startDate = [NSDate dateWithTimeIntervalSinceNow: - (29 * 60 * 60 * 24)];
    if (!endDate)
        endDate = [NSDate date];
    
    /*
    ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionHeader:sessionId clientId:clientId] autorelease];
	[env startElement:@"getUpdated"];
	[env addElement:@"sObjectType" elemValue:sObjectType];
    [env addElement:@"startDate" elemValue:[startDate longFormatString]];
	[env addElement:@"endDate" elemValue:[endDate longFormatString]];
	[env endElement:@"getUpdated"];
	[env endElement:@"s:Body"];
    NSString *xml = [env end]; */
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    FDCMessageElement *getUpdatedElement = [FDCMessageElement elementWithName:@"getUpdated" value:nil];
    [getUpdatedElement addChildElement:[FDCMessageElement elementWithName:@"sObjectType" value:sObjectType]];
    [getUpdatedElement addChildElement:[FDCMessageElement elementWithName:@"startDate" value:[startDate longFormatString]]];
    [getUpdatedElement addChildElement:[FDCMessageElement elementWithName:@"endDate" value:[endDate longFormatString]]];
    [envelope addBodyElement:getUpdatedElement];
    NSString *xml = [envelope stringRepresentation]; 
	
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processGetUpdatedResponse:error:context:) context: wrapperContext];
}

- (void)query:(NSString *)soqlQuery target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    /*ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionHeader:self.sessionId clientId:self.clientId] autorelease];
	[env startElement:@"query"];
	[env addElement:@"queryString" elemValue:soqlQuery];
	[env endElement:@"query"];
	[env endElement:@"s:Body"]; 
    NSString *xml = [env end]; */
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    [envelope addBodyElementNamed:@"query" withChildNamed:@"queryString" value:soqlQuery];
    NSString *xml = [envelope stringRepresentation]; 
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processQueryResponse:error:context:) context: wrapperContext];
}

- (void)queryAll:(NSString *)soqlQuery target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    /*ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionHeader:self.sessionId clientId:self.clientId] autorelease];
	[env startElement:@"queryAll"];
	[env addElement:@"queryString" elemValue:soqlQuery];
	[env endElement:@"queryAll"];
	[env endElement:@"s:Body"]; 
    NSString *xml = [env end]; */
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    [envelope addBodyElementNamed:@"queryAll" withChildNamed:@"queryString" value:soqlQuery];
    NSString *xml = [envelope stringRepresentation]; 
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processQueryResponse:error:context:) context: wrapperContext];
}

- (void)queryMore:(NSString *)queryLocator target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    /*ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionHeader:self.sessionId clientId:self.clientId] autorelease];
	[env startElement:@"queryMore"];
	[env addElement:@"queryLocator" elemValue:queryLocator];
	[env endElement:@"queryMore"];
	[env endElement:@"s:Body"]; 
    NSString *xml = [env end];*/
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    [envelope addBodyElementNamed:@"queryMore" withChildNamed:@"queryLocator" value:queryLocator];
    NSString *xml = [envelope stringRepresentation]; 
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processQueryResponse:error:context:) context: wrapperContext];
}

- (void)search:(NSString *)soslQuery target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    /*ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionHeader:self.sessionId clientId:self.clientId] autorelease];
	[env startElement:@"search"];
	[env addElement:@"searchString" elemValue:soslQuery];
	[env endElement:@"search"];
	[env endElement:@"s:Body"];
    NSString *xml = [env end]; */
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    [envelope addBodyElementNamed:@"search" withChildNamed:@"searchString" value:soslQuery];
    NSString *xml = [envelope stringRepresentation]; 
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processSearchResponse:error:context:) context: wrapperContext];
}

- (void)unDelete:(NSArray *)objectIDs target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    /*ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionId:sessionId updateMru:self.updatesMostRecentlyUsed clientId:clientId] autorelease];
	[env startElement:@"undelete"];
	[env addElement:@"ids" elemValue:objectIDs];
	[env endElement:@"undelete"];
	[env endElement:@"s:Body"];
    NSString *xml = [env end]; */
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    if (self.updatesMostRecentlyUsed)
        [envelope addUpdatesMostRecentlyUsedHeader];
    [envelope addBodyElementNamed:@"undelete" withChildNamed:@"ids" value:objectIDs];
    NSString *xml = [envelope stringRepresentation]; 
	
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processUnDeleteResponse:error:context:) context: wrapperContext];
}

- (void)update:(NSArray *)objects target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
	// if more than we can do in one go, break it up. DC - Ignoring this case.
	/*ZKEnvelope *env = [[[ZKPartnerEnvelope alloc] initWithSessionId:sessionId updateMru:self.updatesMostRecentlyUsed clientId:clientId] autorelease];
	[env startElement:@"update"];
	for (ZKSObject *object in objects)
    {
        [env addElement:@"sobject" elemValue:object];
    }
	[env endElement:@"update"];
	[env endElement:@"s:Body"];
    NSString *xml = [env end];*/
    
    FDCMessageEnvelope *envelope = [FDCMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    if (self.updatesMostRecentlyUsed)
        [envelope addUpdatesMostRecentlyUsedHeader];
    [envelope addBodyElementNamed:@"update" withChildNamed:@"sobject" value:objects];
    NSString *xml = [envelope stringRepresentation]; 
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processSaveResponse:error:context:) context: wrapperContext];
}


#pragma mark -
#pragma mark Apex Calls

- (void)sendApexRequestToURL:(NSString *)webServiceLocation
                    withData:(NSString *)payload
                      target:(id)target
                    selector:(SEL)sel
                     context:(id)context
{
    // The method is equivalent to ZKServerSwitchboard+Private's _sendRequestWithData:target:selector:context
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:webServiceLocation]];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"content-type"];	
	[request addValue:@"\"\"" forHTTPHeaderField:@"SOAPAction"];
    NSLog(@"request = %@", request);
	NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:data];
    
	if(self.logXMLInOut) {
		NSLog(@"OutputHeaders:\n%@", [request allHTTPHeaderFields]);
		NSLog(@"OutputBody:\n%@", payload);
	}
    
    [self _sendRequest:request target:target selector:sel context:context];
}


@end

@implementation FDCServerSwitchboard (CoreWrappers)

- (ZKLoginResult *)_processLoginResponse:(ZKElement *)loginResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    ZKLoginResult *loginResult = nil;
    if (!error)
    {
        ZKElement *result = [[loginResponseElement childElements:@"result"] objectAtIndex:0];
        loginResult = [[[ZKLoginResult alloc] initWithXmlElement:result] autorelease];
        self.apiUrl = [loginResult serverUrl];
        self.sessionId = [loginResult sessionId];
        self.userInfo = [loginResult userInfo];
    }

    [self unwrapContext:context andCallSelectorWithResponse:loginResult error:error];
    return loginResult;
}

- (ZKQueryResult *)_processQueryResponse:(ZKElement *)queryResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    ZKQueryResult *result = nil;
    if (!error)
    {
        result = [[[ZKQueryResult alloc] initFromXmlNode:[[queryResponseElement childElements] objectAtIndex:0]] autorelease];
    }
    [self unwrapContext:context andCallSelectorWithResponse:result error:error];
    return result;
}

- (NSArray *)_processSaveResponse:(ZKElement *)saveResponseElement error:(NSError *)error context:(NSDictionary *)context
{
	NSArray *resultsArr = [saveResponseElement childElements:@"result"];
	NSMutableArray *results = [NSMutableArray arrayWithCapacity:[resultsArr count]];
	
	for (ZKElement *result in resultsArr) {
		ZKSaveResult * saveResult = [[[ZKSaveResult alloc] initWithXmlElement:result] autorelease];
		[results addObject:saveResult];
	}
    [self unwrapContext:context andCallSelectorWithResponse:results error:error];
    return results;
}

- (NSArray *)_processDeleteResponse:(ZKElement *)saveResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    NSArray *resArr = [saveResponseElement childElements:@"result"];
	NSMutableArray *results = [NSMutableArray arrayWithCapacity:[resArr count]];
	for (ZKElement *saveResultElement in resArr) {
		ZKSaveResult *sr = [[[ZKSaveResult alloc] initWithXmlElement:saveResultElement] autorelease];
		[results addObject:sr];
	} 
    [self unwrapContext:context andCallSelectorWithResponse:results error:error];
	return results;
}

- (NSArray *)_processSearchResponse:(ZKElement *)searchResponseElement error:(NSError *)error context:(NSDictionary *)context;
{
  NSArray *searchRecords = [[searchResponseElement childElement:@"result"] childElements:@"searchRecords"];
  NSMutableArray *results = [NSMutableArray arrayWithCapacity:[searchRecords count]];

  for ( ZKElement *sRecord in searchRecords ) {
     ZKSObject *record = [[ZKSObject alloc] initFromXmlNode:[sRecord childElement:@"record"] ];
     [results addObject:record];
  }
  [self unwrapContext:context andCallSelectorWithResponse:results error:error];
  return results;
}



- (FDCGetDeletedResult *)_processGetDeletedResponse:(ZKElement *)getDeletedResponseElement error:(NSError *)error context:(NSDictionary *)context;
{
    FDCGetDeletedResult *result = nil;
    if (!error)
    {
        result = [[[FDCGetDeletedResult alloc] initFromXmlNode:[[getDeletedResponseElement childElements] objectAtIndex:0]] autorelease];
    }
    [self unwrapContext:context andCallSelectorWithResponse:result error:error];
    return result;
}

- (FDCGetUpdatedResult *)_processGetUpdatedResponse:(ZKElement *)getUpdatedResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    FDCGetUpdatedResult *result = nil;
    if (!error)
    {
        result = [[[FDCGetUpdatedResult alloc] initFromXmlNode:[[getUpdatedResponseElement childElements] objectAtIndex:0]] autorelease];
    }
    [self unwrapContext:context andCallSelectorWithResponse:result error:error];
    return result;
}

- (NSArray *)_processUnDeleteResponse:(ZKElement *)saveResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    return [self _processDeleteResponse:saveResponseElement error:error context:context];
}

@end
