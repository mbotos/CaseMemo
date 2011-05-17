//
//  Certificate.m
//  ObjectiveKeychain
//
//  Copyright (c) 2010 Tyler Stromberg
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "Certificate.h"

#import <Security/Security.h>

#import "KeychainItemSubclass.h"

@implementation Certificate

@dynamic certificateType;
@dynamic certificateEncoding;
@dynamic subjectName;
@dynamic issuer;
@dynamic serialNumber;
@dynamic subjectKeyID;
@dynamic publicKeyHash;

- (CFTypeRef)classCode
{
   return kSecClassCertificate;
}

#pragma mark -
#pragma mark Properties

- (NSUInteger)certificateType
{
   NSNumber *certType = [self objectForKey:(id)kSecAttrCertificateType];
   return [certType unsignedIntegerValue];
}

- (NSUInteger)certificateEncoding
{
   NSNumber *certEncoding = [self objectForKey:(id)kSecAttrCertificateEncoding];
   return [certEncoding unsignedIntegerValue];
}

- (NSData *)subjectName
{
   return [self objectForKey:(id)kSecAttrSubject];
}

- (NSData *)serialNumber
{
   return [self objectForKey:(id)kSecAttrSerialNumber];
}

- (NSData *)subjectKeyID
{
   return [self objectForKey:(id)kSecAttrSubjectKeyID];
}

- (NSData *)publicKeyHash
{
   return [self objectForKey:(id)kSecAttrPublicKeyHash];
}

@end
