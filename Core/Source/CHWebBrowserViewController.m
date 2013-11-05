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

#ifndef CHWebBrowserDefaultTintColor
#define CHWebBrowserDefaultTintColor [UIApplication sharedApplication].keyWindow.tintColor
#endif

#ifndef SuProgressBarTag
#define SuProgressBarTag 51381
#endif

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
        [self SuProgressForWebView:_webView inView:self.localNavigationBar];
        
    }
    else {
        [self.localTitleView removeFromSuperview];
        self.navigationItem.titleView = self.localTitleView;
        self.navigationItem.rightBarButtonItem = self.readBarButtonItem;
        [self.localNavigationBar removeFromSuperview];
        //self.localNavigationBar = nil;
        [self SuProgressForWebView:_webView];
    }
    
    [self resetInsets];
    
    [self performSelector:@selector(createScrollingInspectors) withObject:Nil afterDelay:0.1f];
    
    [self setCustomButtonsTintColor:CHWebBrowserDefaultTintColor];
    
    [[self SuProgressBar] setHidden:NO];
    
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
    [_webView stopLoading];
    UIAlertView *memoryWarningAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Memory warning",
                                                                                           @"Alert view title. Memory warning alert in web browser.")
                                                                 message:NSLocalizedString(@"The page will stop loading.",
                                                                                           @"Alert view message. Memory warning alert in web browser.")
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel",
                                                                                           @"Alert view cancel button title. Memory warning alert in web browser.")
                                                       otherButtonTitles:nil];
    [memoryWarningAlert show];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [[self SuProgressBar] setHidden:YES];
    }
    [super viewWillDisappear:animated];
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
                                                                                  self.dismissBarButtonItem.customView.alpha = newAlpha;
                                                                                  self.readBarButtonItem.customView.alpha = newAlpha;
                                                                                  UIBarButtonItem *backButtonItem = self.navigationController.navigationBar.topItem.backBarButtonItem;
                                                                                  if (backButtonItem) {
                                                                                      backButtonItem.tintColor = [backButtonItem.tintColor colorWithAlphaComponent:newAlpha];
                                                                                  }
                                                                                  _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(22+newValue, 0, newValue, 0);
                                                                                  [self.navBarContentAlphaInspector suspend];
                                                                                  [self.navBarYPositionInspector suspend];
                                                                                  [self.toolbarYPositionInspector suspend];
                                                                                  _webView.scrollView.contentInset = UIEdgeInsetsMake(22+newValue, 0, newValue, 0);
                                                                                  [self.navBarContentAlphaInspector resume];
                                                                                  [self.navBarYPositionInspector resume];
                                                                                  [self.toolbarYPositionInspector resume];
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

- (void)resetInsets
{
    _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(66, 0, 44, 0);
    _webView.scrollView.contentInset = UIEdgeInsetsMake(66, 0, 44, 0);
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.titleLabel.text = title;
}

- (void)setCustomButtonsTintColor:(UIColor*)tintColor
{
//    self.navigateBackButton.tintColor = tintColor;
//    self.navigateForwardButton.tintColor = tintColor;
//    self.actionButton.tintColor = tintColor;
//    self.refreshButton.tintColor = tintColor;
//    self.navigationItem.backBarButtonItem.tintColor = tintColor;
    UIButton* backButton = (UIButton*)self.dismissBarButtonItem.customView;
    UIButton* readButton = (UIButton*)self.readBarButtonItem.customView;
    if ([backButton isKindOfClass:[UIButton class]]) {
        [backButton setImage:[CHWebBrowserViewController tintImage:[backButton imageForState:UIControlStateNormal] withColor:tintColor] forState:UIControlStateNormal];
    }
    if ([readButton isKindOfClass:[UIButton class]]) {
        [readButton setImage:[CHWebBrowserViewController tintImage:[readButton imageForState:UIControlStateNormal] withColor:tintColor] forState:UIControlStateNormal];
    }
    
    [[self SuProgressBar] setTintColor:tintColor];
}

- (UIView*)SuProgressBar
{
    UIView *result = nil;
    result = [self.localNavigationBar viewWithTag:SuProgressBarTag];
    if (!result) {
        result = [self.navigationController.navigationBar viewWithTag:SuProgressBarTag];
    }
    return result;
}

#pragma mark


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

- (IBAction)readingModeToggle:(id)sender {
    
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
    [self resetInsets];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    _titleLabel.text = pageTitle;
    [self toggleBackForwardButtons];
    [self resetInsets];
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

#pragma mark - Helpers

// baseImage is the grey scale image. color is the desired tint color
+ (UIImage *)tintImage:(UIImage *)baseImage withColor:(UIColor *)color {
    /* iOS 6 way */
//    UIGraphicsBeginImageContextWithOptions(baseImage.size, NO, baseImage.scale);
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGRect area = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
//    
//    CGContextScaleCTM(ctx, 1, -1);
//    CGContextTranslateCTM(ctx, 0, -area.size.height);
//    
//    CGContextSaveGState(ctx);
//    CGContextClipToMask(ctx, area, baseImage.CGImage);
//    
//    [color set];
//    CGContextFillRect(ctx, area);
//    CGContextRestoreGState(ctx);
//    
//    CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
//    
//    CGContextDrawImage(ctx, area, baseImage.CGImage);
//    
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    // If the original image was stretchable, make the new image stretchable
//    if (baseImage.leftCapWidth || baseImage.topCapHeight) {
//        newImage = [newImage stretchableImageWithLeftCapWidth:baseImage.leftCapWidth topCapHeight:baseImage.topCapHeight];
//    }
//    
//    return newImage;
    
    /* iOS 7 way which somehow ignored imageView.tintColor and uses keyWindow.tintColor */
    UIImage* imageForRendering = [baseImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:imageForRendering];
    imageView.tintColor = color;
    imageView = Nil;
    return imageForRendering;
}

@end
