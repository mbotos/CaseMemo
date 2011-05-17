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


#import <Foundation/Foundation.h>

enum _FDCMessageElementType
{
    FDCMessageElementTypePartner = 0,
    FDCMessageElementTypeEnterprise = 1,
    FDCMessageElementTypeApex = 2
};
typedef NSUInteger FDCMessageElementType;


@interface FDCMessageElement : NSObject {
    NSString *name;
    id value;
    NSMutableDictionary *attributes;
    NSMutableArray *childElements;
    FDCMessageElementType type;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) id value;
@property (nonatomic, readonly) NSArray *childElements;
@property (nonatomic, assign) FDCMessageElementType type;

+ (FDCMessageElement *)elementWithName:(NSString *)aName value:(id)aValue;

- (id)initWithName:(NSString *)aName value:(id)aValue;

- (void)addAttribute:(NSString *)attributeName value:(NSString *)aValue;
- (void)addChildElement:(FDCMessageElement *)element;

- (NSString *)stringRepresentation;

@end
