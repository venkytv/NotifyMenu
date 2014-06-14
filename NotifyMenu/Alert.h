//
//  Alert.h
//  NotifyMenu
//
//  Created by Venky on 14/06/14.
//  Copyright (c) 2014 Venky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Alert : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * handler;

- (BOOL)isEqualToAlert:(Alert *)item;
- (NSString *)titleWithHandler;

@end
