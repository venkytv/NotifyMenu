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

- (BOOL)isEqualToMenuItem:(NMenuItem *)item {
    if (!item) return NO;
    if ([self.message isEqualToString:item.message]
        && (self.handler == item.handler // NULL objects
            || [self.handler isEqualToString:item.handler]) ) {
        return YES;
    }
    return NO;
}

- (BOOL)isEqual:(id)object {
    if (self == object)
        return YES;
    
    if (![object isKindOfClass:[NMenuItem class]])
        return NO;
    
    return [self isEqualToMenuItem:(NMenuItem *)object];
}

- (NSUInteger)hash {
    return ([self.message hash] ^ [self.handler hash]);
}

- (NSString *)title {
    return self.message;
}

@end
