//
//  NSWindow+ShakingAnimation.m
//
//  Based on a post by Bill Dudney on the Cocoa mailing list.
//
//  Created by Saumitro Dasgupta on 9/9/12.
//  Copyright (c) 2012 Saumitro Dasgupta. All rights reserved.
//

#import "NSWindow+ShakingAnimation.h"
#import <QuartzCore/QuartzCore.h>

@implementation NSWindow (ShakingAnimation)

+(CAKeyframeAnimation*) _shakeAnimationForFrame:(NSRect)frame
{
    const int nShakes = 2;
    const CGFloat animDuration = 0.3;
    const CGFloat offset = 10.0f;
    
    CGFloat mX = NSMinX(frame), mY = NSMinY(frame);
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animation];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, mX, mY);
    for(int i=0; i<nShakes; ++i)
    {
        CGPathAddLineToPoint(path, NULL, mX - offset, mY);
        CGPathAddLineToPoint(path, NULL, mX + offset, mY);
    }
    CGPathCloseSubpath(path);
    [animation setPath:path];
    [animation setDuration:animDuration];
    [animation setCalculationMode:kCAAnimationPaced];
    CGPathRelease(path);
    return animation;
}

-(void) activateShakeAnimation
{
    CAKeyframeAnimation* anim = [NSWindow _shakeAnimationForFrame:[self frame]];
    [self setAnimations:@{ @"frameOrigin" : anim }];
}

-(void) shake
{
    [[self animator] setFrameOrigin:[self frame].origin];
}

@end
