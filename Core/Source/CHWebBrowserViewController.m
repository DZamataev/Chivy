//
//  CHWebBrowserViewController.m
//  Chivy
//
//  Created by Denis Zamataev on 10/31/13.
//  Copyright (c) 2013 Denis Zamataev. All rights reserved.
//

#import "CHWebBrowserViewController.h"

enum actionSheetButtonIndex {
	kSafariButtonIndex,
	kChromeButtonIndex,
};

#ifndef CHWebBrowserDefaultTintColor
#define CHWebBrowserDefaultTintColor [UIApplication sharedApplication].keyWindow.tintColor
#endif

#ifndef CHWebBrowserNavBarHeight
#define CHWebBrowserNavBarHeight 44.0f
#endif

#ifndef CHWebBrowserStatusBarHeight
#define CHWebBrowserStatusBarHeight 22.0f
#endif

#ifndef SuProgressBarTag
#define SuProgressBarTag 51381
#endif

#ifndef CHWebBrowserAnimationDurationPerOnePixel
#define CHWebBrowserAnimationDurationPerOnePixel 0.0068181818f
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
    
    _webView.scrollView.delegate = self;
    
    _wasOpenedModally = [self isModal];
    if (_wasOpenedModally) {
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

#pragma mark - View state related methods

- (void)toggleBackForwardButtons {
    _navigateBackButton.enabled = _webView.canGoBack;
    _navigateForwardButton.enabled = _webView.canGoForward;
}

- (void)resetInsets
{
    
    UINavigationBar *topBar = self.wasOpenedModally ? self.localNavigationBar : self.navigationController.navigationBar;
    NSLog(@"TOP BAR SIZE %f ORIGIN Y %f", topBar.frame.size.height, topBar.frame.origin.y);
    if (_wasOpenedModally) {
        _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(CHWebBrowserNavBarHeight + CHWebBrowserStatusBarHeight, 0, CHWebBrowserNavBarHeight, 0);
        _webView.scrollView.contentInset = UIEdgeInsetsMake(CHWebBrowserNavBarHeight + CHWebBrowserStatusBarHeight, 0, CHWebBrowserNavBarHeight, 0);
    }
    else {
        _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, CHWebBrowserNavBarHeight, 0);
        _webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, CHWebBrowserNavBarHeight, 0);
    }
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.titleLabel.text = title;
}

- (void)setCustomButtonsTintColor:(UIColor*)tintColor
{
    /* we won't change the following, cuz it can be achieved using .keyWindow.tintColor, no need to repeat */
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
    NSString *s = [_webView stringByEvaluatingJavaScriptFromString:@"javascript:(function()%7B_readableOptions%3D%7B%27text_font%27:%27quote(Palatino%20Linotype),%20Palatino,%20quote(Book%20Antigua),%20Georgia,%20serif%27,%27text_font_monospace%27:%27quote(Courier%20New),%20Courier,%20monospace%27,%27text_font_header%27:%27quote(Times%20New%20Roman),%20Times,%20serif%27,%27text_size%27:%2718px%27,%27text_line_height%27:%271.5%27,%27box_width%27:%2730em%27,%27color_text%27:%27%23282828%27,%27color_background%27:%27%23F5F5F5%27,%27color_links%27:%27%230000FF%27,%27text_align%27:%27normal%27,%27base%27:%27blueprint%27,%27custom_css%27:%27%27%7D%3Bif(document.getElementsByTagName(%27body%27).length%3E0)%3Belse%7Breturn%3B%7Dif(window.%24readable)%7Bif(window.%24readable.bookmarkletTimer)%7Breturn%3B%7D%7Delse%7Bwindow.%24readable%3D%7B%7D%3B%7Dwindow.%24readable.bookmarkletTimer%3Dtrue%3Bwindow.%24readable.options%3D_readableOptions%3Bif(window.%24readable.bookmarkletClicked)%7Bwindow.%24readable.bookmarkletClicked()%3Breturn%3B%7D_readableScript%3Ddocument.createElement(%27script%27)%3B_readableScript.setAttribute(%27src%27,%27http://readable-static.tastefulwords.com/target.js%3Frand%3D%27%2BencodeURIComponent(Math.random()))%3Bdocument.getElementsByTagName(%27body%27)%5B0%5D.appendChild(_readableScript)%3B%7D)()"];
    NSLog(@"readable mode string: %@", s);
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
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    _titleLabel.text = pageTitle;
    [self toggleBackForwardButtons];
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

#pragma mark - ScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isScrollViewScrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate) {
        _isScrollViewScrolling = NO;
        [self animateViewsAccordingToScrollingEndedInScrollView:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _isScrollViewScrolling = NO;
    [self animateViewsAccordingToScrollingEndedInScrollView:scrollView];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    _isScrollViewScrolling = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _isScrollViewScrolling = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%s \n contentOffset.y %f \n delta %f \n contentInset %@ \n scrollIndicatorsInset %@",__PRETTY_FUNCTION__,scrollView.contentOffset.y, _lastContentOffset.y - scrollView.contentOffset.y, NSStringFromUIEdgeInsets(scrollView.contentInset), NSStringFromUIEdgeInsets(scrollView.scrollIndicatorInsets));
    
    CGFloat delta =  scrollView.contentOffset.y - _lastContentOffset.y;
    BOOL scrollingDown = delta > 0;
    BOOL scrollingBeyondTopBound = (scrollView.contentOffset.y < - scrollView.contentInset.top);
    BOOL scrollingBeyondBottomBound = (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentInset.bottom) > scrollView.contentSize.height;
    BOOL scrollingForbidden = (scrollingBeyondTopBound && scrollingDown) || scrollingBeyondBottomBound;
    NSLog(@"top %i bot %i", scrollingBeyondTopBound, scrollingBeyondBottomBound);
    if (!scrollingForbidden) {
        
        if (scrollView.isDragging) {
            [self moveViewsAccordingToDraggingInScrollView:scrollView];
        }

    }
    _lastContentOffset = scrollView.contentOffset;
}

- (void)moveViewsAccordingToDraggingInScrollView:(UIScrollView*)scrollView
{
    CGFloat delta =  scrollView.contentOffset.y - _lastContentOffset.y;
    
    UINavigationBar *topBar = self.wasOpenedModally ? self.localNavigationBar : self.navigationController.navigationBar;
    
    topBar.frame = CGRectMake(topBar.frame.origin.x,
                              [CHWebBrowserViewController clampFloat:topBar.frame.origin.y - delta withMinimum:-CHWebBrowserStatusBarHeight andMaximum:CHWebBrowserStatusBarHeight],
                              topBar.frame.size.width,
                              topBar.frame.size.height);
   _bottomToolbar.frame = CGRectMake(_bottomToolbar.frame.origin.x,
                                     [CHWebBrowserViewController clampFloat:_bottomToolbar.frame.origin.y + delta withMinimum:_webView.frame.size.height - CHWebBrowserNavBarHeight andMaximum:_webView.frame.size.height],
                                     _bottomToolbar.frame.size.width,
                                     _bottomToolbar.frame.size.height);
    
    float topInset = [CHWebBrowserViewController clampFloat:scrollView.contentInset.top - delta
                                                withMinimum:CHWebBrowserStatusBarHeight
                                                 andMaximum:CHWebBrowserNavBarHeight + CHWebBrowserStatusBarHeight];
    float bottomInset = [CHWebBrowserViewController clampFloat:scrollView.contentInset.bottom - delta
                                                   withMinimum:0
                                                    andMaximum:CHWebBrowserNavBarHeight];
    scrollView.contentInset = UIEdgeInsetsMake(topInset, 0, bottomInset, 0);
    scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(topInset, 0, bottomInset, 0);
    
    float alpha = [CHWebBrowserViewController clampFloat:CHWebBrowserNavBarHeight * _titleLabel.alpha - delta
                                             withMinimum:0
                                              andMaximum:CHWebBrowserNavBarHeight] / CHWebBrowserNavBarHeight;
    _titleLabel.alpha = alpha;
    _dismissBarButtonItem.customView.alpha = alpha;
    _readBarButtonItem.customView.alpha = alpha;
    
}

- (void)animateViewsAccordingToScrollingEndedInScrollView:(UIScrollView*)scrollView
{
    UINavigationBar *topBar = self.wasOpenedModally ? self.localNavigationBar : self.navigationController.navigationBar;

    float topBarTargetValue, topBarDistanceLeft;
    [CHWebBrowserViewController someValue:topBar.frame.origin.y
                             betweenValue:-CHWebBrowserStatusBarHeight
                                 andValue:CHWebBrowserStatusBarHeight
                         traveledDistance:&topBarDistanceLeft
                          andIsHalfPassed:nil
                           andTargetLimit:&topBarTargetValue];
    
    float bottomToolbarTargetValue;
    [CHWebBrowserViewController someValue:_bottomToolbar.frame.origin.y
                             betweenValue:_webView.frame.size.height - CHWebBrowserNavBarHeight
                                 andValue:_webView.frame.size.height
                         traveledDistance:nil
                          andIsHalfPassed:nil
                           andTargetLimit:&bottomToolbarTargetValue];
    
    float topInsetTargetValue;
    [CHWebBrowserViewController someValue:scrollView.contentInset.top
                             betweenValue:CHWebBrowserStatusBarHeight
                                 andValue:CHWebBrowserNavBarHeight + CHWebBrowserStatusBarHeight
                         traveledDistance:nil
                          andIsHalfPassed:nil
                           andTargetLimit:&topInsetTargetValue];
    
    float bottomInsetTargetValue;
    [CHWebBrowserViewController someValue:scrollView.contentInset.bottom
                             betweenValue:0
                                 andValue:CHWebBrowserNavBarHeight
                         traveledDistance:nil
                          andIsHalfPassed:nil
                           andTargetLimit:&bottomInsetTargetValue];
    
    UIEdgeInsets insetTargetValue = UIEdgeInsetsMake(topInsetTargetValue,0,bottomInsetTargetValue,0);
    
    float alphaTargetValue;
    [CHWebBrowserViewController someValue:_titleLabel.alpha
                             betweenValue:0
                                 andValue:1.0f
                         traveledDistance:nil
                          andIsHalfPassed:nil
                           andTargetLimit:&alphaTargetValue];
    
    [UIView animateWithDuration:topBarDistanceLeft * CHWebBrowserAnimationDurationPerOnePixel
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         topBar.frame = CGRectMake(topBar.frame.origin.x, topBarTargetValue, topBar.frame.size.width, topBar.frame.size.height);
                         _bottomToolbar.frame = CGRectMake(_bottomToolbar.frame.origin.x, bottomToolbarTargetValue, _bottomToolbar.frame.size.width, _bottomToolbar.frame.size.height);
                         scrollView.scrollIndicatorInsets = insetTargetValue;
                         scrollView.contentInset = insetTargetValue;
                         _titleLabel.alpha = alphaTargetValue;
                         _dismissBarButtonItem.customView.alpha = alphaTargetValue;
                         _readBarButtonItem.customView.alpha = alphaTargetValue;
                         
    }
                     completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

#pragma mark - Helpers
/*
clamps the value to lie betweem minimum and maximum;
if minimum is smaller than maximum - they will be swapped;
*/
+(float)clampFloat:(float)value withMinimum:(float)min andMaximum:(float)max {
    CGFloat realMin = min < max ? min : max;
    CGFloat realMax = max >= min ? max : min;
    return MAX(realMin, MIN(realMax, value));
}

+(void)someValue:(float)value betweenValue:(float)f1 andValue:(float)f2 traveledDistance:(float *)distance andIsHalfPassed:(BOOL *)halfPassed andTargetLimit:(float *)targetLimit
{
    CGFloat lowerLimit = MIN(f1, f2);
    CGFloat higherLimit = MAX(f1, f2);
    float distance_ = fabsf(higherLimit - lowerLimit);
    BOOL halfPassed_ = value > (lowerLimit + distance_/2);
    float targetLimit_ = halfPassed_ ? higherLimit : lowerLimit;
    if (distance != nil) *distance = distance_;
    if (halfPassed != nil) *halfPassed = halfPassed_;
    if (targetLimit != nil) *targetLimit = targetLimit_;
}

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
