//
//  InternetPassword.h
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

#import "Password.h"

typedef enum
{
   kNetworkProtocolFTP = 0,
   kNetworkProtocolFTPAccount,
   kNetworkProtocolHTTP,
   kNetworkProtocolIRC,
   kNetworkProtocolNNTP,
   kNetworkProtocolPOP3,
   kNetworkProtocolSMTP,
   kNetworkProtocolSOCKS,
   kNetworkProtocolIMAP,
   kNetworkProtocolLDAP,
   kNetworkProtocolAppleTalk,
   kNetworkProtocolAFP,
   kNetworkProtocolTelnet,
   kNetworkProtocolSSH,
   kNetworkProtocolFTPS,
   kNetworkProtocolHTTPS,
   kNetworkProtocolHTTPProxy,
   kNetworkProtocolHTTPSProxy,
   kNetworkProtocolFTPProxy,
   kNetworkProtocolSMB,
   kNetworkProtocolRTSP,
   kNetworkProtocolRTSPProxy,
   kNetworkProtocolDAAP,
   kNetworkProtocolEPPC,
   kNetworkProtocolIPP,
   kNetworkProtocolNNTPS,
   kNetworkProtocolLDAPS,
   kNetworkProtocolTelnetS,
   kNetworkProtocolIMAPS,
   kNetworkProtocolIRCS,
   kNetworkProtocolPOP3S
} NetworkProtocol;

typedef enum
{
   kAuthenticationTypeNTLM = 0,
   kAuthenticationTypeMSN,
   kAuthenticationTypeDPA,
   kAuthenticationTypeRPA,
   kAuthenticationTypeHTTPBasic,
   kAuthenticationTypeHTTPDigest,
   kAuthenticationTypeHTMLForm,
   kAuthenticationTypeDefault
} AuthenticationType;

@interface InternetPassword : Password
{
}

/*
 All of these attributes are handled by our superclass:
   kSecAttrAccessGroup
   kSecAttrCreationDate
   kSecAttrModificationDate
   kSecAttrDescription
   kSecAttrComment
   kSecAttrCreator
   kSecAttrType
   kSecAttrLabel
   kSecAttrIsInvisible
   kSecAttrIsNegative
   kSecAttrAccount
 
 We handle these:
   kSecAttrSecurityDomain
   kSecAttrServer
   kSecAttrProtocol
   kSecAttrAuthenticationType
   kSecAttrPort
   kSecAttrPath
*/

// Represents the Internet security domain
@property (nonatomic, copy) NSString *securityDomain;

// Contains the server's domain name or IP address
@property (nonatomic, copy) NSString *server;

// Denotes the protocol for this item
@property (nonatomic, assign) NetworkProtocol protocol;

// Denotes the authentication scheme for this item
@property (nonatomic, assign) AuthenticationType authenticationType;

// Represents an Internet port number
@property (nonatomic, assign) NSUInteger port;

// Represents a path, typically the path component of the URL
@property (nonatomic, copy) NSString *path;

@end
