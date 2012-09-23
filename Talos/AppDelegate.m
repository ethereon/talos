//
//  AppDelegate.m
//  Talos
//
//  Created by Saumitro Dasgupta on 8/20/12.
//  Copyright (c) 2012 Saumitro Dasgupta. All rights reserved.
//

#import "AppDelegate.h"
#import "AgileKeychain.h"
#import "KeychainWindowController.h"

NSString* const kTalosAgileKeychainPathKey = @"AgileKeychainPath";

@interface AppDelegate ()
@property (retain) KeychainWindowController* keychainWindowController;
@property (nonatomic, retain) AgileKeychain* keychain;
@end

@implementation AppDelegate

@synthesize keychainWindowController;
@synthesize keychain;

+(AppDelegate*) sharedDelegate
{
    return [NSApp delegate];
}

-(void) dealloc
{
    [super dealloc];
}

-(void) applicationDidFinishLaunching:(NSNotification*)aNotification
{
    keychainWindowController = [[KeychainWindowController alloc] init];
    [keychainWindowController showWindow:self];
}

-(AgileKeychain*) keychain
{
    if(!keychain)
    {
        NSString* keychainPath = [[NSUserDefaults standardUserDefaults] stringForKey:kTalosAgileKeychainPathKey];
        if(!(keychainPath && [[NSFileManager defaultManager] fileExistsAtPath:keychainPath])) return NO;
        keychain = [[AgileKeychain alloc] initWithPath:keychainPath name:nil];
    }
    return keychain;
}

-(void) setKeychainPath:(NSString*)newPath
{
    [[NSUserDefaults standardUserDefaults] setObject:newPath forKey:kTalosAgileKeychainPathKey];
}

-(NSString*) keychainPath
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kTalosAgileKeychainPathKey];
}

@end
