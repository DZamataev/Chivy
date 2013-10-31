//
//  CHWebBrowserViewController.h
//  Chivy
//
//  Created by Denis Zamataev on 10/31/13.
//  Copyright (c) 2013 Denis Zamataev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CBAutoScrollLabel.h>

@interface CHWebBrowserViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>
{
    NSString *_requestUrl;
}
@property (nonatomic, strong) IBOutlet UIWebView *webView;

@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *navigateBackButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *navigateForwardButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *refreshButton;

@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) IBOutlet CBAutoScrollLabel *titleLabel;
@property (nonatomic, strong) IBOutlet CBAutoScrollLabel *urlLabel;
@property (nonatomic, strong) IBOutlet UIButton *closeButton;

@property (nonatomic, strong) NSString *requestUrl;




+ (void)openWebBrowserControllerModallyWithUrl:(NSString*)urlString animated:(BOOL)animated completion:(void (^)(void))completion;

@end
