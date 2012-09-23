//
//  AppDelegate.h
//  Talos
//
//  Created by Saumitro Dasgupta on 8/20/12.
//  Copyright (c) 2012 Saumitro Dasgupta. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AgileKeychain.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

+(AppDelegate*) sharedDelegate;
-(AgileKeychain*) keychain;
-(void) setKeychainPath:(NSString*)newPath;
-(NSString*) keychainPath;

@property (assign) IBOutlet NSWindow *window;

@end
