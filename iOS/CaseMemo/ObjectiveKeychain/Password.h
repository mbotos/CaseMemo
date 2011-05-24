//
//  Password.h
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
//  Common abstract superclass for password-type keychain items.

#import <Foundation/Foundation.h>

#import "KeychainItem.h"

@interface Password : KeychainItem
{
}

// The date the item was created.
@property (readonly) NSDate *creationDate;

// The last time the item was updated.
@property (readonly) NSDate *modificationDate;

// Specifies a user-visible string describing this kind of item (for example,
// "Disk image password").
@property (nonatomic, copy) NSString *userDescription;

// Contains the user-editable comment for this item.
@property (nonatomic, copy) NSString *comment;

// This number is the unsigned integer representation of a four-character
// code (for example, 'aCrt').
@property (nonatomic, assign) NSUInteger creator;

// This number is the unsigned integer representation of a four-character
// code (for example, 'aTyp').
@property (nonatomic, assign) NSUInteger type;

// Whether or not the item is invisible (that is, should not be displayed).
@property (nonatomic, assign, getter=isInvisible) BOOL invisible;

// Indicates whether there is a valid password associated with this keychain item.
// This is useful if your application doesn't want a password for some particular
// service to be stored in the keychain, but prefers that it always be entered by the user.
@property (nonatomic, assign, getter=isNegative) BOOL negative;

// Contains an account name
@property (nonatomic, copy) NSString *account;

// Contains the password
@property (nonatomic, copy) NSString *password;

@end
