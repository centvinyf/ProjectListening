//
//  NSString+ZZString.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-13.
//
//

#import "NSString+ZZString.h"

@implementation NSString (ZZString)

+ (NSString *)playTimeToSwitchAdvance:(double)preTime {
	NSInteger currTime=round(preTime);
//    int value_h= currTime/(60*60);
    int value_m= currTime%(60*60)/60;
    int value_s= currTime%(60*60)%60%60;
    
    NSString *minString = @"";
    NSString *secString = @"";
//    NSString *hourString = @"";
    
    if (value_m < 10) {
        minString=[NSString stringWithFormat:@"0%d:",value_m];
    } else {
        minString=[NSString stringWithFormat:@"%d:",value_m];
    }
    
    if (value_s < 10) {
        secString=[NSString stringWithFormat:@"0%d",value_s];
    } else {
        secString=[NSString stringWithFormat:@"%d",value_s];
    }
    
    
    
    
    
    //当前播放时间字符串MM:SS
    NSString *nowCurrTime = [minString stringByAppendingString:secString];
	return (nowCurrTime);
}

+ (NSString *)timeToSwitchAdvance:(double)preTime {
	NSInteger currTime=round(preTime);
    int value_h= currTime/(60*60);
    int value_m= currTime%(60*60)/60;
    int value_s= currTime%(60*60)%60%60;
    
    NSString *minString = @"";
    NSString *secString = @"";
    NSString *hourString = @"";
    
    if (value_h > 0) {
        hourString = [NSString stringWithFormat:@"%dh", value_h];
        if (value_m > 0)
            minString=[NSString stringWithFormat:@"%dm",value_m];
        
    } else {
        if (value_m > 0) {
            minString=[NSString stringWithFormat:@"%dm",value_m];
            if (value_s > 0) {
                secString=[NSString stringWithFormat:@"%ds",value_s];
            }
        } else {
            if (value_s > 0) {
                secString=[NSString stringWithFormat:@"%ds",value_s];
            } else {
                secString = @"0s";
            }
        }
    }

    //当前播放时间字符串MM:SS
    NSString *nowCurrTime = [[hourString stringByAppendingString:minString] stringByAppendingString:secString];
	return (nowCurrTime);
}

+ (NSString *)hmsToSwitchAdvance:(double)preTime {
	NSInteger currTime=round(preTime);
    int value_h= currTime/(60*60);
    int value_m= currTime%(60*60)/60;
    int value_s= currTime%(60*60)%60%60;
    
    NSString *minString = @"";
    NSString *secString = @"";
    NSString *hourString = @"";
    NSString *hour = NSLocalizedString(@"HOUR", nil);
    NSString *min = NSLocalizedString(@"MIN", nil);
    NSString *second = NSLocalizedString(@"SECOND", nil);
    if (value_h > 0) {
        hourString = [NSString stringWithFormat:@"%d%@", value_h, hour];
    }
    
    if (value_m > 0) {
        minString=[NSString stringWithFormat:@"%d%@",value_m, min];
    }
    
    if (value_s > 0) {
        secString=[NSString stringWithFormat:@"%d%@",value_s, second];
    }

    
    //当前播放时间字符串MM:SS
    NSString *nowCurrTime = [[hourString stringByAppendingString:minString] stringByAppendingString:secString];
	return (nowCurrTime);
}

+ (BOOL)isAWordInSelectedRange:(NSRange)range withText:(NSString *)fullText {
    NSString *selectedStr = [fullText substringWithRange:range];
//    NSLog(@"%@", selectedStr);
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" ',./;:?}{][|+=*&^%$#@!~`<>\"_"];
    NSArray *wordArray = [selectedStr componentsSeparatedByCharactersInSet:charSet];
    
    if ([wordArray count] > 1) {
        return NO;
    }
    
    return YES;
}

+ (NSString *)getSelectedWordInRange:(NSRange)range withText:(NSString *)fullText {
    return [fullText substringWithRange:range];
}



@end
