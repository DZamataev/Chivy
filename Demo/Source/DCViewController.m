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
    [CHWebBrowserViewController openWebBrowserControllerModallyWithHomeUrl:[NSURL URLWithString:_urlTextField.text]
                                                                  animated:YES
                                                                completion:^{
                                                                    NSLog(@"Modal animation completed");
                                                                }];
}

- (IBAction)openCustomizedWebBrowserModally:(id)sender
{
    CHWebBrowserViewController *webBrowserVC = [CHWebBrowserViewController initWithDefaultNibAndHomeUrl:[NSURL URLWithString:_urlTextField.text]];
    
    webBrowserVC.view.tintColor = [UIColor redColor];
    webBrowserVC.cAttributes.titleScrollingSpeed = 50.0f;
    webBrowserVC.cAttributes.animationDurationPerOnePixel = 0.0068181818f;
    webBrowserVC.cAttributes.titleTextAlignment = NSTextAlignmentLeft;
    webBrowserVC.cAttributes.isProgressBarEnabled = YES;
    webBrowserVC.cAttributes.isHidingBarsOnScrollingEnabled = NO;
    webBrowserVC.cAttributes.shouldAutorotate = NO;
    webBrowserVC.cAttributes.supportedInterfaceOrientations = UIInterfaceOrientationMaskLandscape;
    
    [CHWebBrowserViewController openWebBrowserController:webBrowserVC
                                          modallyWithUrl:[NSURL URLWithString:_urlTextField.text]
                                                animated:YES
                                              completion:^{
                                                  NSLog(@"Modal animation completed");
                                              }];
}

- (IBAction)pushWebBrowser:(id)sender
{
    [self.navigationController pushViewController:[CHWebBrowserViewController initWithDefaultNibAndHomeUrl:[NSURL URLWithString:_urlTextField.text]]
                                         animated:YES];
}

- (IBAction)randomizeTintColor:(id)sender
{
    [[UIApplication sharedApplication].keyWindow setTintColor:[UIColor colorWithRed:randomFloat(0, 1) green:randomFloat(0, 1) blue:randomFloat(0, 1) alpha:1.0f]];
}

- (IBAction)clearCacheAndCredentialsAndCookies:(id)sender
{
    [CHWebBrowserViewController clearCredentialsAndCookiesAndCache];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers

float randomFloat(float Min, float Max){
    return ((arc4random()%RAND_MAX)/(RAND_MAX*1.0))*(Max-Min)+Min;
}

@end
