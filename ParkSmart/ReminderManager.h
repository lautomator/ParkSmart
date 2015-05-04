//
//  ReminderManager.h
//  ParkSmart
//
//  Created by Rao, Amit on 3/2/15.
//  Copyright (c) 2015 Rao, Amit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReminderManager : NSObject

+ (instancetype)sharedInstance;
- (void)setReminder:(NSString *)expiryTimeString Before:(NSInteger)mins;

@end
