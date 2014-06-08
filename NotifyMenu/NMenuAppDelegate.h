//
//  NMenuAppDelegate.h
//  NotifyMenu
//
//  Created by Venky on 08/06/14.
//  Copyright (c) 2014 Venky. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NMenuAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readwrite, retain) IBOutlet NSMenu *menu;
@property (readwrite, retain) NSStatusItem *statusItem;
@property (readwrite, retain) NSImage *menuIcon;
@property (readwrite, retain) NSImage *highlightIcon;
@property (readwrite, retain) NSImage *menuIconNoAlerts;
@property (readwrite, retain) NSImage *highlightIconNoAlerts;
@property (readwrite, retain) NSMutableArray *items;
@property (readwrite, retain) NSString *launcher;

- (void)menuAction:(id)sender;
- (void)addAlert:(NSString *)message handler:(NSString *)handler;

@end
