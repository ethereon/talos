//
//  SDHotKey.h
//
//  This is a wrapper over Carbon's HotKey api. As of OS X 10.8,
//  this is still the only publicly accessible way of registering
//  global hotkeys. The required Carbon code is 64-bit compatible.
//
//  Created by Saumitro Dasgupta on 9/18/12.
//  Copyright (c) 2012 Saumitro Dasgupta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDHotKey;

typedef void(^SDHotKeyAction)(SDHotKey*);

@interface SDHotKey : NSObject

//Use Cocoa modifier masks (eg: NSCommandKeyMask | NSShiftKeyMask)
+(id) registerHotKeyWithCode:(UInt32)keyCode mask:(UInt32)mask callback:(SDHotKeyAction)block;

//Automatically called by the +register... selector.
-(BOOL) activate;

//Is automatically called on dealloc. Can be manually invoked earlier if required.
-(void) deactivate;

//Called when the hotkey is pressed. The default implementation calls the block.
-(void) invoke;

@property (readonly) UInt32 keyCode;
@property (readonly) UInt32 mask;
@property (copy) SDHotKeyAction callback;

@end
