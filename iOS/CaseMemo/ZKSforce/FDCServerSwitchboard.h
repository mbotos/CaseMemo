

#import <Foundation/Foundation.h>

@class ZKUserInfo;

@interface FDCServerSwitchboard : NSObject {
    CFMutableDictionaryRef connections;
    CFMutableDictionaryRef connectionsData;
    
    NSString    *apiUrl;
    
	NSString	*clientId;	
	NSString	*sessionId;
    NSString    *oAuthRefreshToken;
	NSDate		*sessionExpiry;
    ZKUserInfo	*userInfo;
	NSUInteger  preferredApiVersion;
    
    BOOL        updatesMostRecentlyUsed;
    BOOL        logXMLInOut;

@private
    NSString    *_username;
    NSString    *_password;

    NSTimer     *_oAuthRefreshTimer;
}

@property (nonatomic, copy) NSString *apiUrl;
@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *oAuthRefreshToken;
@property (nonatomic, retain) ZKUserInfo *userInfo;
@property (nonatomic, assign) BOOL updatesMostRecentlyUsed;
@property (nonatomic, assign) BOOL logXMLInOut;

+ (NSString *)baseURL;
+ (FDCServerSwitchboard *)switchboard;
- (NSString *)authenticationUrl;

- (void)setApiUrlFromOAuthInstanceUrl:(NSString *)instanceUrl;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password target:(id)target selector:(SEL)selector;

// Convenience methods that should only really be called from within ZKServerSwitchboard methods
// They're public because categories on ZKServerSwitchboard might need access to them
- (NSDictionary *)contextWrapperDictionaryForTarget:(id)target selector:(SEL)selector context:(id)context;
- (void)unwrapContext:(NSDictionary *)wrapperContext andCallSelectorWithResponse:(id)response error:(NSError *)error;


// Core Calls
- (void)create:(NSArray *)objects target:(id)target selector:(SEL)selector context:(id)context;
- (void)delete:(NSArray *)objectIDs target:(id)target selector:(SEL)selector context:(id)context;
- (void)getDeleted:(NSString *)sObjectType fromDate:(NSDate *)startDate toDate:(NSDate *)endDate target:(id)target selector:(SEL)selector context:(id)context;
- (void)getUpdated:(NSString *)sObjectType fromDate:(NSDate *)startDate toDate:(NSDate *)endDate target:(id)target selector:(SEL)selector context:(id)context;
- (void)query:(NSString *)soqlQuery target:(id)target selector:(SEL)selector context:(id)context;
- (void)queryAll:(NSString *)soqlQuery target:(id)target selector:(SEL)selector context:(id)context;
- (void)queryMore:(NSString *)queryLocator target:(id)target selector:(SEL)selector context:(id)context;
- (void)search:(NSString *)soqlQuery target:(id)target selector:(SEL)selector context:(id)context;
- (void)unDelete:(NSArray *)objectIDs target:(id)target selector:(SEL)selector context:(id)context;
- (void)update:(NSArray *)objects target:(id)target selector:(SEL)selector context:(id)context;

// Apex Calls
- (void)sendApexRequestToURL:(NSString *)webServiceLocation
                    withData:(NSString *)payload
                      target:(id)target
                    selector:(SEL)sel
                     context:(id)context;

@end
