//
//  CHWebBrowserViewController.h
//  Chivy
//
//  Created by Denis Zamataev on 10/31/13.
//  Copyright (c) 2013 Denis Zamataev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CBAutoScrollLabel.h>

@class DZScrollingInspector;
@class CHScrollingInspector;

@interface CHWebBrowserViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, UIBarPositioningDelegate>
{
    NSString *_requestUrl;
}
@property (nonatomic, strong) IBOutlet UIWebView *webView;

@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *navigateBackButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *navigateForwardButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *refreshButton;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *navBarTopOffsetConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *webViewVerticalSpaceConstraint;

@property (nonatomic, strong) IBOutlet UINavigationBar *localNavigationBar;
@property (nonatomic, strong) IBOutlet UIView *localTitleView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *dismissButton;

@property (nonatomic, strong) IBOutlet CBAutoScrollLabel *titleLabel;
@property (nonatomic, strong) IBOutlet CBAutoScrollLabel *urlLabel;

@property (nonatomic, strong) NSString *requestUrl;

@property (nonatomic, assign) BOOL wasOpenedModally;

@property (nonatomic, strong) CHScrollingInspector *navBarYPositionInspector;
@property (nonatomic, strong) CHScrollingInspector *navBarContentAlphaInspector;
@property (nonatomic, strong) CHScrollingInspector *toolbarYPositionInspector;


+ (id)initWithDefaultNib;
+ (id)initWithDefaultNibAndRequestUrl:(NSString*)requestUrl;
+ (void)openWebBrowserControllerModallyWithUrl:(NSString*)urlString animated:(BOOL)animated completion:(void (^)(void))completion;

@end
