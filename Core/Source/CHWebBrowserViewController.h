//
//  CHWebBrowserViewController.h
//  Chivy
//
//  Created by Denis Zamataev on 10/31/13.
//  Copyright (c) 2013 Denis Zamataev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CBAutoScrollLabel.h>
#import <SuProgress.h>
#import "TKAURLProtocol.h"

#define CHWebBrowser_DEBUG_LOGGING

#ifdef CHWebBrowser_DEBUG_LOGGING
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

@interface CHWebBrowserViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIBarPositioningDelegate, UIScrollViewDelegate, TKAURLProtocolDelegate>
{
    CGPoint _lastContentOffset;
    BOOL _isScrollViewScrolling;
    BOOL _isMovingViews;
    BOOL _isAnimatingViews;
    BOOL _isAnimatingResettingViews;
    
    ValuesInAffectedViewsSetterBlock _valuesInAffectedViewsSetterBlock;
}
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

@property (nonatomic, strong) IBOutlet CBAutoScrollLabel *titleLabel;
@property (nonatomic, strong) IBOutlet CBAutoScrollLabel *urlLabel;


/* This URL should be set after creating the controller but before viewWillAppear
 On viewWillAppear it would be used to navigate the webView
 */
@property (nonatomic, strong) NSURL *homeUrl;
@property (nonatomic, strong) NSURLRequest *mainRequest;

@property (nonatomic, assign) BOOL wasOpenedModally;

/* This block is used to set **values** in **views** which both come from arguments in the following situations:
 - scroll view did scroll and user was dragging (not animated call)
 - scroll view ended scrolling and will not decelerate (animated call)
 - scroll view ended decelerating (animated call)
 - reset all views action (can be animated or not)
 
 The ivar is created on first getter occurs
 */
@property (nonatomic, copy) ValuesInAffectedViewsSetterBlock valuesInAffectedViewsSetterBlock;

+ (id)initWithDefaultNib;
+ (id)initWithDefaultNibAndHomeUrl:(NSURL*)url;
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
