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

#ifndef CHWebBrowserTitleScrollingSpeed
#define CHWebBrowserTitleScrollingSpeed 20
#endif

#ifndef CHWebBrowserTitleTextAlignment
#define CHWebBrowserTitleTextAlignment NSTextAlignmentCenter
#endif

#define CHWebBrowserNavModeNavBarYPositionShownStateCorrection (_wasOpenedModally ? 0 : -2)



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
    
    self.titleLabel.scrollSpeed = CHWebBrowserTitleScrollingSpeed;
    self.titleLabel.textAlignment = CHWebBrowserTitleTextAlignment;
    
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

- (UINavigationBar*)topBar {
    return self.wasOpenedModally ? self.localNavigationBar : self.navigationController.navigationBar;
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
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self resetAffectedViewsAnimated:YES];
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
    UINavigationBar *topBar = [self topBar];
    CHWebBrowserLog(@"TOP BAR SIZE %f ORIGIN Y %f VIEW FRAME %@", topBar.frame.size.height, topBar.frame.origin.y, NSStringFromCGRect(self.view.frame));
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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MakeReadableJS" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSString *s = [_webView stringByEvaluatingJavaScriptFromString:content];
    CHWebBrowserLog(@"readable script %@\n outputs: %@", content, s);
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
    [self resetAffectedViewsAnimated:YES];
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
    
    [self resetAffectedViewsAnimated:YES];
	
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
        if (!_isMovingViews && !_isAnimatingViews && !_isAnimatingResettingViews)
            [self animateAffectedViewsAccordingToScrollingEndedInScrollView:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _isScrollViewScrolling = NO;
    if (!_isMovingViews && !_isAnimatingViews && !_isAnimatingResettingViews)
        [self animateAffectedViewsAccordingToScrollingEndedInScrollView:scrollView];
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
    CHWebBrowserLog(@"\n contentOffset.y %f \n delta %f \n contentInset %@ \n scrollIndicatorsInset %@ \n topBarPositionY %f",scrollView.contentOffset.y, _lastContentOffset.y - scrollView.contentOffset.y, NSStringFromUIEdgeInsets(scrollView.contentInset), NSStringFromUIEdgeInsets(scrollView.scrollIndicatorInsets), [self topBar].frame.origin.y);
    
    if (!_isMovingViews && !_isAnimatingViews && !_isAnimatingResettingViews && scrollView.isDragging) {
        CGFloat delta =  scrollView.contentOffset.y - _lastContentOffset.y;
        BOOL scrollingDown = delta > 0;
        BOOL scrollingBeyondTopBound = (scrollView.contentOffset.y < - scrollView.contentInset.top);
        BOOL scrollingBeyondBottomBound = (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentInset.bottom) > scrollView.contentSize.height;
        BOOL shouldNotMoveViews = (scrollingBeyondTopBound && scrollingDown) || scrollingBeyondBottomBound;
        if (!shouldNotMoveViews) {
            [self moveAffectedViewsAccordingToDraggingInScrollView:scrollView];
        }
    }
    _lastContentOffset = scrollView.contentOffset;
}

- (void)moveAffectedViewsAccordingToDraggingInScrollView:(UIScrollView*)scrollView
{
    _isMovingViews = YES;
    
    CGFloat delta =  scrollView.contentOffset.y - _lastContentOffset.y;
    
    UINavigationBar *topBar = [self topBar];
    
    topBar.frame = CGRectMake(topBar.frame.origin.x,
                              [CHWebBrowserViewController clampFloat:topBar.frame.origin.y - delta
                                                         withMinimum:-CHWebBrowserStatusBarHeight
                                                          andMaximum:CHWebBrowserStatusBarHeight + CHWebBrowserNavModeNavBarYPositionShownStateCorrection],
                              topBar.frame.size.width,
                              topBar.frame.size.height);
   _bottomToolbar.frame = CGRectMake(_bottomToolbar.frame.origin.x,
                                     [CHWebBrowserViewController clampFloat:_bottomToolbar.frame.origin.y + delta
                                                                withMinimum:_webView.frame.size.height - CHWebBrowserNavBarHeight
                                                                 andMaximum:_webView.frame.size.height],
                                     _bottomToolbar.frame.size.width,
                                     _bottomToolbar.frame.size.height);
    
    float topInset = [CHWebBrowserViewController clampFloat:scrollView.contentInset.top - delta
                                                withMinimum:CHWebBrowserStatusBarHeight
                                                 andMaximum:CHWebBrowserNavBarHeight + CHWebBrowserStatusBarHeight + CHWebBrowserNavModeNavBarYPositionShownStateCorrection];
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
    
    _isMovingViews = NO;
}

- (void)animateAffectedViewsAccordingToScrollingEndedInScrollView:(UIScrollView*)scrollView
{
    _isAnimatingViews = YES;
    
    UINavigationBar *topBar = [self topBar];

    float topBarTargetValue, topBarDistanceLeft;
    [CHWebBrowserViewController someValue:topBar.frame.origin.y
                             betweenValue:-CHWebBrowserStatusBarHeight
                                 andValue:CHWebBrowserStatusBarHeight + CHWebBrowserNavModeNavBarYPositionShownStateCorrection
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
                                 andValue:CHWebBrowserNavBarHeight + CHWebBrowserStatusBarHeight + CHWebBrowserNavModeNavBarYPositionShownStateCorrection
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
                         topBar.frame = CGRectMake(topBar.frame.origin.x,
                                                   topBarTargetValue,
                                                   topBar.frame.size.width,
                                                   topBar.frame.size.height);
                         _bottomToolbar.frame = CGRectMake(_bottomToolbar.frame.origin.x,
                                                           bottomToolbarTargetValue,
                                                           _bottomToolbar.frame.size.width,
                                                           _bottomToolbar.frame.size.height);
                         
                         scrollView.scrollIndicatorInsets = insetTargetValue;
                         scrollView.contentInset = insetTargetValue;
                         
                         _titleLabel.alpha = alphaTargetValue;
                         _dismissBarButtonItem.customView.alpha = alphaTargetValue;
                         _readBarButtonItem.customView.alpha = alphaTargetValue;
                         
    }
                     completion:^(BOOL finished) {
                         _isAnimatingViews = NO;
    }];
}


- (void)resetAffectedViewsAnimated:(BOOL)animated
{
    UINavigationBar *topBar = [self topBar];
    
    float topBarTargetValue = CHWebBrowserStatusBarHeight + CHWebBrowserNavModeNavBarYPositionShownStateCorrection;
    CGFloat topBarLowerLimit = -CHWebBrowserStatusBarHeight;
    CGFloat topBarHigherLimit = CHWebBrowserStatusBarHeight + CHWebBrowserNavModeNavBarYPositionShownStateCorrection;
    float topBarDistanceLeft = fabsf(topBarHigherLimit - topBarLowerLimit);
    float bottomToolbarTargetValue = _webView.frame.size.height - CHWebBrowserNavBarHeight;
    float topInsetTargetValue = CHWebBrowserNavBarHeight + CHWebBrowserStatusBarHeight + CHWebBrowserNavModeNavBarYPositionShownStateCorrection;
    float bottomInsetTargetValue = CHWebBrowserNavBarHeight;
    UIEdgeInsets insetTargetValue = UIEdgeInsetsMake(topInsetTargetValue,0,bottomInsetTargetValue,0);
    float alphaTargetValue = 1.0f;
    if (animated) {
        _isAnimatingResettingViews = YES;
        [UIView animateWithDuration:topBarDistanceLeft * CHWebBrowserAnimationDurationPerOnePixel
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             topBar.frame = CGRectMake(topBar.frame.origin.x,
                                                       topBarTargetValue,
                                                       topBar.frame.size.width,
                                                       topBar.frame.size.height);
                             _bottomToolbar.frame = CGRectMake(_bottomToolbar.frame.origin.x,
                                                               bottomToolbarTargetValue,
                                                               _bottomToolbar.frame.size.width,
                                                               _bottomToolbar.frame.size.height);
                             
                             _webView.scrollView.scrollIndicatorInsets = insetTargetValue;
                             _webView.scrollView.contentInset = insetTargetValue;
                             
                             _titleLabel.alpha = alphaTargetValue;
                             _dismissBarButtonItem.customView.alpha = alphaTargetValue;
                             _readBarButtonItem.customView.alpha = alphaTargetValue;
                             
                         }
                         completion:^(BOOL finished) {
                             _isAnimatingResettingViews = NO;
                         }];
    }
    else {
        _isMovingViews = YES;
        
        topBar.frame = CGRectMake(topBar.frame.origin.x,
                                  topBarTargetValue,
                                  topBar.frame.size.width,
                                  topBar.frame.size.height);
        _bottomToolbar.frame = CGRectMake(_bottomToolbar.frame.origin.x,
                                          bottomToolbarTargetValue,
                                          _bottomToolbar.frame.size.width,
                                          _bottomToolbar.frame.size.height);
        
        _webView.scrollView.scrollIndicatorInsets = insetTargetValue;
        _webView.scrollView.contentInset = insetTargetValue;
        
        _titleLabel.alpha = alphaTargetValue;
        _dismissBarButtonItem.customView.alpha = alphaTargetValue;
        _readBarButtonItem.customView.alpha = alphaTargetValue;
        
        _isMovingViews = NO;
    }
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
