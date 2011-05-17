//
//  InternetPassword.m
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

#import "InternetPassword.h"

#import <Security/Security.h>

#import "KeychainItemSubclass.h"

@interface InternetPassword(PrivateMethods)

@property (nonatomic, readonly) NSArray *protocols;
@property (nonatomic, readonly) NSArray *authenticationTypes;

@end


#pragma mark -

@implementation InternetPassword

@dynamic securityDomain;
@dynamic server;
@dynamic protocol;
@dynamic authenticationType;
@dynamic port;
@dynamic path;

- (CFTypeRef)classCode
{
   return kSecClassInternetPassword;
}


#pragma mark -
#pragma mark Properties

- (NSString *)securityDomain
{
   return [self objectForKey:(id)kSecAttrSecurityDomain];
}

- (void)setSecurityDomain:(NSString *)newDomain
{
   [self setObject:newDomain forKey:(id)kSecAttrSecurityDomain];
}

- (NSString *)server
{
   return [self objectForKey:(id)kSecAttrServer];
}

- (void)setServer:(NSString *)newServer
{
   [self setObject:newServer forKey:(id)kSecAttrServer];
}

- (NetworkProtocol)protocol
{
   CFTypeRef protocolValue = [self objectForKey:(id)kSecAttrProtocol];
   return [self.protocols indexOfObject:(id)protocolValue];
}

- (void)setProtocol:(NetworkProtocol)newProtocol
{
   CFTypeRef protocolValue = [self.protocols objectAtIndex:newProtocol];
   [self setObject:(id)protocolValue forKey:(id)kSecAttrProtocol];
}

- (AuthenticationType)authenticationType
{
   CFTypeRef authType = [self objectForKey:(id)kSecAttrAuthenticationType];
   return [self.authenticationTypes indexOfObject:(id)authType];
}

- (void)setAuthenticationType:(AuthenticationType)newAuthType
{
   CFTypeRef authType = [self.authenticationTypes objectAtIndex:newAuthType];
   [self setObject:(id)authType forKey:(id)kSecAttrAuthenticationType];
}

- (NSUInteger)port
{
   return [[self objectForKey:(id)kSecAttrPort] unsignedIntegerValue];
}

- (void)setPort:(NSUInteger)newPort
{
   [self setObject:[NSNumber numberWithUnsignedInteger:newPort]
            forKey:(id)kSecAttrPort];
}

- (NSString *)path
{
   return [self objectForKey:(id)kSecAttrPath];
}

- (void)setPath:(NSString *)newPath
{
   [self setObject:newPath forKey:(id)kSecAttrPath];
}

@end


#pragma mark -

@implementation InternetPassword(PrivateMethods)

@dynamic protocols;
@dynamic authenticationTypes;

- (NSArray *)protocols
{
   static NSArray *protocols = nil;
   
   if (protocols == nil)
   {
      protocols = [[NSArray alloc] initWithObjects:
                   (id)kSecAttrProtocolFTP,
                   (id)kSecAttrProtocolFTPAccount,
                   (id)kSecAttrProtocolHTTP,
                   (id)kSecAttrProtocolIRC,
                   (id)kSecAttrProtocolNNTP,
                   (id)kSecAttrProtocolPOP3,
                   (id)kSecAttrProtocolSMTP,
                   (id)kSecAttrProtocolSOCKS,
                   (id)kSecAttrProtocolIMAP,
                   (id)kSecAttrProtocolLDAP,
                   (id)kSecAttrProtocolAppleTalk,
                   (id)kSecAttrProtocolAFP,
                   (id)kSecAttrProtocolTelnet,
                   (id)kSecAttrProtocolSSH,
                   (id)kSecAttrProtocolFTPS,
                   (id)kSecAttrProtocolHTTPS,
                   (id)kSecAttrProtocolHTTPProxy,
                   (id)kSecAttrProtocolHTTPSProxy,
                   (id)kSecAttrProtocolFTPProxy,
                   (id)kSecAttrProtocolSMB,
                   (id)kSecAttrProtocolRTSP,
                   (id)kSecAttrProtocolRTSPProxy,
                   (id)kSecAttrProtocolDAAP,
                   (id)kSecAttrProtocolEPPC,
                   (id)kSecAttrProtocolIPP,
                   (id)kSecAttrProtocolNNTPS,
                   (id)kSecAttrProtocolLDAPS,
                   (id)kSecAttrProtocolTelnetS,
                   (id)kSecAttrProtocolIMAPS,
                   (id)kSecAttrProtocolIRCS,
                   (id)kSecAttrProtocolPOP3S, nil];
   }
   
   return protocols;
}

- (NSArray *)authenticationTypes
{
   static NSArray *authenticationTypes = nil;
   
   if (authenticationTypes == nil)
   {
      authenticationTypes = [[NSArray alloc] initWithObjects:
                             (id)kSecAttrAuthenticationTypeNTLM,
                             (id)kSecAttrAuthenticationTypeDPA,
                             (id)kSecAttrAuthenticationTypeRPA,
                             (id)kSecAttrAuthenticationTypeHTTPBasic,
                             (id)kSecAttrAuthenticationTypeHTTPDigest,
                             (id)kSecAttrAuthenticationTypeHTMLForm,
                             (id)kSecAttrAuthenticationTypeDefault, nil];
   }
   
   return authenticationTypes;
}

@end
