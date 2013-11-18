//
//  TKAURLProtocol.m
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


#import "TKAURLProtocol.h"
static NSURLCredentialPersistence	DefaultCredentialPersistence = NSURLCredentialPersistenceForSession;
static NSString*					TKAURLHeader                 = @"X-TKAURLProtocol";
static NSInteger					RegisterCount				 = 0;

static NSMutableArray*				DownloadRequests			 = nil;
static NSMutableArray*				DownloadDelegates			 = nil;

static NSMutableArray*				LoginRequests				 = nil;
static NSMutableArray*				LoginDelegates			     = nil;

static NSMutableArray*				ObserverRequests			 = nil;
static NSMutableArray*				ObserverDelegates			 = nil;

static NSMutableArray*				SenderRequests		    	 = nil;
static NSMutableArray*				SenderDelegates				 = nil;

static NSMutableArray*				TrustedHosts			     = nil;
static BOOL							TrustSelfSignedCertificates  = NO;
static NSLock*                      VariableLock                 = nil;

@implementation						TKAURLProtocol
@synthesize                         URLConnection;
@synthesize							DownloadDelegate;
@synthesize							ObserverDelegate;
@synthesize							LoginDelegate;
@synthesize							SenderObject;
@synthesize							MainURLRequest;
@synthesize							URLRequest;
@synthesize							URLResponse;
@synthesize							Username;
@synthesize							Password;
@synthesize							IsLoadingMainDocument;
@synthesize							CredentialsPresistance;

//***************************************************************************
//  
//                                 Utility Routines
//
//***************************************************************************
- (void) WaitForCredentialDialog{
	NSDate*               LoopUntil;
	//****************************************************************************
	LoopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
	while ((DialogResult==-1) && ([[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:LoopUntil]))
	{
		LoopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
	}
	//****************************************************************************
}


-(void) MessageBox: (NSString*) Title Description:(NSString *) Text{
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Title
													message:Text
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

//***************************************************************************
//  
//                     UIAlertView Delegate
//
//***************************************************************************
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
	[UsernameField resignFirstResponder];
	[PasswordField resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	if (buttonIndex==1)
	{
		self.Username = UsernameField.text;
		self.Password = PasswordField.text;
//		switch (RememberCredentials.selectedSegmentIndex) {
//			case 0:
//				self.CredentialsPresistance = NSURLCredentialPersistenceNone;
//				break;
//			case 1:
//				self.CredentialsPresistance = NSURLCredentialPersistenceForSession;
//				break;
//			case 2:
//				self.CredentialsPresistance = NSURLCredentialPersistencePermanent;
//				break;
//			default:
//				self.CredentialsPresistance = NSURLCredentialPersistenceForSession;
//				break;
//		}
		[VariableLock lock];
		DefaultCredentialPersistence = CredentialsPresistance;
		[VariableLock unlock];
		DialogResult  = 1;
	}
	if (buttonIndex==0) 
	{
		DialogResult = 0;
	}
	
}

//***************************************************************************
//  
//                     UITextField Delegate
//
//***************************************************************************
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[LoginView dismissWithClickedButtonIndex:1 animated:YES];
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
	return NO;
}

-(void) PresentCredentialDialog{
	LoginView                        = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentication required", @"Basic authorization login and password promt title")
																  message:@""
																 delegate:self 
														cancelButtonTitle:@"Cancel" 
														otherButtonTitles:@"OK", nil];
    [LoginView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
	UsernameField                    = [LoginView textFieldAtIndex:0];
	UsernameField.text               = Username;
	UsernameField.placeholder        = @"Username";
	UsernameField.autocorrectionType = UITextAutocorrectionTypeNo;
	UsernameField.delegate           = self;
//	[UsernameField release];
	
	PasswordField                    = [LoginView textFieldAtIndex:1];
	PasswordField.text               = Password;
	PasswordField.placeholder        = @"Password";
	PasswordField.autocorrectionType = UITextAutocorrectionTypeNo;
 	PasswordField.delegate           = self;
//	[PasswordField release];
	
    // Credenti
//	RememberCredentials                       = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Don't save",@"Temporary",@"Permanent", nil]]; 
//	RememberCredentials.tintColor             = [UIColor colorWithRed:78.0/255.0 green:87.0/255.0 blue:121.0/255.0 alpha:0.0];
//	RememberCredentials.frame                 = CGRectMake(12.0, 120.0, 260.0, 35.0);
//	switch (CredentialsPresistance) {
//		case NSURLCredentialPersistenceNone:
//			RememberCredentials.selectedSegmentIndex  = 0;
//			break;
//		case NSURLCredentialPersistenceForSession:
//			RememberCredentials.selectedSegmentIndex  = 1;
//			break;
//		case NSURLCredentialPersistencePermanent:
//			RememberCredentials.selectedSegmentIndex  = 2;
//			break;	
//		default:
//			RememberCredentials.selectedSegmentIndex  = 1;
//			break;
//	}
//	RememberCredentials.segmentedControlStyle = UISegmentedControlStyleBar;
//	[LoginView addSubview: RememberCredentials];
//	[RememberCredentials release];
	
	// Enable for IPhone
	// CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, 80.0);
	// [LoginView setTransform:transform];
	
	[LoginView show];
	[LoginView release];
	[UsernameField  performSelector:@selector(becomeFirstResponder)
						 withObject:nil
						 afterDelay:0.1];
	
}

//***************************************************************************
//  
//                  TKAURLProtocol Class Methods
//
//***************************************************************************
+ (void)registerProtocol {
	if (!VariableLock) 
	{
		VariableLock = [[NSLock alloc] init];
	}
	[VariableLock lock];
	if (RegisterCount==0)
	{
		[NSURLProtocol registerClass:[self class]];
	}
	RegisterCount++;
	[VariableLock unlock];
}    

+ (void)unregisterProtocol {
	[VariableLock lock];
	RegisterCount--;
	if (RegisterCount==0)
	{
		[NSURLProtocol unregisterClass:[self class]];
	}
	[VariableLock unlock];
}  

+ (void) addDownloadDelegate: (id) delegate ForRequest:(NSURLRequest *) request{
	[VariableLock lock];
    if (DownloadRequests==nil)
	{
		 DownloadRequests = [[NSMutableArray alloc] init];
	}
	if (DownloadDelegates==nil)
	{
		DownloadDelegates = [[NSMutableArray alloc] init];
	}
	[DownloadRequests  addObject: request];
	[DownloadDelegates addObject: delegate];
	[VariableLock unlock];
}

+ (void) removeDownloadDelegateForRequest:(NSURLRequest *) request{
	NSInteger I;
	[VariableLock lock];
	if ((DownloadRequests) && (DownloadDelegates))
	{
		I = [DownloadRequests indexOfObject:request];
		if (I !=  NSNotFound) 
		{
			[DownloadRequests  removeObjectAtIndex:I];
			[DownloadDelegates removeObjectAtIndex:I];
			if (DownloadRequests.count==0)
			{
				[DownloadRequests release];
				DownloadRequests = nil;
			}
			if (DownloadDelegates.count==0)
			{
				[DownloadDelegates release];
				DownloadDelegates = nil;
			}
		}
	}
	[VariableLock unlock];
}

+ (void) addObserverDelegate: (id) delegate ForRequest:(NSURLRequest *) request{
	[VariableLock lock];
    if (ObserverRequests==nil)
	{
		ObserverRequests = [[NSMutableArray alloc] init];
	}
	if (ObserverDelegates==nil)
	{
		ObserverDelegates = [[NSMutableArray alloc] init];
	}
	[ObserverRequests  addObject: request];
	[ObserverDelegates addObject: delegate];
	[VariableLock unlock];
}

+ (void) removeObserverDelegateForRequest:(NSURLRequest *) request{
	NSInteger I;
	[VariableLock lock];
	if ((ObserverRequests) && (ObserverDelegates))
	{
		I = [ObserverRequests indexOfObject:request];
		if (I !=  NSNotFound) 
		{
			[ObserverRequests  removeObjectAtIndex:I];
			[ObserverDelegates removeObjectAtIndex:I];
			if (ObserverRequests.count==0)
			{
				[ObserverRequests release];
				ObserverRequests = nil;
			}
			if (ObserverDelegates.count==0)
			{
				[ObserverDelegates release];
				ObserverDelegates = nil;
			}
		}
	}
	[VariableLock unlock];
}

+ (void) addLoginDelegate: (id) delegate ForRequest:(NSURLRequest *) request{
	[VariableLock lock];
    if (LoginRequests==nil)
	{
		LoginRequests = [[NSMutableArray alloc] init];
	}
	if (LoginDelegates==nil)
	{
		LoginDelegates = [[NSMutableArray alloc] init];
	}
	[LoginRequests  addObject: request];
	[LoginDelegates addObject: delegate];
	[VariableLock unlock];
}

+ (void) removeLoginDelegateForRequest:(NSURLRequest *) request{
	NSInteger I;
	[VariableLock lock];
	if ((LoginRequests) && (LoginDelegates))
	{
		I = [LoginRequests indexOfObject:request];
		if (I !=  NSNotFound) 
		{
			[LoginRequests  removeObjectAtIndex:I];
			[LoginDelegates removeObjectAtIndex:I];
			if (LoginRequests.count==0)
			{
				[LoginRequests release];
				LoginRequests = nil;
			}
			if (LoginDelegates.count==0)
			{
				[LoginDelegates release];
				LoginDelegates = nil;
			}
		}
	}
	[VariableLock unlock];
}

+ (void) addSenderObject: (id) sender  ForRequest:(NSURLRequest *) request{
	[VariableLock lock];
    if (SenderRequests==nil)
	{
		SenderRequests = [[NSMutableArray alloc] init];
	}
	if (SenderDelegates==nil)
	{
		SenderDelegates = [[NSMutableArray alloc] init];
	}
	[SenderRequests  addObject: request];
	[SenderDelegates addObject: sender];
	[VariableLock unlock];
}

+ (void) removeSenderObjectForRequest:(NSURLRequest *) request{
	NSInteger I;
	[VariableLock lock];
	if ((SenderRequests) && (SenderDelegates))
	{
		I = [SenderRequests indexOfObject:request];
		if (I !=  NSNotFound) 
		{
			[SenderRequests  removeObjectAtIndex:I];
			[SenderDelegates removeObjectAtIndex:I];
			if (SenderRequests.count==0)
			{
				[SenderRequests release];
				SenderRequests = nil;
			}
			if (SenderDelegates.count==0)
			{
				[SenderDelegates release];
				SenderDelegates = nil;
			}
		}
	}
	[VariableLock unlock];
}

+ (void) addTrustedHost: (NSString*)HostName{
	[VariableLock lock];
    if (TrustedHosts==nil)
	{
		TrustedHosts = [[NSMutableArray alloc] init];
	}
	[TrustedHosts addObject: HostName];
	[VariableLock unlock];
}

+ (void) removeTrustedHost:(NSString*)HostName{
	NSInteger  X;
	NSString*  Host;
	NSString*  HostNameCopy;
	[VariableLock lock];
	if (TrustedHosts) 
	{
		HostNameCopy = [HostName lowercaseString];
		for (X=0; X < TrustedHosts.count; X++) 
		{
			Host = [[TrustedHosts objectAtIndex:X] lowercaseString];
			if ([Host isEqualToString:HostNameCopy])
			{
				[TrustedHosts removeObjectAtIndex:X];
				if (TrustedHosts.count==0)
				{
					[TrustedHosts release];
					TrustedHosts = nil;
				}
				break;
			}
		}
	}
	[VariableLock unlock];
}

+ (void) setTrustSelfSignedCertificates:(BOOL)Trust{
	[VariableLock lock];
	TrustSelfSignedCertificates = Trust;
	[VariableLock unlock];
}

+ (BOOL) getTrustSelfSignedCertificates{
	[VariableLock lock];
	return TrustSelfSignedCertificates;
	[VariableLock unlock];
}

+ (BOOL) hasDownloadDelegateForRequest:(NSURLRequest*)request
{
	BOOL          Result;
	NSInteger     X;
	NSURLRequest* R;
	
	[VariableLock lock];
	Result = NO;
	if ((DownloadRequests) && (DownloadDelegates))
	{
		for (X = 0; X < DownloadRequests.count; X++) 
		{
			R = [DownloadRequests objectAtIndex:X];
			if ([[request mainDocumentURL] isEqual:[R mainDocumentURL]])
			{
				Result=YES;
				break;
			}
		}
	}
	[VariableLock unlock];
	return Result;
}


+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    if (
		 (
		      ([[[[request URL] scheme] lowercaseString] isEqualToString:@"http"]) 
		   || ([[[[request URL] scheme] lowercaseString] isEqualToString:@"https"]) 
		 )
	     && ([request valueForHTTPHeaderField:TKAURLHeader] == nil) 
		 && ([TKAURLProtocol hasDownloadDelegateForRequest:request])
	   )
    {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

//***************************************************************************
//  
//                  TKAURLProtocol Instance Methods
//
//***************************************************************************
- (id) getDownloadDelegateForRequest:(NSURLRequest*)request
{
	id            Result = nil; 
	NSInteger     X      = 0;
	NSURLRequest* R      = 0;
	[VariableLock lock];
	if ((DownloadRequests) && (DownloadDelegates))
	{
		for (X = 0; X < DownloadRequests.count; X++) 
		{
			R = [DownloadRequests objectAtIndex:X];
			if ([[request URL] isEqual:[R URL]])
			{
				Result = [DownloadDelegates objectAtIndex:X];
				break;
			}
		}
	}
	[VariableLock unlock];
	return Result;
}

- (NSURLRequest*) getMainRequestForRequest:(NSURLRequest*)request
{
	NSInteger     X      = 0;
	NSURLRequest* R      = nil;
	NSURLRequest* Result = nil;
	[VariableLock lock];
	if ((DownloadRequests) && (DownloadDelegates))
	{
		for (X = 0; X < DownloadRequests.count; X++) 
		{
			R = [DownloadRequests objectAtIndex:X];
			if ([[request mainDocumentURL] isEqual:[R mainDocumentURL]])
			{
				Result = [DownloadRequests objectAtIndex:X];
				break;
			}
		}
	}
	[VariableLock unlock];
	return Result;
}

- (id) getObserverDelegateForRequest:(NSURLRequest*)request
{
	id            Result = nil;
	NSInteger     X      = 0;
	NSURLRequest* R      = nil;
	[VariableLock lock];
	if ((ObserverRequests) && (ObserverDelegates))
	{
		for (X = 0; X < ObserverRequests.count; X++) 
		{
			R = [ObserverRequests objectAtIndex:X];
			if ([[request mainDocumentURL] isEqual:[R mainDocumentURL]])
			{
				Result = [ObserverDelegates objectAtIndex:X];
				break;
			}
		}
	}
	[VariableLock unlock];
	return Result;
}

- (id) getLoginDelegateForRequest:(NSURLRequest*)request
{
	id            Result = nil;
	NSInteger     X      = 0;
	NSURLRequest* R      = nil;
	[VariableLock lock];
	if ((LoginRequests) && (LoginDelegates))
	{
		for (X = 0; X < LoginRequests.count; X++) 
		{
			R = [LoginRequests objectAtIndex:X];
			if ([[request mainDocumentURL] isEqual:[R mainDocumentURL]])
			{
				Result = [LoginDelegates objectAtIndex:X];
				break;
			}
		}
	}
	[VariableLock unlock];
	return Result;
}


- (id) getSenderObjectForRequest:(NSURLRequest*)request
{
	id            Result = nil;
	NSInteger     X      = 0;
	NSURLRequest* R      = nil;
	[VariableLock lock];
	if ((SenderRequests) && (SenderDelegates))
	{
		for (X = 0; X < SenderRequests.count; X++) 
		{
			R = [SenderRequests objectAtIndex:X];
			if ([[request mainDocumentURL] isEqual:[R mainDocumentURL]])
			{
				Result = [SenderDelegates objectAtIndex:X];
			}
		}
	}
	[VariableLock unlock];
	return Result;
}

-(id)initWithRequest:(NSURLRequest *)request
      cachedResponse:(NSCachedURLResponse *)cachedResponse
              client:(id <NSURLProtocolClient>)client
{
	NSMutableURLRequest* Request;
	//************************************************
	LoginDialogLock			    = [[NSLock alloc] init];
	//************************************************
    Request = [request mutableCopy];
    [Request setValue:@"" forHTTPHeaderField:TKAURLHeader];
    //************************************************
    self = [super initWithRequest:Request
                   cachedResponse:cachedResponse
                           client:client];
	//************************************************
    if (self) 
	{
		self.Username			    = @""; 
		self.Password	            = @"";
	    self.URLRequest             = Request;	
		self.MainURLRequest         = [self getMainRequestForRequest:request];
		self.DownloadDelegate       = [self getDownloadDelegateForRequest:request];
		self.ObserverDelegate       = [self getObserverDelegateForRequest:request];
		self.LoginDelegate          = [self getLoginDelegateForRequest:request];
		self.SenderObject			= [self getSenderObjectForRequest:request];
		IsLoadingMainDocument       = [MainURLRequest.URL isEqual:[URLRequest URL]];
		[VariableLock lock];
		self.CredentialsPresistance	= DefaultCredentialPersistence;	
		[VariableLock unlock];
    }
	//************************************************
	[Request release];
	//************************************************
	return self;
}

- (void)dealloc
{
	self.URLConnection      = nil; 
	self.MainURLRequest     = nil;
	self.URLRequest			= nil;
	self.URLResponse		= nil;
	self.Username			= nil;
	self.Password			= nil;
	self.DownloadDelegate	= nil;
	self.ObserverDelegate	= nil;
    self.LoginDelegate      = nil;
	self.SenderObject		= nil;
	[LoginDialogLock release];
	[super           dealloc];
}

- (void)startLoading
{
	if (DownloadDelegate)
	{
		if([DownloadDelegate respondsToSelector:@selector(navigationDownloadWillStart:)]) 
		{
			[DownloadDelegate navigationDownloadWillStart: self];
		}
	}
	if (ObserverDelegate)
	{
		if([ObserverDelegate respondsToSelector:@selector(contentDownloadWillStart:)]) 
		{
			[ObserverDelegate contentDownloadWillStart: self];
		} 
	}
    CurrentConnection  = [NSURLConnection connectionWithRequest:self.URLRequest delegate:self];
	self.URLConnection = CurrentConnection;
}

-(void)stopLoading {
	[CurrentConnection cancel];
	self.URLConnection      = nil; 
	self.MainURLRequest     = nil;
	self.URLRequest			= nil;
	self.URLResponse		= nil;
	self.Username			= nil;
	self.Password			= nil;
	self.DownloadDelegate	= nil;
	self.ObserverDelegate	= nil;
    self.LoginDelegate      = nil;
	self.SenderObject		= nil;
}

//***************************************************************************
//  
//                             NSURLRequest Delegate
//
//***************************************************************************
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse{
	NSMutableURLRequest* Request = [[request mutableCopy] autorelease];
	if (redirectResponse)
	{
		[Request setValue:nil forHTTPHeaderField:TKAURLHeader];
		[[self client] URLProtocol:self wasRedirectedToRequest:Request redirectResponse:redirectResponse];	
	}
	self.URLRequest  = Request;
	self.URLResponse = redirectResponse;
	return Request;
}


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{	
	return YES;
}
 

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection{
	return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
	NSURLCredential*   Credential     = nil;
	BOOL               Cancel         = NO;
	BOOL               ShowDialog     = YES;
	AuthenticationOccured             = YES;
	//***********************************************************************************
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"])
	{
		if (TrustSelfSignedCertificates)
		{
			[[challenge sender] useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
		}
		else
		if ([TrustedHosts containsObject:challenge.protectionSpace.host])
		{
			[[challenge sender] useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
		}
		else 
		{
			[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
		}
	}
	//***********************************************************************************
	else 
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodClientCertificate"])
	{
		if (LoginDelegate)
		{
			if([LoginDelegate respondsToSelector:@selector(getCertificateCredential: ForChallenge:)]) 
			{
				Credential = [LoginDelegate getCertificateCredential:self ForChallenge:challenge];		
				if (Credential)
				{
					[[challenge sender] useCredential:Credential forAuthenticationChallenge:challenge];
				}
				else 
				{
					[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
				}

			}
			else 
			{
				[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
			}
		}
		else
		{
			[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
		}
	}
	//***********************************************************************************
	else 
	{
		if (LoginDelegate)
		{
			if([LoginDelegate respondsToSelector:@selector(shouldPresentLoginDialog: CancelAuthentication:)]) 
			{
				ShowDialog = [LoginDelegate shouldPresentLoginDialog:self CancelAuthentication:&Cancel];		
			}
		}
		//***********************************************************************************
		if (ShowDialog) 
		{
			[LoginDialogLock lock];
			DialogResult = -1;
			[self performSelectorOnMainThread:@selector(PresentCredentialDialog) withObject:nil waitUntilDone:YES];
			[self performSelectorOnMainThread:@selector(WaitForCredentialDialog) withObject:nil waitUntilDone:YES];
			switch (DialogResult) 
			{
				case 0:  
				{
					ChallengeCanceled = YES;
					Username          = @"";
					Password          = @"";
					[[challenge sender] cancelAuthenticationChallenge:challenge];
					break;
				}
					
				case 1:	 
				{
					ChallengeCanceled = NO;
					[[challenge sender] useCredential:[NSURLCredential credentialWithUser:Username password:Password persistence:CredentialsPresistance] forAuthenticationChallenge:challenge];
					break;
				}
					
				default: 
				{
					ChallengeCanceled = NO;
					[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
					break; 
				}
			}
			[LoginDialogLock unlock];
		}
		else 
		{
			if (Cancel)
			{
				ChallengeCanceled = YES;
				[[challenge sender] cancelAuthenticationChallenge:challenge];
			}
			else
				if ((Username) && (Password))
				{
					if ((Username.length != 0) && (Password.length != 0))
					{
						ChallengeCanceled = NO;
						[[challenge sender] useCredential:[NSURLCredential credentialWithUser:Username password:Password persistence:CredentialsPresistance] forAuthenticationChallenge:challenge];
					}
					else 
					{
						ChallengeCanceled = NO;
						[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
					}
				}
				else 
				{
					Username          = @"";
					Password          = @"";
				}
		}
	}
	//***********************************************************************************
	[[self client] URLProtocol:self didReceiveAuthenticationChallenge: challenge];
}


- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
	ChallengeCanceled           = YES;
	Username                    = @"";
	Password                    = @"";
	[[self client] URLProtocol:self didCancelAuthenticationChallenge: challenge];
}


- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
	if (cachedResponse) 
	{
		[[self client] URLProtocol:self cachedResponseIsValid:cachedResponse];
	}
	return cachedResponse;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	BOOL      ShowDialog             = YES;
	self.URLResponse				 = response;
	if (![[URLResponse MIMEType] compare:@"text/html" options:NSCaseInsensitiveSearch] == NSOrderedSame)
	{
		if (DownloadDelegate) 
		{
			if (IsLoadingMainDocument)
			{
				if([DownloadDelegate respondsToSelector:@selector(presentDownloadDialog:)]) 
				{
					ShowDialog = [DownloadDelegate presentDownloadDialog: self];
				}
			}
			else 
			{
			   ShowDialog = NO;	
			}

		}
		if (ObserverDelegate)
		{
			if([ObserverDelegate respondsToSelector:@selector(contentDownloadStarted:)]) 
			{
				[ObserverDelegate contentDownloadStarted: self];
			} 
		}
	}
	else 
	{
		ShowDialog = NO;
	}
	if (ShowDialog)
	{
		
	}
	else
	{
		if (DownloadDelegate)
		{
			if([DownloadDelegate respondsToSelector:@selector(navigationDownloadStarted:)]) 
			{
				[DownloadDelegate navigationDownloadStarted: self];
			}
		}
		if (ObserverDelegate)
		{
			if([ObserverDelegate respondsToSelector:@selector(contentDownloadStarted:)]) 
			{
				[ObserverDelegate contentDownloadStarted: self];
			}
		}
	}
	[[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (DownloadDelegate)
	{
		if([DownloadDelegate respondsToSelector:@selector(navigationDownloadDataReceived: Data:)]) 
		{
			[DownloadDelegate navigationDownloadDataReceived: self Data:data];
		}
	}
	if (ObserverDelegate)
	{
		if([ObserverDelegate respondsToSelector:@selector(contentDownloadDataReceived: Data:)]) 
		{
			[ObserverDelegate contentDownloadDataReceived:self Data:data];
		}
	}
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (DownloadDelegate)
	{
		if([DownloadDelegate respondsToSelector:@selector(navigationDownloadFailed: WithError:)]) 
		{
			[DownloadDelegate navigationDownloadFailed: self WithError: error];
		}
	}
	if (ObserverDelegate)
	{
		if([ObserverDelegate respondsToSelector:@selector(contentDownloadFailed: WithError:)]) 
		{
			[ObserverDelegate contentDownloadFailed:self WithError:error];
		}
	}
    [[self client] URLProtocol:self didFailWithError:error];
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (DownloadDelegate)
	{
		if([DownloadDelegate respondsToSelector:@selector(navigationDownloadFinished:)]) 
		{
			[DownloadDelegate navigationDownloadFinished: self];
		}
	}
	if (ObserverDelegate)
	{
		if([ObserverDelegate respondsToSelector:@selector(contentDownloadFinished:)]) 
		{
			[ObserverDelegate contentDownloadFinished:self];
		}
	}
    [[self client] URLProtocolDidFinishLoading:self];
}

 
@end

