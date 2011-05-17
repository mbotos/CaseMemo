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

#import "ZKBaseClient.h"
#import "ZKSoapException.h"
#import "ZKParser.h"

@implementation ZKBaseClient

static NSString *SOAP_NS = @"http://schemas.xmlsoap.org/soap/envelope/";

NSString * const TEXTXML_CONTENTTYPE = @"text/xml";

@synthesize httpResponse;
//@synthesize receivedData;
@synthesize connectionStack;

- (id) init 
{
    if (self = [super init]) {
        connectionStack = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
	return self;
}

- (void)dealloc {
    [connectionStack release];
	[endpointUrl release]; 
	[super dealloc];
}

- (NSMutableURLRequest *)makeRequest:(NSString *)payload 
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpointUrl]];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"content-type"];	
	[request setValue:@"salesforce-toolkit-ios/20.0" forHTTPHeaderField:@"User-Agent"];	
	[request addValue:@"\"\"" forHTTPHeaderField:@"SOAPAction"];
	
	NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:data];
	return request;
}

- (void) sendRequestAsync:(NSString *)payload withResponseDelegate:(id)responseDelegate 
      andResponseSelector:(SEL)responseSelector 
        withOperationName:(NSString *)operation 
           withObjectName:(NSString *)objectName 
             withDelegate:(id)delegate 
{
	
	NSMutableURLRequest *request = [self makeRequest:payload] ;
	FDCURLConnection * conn = [[FDCURLConnection alloc] initWithRequest:request delegate:self withResponseDelegate:responseDelegate withResponseSelector:responseSelector 
												   withClientDelegate:delegate withLayoutObjectName:objectName withOperationName:operation];
	[conn release];
}

- (NSString *)getConnectionHashString:(NSURLConnection *)conn 
{
	NSNumber *hash = [NSNumber numberWithInt:[conn hash]];
	return [NSString stringWithFormat:@"%@", hash];
}

// A delegate method called by the NSURLConnection when the request/response 
// exchange is complete.  We look at the response to check that the HTTP 
// status code is 2xx and that the Content-Type is acceptable.  If these checks 
// fail, we give up on the transfer.
- (void)connection:(FDCURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse");
    
    self.httpResponse = (NSHTTPURLResponse *) response;
    assert( [self.httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
	if ((self.httpResponse.statusCode / 100) != 2) {
		NSLog(@"Bad status code.");
		//[self _stopReceiveWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode] withConnection:conn];
    } else {
		NSString *  fileMIMEType;
        
		fileMIMEType = [[self.httpResponse MIMEType] lowercaseString];
		
		if (fileMIMEType == nil) {
			NSLog(@"Bad MIME type.");
			[self _stopReceiveWithStatus:@"No Content-Type!" withConnection:conn];
		} else if ( ! [fileMIMEType isEqualToString:TEXTXML_CONTENTTYPE] ) {
			NSLog(@"Unsupported Content-Type");
			[self _stopReceiveWithStatus:[NSString stringWithFormat:@"Unsupported Content-Type (%@)", fileMIMEType] withConnection:conn];
		} else {
			NSLog(@"Response was OK.");
			//[self _updateStatus:@"Response OK."];
		}
    }    
}

// A delegate method called by the NSURLConnection as data arrives.  We just 
// write the data to the file.
- (void)connection:(FDCURLConnection *)conn didReceiveData:(NSData *)data
{
	NSLog(@"Data Received.");
	
	//TODO call some event hook or a block method.
	[conn.receivedData appendData:data];
}

// Shuts down the connection and displays the result (statusString == nil) 
// or the error status (otherwise).
- (void)_stopReceiveWithStatus:(NSString *)statusString withConnection:(FDCURLConnection *)conn
{
    if (conn != nil) 
    {
        [conn cancel];
    }
    //[self _receiveDidStopWithStatus:statusString];
}



-(ZKElement *)processResponse:(NSData *)respPayload response:(NSHTTPURLResponse *)resp error:(NSError **)err 
{
	ZKElement *root = [ZKParser parseData:respPayload];
	if (root == nil)	
		@throw [NSException exceptionWithName:@"Xml error" reason:@"Unable to parse XML returned by server" userInfo:nil];
	if (![[root name] isEqualToString:@"Envelope"])
		@throw [NSException exceptionWithName:@"Xml error" reason:[NSString stringWithFormat:@"response XML not valid SOAP, root element should be Envelope, but was %@", [root name]] userInfo:nil];
	if (![[root namespace] isEqualToString:SOAP_NS])
		@throw [NSException exceptionWithName:@"Xml error" reason:[NSString stringWithFormat:@"response XML not valid SOAP, root namespace should be %@ but was %@", SOAP_NS, [root namespace]] userInfo:nil];
	ZKElement *body = [root childElement:@"Body" ns:SOAP_NS];
	if (500 == resp.statusCode) 
    {
		ZKElement *fault = [body childElement:@"Fault" ns:SOAP_NS];
		if (fault == nil)
			@throw [NSException exceptionWithName:@"Xml error" reason:@"Fault status code returned, but unable to find soap:Fault element" userInfo:nil];
		NSString *fc = [[fault childElement:@"faultcode"] stringValue];
		NSString *fm = [[fault childElement:@"faultstring"] stringValue];
		@throw [ZKSoapException exceptionWithFaultCode:fc faultString:fm];
	}
	return [[body childElements] objectAtIndex:0];
}

#pragma mark Original Code


- (ZKElement *)sendRequest:(NSString *)payload 
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpointUrl]];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"content-type"];	
	[request addValue:@"salesforce-toolkit-ios/20.0" forHTTPHeaderField:@"User-Agent"];	
	[request addValue:@"\"\"" forHTTPHeaderField:@"SOAPAction"];
	
	NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:data];
	 
	NSHTTPURLResponse *resp = nil;
	NSError *err = nil;
	// todo, support request compression
	// todo, support response compression
	NSData *respPayload = [FDCURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
	ZKElement *root = [ZKParser parseData:respPayload];
	if (root == nil)	
		@throw [NSException exceptionWithName:@"Xml error" reason:@"Unable to parse XML returned by server" userInfo:nil];
	if (![[root name] isEqualToString:@"Envelope"])
		@throw [NSException exceptionWithName:@"Xml error" reason:[NSString stringWithFormat:@"response XML not valid SOAP, root element should be Envelope, but was %@", [root name]] userInfo:nil];
	if (![[root namespace] isEqualToString:SOAP_NS])
		@throw [NSException exceptionWithName:@"Xml error" reason:[NSString stringWithFormat:@"response XML not valid SOAP, root namespace should be %@ but was %@", SOAP_NS, [root namespace]] userInfo:nil];
	ZKElement *body = [root childElement:@"Body" ns:SOAP_NS];
	if (500 == [resp statusCode]) 
    {
		ZKElement *fault = [body childElement:@"Fault" ns:SOAP_NS];
		if (fault == nil)
			@throw [NSException exceptionWithName:@"Xml error" reason:@"Fault status code returned, but unable to find soap:Fault element" userInfo:nil];
		NSString *fc = [[fault childElement:@"faultcode"] stringValue];
		NSString *fm = [[fault childElement:@"faultstring"] stringValue];
		@throw [ZKSoapException exceptionWithFaultCode:fc faultString:fm];
	}
	return [[body childElements] objectAtIndex:0];
}

@end
