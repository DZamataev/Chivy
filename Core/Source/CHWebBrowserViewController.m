//
//  CHWebBrowserViewController.m
//  Chivy
//
//  Created by Denis Zamataev on 10/31/13.
//  Copyright (c) 2013 Denis Zamataev. All rights reserved.
//

#import "CHWebBrowserViewController.h"
#import "CHScrollingInspector.h"
#import "DZScrollingInspector.h"

enum actionSheetButtonIndex {
	kSafariButtonIndex,
	kChromeButtonIndex,
};

@interface CHWebBrowserViewController ()

@end

@implementation CHWebBrowserViewController

+ (void)openWebBrowserControllerModallyWithUrl:(NSString*)urlString animated:(BOOL)animated completion:(void (^)(void))completion {
    CHWebBrowserViewController *webBrowserController = [[CHWebBrowserViewController alloc] initWithNibName:[CHWebBrowserViewController defaultNibFileName]
                                                                                                    bundle:nil];
    webBrowserController.requestUrl = urlString;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = window.rootViewController;
    [rootViewController presentViewController:webBrowserController animated:animated completion:completion];
}

+ (id)initWithDefaultNib
{
    return [CHWebBrowserViewController initWithDefaultNibAndRequestUrl:nil];
}

+ (id)initWithDefaultNibAndRequestUrl:(NSString*)requestUrl
{
    CHWebBrowserViewController *webBrowserController = [[CHWebBrowserViewController alloc] initWithNibName:[CHWebBrowserViewController defaultNibFileName]
                                                                                                    bundle:nil];
    webBrowserController.requestUrl = requestUrl;
    return webBrowserController;
}

+ (NSString*)defaultNibFileName {
    return @"CHWebBrowserViewController";
}

- (id)init {
    NSAssert(FALSE, @"Init not implemented, use initWithNibName instead");
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.wasOpenedModally = [self isModal];
    if ([self isModal]) {
    }
    else {

        [self.localTitleView removeFromSuperview];
        self.navigationItem.titleView = self.localTitleView;
        [self.localNavigationBar removeFromSuperview];
        //self.localNavigationBar = nil;
    }
    
    [self updateInsets];
    
    [self performSelector:@selector(createScrollingInspectors) withObject:Nil afterDelay:0.1f];
    
    if (_requestUrl) {
        [_webView loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:_requestUrl]]];
    }
}

- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || self.navigationController.presentingViewController.presentedViewController == self.navigationController
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

- (void)setRequestUrl:(NSString *)urlToLoad
{
    _requestUrl = urlToLoad;
}

- (NSString*)requestUrl
{
    return _requestUrl;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scrolling inspectors related methods

- (void)createScrollingInspectors
{
    UINavigationBar *topBar = self.wasOpenedModally ? self.localNavigationBar : self.navigationController.navigationBar;
    self.navBarYPositionInspector = [[CHScrollingInspector alloc] initWithObservedScrollView:_webView.scrollView
                                                                   andOffsetKeyPath:@"y"
                                                                    andInsetKeypath:@"top"
                                                                          andTarget:topBar
                                                                              andSetterBlock:^void(NSObject *target, float newValue) {
                                                                                  NSLog(@"setting frame %f", newValue);
                                                                        CGRect frame = ((UINavigationBar*)target).frame;
                                                                        ((UINavigationBar*)target).frame = CGRectMake(frame.origin.x, newValue, frame.size.width, frame.size.height);
                                                                    } andGetterBlock:^float(NSObject *target) {
                                                                        return ((UINavigationBar*)target).frame.origin.y;
                                                                    } andLimits:DZScrollingInspectorTwoOrientationsLimitsMake(topBar.frame.origin.y,
                                                                                                                              topBar.frame.origin.y-topBar.frame.size.height,
                                                                                                                              topBar.frame.origin.y,
                                                                                                                              topBar.frame.origin.y-topBar.frame.size.height)];
    
    self.navBarContentAlphaInspector = [[CHScrollingInspector alloc] initWithObservedScrollView:_webView.scrollView
                                                                            andOffsetKeyPath:@"y"
                                                                             andInsetKeypath:@"top"
                                                                                   andTarget:self.localTitleView
                                                                              andSetterBlock:^void(NSObject *target, float newValue) {
                                                                                  NSLog(@"setting %f", newValue);
                                                                                  float newAlpha = newValue / topBar.frame.size.height;
                                                                                  ((UIView*)target).alpha = newAlpha;
                                                                                  UIColor *tint = self.dismissButton.tintColor;
                                                                                  float red, green, blue, oldAlpha;
                                                                                  [tint getRed:&red green:&green blue:&blue alpha:&oldAlpha];
                                                                                  self.dismissButton.tintColor = [UIColor colorWithRed:red green:green blue:blue alpha:newAlpha];
                                                                              } andGetterBlock:^float(NSObject *target) {
                                                                                  return ((UIView*)target).alpha * topBar.frame.size.height;
                                                                              } andLimits:DZScrollingInspectorTwoOrientationsLimitsMake(topBar.frame.size.height,
                                                                                                                                        0,
                                                                                                                                        topBar.frame.size.height,
                                                                                                                                        0)];
    
    self.toolbarYPositionInspector = [[CHScrollingInspector alloc] initWithObservedScrollView:_webView.scrollView
                                                                            andOffsetKeyPath:@"y"
                                                                             andInsetKeypath:@"top"
                                                                                   andTarget:self.bottomToolbar
                                                                              andSetterBlock:^void(NSObject *target, float newValue) {
                                                                                  CGRect frame = ((UIToolbar*)target).frame;
                                                                                  ((UIToolbar*)target).frame = CGRectMake(frame.origin.x, newValue, frame.size.width, frame.size.height);
                                                                              } andGetterBlock:^float(NSObject *target) {
                                                                                  return ((UIToolbar*)target).frame.origin.y;
                                                                              } andLimits:DZScrollingInspectorTwoOrientationsLimitsMake(_bottomToolbar.frame.origin.y, _bottomToolbar.frame.origin.y+_bottomToolbar.frame.size.height, _bottomToolbar.frame.origin.y, _bottomToolbar.frame.origin.y+_bottomToolbar.frame.size.height)];
}

#pragma mark - View state related methods

- (void)toggleBackForwardButtons {
    _navigateBackButton.enabled = _webView.canGoBack;
    _navigateForwardButton.enabled = _webView.canGoForward;
}

- (void)updateInsets
{
    _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(66, 0, 44, 0);
    _webView.scrollView.contentInset = UIEdgeInsetsMake(66, 0, 44, 0);

}


#pragma mark - Action Sheet

- (void)showActionSheet {
    NSString *urlString = @"";
    NSURL* url = [_webView.request URL];
    urlString = [url absoluteString];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = urlString;
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", nil)];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]]) {
        // Chrome is installed, add the option to open in chrome.
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Chrome", nil)];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [actionSheet showFromToolbar:_bottomToolbar];
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) return;
    
    NSURL *theURL = [_webView.request URL];
    if (theURL == nil || [theURL isEqual:[NSURL URLWithString:@""]]) {
        theURL = [NSURL URLWithString:_requestUrl];
    }
    
    if (buttonIndex == kSafariButtonIndex) {
        [[UIApplication sharedApplication] openURL:theURL];
    }
    else if (buttonIndex == kChromeButtonIndex) {
        NSString *scheme = theURL.scheme;
        
        // Replace the URL Scheme with the Chrome equivalent.
        NSString *chromeScheme = nil;
        if ([scheme isEqualToString:@"http"]) {
            chromeScheme = @"googlechrome";
        } else if ([scheme isEqualToString:@"https"]) {
            chromeScheme = @"googlechromes";
        }
        
        // Proceed only if a valid Google Chrome URI Scheme is available.
        if (chromeScheme) {
            NSString *absoluteString = [theURL absoluteString];
            NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
            NSString *urlNoScheme = [absoluteString substringFromIndex:rangeForScheme.location];
            NSString *chromeURLString = [chromeScheme stringByAppendingString:urlNoScheme];
            NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
            
            // Open the URL with Chrome.
            [[UIApplication sharedApplication] openURL:chromeURL];
        }
    }
}

#pragma mark - Actions

- (IBAction)backButtonTouchUp:(id)sender {
    [_webView goBack];
    
    [self toggleBackForwardButtons];
}

- (IBAction)forwardButtonTouchUp:(id)sender {
    [_webView goForward];
    
    [self toggleBackForwardButtons];
}

- (IBAction)reloadButtonTouchUp:(id)sender {
    [_webView reload];
    
    [self toggleBackForwardButtons];
}

- (IBAction)buttonActionTouchUp:(id)sender {
    [self showActionSheet];
}

- (IBAction)dismissModally:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[request.URL absoluteString] hasPrefix:@"sms:"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
	
	else
	{
		if ([[request.URL absoluteString] hasPrefix:@"http://www.youtube.com/v/"] ||
			[[request.URL absoluteString] hasPrefix:@"http://itunes.apple.com/"] ||
			[[request.URL absoluteString] hasPrefix:@"http://phobos.apple.com/"]) {
			[[UIApplication sharedApplication] openURL:request.URL];
			return NO;
		}
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self toggleBackForwardButtons];
    [self updateInsets];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    _titleLabel.text = pageTitle;
    [self toggleBackForwardButtons];
    [self updateInsets];
    self.webView.hidden = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    // To avoid getting an error alert when you click on a link
    // before a request has finished loading.
    if ([error code] == NSURLErrorCancelled) {
        return;
    }
	
    // Show error alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not load page", nil)
                                                    message:error.localizedDescription
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alert show];
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
