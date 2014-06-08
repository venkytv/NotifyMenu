//
//  NMenuItem.m
//  NotifyMenu
//
//  Created by Venky on 08/06/14.
//  Copyright (c) 2014 Venky. All rights reserved.
//

#import "NMenuItem.h"

@implementation NMenuItem

- (id)initWithMessage:(NSString *)message {
    self = [super init];
    
    if (self) {
        self.message = message;
        self.handler = NULL;
    }
    return self;
}

- (id)initWithMessage:(NSString *)message handler:(NSString *)handler {
    self = [super init];
    
    if (self) {
        self.message = message;
        self.handler = handler;
    }
    return self;
}

- (NSString *)title {
    return self.message;
}

@end
