//
//  KeychainItem.m
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

#import "KeychainItem.h"

#import <Security/Security.h>

#import "KeychainItemSubclass.h"

@implementation KeychainItem

@dynamic accessGroup;
@dynamic label;

// TODO: Custom search query attributes per class

- (id)init
{
   return [self initWithLabel:nil accessGroup:nil];
}

- (id)initWithLabel:(NSString *)label accessGroup:(NSString *)accessGroup
{
   if (self = [super init])
   {
      // Begin Keychain search setup.
      mItemQuery = [[NSMutableDictionary alloc] init];
      
      [mItemQuery setObject:(id)[self classCode] forKey:(id)kSecClass];
      [mItemQuery setObject:label forKey:(id)kSecAttrLabel];
      
      // The keychain access group attribute determines if this item can be shared
      // amongst multiple apps whose code signing entitlements contain the same keychain access group.
      if (accessGroup != nil)
      {
#if TARGET_IPHONE_SIMULATOR
         // Ignore the access group if running on the iPhone simulator.
         // 
         // Apps that are built for the simulator aren't signed, so there's no keychain access group
         // for the simulator to check. This means that all apps can see all keychain items when run
         // on the simulator.
         //
         // If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
         // simulator will return -25243 (errSecNoAccessForItem).
#else           
         [mItemQuery setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
#endif
      }
      
      // Use the proper search constants, return only the attributes of the first match.
      [mItemQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
      [mItemQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
      
      NSDictionary *tempQuery = [NSDictionary dictionaryWithDictionary:mItemQuery];
      NSMutableDictionary *outDictionary = nil;
      
      if (!SecItemCopyMatching((CFDictionaryRef)tempQuery, (CFTypeRef *)&outDictionary) == noErr)
      {
         // Stick these default values into keychain item if nothing found.
         [self resetKeychainItem];
         
         // Add the generic attribute and the keychain access group.
         self.label = label;
         
         if (accessGroup != nil)
         {
#if TARGET_IPHONE_SIMULATOR
            // Ignore the access group if running on the iPhone simulator.
            // 
            // Apps that are built for the simulator aren't signed, so there's no keychain access group
            // for the simulator to check. This means that all apps can see all keychain items when run
            // on the simulator.
            //
            // If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
            // simulator will return -25243 (errSecNoAccessForItem).
#else           
            self.accessGroup = accessGroup;
#endif
         }
      }
      else
      {
         // Load the saved data from the Keychain.
         mKeychainItemData = [[self secItemFormatToDictionary:outDictionary] retain];
      }
      
      [outDictionary release];
   }
   
   return self;
}

- (void)dealloc
{
   [mKeychainItemData release];
   [mItemQuery release];
   
   [super dealloc];
}


#pragma mark -

- (BOOL)writeToKeychain:(NSError **)error
{
   if (!mDirty)
   {
      return NO;
   }
   
   NSDictionary *attributes = NULL;
   NSMutableDictionary *updateItem = NULL;
   OSStatus result;
   
   // See if the item already exists in the Keychain
   result = SecItemCopyMatching((CFDictionaryRef)mItemQuery, (CFTypeRef *)&attributes);
   if (result == noErr)
   {
      // First we need the attributes from the Keychain.
      updateItem = [NSMutableDictionary dictionaryWithDictionary:attributes];
      
      // Second we need to add the appropriate search key/values.
      [updateItem setObject:[mItemQuery objectForKey:(id)kSecClass] forKey:(id)kSecClass];
      
      // Lastly, we need to set up the updated attribute list, being careful to remove the class.
      NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat:mKeychainItemData];
      [tempCheck removeObjectForKey:(id)kSecClass];
      
#if TARGET_IPHONE_SIMULATOR
      // Remove the access group if running on the iPhone simulator.
      // 
      // Apps that are built for the simulator aren't signed, so there's no keychain access group
      // for the simulator to check. This means that all apps can see all keychain items when run
      // on the simulator.
      //
      // If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
      // simulator will return -25243 (errSecNoAccessForItem).
      //
      // The access group attribute will be included in items returned by SecItemCopyMatching,
      // which is why we need to remove it before updating the item.
      [tempCheck removeObjectForKey:(id)kSecAttrAccessGroup];
#endif
      
      // An implicit assumption is that you can only update a single item at a time.
      result = SecItemUpdate((CFDictionaryRef)updateItem, (CFDictionaryRef)tempCheck);
      NSAssert(result == noErr, @"Couldn't update the Keychain Item.");
   }
   else
   {
      // No existing item found; add the new one.
      result = SecItemAdd((CFDictionaryRef)[self dictionaryToSecItemFormat:mKeychainItemData], NULL);
      NSAssert(result == noErr, @"Couldn't add the Keychain Item.");
   }
   
   mDirty = NO;
   
   return YES;
}

- (void)deleteFromKeychain
{
   if (mKeychainItemData == nil)
   {
      return;
   }
   
   OSStatus junk = noErr;
   NSMutableDictionary *tempDictionary = [self dictionaryToSecItemFormat:mKeychainItemData];
   junk = SecItemDelete((CFDictionaryRef)tempDictionary);
   NSAssert(junk == noErr || junk == errSecItemNotFound, @"Problem deleting keychain item.");
}

- (void)resetKeychainItem
{
   if (mKeychainItemData == nil)
   {
      mKeychainItemData = [[NSMutableDictionary alloc] init];
   }
   else if (mKeychainItemData != nil)
   {
      [self deleteFromKeychain];
   }
   
   // Default attributes for keychain item
   [mKeychainItemData setObject:@"" forKey:(id)kSecAttrLabel];
}

- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert
{
   // The assumption is that this method will be called with a properly populated dictionary
   // containing all the right key/value pairs for a SecItem.
   
   // Create a dictionary to return populated with the attributes and data.
   NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];
   
   // Add the class attribute.
   [returnDictionary setObject:(id)[self classCode] forKey:(id)kSecClass];
   
   return returnDictionary;
}

- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert
{
   // The assumption is that this method will be called with a properly populated
   // dictionary containing all the right key/value pairs for the UI element.
   
   // Create a dictionary to return populated with the attributes and data.
   NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];
   
   // Add the proper search key and class attribute.
   [returnDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
   [returnDictionary setObject:(id)[self classCode] forKey:(id)kSecClass];
   
   // Acquire the item data from the attributes.
   NSData *itemData = NULL;
   
   if (SecItemCopyMatching((CFDictionaryRef)returnDictionary, (CFTypeRef *)&itemData) == noErr)
   {
      // Remove the search, class, and identifier key/value, we don't need them anymore.
      [returnDictionary removeObjectForKey:(id)kSecReturnData];
      
      [returnDictionary setObject:itemData forKey:(id)kSecValueData];      
   }
   else
   {
      // Don't do anything if nothing is found.
      NSAssert(NO, @"Serious error, no matching item found in the keychain.\n");
   }
   
   [itemData release];
   
   return returnDictionary;
}


#pragma mark -
#pragma mark Subclass Stubs

- (CFTypeRef)classCode
{
   [NSException raise:@"OKSubclassMethodImplementationMissingException"
               format:@"Abstract superclass 'KeychainItem' does not implement 'classCode.'" \
                      "It must be implemented by the subclass."];
   
   return nil;
}


#pragma mark -
#pragma mark Properties

- (id)objectForKey:(id)key
{
   return [mKeychainItemData objectForKey:key];
}

- (void)setObject:(id)object forKey:(id)key
{
   mDirty = YES;
   [mKeychainItemData setObject:object forKey:key];
}

- (NSString *)accessGroup
{
   return [mKeychainItemData objectForKey:(id)kSecAttrAccessGroup];
}

- (void)setAccessGroup:(NSString *)newGroup
{
   [mKeychainItemData setObject:newGroup forKey:(id)kSecAttrAccessGroup];
}

- (NSString *)label
{
   return [mKeychainItemData objectForKey:(id)kSecAttrLabel];
}

- (void)setLabel:(NSString *)newLabel
{
   [mKeychainItemData setObject:newLabel forKey:(id)kSecAttrLabel];
}

@end
