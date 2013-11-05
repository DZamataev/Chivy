//
//  DCViewController.m
//  Chivy
//
//  Created by Denis Zamataev on 10/31/13.
//  Copyright (c) 2013 Denis Zamataev. All rights reserved.
//

#import "DCViewController.h"
#import "CHWebBrowserViewController.h"

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
    [CHWebBrowserViewController openWebBrowserControllerModallyWithUrl:_urlTextField.text animated:YES completion:^{
        NSLog(@"Modal animation completed");
    }];
}

float randomFloat(float Min, float Max){
    return ((arc4random()%RAND_MAX)/(RAND_MAX*1.0))*(Max-Min)+Min;
}

- (IBAction)randomizeTintColor:(id)sender
{
    [[UIApplication sharedApplication].keyWindow setTintColor:[UIColor colorWithRed:randomFloat(0, 1) green:randomFloat(0, 1) blue:randomFloat(0, 1) alpha:1.0f]];
}

- (IBAction)pushWebBrowser:(id)sender
{
    [self.navigationController pushViewController:[CHWebBrowserViewController initWithDefaultNibAndRequestUrl:_urlTextField.text] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
