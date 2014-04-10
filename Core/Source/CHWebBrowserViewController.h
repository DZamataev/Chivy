//
//  CHWebBrowserViewController.h
//  Chivy
//
//  Created by Denis Zamataev on 10/31/13.
//  Copyright (c) 2013 Denis Zamataev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CBAutoScrollLabel.h>
#import <DKBackBarButtonItem.h>
#import <ARSafariActivity.h>
#import <ARChromeActivity.h>
#import <NJKWebViewProgress.h>
#import <NJKWebViewProgressView.h>
#import "TKAURLProtocol.h"
#import "NSURL+IDN.h"

#ifndef CHWebBrowserNavBarHeight
#define CHWebBrowserNavBarHeight (self.topBar.frame.size.height)
#endif

#ifndef CHWebBrowserStatusBarHeight
#define CHWebBrowserStatusBarHeight (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? [UIApplication sharedApplication].statusBarFrame.size.height : [UIApplication sharedApplication].statusBarFrame.size.width)
#endif

#ifndef CHWebBrowserViewsAffectedByAlphaChangingByDefault
#define CHWebBrowserViewsAffectedByAlphaChangingByDefault (@[self.localTitleView, self.dismissBarButtonItem.customView, self.readBarButtonItem.customView, self.customBackBarButtonItem.customView])
#endif

#ifdef DEBUG
#	define CHWebBrowserLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define CHWebBrowserLog(...)
#endif

typedef void (^ValuesInAffectedViewsSetterBlock)(UIView *topBar,
                                                 float topBarYPosition,
                                                 UIView *bottomBar,
                                                 float bottomBarYPosition,
                                                 UIScrollView *scrollView,
                                                 UIEdgeInsets contentInset,
                                                 UIEdgeInsets scrollingIndicatorInsets,
                                                 NSArray *viewsAffectedByAlphaChanging,
                                                 float alpha);


@interface CHWebBrowserViewControllerAttributes : NSObject
@property (nonatomic, assign) float titleScrollingSpeed;
@property (nonatomic, assign) float animationDurationPerOnePixel;
@property (nonatomic, assign) NSTextAlignment titleTextAlignment;
@property (nonatomic, assign) BOOL isProgressBarEnabled;
@property (nonatomic, assign) BOOL isHidingBarsOnScrollingEnabled;
@property (nonatomic, assign) BOOL shouldAutorotate;
@property (nonatomic, assign) NSUInteger supportedInterfaceOrientations;
@property (nonatomic, assign) UIStatusBarStyle preferredStatusBarStyle;
@property (nonatomic, assign) BOOL isHttpAuthenticationPromptEnabled;
@property (nonatomic, assign) float progressBarViewThickness;

+ (CHWebBrowserViewControllerAttributes*)defaultAttributes;
@end

@interface CHWebBrowserViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIBarPositioningDelegate, UIScrollViewDelegate, TKAURLProtocolDelegate, NJKWebViewProgressDelegate>
{
    CGPoint _lastContentOffset;
    BOOL _isScrollViewScrolling;
    BOOL _isMovingViews;
    BOOL _isAnimatingViews;
    BOOL _isAnimatingResettingViews;
    NJKWebViewProgress *_progressDelegateProxy;
    NJKWebViewProgressView *_progressView;
    NSInteger _loadsInProgressCount;
        
    // baking ivars
    NSMutableArray *_viewsAffectedByAlphaChanging;
    CHWebBrowserViewControllerAttributes *_cAttributes;
    ValuesInAffectedViewsSetterBlock _valuesInAffectedViewsSetterBlock;
    BOOL _shouldShowDismissButton;
    DKBackBarButtonItem *_customBackBarButtonItem;
    NSString *_customBackBarButtonItemTitle;
}
@property (nonatomic, strong) CHWebBrowserViewControllerAttributes *cAttributes;

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *navigateBackButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *navigateForwardButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *refreshButton;

@property (nonatomic, strong) IBOutlet UINavigationBar *localNavigationBar;
@property (nonatomic, strong) IBOutlet UIView *localTitleView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *dismissBarButtonItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *readBarButtonItem;

@property (nonatomic, strong) NSMutableArray *viewsAffectedByAlphaChanging;

@property (nonatomic, strong) IBOutlet CBAutoScrollLabel *titleLabel;
@property (nonatomic, strong) IBOutlet CBAutoScrollLabel *urlLabel;

@property (nonatomic, strong) DKBackBarButtonItem *customBackBarButtonItem;
@property (nonatomic, strong) NSString *customBackBarButtonItemTitle;

@property (nonatomic, readonly) UINavigationBar *topBar;

@property (nonatomic, strong) NSURL *chromeActivityCallbackUrl; // Nil by default. Defines whether or not 'googlechrome-x-callback' URI scheme should be used instead of 'googlechrome' ('googlechromes') URI scheme. More about callback url here: https://developers.google.com/chrome/mobile/docs/ios-links

@property (nonatomic, copy) void (^onDismissCallback)(CHWebBrowserViewController *webBrowser);

@property (nonatomic, assign) BOOL shouldShowDismissButton;
@property (nonatomic, assign) BOOL wasNavigationBarHiddenByControllerOnEnter;
@property (nonatomic, assign) BOOL wasNavigationBarHiddenAsViewOnEnter;


/* This URL should be set after creating the controller but before viewWillAppear
 On viewWillAppear it would be used to navigate the webView
 */
@property (nonatomic, strong) NSURL *homeUrl;
@property (nonatomic, strong) NSString *homeUrlString;
@property (nonatomic, strong) NSURLRequest *mainRequest;

/* This block is used to set **values** in **views** which both come from arguments in the following situations:
 - scroll view did scroll and user was dragging (not animated call)
 - scroll view ended scrolling and will not decelerate (animated call)
 - scroll view ended decelerating (animated call)
 - reset all views action (can be animated or not)
 
 The ivar is created on first getter occurs
 */
@property (nonatomic, copy) ValuesInAffectedViewsSetterBlock valuesInAffectedViewsSetterBlock;

+ (id)webBrowserControllerWithDefaultNib;
+ (id)webBrowserControllerWithDefaultNibAndHomeUrl:(NSURL*)url;

+ (void)openWebBrowserController:(CHWebBrowserViewController*)vc
                  modallyWithUrl:(NSURL*)url
                  fromController:(UIViewController*)viewControllerToPresetFrom
                        animated:(BOOL)animated
               showDismissButton:(BOOL)showDismissButton
                      completion:(void (^)(void))completion;
+ (void)openWebBrowserController:(CHWebBrowserViewController*)vc modallyWithUrl:(NSURL*)url animated:(BOOL)animated showDismissButton:(BOOL)showDismissButton completion:(void (^)(void))completion;
+ (void)openWebBrowserController:(CHWebBrowserViewController*)vc modallyWithUrl:(NSURL*)url animated:(BOOL)animated completion:(void (^)(void))completion;
+ (void)openWebBrowserController:(CHWebBrowserViewController*)vc modallyWithUrl:(NSURL*)url animated:(BOOL)animated;
+ (void)openWebBrowserControllerModallyWithHomeUrl:(NSURL*)url animated:(BOOL)animated;
+ (void)openWebBrowserControllerModallyWithHomeUrl:(NSURL*)url animated:(BOOL)animated completion:(void (^)(void))completion;

+ (void)clearCredentialsAndCookiesAndCache;
+ (void)clearCredentials;
+ (void)clearCookies;
+ (void)clearCache;

- (void)loadUrlString:(NSString*)urlString;
- (void)loadUrl:(NSURL*)url;

- (void)resetAffectedViewsAnimated:(BOOL)animated;

@end