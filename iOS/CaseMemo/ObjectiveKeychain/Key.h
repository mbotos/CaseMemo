//
//  Key.h
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

#import "KeychainItem.h"

typedef enum
{
   kKeyClassPublic = 0,
   kKeyClassPrivate,
   kKeyClassSymmetric
} KeyClass;

typedef enum
{
   kKeyTypeRSA = 0,
#if !TARGET_IPHONE_SIMULATOR
   kKeyTypeEC
#endif
} KeyType;

@interface Key : KeychainItem
{
}

/*
 Our superclass handles these:
   kSecAttrAccessGroup
   kSecAttrLabel
 
 We handle these:
   kSecAttrKeyClass
   kSecAttrApplicationLabel
   kSecAttrIsPermanent
   kSecAttrApplicationTag
   kSecAttrKeyType
   kSecAttrKeySizeInBits
   kSecAttrEffectiveKeySize
   kSecAttrCanEncrypt
   kSecAttrCanDecrypt
   kSecAttrCanDerive
   kSecAttrCanSign
   kSecAttrCanVerify
   kSecAttrCanWrap
   kSecAttrCanUnwrap
*/

// Specifies the type of cryptographic key
@property (nonatomic, readonly) KeyClass keyClass;

// Contains a label for this item. This attribute is different from the 'label'
// attribute, which is intended to be human-readable. This attribute is used to
// look up a key programmatically; in particular, for keys of class kKeyClassPublic
// and kKeyClassPrivate, the value of this attribute is the hash of the public key.
@property (nonatomic, copy) NSString *applicationLabel;

// Indicates whether this cryptographic key is to be stored permanently
@property (nonatomic, assign, getter=isPermanent) BOOL permanent;

// Contains private tag data
@property (nonatomic, copy) NSData *tag;

// Indicates the algorithm associated with this cryptographic key (see the CSSM_ALGORITHMS
// enumeration in cssmtype.h and “Key Type Value”).
@property (nonatomic, readonly) KeyType keyType;

// Indicates the total number of bits in this cryptographic key. Compare with effectiveKeySize.
@property (nonatomic, readonly) NSUInteger keySizeInBits;

// Indicates the effective number of bits in this cryptographic key. For example,
// a DES key has a keySizeInBits of 64, but an effectiveKeySize of 56 bits.
@property (nonatomic, readonly) NSUInteger effectiveKeySize;

// Indicates whether this cryptographic key can be used to encrypt data
@property (nonatomic, assign) BOOL canEncrypt;

// Indicates whether this cryptographic key can be used to decrypt data
@property (nonatomic, assign) BOOL canDecrypt;

// Indicates whether this cryptographic key can be used to derive another key
@property (nonatomic, assign) BOOL canDerive;

// Indicates whether this cryptographic key can be used to create a digital signature
@property (nonatomic, assign) BOOL canSign;

// Indicates whether this cryptographic key can be used to verify a digital signature
@property (nonatomic, assign) BOOL canVerify;

// Indicates whether this cryptographic key can be used to wrap another key
@property (nonatomic, assign) BOOL canWrap;

// Indicates whether this cryptographic key can be used to unwrap another key
@property (nonatomic, assign) BOOL canUnwrap;

@end
