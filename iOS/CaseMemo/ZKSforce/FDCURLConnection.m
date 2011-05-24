//
//  ZKURLConnection.m
//  SplitForce
//
//  Created by Dave Carroll on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FDCURLConnection.h"


@implementation FDCURLConnection
@synthesize responseDelegate, responseSelector, operationName, layoutObjectName, clientDelegate, receivedData;

-(id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate 
	  withResponseDelegate:(id)inResponseDelegate 
	  withResponseSelector:(SEL)inResponseSelector
		withClientDelegate:(id)inClientDelegate 
	  withLayoutObjectName:(NSString *)inLayoutObjectName 
		withOperationName:(NSString *)inOperationName
{
	if (self = [super initWithRequest:request delegate:delegate]) {
		self.receivedData = [NSMutableData data];
        self.responseDelegate = inResponseDelegate; 
        self.responseSelector = inResponseSelector;
        self.clientDelegate = inClientDelegate;
        self.layoutObjectName = inLayoutObjectName;
        self.operationName = inOperationName;
	}
	return self;
}
@end
