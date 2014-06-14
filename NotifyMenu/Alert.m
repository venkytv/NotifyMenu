//
//  Alert.m
//  NotifyMenu
//
//  Created by Venky on 14/06/14.
//  Copyright (c) 2014 Venky. All rights reserved.
//

#import "Alert.h"
#import "Constants.h"

@implementation Alert

@dynamic title;
@dynamic handler;

- (BOOL)isEqualToAlert:(Alert *)item {
    if (!item) return NO;
    if ([self.title isEqualToString:item.title]
        && (self.handler == item.handler // NULL objects
            || [self.handler isEqualToString:item.handler]) ) {
            return YES;
        }
    return NO;
}

- (NSString *)titleWithHandler {
    BOOL withHandler = [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_HANDLERS];
    if (!withHandler) return self.title;
    if (self.handler == (id)[NSNull null] || self.handler.length == 0)
        return self.title;
    return [NSString stringWithFormat:@"%@ (%@)", self.title, self.handler];
}

@end
