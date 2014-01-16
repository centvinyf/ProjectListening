//
//  NSString+ZZString.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (ZZString)

+ (NSString *)timeToSwitchAdvance:(double)preTime;
+ (NSString *)hmsToSwitchAdvance:(double)preTime;

+ (NSString *)playTimeToSwitchAdvance:(double)preTime;

//获取选择的字符串
+ (NSString *)getSelectedWordInRange:(NSRange)range withText:(NSString *)fullText;
//选中的是不是一个单词
+ (BOOL)isAWordInSelectedRange:(NSRange)range withText:(NSString *)fullText;

@end
