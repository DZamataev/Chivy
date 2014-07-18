//
//  CHSearchWebViewActivity.m
//  Chivy
//
//  Created by Denis Zamataev on 7/17/14.
//  Copyright (c) 2014 Denis Zamataev. All rights reserved.
//

#import "CHButtonActivity.h"

@implementation CHButtonActivity

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithTitle:(NSString*)title image:(UIImage*)image
{
    self = [super init];
    if (self) {
        self.activityTitle = title;
        self.activityImage = image;
    }
    return self;
}

- (NSString *)activityType {
    return NSStringFromClass([self class]);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
}

- (void)performActivity {
    if (self.actionBlock) {
        self.actionBlock(self);
        [self activityDidFinish:YES];
    }
}
@end
