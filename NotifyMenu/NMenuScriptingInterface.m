//
//  NMenuScriptingInterface.m
//  NotifyMenu
//
//  Created by Venky on 08/06/14.
//  Copyright (c) 2014 Venky. All rights reserved.
//

#import "NMenuScriptingInterface.h"
#import "NMenuAppDelegate.h"

@implementation NMenuScriptingInterface

-(id)performDefaultImplementation {
    NSString *currentCommand = [[self commandDescription] commandName];
    NSDictionary *args = [self evaluatedArguments];
    
    if ([currentCommand isEqualToString:@"add alert"]) {
        if (args.count) {
            NMenuAppDelegate *delegate = [NSApp delegate];
            NSString *handler = [args valueForKey:@"handler"];
            [delegate addAlert:[self directParameter] handler:handler];
        } else {
            [self setScriptErrorNumber:-50];
            [self setScriptErrorString:@"Expected item to add to alert list"];
        }
        
        
    } else {
        // Unknown command
        return [super performDefaultImplementation];
    }
    
    return nil;
}


@end
