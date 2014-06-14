//
//  NMenuAppDelegate.m
//  NotifyMenu
//
//  Created by Venky on 08/06/14.
//  Copyright (c) 2014 Venky. All rights reserved.
//

#import "NMenuAppDelegate.h"
#import "NMenuItem.h"

//Globals
NSFileManager *fileManager;

NSString *const HIDE_ICON_WHEN_EMPTY    = @"HideIconWhenEmpty";
NSString *const SUPPRESS_DUPLICATES     = @"SuppressDuplicates";
NSString *const DISPLAY_HANDLERS        = @"DisplayHandlers";

@implementation NMenuAppDelegate


- (id) init {
    fileManager = [[NSFileManager alloc] init];

    self.launcher = [NSString stringWithFormat:@"%@/libexec/notifymenu-alert-handler",
                     [[[NSProcessInfo processInfo] environment] objectForKey:@"HOME" ]];
    self.items = [[NSMutableArray alloc] init];
    self.menuIcon       = [NSImage imageNamed:@"Alerts"];
    self.highlightIcon  = self.menuIcon;
    self.menuIconNoAlerts = [NSImage imageNamed:@"No Alerts"];
    self.highlightIconNoAlerts = self.menuIconNoAlerts;
    
    return [super init];
}

- (void)awakeFromNib {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    NSStatusItem *myStatusItem = [self statusItem];
    [myStatusItem setMenu:[self menu]];
    [myStatusItem setHighlightMode:YES];
    
    [self populateMenu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:NO], HIDE_ICON_WHEN_EMPTY,
                                 [NSNumber numberWithBool:YES], SUPPRESS_DUPLICATES,
                                 [NSNumber numberWithBool:YES], DISPLAY_HANDLERS,
                                 nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
}

- (void)menuAction:(id)sender {
    
    NSUInteger index = [sender tag];
    
    if (index > 0) {
        NMenuItem *item = [self.items objectAtIndex:(index - 1)];
        
        if (! [fileManager isExecutableFileAtPath:self.launcher]) {
            NSLog(@"Launcher not found: %@", self.launcher);
        } else {
            NSString *alertMessage, *alertHandler;
            alertMessage = [item message];
            alertHandler = [item handler];
            if (! alertHandler) alertHandler = @"";
            [NSTask launchedTaskWithLaunchPath:self.launcher
                                     arguments:[NSArray arrayWithObjects:alertMessage, alertHandler, nil]];
        }
        
        [self.items removeObject:item];
        [self populateMenu];

    }

}

- (void)clearAll {
    [self.items removeAllObjects];
    [self populateMenu];
}

- (void)populateMenu {
    NSMenu *menu = self.menu;
    NSStatusItem *statusItem = [self statusItem];
    SEL clearAllSelector = NULL;
    
    [menu removeAllItems];
    
    NSUInteger count = self.items.count;
    if (count > 0) {
        clearAllSelector = @selector(clearAll);
        [statusItem setImage:self.menuIcon];
        [statusItem setAlternateImage:self.highlightIcon];
        [statusItem setLength:NSVariableStatusItemLength];
        
        NSString *tooltip = [[NSString alloc] initWithFormat:@" %lu alert%@ pending ", (unsigned long)count, (count != 1 ? @"s" : @"")];
        [statusItem setToolTip:tooltip];
        for (NSUInteger i = 1; i <= count; i++) {
            NMenuItem *item = [self.items objectAtIndex:(i - 1)];
            NSString *title;
            if ([[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_HANDLERS]) {
                title = item.titleWithHandler;
            } else {
                title = item.title;
            }
            NSMenuItem *menuItem = [menu addItemWithTitle:title
                                               action:@selector(menuAction:) keyEquivalent:@""];
            [menuItem setTag:i];
        }
    } else {
        [statusItem setImage:self.menuIconNoAlerts];
        [statusItem setAlternateImage:self.highlightIconNoAlerts];
        [menu addItemWithTitle:@"No Alerts" action:NULL keyEquivalent:@""];
        [statusItem setToolTip:@""];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:HIDE_ICON_WHEN_EMPTY]) {
            [statusItem setLength:0];
        }
    }
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Clear All" action:clearAllSelector keyEquivalent:@""];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
}

-(void)addAlert:(NSString *)message handler:(NSString *)handler {
    NMenuItem *item = [[NMenuItem alloc] initWithMessage:message handler:handler];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SUPPRESS_DUPLICATES]) {
        NSMutableArray *duplicates = [[NSMutableArray alloc] init];
        for (NMenuItem *existing in self.items) {
            if ([existing isEqualToMenuItem:item]) {
                [duplicates addObject:existing];
            }
        }
        for (NMenuItem *duplicate in duplicates)
            [self.items removeObject:duplicate];
    }
    
    [self.items addObject:item];
    [self populateMenu];
}

@end
