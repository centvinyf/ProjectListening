//
//  ZZAssistant.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-12.
//
//

#import "ZZAssistant.h"

#import "NSDate+ZZDate.h"
#import "UserSetting.h"
#include <sqlite3.h>

@interface ZZAssistant() {
    NSString *dataPath;
    
    sqlite3 *database;
}
@property (nonatomic, retain)NSDictionary *data;
@end

@implementation ZZAssistant
@synthesize data = _data;

- (void)dealloc {
    [_data release], _data = nil;
    [super dealloc];
}

- (id)init {
    
    self = [super init];
    if (self) {
        
        dataPath = [ZZAcquirePath getDocDirectoryWithFileName:PLIST_NAME_PROGRESS];
        _data = [[NSDictionary dictionaryWithContentsOfFile:dataPath] retain];
        
        //计算用户总共启动应用的次数
        int count = [UserSetting OpenTimes];
        [UserSetting setOpenTimes:++count];
        
    }
    return self;
}

- (void)openDatabaseIn:(NSString *)dbPath {
    if (sqlite3_open([dbPath UTF8String], &database) != SQLITE_OK) {
//        sqlite3_close(database);
        
        NSAssert(NO, @"Open database failed");
    }
}

- (void)closeDatabase {
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert(NO, @"Close database failed");
    }
}

- (AMTags)getAssistantStatus {
    
    //不是内购
    if ([UserSetting isNeedPurchase] && !IS_PRO_Ver && NO) {//测试是否需要内购
        return AMTagsNeedPurchase;
    } else if ([self isLongTimeNoSee]) {//是否长时间没有打开应用，反馈
        return AMTagsLongTimeNoSee;
    } else if ([self isNeedRate]) {//是否需要评价
        return AMTagsNeedRate;
    } else if ([self isNoWordToSay]) {//是否使用过太多次，助理发出"词穷"警告
        //只显示一次
        [UserSetting setOpenTimes:([UserSetting OpenTimes] + 1)];
        return AMTagsNoWordToSay;
    } else if ([UserSetting isTodayFirstTimeOpen]) {//是否是今天第一次打开应用

        int randomNum = arc4random() % 3 + 4;
        switch (randomNum) {
            case 4://根据七天的成绩总结评语
                //从progress表中抽取七天的Score字段分析
                return [self recentScoreSummarise];
                break;
                
            case 5://根据最晚启动时间推算休息时间
                //从progress表中抽取七天的LateTime字段分析
                return [self recentSleepTimeSummarise];
                break;
                
            case 6://根据最早启动时间推算起床时间
                //从progress表中抽取七天的EarlyTime字段分析
                return [self recentWakeTimeSummarise];
                break;
                
//            case 7://名人名言
//                //随即从数据库中抽取
//                return AMTagsSayings;
//                break;
                
//            case 8://笑话
//                //随即从数据库中抽取
//                return AMTagsJokes;
//                break;
                
//            case 9://考试技巧
//                return AMTagsSkills;
//                //随即从数据库中抽取,指定的考试类型
//                break;
                
            default:
                return 0;
                break;
        }
    } else {//是今天的第二次以上打开应用
        int randomNum = arc4random() % 27 + 10;
//        int randomNum = 30;
        switch (randomNum) {
            case 30:
            case 17:
            case 18:
            case 10://根据今天的学习状态进行评价
                //根据当天的Score评价
                return [self todayScore];
//                return [self recentScoreSummarise];
                break;
            
            case 31:
            case 19:
            case 20:
            case 11://根据最晚启动时间推算休息时间
                //从progress表中抽取七天的LateTime字段分析
                return AMTagsHealthyTip;
                break;
                
            case 34:
            case 29:
            case 36:
            case 32:
            case 21:
            case 22:
            case 15:
            case 12://名人名言
                //随即从数据库中抽取
                if ([TestType isJapaneseTest]) {
                    return AMTagsSayingsJP;
                } else if ([TestType isChineseTest]) {
                    return AMTagsSayingsCN;
                } else {
                    return AMTagsSayings;
                }
                
                break;
                
            case 33:
            case 23:
            case 24:
            case 13://笑话
                //随即从数据库中抽取
                if ([TestType isJapaneseTest]) {
                    return AMTagsJokesJP;
                } else if ([TestType isChineseTest]) {
                    return AMTagsJokesCN;
                } else {
                    return AMTagsJokes;
                }
                
                break;
                

            case 25:
            case 26:
            case 14://考试技巧
                //随即从数据库中抽取,指定的考试类型
                if ([TestType isJLPT]) {
                    return AMTagsSkillJLPT;
                } else if ([TestType isToefl]) {
                    if ([TestType systemLanguage] == LanguageEN) {
                        return AMTagsSayings;
                    }
                    return AMTagsSkillToefl;
                } else if ([TestType isToeic]) {
                    if ([TestType systemLanguage] == LanguageEN) {
                        return AMTagsSayings;
                    }
                    return AMTagsSkillToeic;
                } else if ([TestType isHSK]) {
                    return AMTagsSkillHSK;
                } else if ([TestType isTEM4]) {
                    return AMTagsSkillTEM4;
                } else {
                    NSAssert(NO, @"没有正确的考试类型,助理的话语");
                    return AMTagsSayings;
                }
                break;
                
            case 35:
            case 27:
            case 28:
            case 16:
                //从progress表中抽取七天的EarlyTime字段分析
                return AMTagsPsychologyTip;
                
//            case 37:
//                return [self recentScoreSummarise];
                
            default:
                return AMTagsSayings;
                break;
        }

    }

}

- (BOOL)isLongTimeNoSee {
    BOOL isNeedFeedback = [UserSetting isNeedFeedback];
    int howManyDays = [[_data objectForKey:ASSISTANT_LAST_NOW_INTERVAL_DAYS] intValue];
    if (howManyDays > 3 && isNeedFeedback) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isNeedRate {
    BOOL isNeedRate = [UserSetting isNeedRate];
    int howManyTimes = [UserSetting OpenTimes];
    if (howManyTimes > 10 && isNeedRate) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isNoWordToSay {
    int howManyTimes = [UserSetting OpenTimes];
    if (howManyTimes == 60) {
        return YES;
    }
    
    return NO;
}

- (NSMutableArray *)getRecentScore {
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:dbPath];
    
    int todayYMD = [NSDate getDateInNumBy:[NSDate getLocateDate:[NSDate date]]];
    
    //开始查询,不算今天的成绩
    NSString *sel = [NSString stringWithFormat:@"SELECT Score FROM Progress WHERE YMD != %d ORDER BY YMD DESC", todayYMD];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, @"查询信息失败");
    }
    
    int selInt;
    NSMutableArray *selArray = [[[NSMutableArray alloc] init] autorelease];
    
    int dateCount = 0;
    while (sqlite3_step(stmt) == SQLITE_ROW && dateCount++ <= 5) {//最多分析6天成绩
        selInt = sqlite3_column_int(stmt, 0);
        [selArray addObject:[NSNumber numberWithInt:selInt]];
        
        
    }
    sqlite3_finalize(stmt);
    
    //关闭数据库
    [self closeDatabase];
    
    return selArray;
}

- (NSMutableArray *)getRecentDataIsScore1IsEarlyTime2IsLateTime3:(int)tag {
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:dbPath];
    
    //开始查询
    NSString *sel = [NSString stringWithFormat:@"SELECT Score, EarlyTime, LateTime FROM Progress ORDER BY YMD DESC"];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, @"查询信息失败");
    }
    
    int selInt;
    NSMutableArray *selArray = [[[NSMutableArray alloc] init] autorelease];
    
    int dateCount = 0;
    while (sqlite3_step(stmt) == SQLITE_ROW && dateCount++ <= 6) {//最多分析7天成绩
        
        int col = 0;
        switch (tag) {
            case 1:
                col = 0;
                break;
                
            case 2:
                col = 1;
                break;
                
            case 3:
                col = 2;
                break;
                
            default:
                break;
        }
        
        selInt = sqlite3_column_int(stmt, col);
        [selArray addObject:[NSNumber numberWithInt:selInt]];
        
        
    }
    sqlite3_finalize(stmt);
        
    //关闭数据库
    [self closeDatabase];
    
    return selArray;
}

- (AMTags)recentScoreSummarise {
    
    NSMutableArray *scoreArray = [self getRecentScore];
    
    //对比平均分和方差得出用户的任务完成情况
    int count = [scoreArray count];
    if (count < 3) {
        //刚用3天不到,显示鼓励的话语
        
        return AMTagsRecentScore0;
    }
    
    //计算平均分
    float M = 0;
    for (NSNumber *score in scoreArray) {
        M += (float)[score intValue];
    }
    M /= (float)count;
    
    //计算标准差
    float S = 0.0f;
    for (NSNumber *score in scoreArray) {
        S += ([score intValue] - M) * ([score intValue] - M);
    }
    S /= (float)count;
    S = sqrtf(S);
    
    //求变异系数, 变异系数越高，说明成绩波动越大
    
    float CV = 100 * S / M;
    
#if COCOS2D_DEBUG    
    NSLog(@"几天的成绩：%@;最近成绩的平均分：%f, 波动：%f", scoreArray, M, CV);
#endif
    
    //平均分高代表成绩好，变异系数大代表成绩不稳定
    if (CV <= 10) {
        
        if (M >= 90) {
            //成绩优秀，非常稳定,保持住
            return AMTagsRecentScore1;
        } else if (M >= 80) {
            //成绩良，非常稳定，再加油一定能更优秀
            return AMTagsRecentScore2;
        } else if (M >= 70) {
            //成绩及格，非常稳定，但是还需要加油
            return AMTagsRecentScore3;
        } else if (M >= 60) {
            //成绩在及格边缘徘徊，非常稳定，不能安于现状，需要努力了
            return AMTagsRecentScore4;
        } else if (M >= 20){
            //成绩很差，很稳定
            return AMTagsRecentScore5;
        } else {
            //你到底在没在学习啊？
            return AMTagsRecentScore6;
        }
        
    } else if (CV <= 20) {
        
        if (M >= 90) {
            //成绩优秀，再稳定些就更好了
            return AMTagsRecentScore7;
        } else if (M >= 80) {
            //成绩有时很好，但是有时也在及格边缘，要注意了
            return AMTagsRecentScore8;
        } else if (M >= 70) {
            //成绩已经出现不及格了，要加油了哦
            return AMTagsRecentScore9;
        } else if (M >= 60) {
            //再加把劲，你会做的很好，成绩48-72徘徊
            return AMTagsRecentScore10;
        } else if (M >= 20){
            //成绩很差
//            return AMTagsRecentScore11;
            return AMTagsRecentScore5;
        } else {
            //你到底在没在学习啊?
//            return AMTagsRecentScore12;
            return AMTagsRecentScore6;
        }
        
    } else if (CV <= 30) {
        if (M >= 90) {
            //成绩优秀，但是有时也很一般,比较波动
            return AMTagsRecentScore13;
        } else if (M >= 80) {
            //成绩有时很好，但是有时也在及格边缘，要注意了
            return AMTagsRecentScore14;
        } else if (M >= 70) {
            //成绩已经出现不及格了，要加油了哦
            return AMTagsRecentScore15;
        } else if (M >= 60) {
            //再加把劲，你会做的很好，成绩48-72徘徊
            return AMTagsRecentScore16;
        } else if (M >= 20){
            //成绩很差
//            return AMTagsRecentScore17;
            return AMTagsRecentScore5;
        } else {
            //你到底在没在学习啊？
//            return AMTagsRecentScore18;
            return AMTagsRecentScore6;
        }
        
    } else {
        if (M >= 90) {
            //你还是有实力能学的很好的，只要你愿意，波动太大
            return AMTagsRecentScore19;
        } else if (M >= 70) {
            //只要努力，你可以的，波动很大
            return AMTagsRecentScore20;
        } else if (M >= 60) {
            //波动太大，成绩还不好
            return AMTagsRecentScore21;
        } else if (M >= 20){
            //成绩很差，
//            return AMTagsRecentScore22;
            return AMTagsRecentScore5;
        } else {
            //你到底在没在学习啊？
//            return AMTagsRecentScore23;
            return AMTagsRecentScore6;
        }
    }
}

- (AMTags)recentSleepTimeSummarise {
    NSMutableArray *timeArray = [self getRecentDataIsScore1IsEarlyTime2IsLateTime3:3];
    
    //对比平均分和方差得出用户的任务完成情况
    int count = [timeArray count];
    if (count < 3) {
        //刚用3天不到,显示提倡早休息
        
        return AMTagsHealthyTip;
    }
    
//    int count = [timeArray count];
    int lateCount = 0;
    for (NSNumber *hour in timeArray) {
        int time = [hour intValue];
        if (time >= 22 && time <= 3) {
            ++lateCount;
        }
    }
    
    if (100 * lateCount / count >= 50) {
        //最近睡觉比较晚
        return AMTagsRecentSleepTime1;
    } else {
        //告诫早休息
        return AMTagsHealthyTip;
    }
}

- (AMTags)recentWakeTimeSummarise {
    NSMutableArray *timeArray = [self getRecentDataIsScore1IsEarlyTime2IsLateTime3:2];
    
    //对比平均分和方差得出用户的任务完成情况
    int count = [timeArray count];
    if (count < 3) {
        //刚用3天不到,显示提倡早睡早起
        
        return AMTagsPsychologyTip;
    }
    
    //    int count = [timeArray count];
    int earlyCount = 0;
    for (NSNumber *hour in timeArray) {
        int time = [hour intValue];
        if (time <= 8) {
            ++earlyCount;
        }
    }
    
    if (100 * earlyCount / count >= 50) {
        //最近起的比较早
        return AMTagsRecentWakeTime1;
    } else {
        //早睡早起身体好,加油学习
        return AMTagsPsychologyTip;
    }

}

- (AMTags)todayScore {
//    NSDate *today = [_data objectForKey:ASSISTANT_LAST_OPEN_DATE];
    NSDate *today = [NSDate getLocateDate:[NSDate date]];
    int ymd = [NSDate getDateInNumBy:today];
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:dbPath];
    
    //取出今天的成绩
    NSString *sel = [NSString stringWithFormat:@"SELECT Score FROM Progress WHERE YMD = %d", ymd];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, @"查询信息失败");
    }
    
    int todayScore = 0;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        todayScore = sqlite3_column_int(stmt, 0);
    }
    sqlite3_finalize(stmt);
    
    [self closeDatabase];
    
    if (todayScore >= 90) {
        return AMTagsTodayScore0;
    } else if (todayScore >= 80) {
        return AMTagsTodayScore1;
    } else if (todayScore >= 70) {
        return AMTagsTodayScore2;
    } else if (todayScore >= 60) {
        return AMTagsTodayScore3;
    } else if (todayScore >= 50) {
        return AMTagsTodayScore4;
    } else if (todayScore >= 40) {
        return AMTagsTodayScore5;
    } else if (todayScore > 0 && todayScore < 40) {
        return AMTagsTodayScore6;
    } else {
        //等于0分的时候代表今天没有学习，不需要提示成绩差，有可能还没开始学习
        return AMTagsTodayScore7;
    }
}

+ (int)getRandomNumBelow:(int)low {
    NSAssert(low > 0, @"low 值错误");
    
    return arc4random() % low;
}

- (NSString *)getAssistantMessageWithTag:(AMTags)tag {
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getBundleDirectoryWithFileName:DB_NAME_ASSISTANT];
    [self openDatabaseIn:dbPath];
    
    int assID = [UserSetting assistantID];
    
    //取出今天的成绩
    NSString *sel = [NSString stringWithFormat:@"SELECT count() FROM AssistantSaid WHERE AMTags = %d AND (AssistantID = %d OR AssistantID = -1);", tag, assID];
    
    //查询行数
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
#if COCOS2D_DEBUG
        NSLog(@"%d", sqlite3_prepare_v2(database, [sel UTF8String], -1, &stmt, nil));
#endif
        sqlite3_close(database);
        NSAssert(NO, @"查询行数量失败");
    } 
    
    int count = 0;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        count = sqlite3_column_int(stmt, 0);
    }
    sqlite3_finalize(stmt);
    
    //随即返回一句话
    int randomNum = [ZZAssistant getRandomNumBelow:count];
    sel = [NSString stringWithFormat:@"SELECT Chinese, English, Japanese FROM AssistantSaid WHERE AMTags = %d AND AMIndex = %d AND (AssistantID = %d OR AssistantID = -1);", tag, randomNum, assID];
    sqlite3_stmt *stmtRand;
    if (sqlite3_prepare_v2(database, [sel UTF8String], -1, &stmtRand, nil) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, @"查询行数量失败");
    }
    
    //此处需要本地化一下子
    NSString *message = @"OK";
    while (sqlite3_step(stmtRand) == SQLITE_ROW) {
        int whichLanguage = LanguageMAX;
        switch ([TestType systemLanguage]) {
            case LanguageCN:
                whichLanguage = 0;
                break;
                
            case LanguageEN:
                whichLanguage = 1;
                break;
                
            case LanguageJP:
                whichLanguage = 2;
                break;
                
            default:
                NSAssert(NO, @"没有正确的系统语言");
                break;
        }
        message = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmtRand, whichLanguage)];
    }
    sqlite3_finalize(stmtRand);
    
    [self closeDatabase];
//    Chinese = [[Chinese stringByAppendingFormat:@"++%@", English] stringByAppendingFormat:@"++%@", Japanese];
    return message;
}


@end
