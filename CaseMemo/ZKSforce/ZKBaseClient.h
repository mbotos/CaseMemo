// Copyright (c) 2006-2008 Simon Fell
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

#import "FDCURLConnection.h"

@protocol BaseClientProtocol

-(void)responseReady:(id)response;

@end

@class ZKElement;

extern NSString * const TEXTXML_CONTENTTYPE;

@interface ZKBaseClient : NSObject {
	NSString	*endpointUrl;
	NSHTTPURLResponse * httpResponse;
	//NSMutableData *receivedData;
	NSMutableDictionary *connectionStack;
	id<BaseClientProtocol> baseClientDelegate;
}

@property (nonatomic, retain) NSHTTPURLResponse * httpResponse;
//@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSMutableDictionary *connectionStack;

- (ZKElement *)sendRequest:(NSString *)payload;
- (ZKElement *)processResponse:(NSData *)respPayload response:(NSHTTPURLResponse *)resp error:(NSError **)err;
- (void) sendRequestAsync:(NSString *)payload withResponseDelegate:(id)responseDelegate andResponseSelector:(SEL)responseSelector withOperationName:(NSString *)operation withObjectName:(NSString *)objectName withDelegate:(id)delegate;

- (void)_stopReceiveWithStatus:(NSString *)statusString withConnection:(FDCURLConnection *)conn;
- (NSString *)getConnectionHashString:(NSURLConnection *)conn;
- (id) init;
- (NSMutableURLRequest *)makeRequest:(NSString *)payload;

@end
