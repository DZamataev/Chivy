//
//  DCViewController.h
//  Chivy
//
//  Created by Denis Zamataev on 10/31/13.
//  Copyright (c) 2013 Denis Zamataev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCViewController : UIViewController
@property (nonatomic, strong) IBOutlet UITextField *urlTextField;

- (IBAction)openWebBrowserModally:(id)sender;
- (IBAction)pushWebBrowser:(id)sender;
@end
