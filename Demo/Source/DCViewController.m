//
//  DCViewController.m
//  Chivy
//
//  Created by Denis Zamataev on 10/31/13.
//  Copyright (c) 2013 Denis Zamataev. All rights reserved.
//

#import "DCViewController.h"

@interface DCViewController ()

@end

@implementation DCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)openWebBrowserModally:(id)sender
{
    [CHWebBrowserViewController openWebBrowserControllerModallyWithHomeUrl:[CHWebBrowserViewController URLWithString:_urlTextField.text]
                                                                  animated:YES
                                                                completion:^{
                                                                    NSLog(@"Modal animation completed");
                                                                }];
}

- (IBAction)openCustomizedWebBrowserModally:(id)sender
{
    NSURL *urlToOpen = [CHWebBrowserViewController URLWithString:_urlTextField.text];
    CHWebBrowserViewController *webBrowserVC = [CHWebBrowserViewController webBrowserControllerWithDefaultNibAndHomeUrl:urlToOpen];
    
    webBrowserVC.cAttributes.titleScrollingSpeed = 10.0f;
    webBrowserVC.cAttributes.animationDurationPerOnePixel = 0.0008f; // faster animation on hiding bars
    webBrowserVC.cAttributes.titleTextAlignment = NSTextAlignmentLeft;
    webBrowserVC.cAttributes.isProgressBarEnabled = YES;
    webBrowserVC.cAttributes.isHidingBarsOnScrollingEnabled = NO;
    webBrowserVC.cAttributes.isReadabilityButtonHidden = YES;
    webBrowserVC.cAttributes.shouldAutorotate = NO;
    webBrowserVC.cAttributes.supportedInterfaceOrientations = UIInterfaceOrientationMaskLandscape;
    
    /* 
     let's use google chrome URI scheme which provides callback url.
     we should specify only 'x-success' parameter using webBrowserViewController property
     the 'x-source' would be taken from 'CFBundleName' in InfoPlist.strings
     */
    NSURL *callbackURL = [NSURL URLWithString:@"returned-from-chrome"];
    webBrowserVC.chromeActivityCallbackUrl = callbackURL;

    [webBrowserVC setOnDismissCallback:^(CHWebBrowserViewController *webBrowser) {
        NSLog(@"dismiss callback trigerred");
    }];
    
    [CHWebBrowserViewController openWebBrowserController:webBrowserVC
                                          modallyWithUrl:[CHWebBrowserViewController URLWithString:_urlTextField.text]
                                                animated:YES
                                       showDismissButton:NO
                                              completion:^{
                                                  NSLog(@"Modal animation completed");
                                              }];
    
    
    float delayInSeconds = 5.0f;
    NSLog(@"Dismiss button will appear in %f seconds. Please wait.", delayInSeconds);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        webBrowserVC.shouldShowDismissButton = YES;
    });
    
}

- (IBAction)pushWebBrowser:(id)sender
{
    [self.navigationController pushViewController:[CHWebBrowserViewController webBrowserControllerWithDefaultNibAndHomeUrl:[CHWebBrowserViewController URLWithString:_urlTextField.text]]
                                         animated:YES];
}

- (IBAction)pushCustomizedWebBrowser:(id)sender
{
    CHWebBrowserViewController *webBrowserVC = [CHWebBrowserViewController webBrowserControllerWithDefaultNibAndHomeUrl:[CHWebBrowserViewController URLWithString:_urlTextField.text]];
    
    webBrowserVC.cAttributes.titleScrollingSpeed = 10.0f;
    webBrowserVC.cAttributes.animationDurationPerOnePixel = 0.0008f; // faster animation on hiding bars
    webBrowserVC.cAttributes.titleTextAlignment = NSTextAlignmentLeft;
    webBrowserVC.cAttributes.isProgressBarEnabled = YES;
    webBrowserVC.cAttributes.isHidingBarsOnScrollingEnabled = YES;
    webBrowserVC.cAttributes.shouldAutorotate = NO;
    webBrowserVC.cAttributes.supportedInterfaceOrientations = UIInterfaceOrientationMaskLandscape;
    webBrowserVC.customBackBarButtonItemTitle = @"mytitle";
    
    /*
     let's use google chrome URI scheme which provides callback url.
     we should specify only 'x-success' parameter using webBrowserViewController property
     the 'x-source' would be taken from 'CFBundleName' in InfoPlist.strings
     */
    NSURL *callbackURL = [NSURL URLWithString:@"chivy://"];
    webBrowserVC.chromeActivityCallbackUrl = callbackURL;
    
    [webBrowserVC setOnDismissCallback:^(CHWebBrowserViewController *webBrowser) {
        NSLog(@"dismiss callback trigerred");
    }];
    [webBrowserVC setOnLoadingFailedCallback:^(CHWebBrowserViewController *webBrowserVC,
                                               NSError *error,
                                               NSURL *url,
                                               BOOL *shouldShowAlert) {
        NSLog(@"loading failed callback trigerred");
        *shouldShowAlert = NO;
        NSLog(@"there will be no alert cuz it was just told not to show");
    }];
    
    [self.navigationController pushViewController:webBrowserVC animated:YES];
}

- (IBAction)randomizeTintColor:(id)sender
{
    UIColor *randomColor = [UIColor colorWithRed:randomFloat(0, 1) green:randomFloat(0, 1) blue:randomFloat(0, 1) alpha:1.0f];
    [[UIApplication sharedApplication].keyWindow setTintColor:randomColor]; // this would color everything, including buttons
    self.navigationController.navigationBar.tintColor = randomColor; // this is another way that colors only bar buttons, it will also work
}

- (IBAction)clearCacheAndCredentialsAndCookies:(id)sender
{
    [CHWebBrowserViewController clearCredentialsAndCookiesAndCache];
}

- (IBAction)switchNavBarVisibility:(id)sender
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CHWebBrowserViewController class]]) {
        CHWebBrowserViewController *webBrowserVC = segue.destinationViewController;
        webBrowserVC.homeUrlString = _urlTextField.text;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField protocol implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Helpers

float randomFloat(float Min, float Max){
    return ((arc4random()%RAND_MAX)/(RAND_MAX*1.0))*(Max-Min)+Min;
}

@end
