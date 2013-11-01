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
