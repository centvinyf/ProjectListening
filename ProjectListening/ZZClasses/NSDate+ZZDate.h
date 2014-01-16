//
//  NSDate+ZZDate.h
//  ProjectListening
//
//  Created by zhaozilong on 13-3-13.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (ZZDate)
+ (int)compareCurrentTime:(NSDate*) compareDate;
+ (NSDate *)getLocateDate:(NSDate *)oneDate;
+ (NSDate *)getDateSinceNow:(int)days;
+ (int)getDateInNumBy:(NSDate *)date;
+ (int)getTimeBy:(NSDate *)date;
+ (NSTimeInterval)passedSecondFormDate:(NSDate *)compareDate;


@end
