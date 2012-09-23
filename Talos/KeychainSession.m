//
//  KeychainSession.m
//  Talos
//
//  Created by Saumitro Dasgupta on 9/18/12.
//  Copyright (c) 2012 Saumitro Dasgupta. All rights reserved.
//

#import "KeychainSession.h"

@interface KeychainSession ()
@property (assign) NSTimeInterval timeout;
@property (assign) NSTimer* timer;
@end

@implementation KeychainSession

@synthesize delegate;
@synthesize timeout, timer;

+(id) sessionWithTimeout:(NSTimeInterval)timeout
{
    KeychainSession* session = [[[KeychainSession alloc] init] autorelease];
    [session setTimeout:timeout];
    return session;
}

-(void) begin
{
    if(![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(begin)
                               withObject:nil
                            waitUntilDone:YES];
        return;
    }
    
    NSAssert(timer==nil, @"Attempted to start a session while it's already active.");
    timer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                             target:self
                                           selector:@selector(sessionDidTimeout:)
                                           userInfo:nil
                                            repeats:NO];
}

-(void) end
{
    if(![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(end) withObject:nil waitUntilDone:YES];
        return;
    }
    
    if([timer isValid])
    {
        [timer invalidate];
    }
    [self setTimer:nil];
}

-(void) sessionDidTimeout:(NSTimer*)timer
{
    [self end];
    if([delegate respondsToSelector:@selector(sessionDidTimeout:)])
    {
        [delegate sessionDidTimeout:self];
    }
}

@end
