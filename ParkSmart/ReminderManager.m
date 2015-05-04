//
//  ReminderManager.m
//  ParkSmart
//
//  Created by Rao, Amit on 3/2/15.
//  Copyright (c) 2015 Rao, Amit. All rights reserved.
//

#import "ReminderManager.h"

@implementation ReminderManager

+ (instancetype)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)setReminder:(NSString *)expiryTimeString Before:(NSInteger)mins
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSDate *expiryTime = [self convertTo24HourFormat:expiryTimeString];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setMinute:-mins];
    if(expiryTime)
    {
        NSDate *alarmTime = [calendar dateByAddingComponents:components toDate:expiryTime options:0];

#define TESTING 1
#if TESTING
        alarmTime = [NSDate dateWithTimeIntervalSinceNow:10];
#endif

        [self scheduleNotificationForDate:alarmTime];

        NSString *alarmMessage = [NSString stringWithFormat:@"Would you like a 15 min parking reminder?"];
  
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:alarmMessage
                                                       delegate:self
                                              cancelButtonTitle:@"NO"
                                              otherButtonTitles:@"YES", nil];
        [alert show];

    }
}


- (NSDate *)convertTo24HourFormat:(NSString *)expiryTime
{
    NSString *dateString;
    NSDate *expiryDate;
    NSRange notFound = {NSNotFound, 0};
    
    NSRange rangeAM = [expiryTime rangeOfString:@"AM"];
    NSRange rangePM = [expiryTime rangeOfString:@"PM"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];

    NSDate *now = [NSDate date];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    unsigned unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;

    unsigned expiryDateUnitFlags = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitTimeZone;

    NSDateComponents *todaysDateComponents = [calendar components:unitFlags fromDate:now];

    if(!NSEqualRanges(rangeAM, notFound))
    {
        dateString = [expiryTime substringToIndex:rangeAM.location];
        expiryDate = [dateFormatter dateFromString:dateString];
        expiryDate = [calendar dateByAddingComponents:todaysDateComponents toDate:expiryDate options:0];
    }
    else if(!NSEqualRanges(rangePM, notFound))
    {
        dateString = [expiryTime substringToIndex:rangePM.location];
        expiryDate = [dateFormatter dateFromString:dateString];
        NSDateComponents *expiryDateComponents = [calendar components:expiryDateUnitFlags fromDate:expiryDate];
        [expiryDateComponents setYear:todaysDateComponents.year];
        [expiryDateComponents setMonth:todaysDateComponents.month];
        [expiryDateComponents setDay:todaysDateComponents.day];

        [expiryDateComponents setHour:(expiryDateComponents.hour+12)];
        expiryDate = [calendar dateFromComponents:expiryDateComponents];
    }
    
    return expiryDate;
}



- (void)scheduleNotificationForDate:(NSDate *)date
{
    // Here we cancel all previously scheduled notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    localNotification.fireDate = date;
    NSLog(@"Notification will be shown on: %@",localNotification.fireDate);
    
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = [NSString stringWithFormat:@"Your parking meter will expire in 15 mins"];
    localNotification.alertAction = NSLocalizedString(@"View details", nil);
    
    /* Here we set notification sound and badge on the app's icon "-1"
     means that number indicator on the badge will be decreased by one
     - so there will be no badge on the icon */
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = -1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


@end
