//
//  Certificate.h
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

@interface Certificate : KeychainItem
{
}

/*
 These are handled by our superclass:
   kSecAttrAccessGroup
   kSecAttrLabel
 
 We handle these:
   kSecAttrCertificateType
   kSecAttrCertificateEncoding
   kSecAttrSubject
   kSecAttrIssuer
   kSecAttrSerialNumber
   kSecAttrSubjectKeyID
   kSecAttrPublicKeyHash
*/

// Denotes the certificate type (see the CSSM_CERT_TYPE enumeration in cssmtype.h):
//   CSSM_CERT_UNKNOWN =					0x00,
//   CSSM_CERT_X_509v1 =					0x01,
//   CSSM_CERT_X_509v2 =					0x02,
//   CSSM_CERT_X_509v3 =					0x03,
//   CSSM_CERT_PGP =                   0x04,
//   CSSM_CERT_SPKI =                  0x05,
//   CSSM_CERT_SDSIv1 =                0x06,
//   CSSM_CERT_Intel =                 0x08,
//   CSSM_CERT_X_509_ATTRIBUTE =			0x09, /* X.509 attribute cert */
//   CSSM_CERT_X9_ATTRIBUTE =          0x0A, /* X9 attribute cert */
//   CSSM_CERT_TUPLE =                 0x0B,
//   CSSM_CERT_ACL_ENTRY =             0x0C,
//   CSSM_CERT_MULTIPLE =              0x7FFE,
//   CSSM_CERT_LAST =                  0x7FFF,
//   /* Applications wishing to define their own custom certificate
//    type should define and publicly document a uint32 value greater
//    than the CSSM_CL_CUSTOM_CERT_TYPE */
//   CSSM_CL_CUSTOM_CERT_TYPE =			0x08000
@property (readonly) NSUInteger certificateType;

// Denotes the certificate encoding (see the CSSM_CERT_ENCODING enumeration in cssmtype.h):
//   CSSM_CERT_ENCODING_UNKNOWN =      0x00,
//   CSSM_CERT_ENCODING_CUSTOM =       0x01,
//   CSSM_CERT_ENCODING_BER =          0x02,
//   CSSM_CERT_ENCODING_DER =          0x03,
//   CSSM_CERT_ENCODING_NDR =          0x04,
//   CSSM_CERT_ENCODING_SEXPR =        0x05,
//   CSSM_CERT_ENCODING_PGP =          0x06,
//   CSSM_CERT_ENCODING_MULTIPLE =     0x7FFE,
//   CSSM_CERT_ENCODING_LAST =         0x7FFF,
//	  /* Applications wishing to define their own custom certificate
//    encoding should create a uint32 value greater than the
//    CSSM_CL_CUSTOM_CERT_ENCODING */
//	  CSSM_CL_CUSTOM_CERT_ENCODING =    0x8000
@property (readonly) NSUInteger certificateEncoding;

// Contains the X.500 subject name of the certificate
@property (readonly) NSData *subjectName;

// Contains the X.500 issuer name of the certificate
@property (readonly) NSData *issuer;

// Contains the serial number data of the certificate
@property (readonly) NSData *serialNumber;

// Contains the subject key ID of the certificate
@property (readonly) NSData *subjectKeyID;

// Contains the hash of the certificate's public key
@property (readonly) NSData *publicKeyHash;

@end
