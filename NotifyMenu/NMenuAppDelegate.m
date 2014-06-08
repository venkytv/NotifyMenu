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
            NSMenuItem *menuItem = [menu addItemWithTitle:[item title]
                                               action:@selector(menuAction:) keyEquivalent:@""];
            [menuItem setTag:i];
        }
    } else {
        [statusItem setImage:self.menuIconNoAlerts];
        [statusItem setAlternateImage:self.highlightIconNoAlerts];
        [menu addItemWithTitle:@"No Alerts" action:NULL keyEquivalent:@""];
        [statusItem setToolTip:@""];
        [statusItem setLength:0];
    }
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Clear All" action:clearAllSelector keyEquivalent:@""];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
}

-(void)addAlert:(NSString *)message handler:(NSString *)handler {
    NMenuItem *item = [[NMenuItem alloc] initWithMessage:message handler:handler];
    [self.items addObject:item];
    [self populateMenu];
}

@end
