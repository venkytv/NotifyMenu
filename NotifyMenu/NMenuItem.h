//
//  NMenuItem.h
//  NotifyMenu
//
//  Created by Venky on 08/06/14.
//  Copyright (c) 2014 Venky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NMenuItem : NSObject

@property (readwrite, retain) NSString *message;
@property (readwrite, retain) NSString *handler;

- (id)initWithMessage:(NSString *)message;
- (id)initWithMessage:(NSString *)message handler:(NSString *)handler;

- (BOOL)isEqualToMenuItem:(NMenuItem *)item;

- (NSString *)title;

@end
