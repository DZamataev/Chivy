//
//  CHScrollingInspector.m
//  Chivy
//  Derived from DZScrollingInspector.h
//  DZTSMiniWebBrowser
//
//
//  Created by Denis Zamataev on 9/2/13.
//  Copyright (c) 2013 Denis Zamataev. All rights reserved.
//

#import "CHScrollingToConstraintInspector.h"

@implementation CHScrollingToConstraintInspector

@synthesize limits = _limits;

- (id)initWithObservedScrollView:(UIScrollView *)scrollView
                andOffsetKeyPath:(NSString *)offsetKeyPath
                 andInsetKeypath:(NSString *)insetKeyPath
             andTargetConstraint:(NSLayoutConstraint *)target
                       andLimits:(DZScrollingInspectorTwoOrientationsLimits)limits
{
    if (self = [super init])
    {
        // defaults
        _isSuspended = NO;
        _isAnimatingTargetConstraint = NO;
        
        // arguments to properties
        _scrollView = scrollView;
        _targetConstraint = target;
        _limits = limits;
        _offsetKeypath = offsetKeyPath;
        _insetKeypath = insetKeyPath;
        
        // get more parameters from target
        _offset = [CHScrollingToConstraintInspector contentOffsetValueForKey:offsetKeyPath fromObject:scrollView];
        _inset = [CHScrollingToConstraintInspector contentInsetValueForKey:insetKeyPath fromObject:scrollView];
        
        _targetConstraintInitialConstant = target.constant;
        
        [self registerAsObserver];
    }
    return self;
}

// Apple documentation about the observing https://developer.apple.com/library/ios/DOCUMENTATION/Cocoa/Conceptual/KeyValueObserving/Articles/KVOBasics.html
- (void)registerAsObserver {
    /*
     Register self to receive change notifications for the "_keypath_" property of
     the 'scrollView' object and specify that both the old and new values of "_keypath_"
     should be provided in the observe… method.
     */
    [_scrollView addObserver:self
                  forKeyPath: DZScrollingInspector_CONTENT_OFFSET_KEYPATH
                 options:(NSKeyValueObservingOptionNew |
                          NSKeyValueObservingOptionOld)
                 context:NULL];
    
    [_scrollView addObserver:self
                  forKeyPath: DZScrollingInspector_CONTENT_INSET_KEYPATH
                     options:(NSKeyValueObservingOptionNew |
                              NSKeyValueObservingOptionOld)
                     context:NULL];
    
    [_scrollView addObserver:self
                  forKeyPath: DZScrollingInspector_PAN_STATE_KEYPATH
                     options:(NSKeyValueObservingOptionNew |
                              NSKeyValueObservingOptionOld)
                     context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    CGFloat offset = 0.0f;
    CGFloat inset = 0.0f;
    
    BOOL offsetChanged = NO;
    BOOL insetChanged = NO;
    BOOL startedDragging = NO;
    BOOL endedDragging = NO;
    
    if ([keyPath isEqual:DZScrollingInspector_CONTENT_OFFSET_KEYPATH]) {
        NSValue *newValue = [change objectForKey:NSKeyValueChangeNewKey];
        offset = [CHScrollingToConstraintInspector contentOffsetValueForKey:_offsetKeypath fromCGPoint:newValue.CGPointValue];
        
        if (offset != _offset)
            offsetChanged = YES;
    }
    
    
    if ([keyPath isEqual:DZScrollingInspector_CONTENT_INSET_KEYPATH]) {
        NSValue *newValue = [change objectForKey:NSKeyValueChangeNewKey];
        
        inset = [CHScrollingToConstraintInspector contentInsetValueForKey:_insetKeypath fromUIEdgeInsets:newValue.UIEdgeInsetsValue];
        
        if (inset != _inset)
            insetChanged = YES;
    }
    
    if ([keyPath isEqual:DZScrollingInspector_PAN_STATE_KEYPATH]) {
        NSNumber *newNumber = [change objectForKey:NSKeyValueChangeNewKey];
        NSNumber *oldNumber = [change objectForKey:NSKeyValueChangeOldKey];
        UIGestureRecognizerState newPanState = newNumber.intValue;
        UIGestureRecognizerState oldPanState = oldNumber.intValue;
        
        if (newPanState != oldPanState) {
            switch (newPanState) {
                case UIGestureRecognizerStateBegan:
                    startedDragging = YES;
                    break;
                    
                case UIGestureRecognizerStateEnded:
                    endedDragging = YES;
                    break;
                    
                default:
                    break;
            }
        }
        
    }
    
    if (offsetChanged) {
        inset = _inset;
        DZScrollingInspectorLog(@"new offset: %f", offset);
    }
    if (insetChanged) {
        offset = _offset;
        DZScrollingInspectorLog(@"new inset: %f", inset);
    }
    
    // reaction
    if (!_isSuspended) {
        if (insetChanged || offsetChanged) {
            
            if ((_scrollView.isDragging && !_isAnimatingTargetConstraint) ||
                (- offset < _inset && !_isAnimatingTargetConstraint)) {
                [self assumeShiftDeltaAndApplyToTargetAccordingToOffset:offset andInset:inset];
            }
        }
        else if (startedDragging || endedDragging) {
            
            BOOL scrollingBeyondBounds = NO;
            if (_offset < 0 && -_offset < _inset) {
                scrollingBeyondBounds = YES;
            }
            
            if (endedDragging && ![self isLimitForCurrentInterfaceOrientationReached] && !scrollingBeyondBounds && !_isAnimatingTargetConstraint) {
                [self animateTargetToReachLimitForCurrentDirection];
            }
        }
    }
    
    
    
    // set stored values
    if (offsetChanged) {
        _offset = offset;
    }
    if (insetChanged) {
        _inset = inset;
    }
    
    /*
     Be sure to call the superclass's implementation *if it implements it*.
     NSObject does not implement the method.
     
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
     */
}

- (void)unregisterAsObserver {
    [_scrollView removeObserver:self forKeyPath:DZScrollingInspector_CONTENT_OFFSET_KEYPATH];
    [_scrollView removeObserver:self forKeyPath:DZScrollingInspector_CONTENT_INSET_KEYPATH];
    [_scrollView removeObserver:self forKeyPath:DZScrollingInspector_PAN_STATE_KEYPATH];
}

- (void)assumeShiftDeltaAndApplyToTargetAccordingToOffset:(CGFloat)newOffset andInset:(CGFloat)newInset
{
    
    
        
    // calculate movement delta
    CGFloat delta = (newInset + newOffset) - (_inset + _offset);
    
    CGFloat existingValue = [self getTargetCurrentValue];
    
    BOOL existingValuePassesLimitation = NO;
    BOOL scrollingBeyondBounds = NO; // means bouncing
    CGFloat directionCoefficient = 1.0f;
    
    DZScrollingInspectorLimit l = [self limitForCurrentInterfaceOrientation];
    
    if (l.min < l.max &&
        existingValue >= l.min && existingValue <= l.max) {
        existingValuePassesLimitation = YES;
        directionCoefficient = 1.0f;
    }
    else if (l.min > l.max &&
         existingValue <= l.min && existingValue >= l.max) {
        existingValuePassesLimitation = YES;
        directionCoefficient = -1.0f;
    }
    
    if (newOffset < -newInset) {
        scrollingBeyondBounds = YES;
    }
    
    
    if (existingValuePassesLimitation && !scrollingBeyondBounds) {
        CGFloat shiftedValue = existingValue + delta * directionCoefficient;
        shiftedValue = [CHScrollingToConstraintInspector clampFloat:shiftedValue withMinimum:l.min andMaximum:l.max];
        
        
        
        if (existingValue != shiftedValue) {
            [self setTargetNewValue:shiftedValue];
        }
    }
}

- (void)animateTargetToReachLimitForCurrentDirection
{
    NSNumber *targetValueThatMatchesLimit = nil;
    DZScrollingInspectorLimit currentLimit = [self limitForCurrentInterfaceOrientation];
    CGFloat currentTargetValue = [self getTargetCurrentValue];
    CGFloat lowerLimit = MIN(currentLimit.min, currentLimit.max);
    CGFloat higherLimit = MAX(currentLimit.min, currentLimit.max);
    CGFloat distance = fabsf(higherLimit - lowerLimit);
    
    
    
    CGFloat halfPassed = lowerLimit + distance/2;
    
    
    CGFloat distanceLeft = 0.0f;
    
    if (currentLimit.min < currentLimit.max) {
        if (currentTargetValue < halfPassed) {
            targetValueThatMatchesLimit = [NSNumber numberWithFloat:currentLimit.min];
            distanceLeft = currentTargetValue - currentLimit.min;
        }
        else {
            targetValueThatMatchesLimit = [NSNumber numberWithFloat:currentLimit.max];
            distanceLeft = currentLimit.max - currentTargetValue;
        }
    }
    else {
        if (currentTargetValue < halfPassed)  {
            targetValueThatMatchesLimit = [NSNumber numberWithFloat:currentLimit.max];
            distanceLeft = currentTargetValue - currentLimit.max;
        }
        else {
            targetValueThatMatchesLimit = [NSNumber numberWithFloat:currentLimit.min];
            distanceLeft = currentLimit.min - currentTargetValue;
        }
    }
    
    
    CGFloat animationDuration = distanceLeft * DZScrollingInspector_ANIMATION_DURATION_PER_ONE_PIXEL;
    
    
    if (targetValueThatMatchesLimit) {
        if ([_targetConstraint isKindOfClass:[NSLayoutConstraint class]]) {
            [UIView animateWithDuration:animationDuration
                                  delay:0.0f
                                options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                _isAnimatingTargetConstraint = true;
                [self setTargetNewValue:targetValueThatMatchesLimit.floatValue];
            }
                             completion:^(BOOL finished) {
                _isAnimatingTargetConstraint = false;
            }];
        }
    }
}

- (BOOL)isLimitForCurrentInterfaceOrientationReached
{
    CGFloat currentTargetValue = [self getTargetCurrentValue];
    DZScrollingInspectorLimit currentLimit = [self limitForCurrentInterfaceOrientation];
    return currentTargetValue == currentLimit.min || currentTargetValue == currentLimit.max;
}

- (DZScrollingInspectorLimit)limitForCurrentInterfaceOrientation
{
    UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    return UIInterfaceOrientationIsPortrait(currentInterfaceOrientation) ? _limits.portraitLimit : _limits.landscapeLimit;
}

- (CGFloat)getTargetCurrentValue
{
    return _targetConstraint.constant;
}

- (void)setTargetNewValue:(CGFloat)newValue
{
    _targetConstraint.constant = newValue;
}

-(void)dealloc
{
    [self unregisterAsObserver];
}

#pragma mark - Public methods

-(void)suspend
{
    _isSuspended = YES;
}

-(void)resume
{
    _isSuspended = NO;
}

-(void)resetTargetToMinLimit
{
    [self setTargetNewValue:[self limitForCurrentInterfaceOrientation].min];
}

#pragma mark - Static helpers
/*
 clamps the value to lie betweem minimum and maximum;
 if minimum is smaller than maximum - they will be swapped;
 */
+(CGFloat)clampFloat:(CGFloat)value withMinimum:(CGFloat)min andMaximum:(CGFloat)max {
    CGFloat realMin = min < max ? min : max;
    CGFloat realMax = max >= min ? max : min;
    return MAX(realMin, MIN(realMax, value));
}

/*
 possible keys:
 x
 y
 */
+(CGFloat)contentOffsetValueForKey:(NSString*)key fromObject:(id)object
{
    if (!object) {
        [NSException raise:NSInvalidArgumentException format:@"Argument 'object' must be non-nil"];
    }
    if (!key) {
        [NSException raise:NSInvalidArgumentException format:@"Argument 'key' must be non-nil"];
    }
    
    NSValue *contentOffsetValue = [object valueForKeyPath:DZScrollingInspector_CONTENT_OFFSET_KEYPATH];
    CGFloat contentOffsetFloat = [CHScrollingToConstraintInspector contentOffsetValueForKey:key fromCGPoint:contentOffsetValue.CGPointValue];
    return contentOffsetFloat;
}

+(CGFloat)contentOffsetValueForKey:(NSString*)key fromCGPoint:(CGPoint)contentOffsetPoint
{
    if (!key) {
        [NSException raise:NSInvalidArgumentException format:@"Argument 'key' must be non-nil"];
    }
    
    NSDictionary *contentOffsetDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithFloat:contentOffsetPoint.y], @"y",
                                             [NSNumber numberWithFloat:contentOffsetPoint.x], @"x",
                                             nil];
    
    NSNumber *offsetNumber = [contentOffsetDictionary objectForKey:key];
    
    return offsetNumber.floatValue;
}

/*
 possible keys:
 top
 bottom
 left
 right
 */
+(CGFloat)contentInsetValueForKey:(NSString*)key fromObject:(id)object
{
    if (!object) {
        [NSException raise:NSInvalidArgumentException format:@"Argument 'object' must be non-nil"];
    }
    if (!key) {
        [NSException raise:NSInvalidArgumentException format:@"Argument 'key' must be non-nil"];
    }
    
    NSValue *contentInsetValue = [object valueForKeyPath:DZScrollingInspector_CONTENT_INSET_KEYPATH];
    UIEdgeInsets contentInsetEdgeInsets = contentInsetValue.UIEdgeInsetsValue;
    
    return [CHScrollingToConstraintInspector contentInsetValueForKey:key fromUIEdgeInsets:contentInsetEdgeInsets];
}

+(CGFloat)contentInsetValueForKey:(NSString*)key fromUIEdgeInsets:(UIEdgeInsets)contentInsetEdgeInsets
{
    if (!key) {
        [NSException raise:NSInvalidArgumentException format:@"Argument 'key' must be non-nil"];
    }
    
    NSDictionary *contentInsetDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithFloat:contentInsetEdgeInsets.top], @"top",
                                            [NSNumber numberWithFloat:contentInsetEdgeInsets.bottom], @"bottom",
                                            [NSNumber numberWithFloat:contentInsetEdgeInsets.left], @"left",
                                            [NSNumber numberWithFloat:contentInsetEdgeInsets.right], @"right",
                                            nil];
    
    NSNumber *insetNumber = [contentInsetDictionary objectForKey:key];
    
    return insetNumber.floatValue;
}

@end
