//
//  NSDate.m
//  Manga Out
//
//  Created by Jérémy chaufourier on 14/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import "NSDate.h"

@implementation NSDate (date)

- (BOOL)isSameDay:(NSDate*)anotherDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    NSDateComponents* components2 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:anotherDate];

    return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
}

@end
