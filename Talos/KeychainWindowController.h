//
//  KeychainWindowController.h
//  Talos
//
//  Created by Saumitro Dasgupta on 9/5/12.
//  Copyright (c) 2012 Saumitro Dasgupta. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KeychainSession.h"

@interface KeychainWindowController : NSWindowController<KeychainSessionDelegate>

-(IBAction) acceptPassword:(id)sender;

@property (nonatomic, assign) IBOutlet NSTableView* keychainTableView;
@property (nonatomic, assign) IBOutlet NSArrayController* arrayController;
@property (nonatomic, retain) IBOutlet NSSearchField* searchField;
@property (nonatomic, retain) IBOutlet NSSecureTextField* passwordField;

@end
