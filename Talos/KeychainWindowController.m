//
//  KeychainWindowController.m
//  Talos
//
//  Created by Saumitro Dasgupta on 9/5/12.
//  Copyright (c) 2012 Saumitro Dasgupta. All rights reserved.
//

#import "KeychainWindowController.h"
#import "AppDelegate.h"
#import "NSWindow+ShakingAnimation.h"
#import "SDHotKey.h"

static const UInt32 kHotKeyCode = 0x12; //The 1 key
static const CGFloat kCollapsedWindowHeight = 65;
static const CGFloat kExpandedWindowHeight = 275;
static const NSTimeInterval kSessionDuration = 5*60.0;

@interface KeychainWindowController ()
@property (assign) AgileKeychain* keychain;
@property (retain) KeychainSession* session;
@property (retain) SDHotKey* hotKey;
@end

@implementation KeychainWindowController

@synthesize keychainTableView, arrayController, searchField, passwordField;
@synthesize keychain, session, hotKey;

-(id) init
{
    if(!(self=[super initWithWindowNibName:@"KeychainManagerWindow"])) return nil;
    [self setSession:[KeychainSession sessionWithTimeout:kSessionDuration]];
    [[self session] setDelegate:self];
    return self;
}

-(void) dealloc
{
    [self setHotKey:nil];
    [self setSearchField:nil];
    [self setPasswordField:nil];
    [super dealloc];
}

-(void) setWindowHeight:(CGFloat)h animate:(BOOL)animate
{
    NSRect f = [[self window] frame];
    CGFloat delta = NSHeight(f)-h;
    f.origin.y += delta;
    f.size.height = h;
    [[self window] setFrame:f display:YES animate:animate];
}

-(void) setActiveField:(NSView*)field
{
    NSView* parentView = [[self window] contentView];
    if([field superview]==parentView) return;
    NSView* activeView = (field==searchField)?passwordField:searchField;
    [field setFrame:[activeView frame]];
    [parentView replaceSubview:activeView with:field];
    [[self window] makeFirstResponder:field];
}

-(void) collapse
{
    [self setWindowHeight:kCollapsedWindowHeight animate:NO];
    [keychainTableView setHidden:YES];
    [[keychainTableView enclosingScrollView] setHidden:YES];
    [self setActiveField:passwordField];
}

-(void) expand
{
    [keychainTableView setHidden:NO];
    [[keychainTableView enclosingScrollView] setHidden:NO];
    [keychainTableView reloadData];
    [self setActiveField:searchField];
    [self setWindowHeight:kExpandedWindowHeight animate:YES];
}

-(void) setInitialWindowState
{
    [self collapse];
    [[self window] center];
    [[self window] activateShakeAnimation];
    [[self window] setLevel:NSFloatingWindowLevel];
}

-(void) windowDidLoad
{
    [super windowDidLoad];
    
    //Acquire the keychain file, or quit if the user cancels.
    while(!(keychain = [[AppDelegate sharedDelegate] keychain]))
    {
        NSOpenPanel* openPanel = [NSOpenPanel openPanel];
        [openPanel setTitle:NSLocalizedString(@"Select the keychain file", @"Title")];
        [openPanel setMessage:NSLocalizedString(@"Please select your 1Password keychain file", @"Message")];
        [openPanel setPrompt:NSLocalizedString(@"Choose", @"Prompt")];
        [openPanel setAllowsMultipleSelection:NO];
        [openPanel setAllowedFileTypes:@[@"agilekeychain"]];
        [openPanel setCanChooseDirectories:YES];
        NSInteger result = [openPanel runModal];
        if(result==NSFileHandlingPanelCancelButton)
        {
            [NSApp terminate:self];
            return;
        }
        [[AppDelegate sharedDelegate] setKeychainPath:[[openPanel URL] path]];
    }
    
    //Register global hot key
    [self setHotKey:[SDHotKey registerHotKeyWithCode:kHotKeyCode
                                                mask:NSCommandKeyMask | NSShiftKeyMask
                                            callback:^(SDHotKey* hk) {
                                                
                                                [self showWindow:nil];
                                            }]];
    
    //Collapsing the window directly here will cause the field editor's position to be glitchy.
    //So, we do it in the next cycle and everything works fine.
    [self performSelector:@selector(setInitialWindowState) withObject:nil afterDelay:0.0];
}

-(BOOL) copyPasswordForSelectedItem
{
    NSInteger idx = [keychainTableView selectedRow];
    BOOL isValid = (idx!=-1);
    if(isValid)
    {
        AgileKeychainItem* item = [[arrayController arrangedObjects] objectAtIndex:idx];
        NSPasteboard* pb = [NSPasteboard generalPasteboard];
        [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
        [pb setString:[item password] forType:NSStringPboardType];
    }
    return isValid;
}

-(IBAction) acceptPassword:(id)sender
{
    NSString* password = [passwordField stringValue];
    if([keychain unlockWithPassword:password])
    {
        [[self session] begin];
        [arrayController bind:@"contentArray" toObject:keychain withKeyPath:@"items" options:nil];
        [keychainTableView reloadData];
        [self expand];
        [passwordField setStringValue:@""];
    }
    else
    {
        [[self window] shake];
    }
}

-(void) lockKeychain:(id)sender
{
    //Invoked via the shortcut
    [[self window] close];
    [self lock];
}

-(void) lock
{
    if([keychain isUnlocked])
    {
        [[self session] end];
        [self collapse];
        [keychain lock];
    }
}

#pragma mark - Search + Password field key handling

-(BOOL) control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
    BOOL isSearchField = (control==searchField);
    BOOL isPasswordField = (control==passwordField);
    
    if(isSearchField)
    {
        BOOL isMoveDown = (command==@selector(moveDown:));
        if(isMoveDown || command==@selector(moveUp:))
        {
            //Propagate the UP/DOWN arrow key movements in the search field to the table
            NSInteger idx = [keychainTableView selectedRow];
            if(idx>=0)
            {
                idx = (idx + (isMoveDown?1:-1));
                if(idx<0) idx += [keychainTableView numberOfRows];
                idx %= [keychainTableView numberOfRows];
                [keychainTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:idx] byExtendingSelection:NO];
                [keychainTableView scrollRowToVisible:idx];
                return YES;
            }
        }
        else if(command==@selector(insertNewline:))
        {
            if([self copyPasswordForSelectedItem])
            {
                [[self window] close];
            }
            return YES;
        }
    }
    
    if(isSearchField || isPasswordField)
    {
        if(command==@selector(cancelOperation:) && (isPasswordField || ([[control stringValue] length]==0)))
        {
            [[self window] close];
            return YES;
        }
    }
    
    return NO;
}


#pragma mark - Keychain Session Delegate Methods

-(void) sessionDidTimeout:(id)session
{
    [self lock];
}

@end
