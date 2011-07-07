//
//  Key.m
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

#import "Key.h"

#import <Security/Security.h>

#import "KeychainItemSubclass.h"

@interface Key (PrivateMethods)

@property (nonatomic, readonly) NSArray *keyClasses;
@property (nonatomic, readonly) NSArray *keyTypes;

@end


#pragma mark -

@implementation Key

@dynamic keyClass;
@dynamic applicationLabel;
@dynamic permanent;
@dynamic tag;
@dynamic keyType;
@dynamic keySizeInBits;
@dynamic effectiveKeySize;
@dynamic canEncrypt;
@dynamic canDecrypt;
@dynamic canDerive;
@dynamic canSign;
@dynamic canVerify;
@dynamic canWrap;
@dynamic canUnwrap;

- (CFTypeRef)classCode
{
   return kSecClassKey;
}


#pragma mark -
#pragma mark Properties

- (KeyClass)keyClass
{
   CFTypeRef keyClass = [self objectForKey:(id)kSecAttrKeyClass];
   return [self.keyClasses indexOfObject:(id)keyClass];
}

- (NSString *)applicationLabel
{
   return [self objectForKey:(id)kSecAttrApplicationLabel];
}

- (void)setApplicationLabel:(NSString *)newLabel
{
   [self setObject:newLabel forKey:(id)kSecAttrApplicationLabel];
}

- (BOOL)isPermanent
{
   CFBooleanRef value = (CFBooleanRef)[self objectForKey:(id)kSecAttrIsPermanent];
   return CFBooleanGetValue(value);
}

- (void)setPermanent:(BOOL)isPermanent
{
   CFBooleanRef newValue = isPermanent ? kCFBooleanTrue : kCFBooleanFalse;
   [self setObject:(id)newValue forKey:(id)kSecAttrIsPermanent];
}

- (NSData *)tag
{
   return [self objectForKey:(id)kSecAttrApplicationTag];
}

- (void)setTag:(NSData *)newTagData
{
   [self setObject:newTagData forKey:(id)kSecAttrApplicationTag];
}

- (KeyType)keyType
{
   CFTypeRef keyType = [self objectForKey:(id)kSecAttrKeyType];
   return [self.keyTypes indexOfObject:(id)keyType];
}

- (NSUInteger)keySizeInBits
{
   NSNumber *keySize = [self objectForKey:(id)kSecAttrKeySizeInBits];
   return [keySize unsignedIntegerValue];
}

- (NSUInteger)effectiveKeySize
{
   NSNumber *keySize = [self objectForKey:(id)kSecAttrEffectiveKeySize];
   return [keySize unsignedIntegerValue];
}

@end


#pragma mark -

@implementation Key(PrivateMethods)

@dynamic keyClasses;
@dynamic keyTypes;

- (NSArray *)keyClasses
{
   static NSArray *keyClasses = nil;
   
   if (keyClasses == nil)
   {
      keyClasses = [[NSArray alloc] initWithObjects:
                    (id)kSecAttrKeyClassPublic,
                    (id)kSecAttrKeyClassPrivate,
                    (id)kSecAttrKeyClassSymmetric, nil];
   }
   
   return keyClasses;
}

- (NSArray *)keyTypes
{
   static NSArray *keyTypes = nil;
   
   if (keyTypes == nil)
   {
      keyTypes = [[NSArray alloc] initWithObjects:
                  (id)kSecAttrKeyTypeRSA,
                  nil];
   }
   
   return keyTypes;
}

@end
