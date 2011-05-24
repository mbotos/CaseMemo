//
//  Password.m
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

#import "Password.h"

#import <Security/Security.h>

#import "KeychainItemSubclass.h"

@implementation Password

@dynamic creationDate;
@dynamic modificationDate;

@dynamic userDescription;
@dynamic comment;
@dynamic creator;
@dynamic type;
@dynamic invisible;
@dynamic negative;
@dynamic account;
@dynamic password;


#pragma mark -

- (void)resetKeychainItem
{
   [super resetKeychainItem];
   
   // Default attributes
   self.account = @"";
   self.userDescription = @"";
   self.password = @"";
}

- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert
{
   NSMutableDictionary *returnDict = [super dictionaryToSecItemFormat:dictionaryToConvert];
   
   // This is where to store sensitive data that should be encrypted.
   //
   // Convert the NSString to NSData to meet the requirements for the value
   // type kSecValueData.
   NSString *password = [dictionaryToConvert objectForKey:(id)kSecValueData];
   NSData *encodedPassword = [password dataUsingEncoding:NSUTF8StringEncoding];
   
   [returnDict setObject:encodedPassword forKey:(id)kSecValueData];
   
   return returnDict;
}

- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert
{
   NSMutableDictionary *returnDict = [super secItemFormatToDictionary:dictionaryToConvert];
   
   // Convert the password from NSData to NSString.
   NSData *passwordData = [returnDict valueForKey:(id)kSecValueData];
   NSString *password = [[[NSString alloc] initWithBytes:[passwordData bytes]
                                                  length:[passwordData length] 
                                                encoding:NSUTF8StringEncoding] autorelease];
   
   [returnDict setObject:password forKey:(id)kSecValueData];
   
   return returnDict;
}


#pragma mark -
#pragma mark Properties

- (NSDate *)creationDate
{
   return [self objectForKey:(id)kSecAttrCreationDate];
}

- (NSDate *)modificationDate
{
   return [self objectForKey:(id)kSecAttrModificationDate];
}

- (NSString *)userDescription
{
   return [self objectForKey:(id)kSecAttrDescription];
}

- (void)setUserDescription:(NSString *)newDescription
{
   [self setObject:newDescription forKey:(id)kSecAttrDescription];
}

- (NSString *)comment
{
   return [self objectForKey:(id)kSecAttrComment];
}

- (void)setComment:(NSString *)newComment
{
   [self setObject:newComment forKey:(id)kSecAttrComment];
}

- (NSUInteger)creator
{
   return [[self objectForKey:(id)kSecAttrCreator] unsignedIntegerValue];
}

- (void)setCreator:(NSUInteger)newCreator
{
   [self setObject:[NSNumber numberWithUnsignedInteger:newCreator]
            forKey:(id)kSecAttrCreator];
}

- (NSUInteger)type
{
   return [[self objectForKey:(id)kSecAttrType] unsignedIntegerValue];
}

- (void)setType:(NSUInteger)newType
{
   [self setObject:[NSNumber numberWithUnsignedInteger:newType]
            forKey:(id)kSecAttrType];
}

- (BOOL)isInvisible
{
   CFBooleanRef value = (CFBooleanRef)[self objectForKey:(id)kSecAttrIsInvisible];
   
   if (value != nil)
   {
      return CFBooleanGetValue(value);
   }
   else
   {
      return NO;
   }
}

- (void)setInvisible:(BOOL)isInvisible
{
   CFBooleanRef newValue = isInvisible ? kCFBooleanTrue : kCFBooleanFalse;
   [self setObject:(id)newValue forKey:(id)kSecAttrIsInvisible];
}

- (BOOL)isNegative
{
   CFBooleanRef value = (CFBooleanRef)[self objectForKey:(id)kSecAttrIsNegative];
   
   if (value != nil)
   {
      return CFBooleanGetValue(value);
   }
   else
   {
      return NO;
   }
}

- (void)setNegative:(BOOL)isNegative
{
   CFBooleanRef newValue = isNegative ? kCFBooleanTrue : kCFBooleanFalse;
   [self setObject:(id)newValue forKey:(id)kSecAttrIsNegative];
}

- (NSString *)account
{
   return [self objectForKey:(id)kSecAttrAccount];
}

- (void)setAccount:(NSString *)newAccount
{
   [self setObject:newAccount forKey:(id)kSecAttrAccount];
}

- (NSString *)password
{
   return [self objectForKey:(id)kSecValueData];
}

- (void)setPassword:(NSString *)newPassword
{
   [self setObject:newPassword forKey:(id)kSecValueData];
}

@end
