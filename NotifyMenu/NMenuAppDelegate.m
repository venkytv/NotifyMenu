//
//  NMenuAppDelegate.m
//  NotifyMenu
//
//  Created by Venky on 08/06/14.
//  Copyright (c) 2014 Venky. All rights reserved.
//

#import "NMenuAppDelegate.h"
#import "Alert.h"
#import "Constants.h"

//Globals
NSFileManager *fileManager;

NSString *const HIDE_ICON_WHEN_EMPTY    = @"HideIconWhenEmpty";
NSString *const SUPPRESS_DUPLICATES     = @"SuppressDuplicates";
NSString *const DISPLAY_HANDLERS        = @"DisplayHandlers";

NSString *const ALERT_ENTITY            = @"Alert";

@implementation NMenuAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (id) init {
    fileManager = [[NSFileManager alloc] init];

    self.launcher = [NSString stringWithFormat:@"%@/libexec/notifymenu-alert-handler",
                     [[[NSProcessInfo processInfo] environment] objectForKey:@"HOME" ]];
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
    NSArray *items = [self allAlerts];
    
    if (index > 0) {
        Alert *item = [items objectAtIndex:(index - 1)];
        
        if (! [fileManager isExecutableFileAtPath:self.launcher]) {
            NSLog(@"Launcher not found: %@", self.launcher);
        } else {
            NSString *alertMessage, *alertHandler;
            alertMessage = item.title;
            alertHandler = item.handler;
            if (! alertHandler) alertHandler = @"";
            [NSTask launchedTaskWithLaunchPath:self.launcher
                                     arguments:[NSArray arrayWithObjects:alertMessage, alertHandler, nil]];
        }
        
        [self removeAlert:item];
        [self populateMenu];
    }

}

- (void)clearAll {
    NSArray *items = [self allAlerts];
    NSManagedObjectContext *context = [self managedObjectContext];
    for (Alert *item in items) {
        [context deleteObject:item];
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error saving alert: %@", [error localizedDescription]);
    }
    [self populateMenu];
}

- (void)populateMenu {
    NSMenu *menu = self.menu;
    NSStatusItem *statusItem = [self statusItem];
    SEL clearAllSelector = NULL;
    
    [menu removeAllItems];
    
    NSArray *items = [self allAlerts];
    NSUInteger count = items.count;
    if (count > 0) {
        clearAllSelector = @selector(clearAll);
        [statusItem setImage:self.menuIcon];
        [statusItem setAlternateImage:self.highlightIcon];
        [statusItem setLength:NSVariableStatusItemLength];
        
        NSString *tooltip = [[NSString alloc] initWithFormat:@" %lu alert%@ pending ", (unsigned long)count, (count != 1 ? @"s" : @"")];
        [statusItem setToolTip:tooltip];
        
        for (NSUInteger i = 1; i <= count; i++) {
            Alert *item = [items objectAtIndex:(i - 1)];
            NSMenuItem *menuItem = [menu addItemWithTitle:item.titleWithHandler
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
    NSError *error;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    Alert *item = [NSEntityDescription insertNewObjectForEntityForName:ALERT_ENTITY
                                                inManagedObjectContext:context];
    item.title = message;
    item.handler = handler;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SUPPRESS_DUPLICATES]) {
        NSMutableArray *duplicates = [[NSMutableArray alloc] init];
        NSArray *items = [self allAlerts];
        for (Alert *existing in items) {
            if (item != existing && [existing isEqualToAlert:item]) {
                [duplicates addObject:existing];
            }
        }
        for (Alert *duplicate in duplicates)
            [context deleteObject:duplicate];
    }
    
    if (![context save:&error]) {
        NSLog(@"Error saving alert: %@", [error localizedDescription]);
    }

    [self populateMenu];
}

- (NSArray *)allAlerts {
    NSError *error;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ALERT_ENTITY
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    if (!items) {
        NSLog(@"Error fetching all alerts: %@", [error localizedDescription]);
    }
    return items;
}

- (void)removeAlert:(Alert *)alert {
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:alert];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error saving alert: %@", [error localizedDescription]);
    }
}

// Core Data Boilerplate Code

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.duh-uh.NotifyMenu" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.duh-uh.NotifyMenu"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"NotifyMenu.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

@end
