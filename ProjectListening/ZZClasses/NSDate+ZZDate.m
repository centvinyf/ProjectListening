//
//  NSDate+ZZDate.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-13.
//
//

#import "NSDate+ZZDate.h"

@implementation NSDate (ZZDate)

+ (int)compareCurrentTime:(NSDate*) compareDate {
    NSDate *today = [NSDate getLocateDate:[NSDate date]];
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceDate:today];
    timeInterval = -timeInterval;
    long temp = 0;
    int result;
    if((temp = timeInterval/60) <60){
        result = 0;//[NSString stringWithFormat:@"%ld分前",temp];
    }
    
    else if((temp = temp/60) <24){
        result = 0;//[NSString stringWithFormat:@"%ld小前",temp];
    }
    
    else if((temp = temp/24) <30){
        result = (int)temp;//[NSString stringWithFormat:@"%ld天前",temp];
        
        //        //最多-7
        //        if (result > 7) {
        //            result = 7;
        //        }
    }
    
    else if((temp = temp/30) <12){
        //        result = [NSString stringWithFormat:@"%ld月前",temp];
        
        result = (int)temp * 30;
        
        //        //最多-7
        //        if (result > 7) {
        //            result = 7;
        //        }
    }
    
    else{
        temp = temp/12;
        //        result = [NSString stringWithFormat:@"%ld年前",temp];
        
        result = (int)temp * 365;
        
        
        //最多-7
        //        if (result > 7) {
        //            result = 7;
        //        }
    }
    
    return  result;
}


//日期本地化
+ (NSDate *)getLocateDate:(NSDate *)oneDate {
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: oneDate];
    
    NSDate *localeDate = [oneDate  dateByAddingTimeInterval: interval];
    
//    NSLog(@"时区：%@, 日期是%@", [zone description], [localeDate description]);//直接打印数据。
    
    return localeDate;
}

//本地化距离当前days的日期
+ (NSDate *)getDateSinceNow:(int)days {
    
    NSDate *oneDay = [NSDate dateWithTimeIntervalSinceNow: -(24 * 60 * 60) * days];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: oneDay];
    
    NSDate *localeDate = [oneDay  dateByAddingTimeInterval: interval];
    
    return localeDate;
}

//分析日期字符串，返回hms字符串或ymd字符串
+ (int)getDateInNumBy:(NSDate *)date{
    
    NSArray *dateComponents = [[date description] componentsSeparatedByString:@" "];
    
    NSString *dateStr = [[dateComponents objectAtIndex:0] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    return [dateStr intValue];
}

+ (int)getTimeBy:(NSDate *)date {
    
    NSArray *dateComponents = [[date description] componentsSeparatedByString:@" "];
    
    NSString *timeStr = (NSString *)[dateComponents objectAtIndex:1];
    NSArray *timeArray = [timeStr componentsSeparatedByString:@":"];
    int hour = [[timeArray objectAtIndex:0] intValue];
    
    return hour;
}

/**
 * 计算指定时间与当前的时间差
 * @param compareDate   某一指定时间
 * @return 多少(秒or分or天or月or年)+前 (比如，3天前、10分钟前)
 */

+ (NSTimeInterval)passedSecondFormDate:(NSDate *)compareDate {
    NSDate *now = [NSDate getLocateDate:[NSDate date]];
    NSTimeInterval timeInterval = [compareDate timeIntervalSinceDate:now];
    timeInterval = -timeInterval;
    return timeInterval;
 
}

//以下是NSDate中的常用方法:
/**
 
 - (id)initWithTimeInterval:(NSTimeInterval)secs sinceDate:(NSDate *)refDate;
 初始化为以refDate为基准，然后过了secs秒的时间
 
 - (id)initWithTimeIntervalSinceNow:(NSTimeInterval)secs;
 初始化为以当前时间为基准，然后过了secs秒的时间
 
 
 - (NSTimeInterval)timeIntervalSinceDate:(NSDate *)refDate;
 以refDate为基准时间，返回实例保存的时间与refDate的时间间隔
 
 - (NSTimeInterval)timeIntervalSinceNow;
 以当前时间(Now)为基准时间，返回实例保存的时间与当前时间(Now)的时间间隔
 
 - (NSTimeInterval)timeIntervalSince1970;
 以1970/01/01 GMT为基准时间，返回实例保存的时间与1970/01/01 GMT的时间间隔
 
 - (NSTimeInterval)timeIntervalSinceReferenceDate;
 以2001/01/01 GMT为基准时间，返回实例保存的时间与2001/01/01 GMT的时间间隔
 
 
 + (NSTimeInterval)timeIntervalSinceReferenceDate;

//秒
// - (NSTimeInterval)timeIntervalSinceNow;
//    以当前时间(Now)为基准时间，返回实例保存的时间与当前时间(Now)的时间间隔
 
*/


@end
