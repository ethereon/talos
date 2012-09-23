//
//  SDHotKey.m
//
//  Created by Saumitro Dasgupta on 9/18/12.
//  Copyright (c) 2012 Saumitro Dasgupta. All rights reserved.
//

#import "SDHotKey.h"
#import <Carbon/Carbon.h>
#include <libkern/OSAtomic.h>

static const OSType kSDHotKeySignature = 'SDHK';
static int32_t gSDHotKeyID = 0;
static NSMutableDictionary* gActiveHotkeys = nil;

@interface SDHotKey ()
@property (readwrite) UInt32 keyCode;
@property (readwrite) UInt32 mask;
@property (assign) UInt32 keyID;
@property (assign) EventHotKeyRef keyRef;
@end

# pragma mark - Event Handling Functions

static NSNumber* lutKeyForHotKeyID(UInt32 keyID)
{
    return [NSNumber numberWithUnsignedInt:keyID];
}

static UInt32 convertMaskFromCocoaToCarbon(UInt32 cocoaMask)
{
    __block UInt32 carbonMask = 0;
    void(^mapMask)(UInt32, UInt32) = ^(UInt32 mskCC, UInt32 mskCB) { if(cocoaMask & mskCC) carbonMask |= mskCB; };
    mapMask(NSCommandKeyMask, cmdKey);
    mapMask(NSAlternateKeyMask, optionKey);
    mapMask(NSControlKeyMask, controlKey);
    mapMask(NSShiftKeyMask, shiftKey);
    return carbonMask;
}

static OSStatus hotKeyEventHandler(EventHandlerCallRef handler, EventRef event, void* userData)
{
    @autoreleasepool
    {
        EventHotKeyID hkID;
        GetEventParameter(event, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkID), NULL, &hkID);
        if(hkID.signature==kSDHotKeySignature)
        {
            SDHotKey* hotKey = [gActiveHotkeys objectForKey:lutKeyForHotKeyID(hkID.id)];
            if(hotKey)
            {
                [hotKey invoke];
            }
            else
            {
                NSLog(@"Received event for hot key with unknown ID: %d", hkID.id);
            }
        }
    }
    return noErr;
}

#pragma mark - SDHotKey 

@implementation SDHotKey

@synthesize keyCode, mask, callback;
@synthesize keyID, keyRef;

+(id) registerHotKeyWithCode:(UInt32)keyCode mask:(UInt32)mask callback:(SDHotKeyAction)block
{
    SDHotKey* hotKey = [[[SDHotKey alloc] init] autorelease];
    [hotKey setKeyCode:keyCode];
    [hotKey setMask:mask];
    [hotKey setCallback:block];
    [hotKey setKeyID:(UInt32)OSAtomicIncrement32(&gSDHotKeyID)];
    if([hotKey activate])
        return hotKey;
    return nil;
}

-(id) init
{
    if(!(self=[super init])) return nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        gActiveHotkeys = [[NSMutableDictionary alloc] init];
        EventTypeSpec eventType;
        eventType.eventClass = kEventClassKeyboard;
		eventType.eventKind = kEventHotKeyReleased;
        InstallApplicationEventHandler(&hotKeyEventHandler, 1, &eventType, NULL, NULL);
    });
    return self;
}

-(void) dealloc
{
    [self deactivate];
    [super dealloc];
}

-(void) invoke
{
    if(callback)
    {
        callback(self);
    }
}

-(BOOL) activate
{
    NSAssert([self keyRef]==nil, @"Attempted to activate an active hotkey.");
    EventHotKeyID hkID;
    hkID.id = [self keyID];
    hkID.signature = kSDHotKeySignature;
    EventHotKeyRef hkRef;
    OSStatus result = RegisterEventHotKey([self keyCode],
                                          convertMaskFromCocoaToCarbon([self mask]),
                                          hkID,
                                          GetEventDispatcherTarget(),
                                          0,
                                          &hkRef);
    if(result==noErr)
    {
        [self setKeyRef:hkRef];
        @synchronized(gActiveHotkeys)
        {
            [gActiveHotkeys setObject:self forKey:lutKeyForHotKeyID([self keyID])];
        }
        return YES;
    }
    return NO;
}

-(void) deactivate
{
    if([self keyRef])
    {
        UnregisterEventHotKey([self keyRef]);
        @synchronized(gActiveHotkeys)
        {
            [gActiveHotkeys removeObjectForKey:lutKeyForHotKeyID([self keyID])];
        }
        [self setKeyRef:nil];
    }
}

@end
