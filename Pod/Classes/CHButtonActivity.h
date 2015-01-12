//
//  CHSearchWebViewActivity.h
//  Chivy
//
//  Created by Denis Zamataev on 7/17/14.
//  Copyright (c) 2014 Denis Zamataev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHButtonActivity : UIActivity
@property (nonatomic, strong) NSString *activityTitle;
@property (nonatomic, strong) UIImage *activityImage;

@property (nonatomic, copy) void (^actionBlock)(CHButtonActivity *sender);

- (id)initWithTitle:(NSString*)title image:(UIImage*)image;
@end
