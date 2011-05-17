//
//  KeychainItem.h
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

#import <Foundation/Foundation.h>

@interface KeychainItem : NSObject
{
   NSMutableDictionary *mKeychainItemData;
   NSMutableDictionary *mItemQuery;
   
   BOOL mDirty;
}

// Indicates which access group an item is in. Access groups can be used to share
// keychain items among two or more applications. For applications to share a
// keychain item, the applications must have a common access group listed in their
// keychain-access-groups entitlement, and the application adding the shared item
// to the keychain must specify this shared access-group name as the value for this
// key in the dictionary passed to the SecItemAdd function.
//
// An application can be a member of any number of access groups. By default, the
// SecItemUpdate, SecItemDelete, and SecItemCopyMatching functions search all the
// access groups an application is a member of. Include this key in the search
// dictionary for these functions to specify which access group is searched.
//
// A keychain item can be in only a single access group.
@property (nonatomic, copy) NSString *accessGroup;

// The user-visible label for this item.
@property (nonatomic, copy) NSString *label;

// Designated initializer
- (id)initWithLabel:(NSString *)label accessGroup:(NSString *)accessGroup;

// Saves any modifications to the item to the keychain. Note: If you do not call
// this method, any changes made to the item will not be persisted.
- (BOOL)writeToKeychain:(NSError **)error;

- (void)deleteFromKeychain;

@end
