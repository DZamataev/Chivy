//
//  TKAURLProtocol.h
//  Version 2.0
//  Created by Kiril Antonov on 11/9/10.
//
//  Copyright (c) 2010 Kiril Antonov
// ================================================================================
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
// 
// ================================================================================


#import <Foundation/Foundation.h>
@class TKAURLProtocol;
@protocol TKAURLProtocolDelegate
@optional

// This delegates are called when internal NSURLConnection receives an authentication challenge
- (BOOL)             shouldPresentLoginDialog: (TKAURLProtocol*) urlProtocol CancelAuthentication: (BOOL*) cancel;
- (NSURLCredential*) getCertificateCredential: (TKAURLProtocol*) urlProtocol ForChallenge:         (NSURLAuthenticationChallenge *)challenge;

// These delegates are called only when user click a link or enter URL or get/post data in a form
- (BOOL) presentDownloadDialog	        : (TKAURLProtocol*) urlProtocol;
- (void) navigationDownloadWillStart    : (TKAURLProtocol*) urlProtocol;
- (void) navigationDownloadStarted		: (TKAURLProtocol*) urlProtocol;
- (void) navigationDownloadDataReceived	: (TKAURLProtocol*) urlProtocol Data      : (NSData*)data;
- (void) navigationDownloadFinished		: (TKAURLProtocol*) urlProtocol;
- (void) navigationDownloadFailed		: (TKAURLProtocol*) urlProtocol WithError : (NSError*) error;

// These delegates are called for html files and all objects inside them like images/css etc.
- (void) contentDownloadWillStart       : (TKAURLProtocol*) urlProtocol;
- (void) contentDownloadStarted			: (TKAURLProtocol*) urlProtocol;
- (void) contentDownloadDataReceived	: (TKAURLProtocol*) urlProtocol Data:(NSData*)data;
- (void) contentDownloadFinished		: (TKAURLProtocol*) urlProtocol;
- (void) contentDownloadFailed			: (TKAURLProtocol*) urlProtocol WithError : (NSError*) error;
@end

@interface TKAURLProtocol : NSURLProtocol <UIAlertViewDelegate, UITextFieldDelegate>{
	@private
		NSURLConnection*            CurrentConnection;
		UIAlertView*				LoginView;
		UITextField*				UsernameField;
		UITextField*				PasswordField;
		NSLock*						LoginDialogLock;
		NSInteger					DialogResult;
		BOOL						AuthenticationOccured;    
		BOOL						ChallengeCanceled;
	@protected
	    NSURLConnection*            URLConnection;
		NSURLRequest*               MainURLRequest;
		NSURLRequest*				URLRequest;
		NSURLResponse*				URLResponse;
		NSString*					Username;
		NSString*					Password;
	    BOOL						IsLoadingMainDocument;
		NSURLCredentialPersistence	CredentialsPresistance;          
		id							DownloadDelegate;
		id                          ObserverDelegate;
	    id                          LoginDelegate;
		id                          SenderObject;
   @public
}
//***********************************************************************************
@property (retain)    NSURLConnection*              URLConnection;
@property (retain)    NSURLRequest*					MainURLRequest;
@property (retain)    NSURLRequest*					URLRequest;
@property (retain)    NSURLResponse*				URLResponse;
@property (retain)    NSString*						Username;
@property (retain)    NSString*						Password;
@property (readonly)  BOOL						    IsLoadingMainDocument;
@property (readwrite) NSURLCredentialPersistence	CredentialsPresistance;
@property (retain)    id							DownloadDelegate;
@property (retain)    id							ObserverDelegate;
@property (retain)    id							LoginDelegate;
@property (retain)    id							SenderObject;
//***********************************************************************************
+ (void) registerProtocol;
+ (void) unregisterProtocol;
+ (void) setTrustSelfSignedCertificates:(BOOL)Trust;
+ (BOOL) getTrustSelfSignedCertificates;
+ (void) addTrustedHost: (NSString*)HostName;
+ (void) removeTrustedHost:(NSString*)HostName;	
+ (void) addDownloadDelegate: (id) delegate ForRequest:(NSURLRequest *) request;
+ (void) removeDownloadDelegateForRequest:(NSURLRequest *) request;
+ (void) addObserverDelegate: (id) delegate ForRequest:(NSURLRequest *) request;
+ (void) removeObserverDelegateForRequest:(NSURLRequest *) request;
+ (void) addLoginDelegate: (id) delegate ForRequest:(NSURLRequest *) request;
+ (void) removeLoginDelegateForRequest:(NSURLRequest *) request;
+ (void) addSenderObject: (id) sender ForRequest:(NSURLRequest *) request;
+ (void) removeSenderObjectForRequest:(NSURLRequest *) request;
//***********************************************************************************
@end
