//
//  CHScrollingInspector.h
//  Chivy
//  Derived from DZScrollingInspector.h
//  DZTSMiniWebBrowser
//
//
//  Created by Denis Zamataev on 9/2/13.
//  Copyright (c) 2013 Denis Zamataev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DZScrollingInspector.h"

#define DZScrollingInspector_LOGGING_ENABLED

#ifdef DZScrollingInspector_LOGGING_ENABLED
#	define DZScrollingInspectorLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DZScrollingInspectorLog(...)
#endif

/* 
 the used UIView and UIScrollView properties keypaths defined here
 in order to accomodate future possible renaming of these properties
 */
#define DZScrollingInspector_CONTENT_OFFSET_KEYPATH @"contentOffset"
#define DZScrollingInspector_CONTENT_INSET_KEYPATH @"contentInset"
#define DZScrollingInspector_FRAME_KEYPATH @"frame"
#define DZScrollingInspector_PAN_STATE_KEYPATH @"pan.state"
#define DZScrollingInspector_ANIMATION_DURATION_PER_ONE_PIXEL 0.0068181818f

@interface CHScrollingToConstraintInspector : NSObject
{
    UIScrollView *_scrollView;
    BOOL _scrollViewIsDragging;
    
    NSLayoutConstraint *_targetConstraint;
    CGFloat _targetConstraintInitialConstant;
    BOOL _isAnimatingTargetConstraint;
    
    DZScrollingInspectorTwoOrientationsLimits _limits;
    
    NSString *_insetKeypath;
    NSString *_offsetKeypath;
    CGFloat _inset;
    CGFloat _offset;
    
    BOOL _isSuspended;
}
-(id)initWithObservedScrollView:(UIScrollView*)scrollView
               andOffsetKeyPath:(NSString*)offsetKeyPath
                andInsetKeypath:(NSString*)insetKeyPath
            andTargetConstraint:(NSLayoutConstraint*)target
                      andLimits:(DZScrollingInspectorTwoOrientationsLimits)limits;

@property DZScrollingInspectorTwoOrientationsLimits limits;

-(void)suspend;
-(void)resume;

-(void)resetTargetToMinLimit;

DZScrollingInspectorTwoOrientationsLimits DZScrollingInspectorTwoOrientationsLimitsMake(CGFloat portraitMin, CGFloat portraitMax, CGFloat landscapeMin, CGFloat landscapeMax);

@end
