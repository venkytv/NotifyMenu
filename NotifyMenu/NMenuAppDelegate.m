//
//  NMenuAppDelegate.m
//  NotifyMenu
//
//  Created by Venky on 08/06/14.
//  Copyright (c) 2014 Venky. All rights reserved.
//

#import "NMenuAppDelegate.h"

//Globals
NSFileManager *fileManager;

@implementation NMenuAppDelegate


- (id) init {
    fileManager = [[NSFileManager alloc] init];

    self.launcher = [NSString stringWithFormat:@"%@/libexec/alert-handler",
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
    NSLog(@"menuAction: %@: %@, %ld", sender, self.launcher, (long)[sender tag]);
    if (! [fileManager isExecutableFileAtPath:self.launcher]) {
        NSLog(@"Launcher not found: %@", self.launcher);
        return;
    }
    
    NSUInteger index = [sender tag];
    if (index > 0)
        [self.items removeObjectAtIndex:(index - 1)];
    
    [self populateMenu];
    
    [NSTask launchedTaskWithLaunchPath:self.launcher
                             arguments:[NSArray arrayWithObjects:[sender title], nil]];

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
        for (NSUInteger i = 1; i <= count; i++) {
            NSMenuItem *item = [menu addItemWithTitle:(NSString *)[self.items objectAtIndex:(i - 1)]
                                               action:@selector(menuAction:) keyEquivalent:@""];
            [item setTag:i];
        }
    } else {
        [statusItem setImage:self.menuIconNoAlerts];
        [statusItem setAlternateImage:self.highlightIconNoAlerts];
        [menu addItemWithTitle:@"No Alerts" action:NULL keyEquivalent:@""];
    }
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Clear All" action:clearAllSelector keyEquivalent:@""];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
}

-(void)addAlert:(NSString *)message {
    [self.items addObject:message];
    [self populateMenu];
}

@end
