//
//  ZZAI.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-6.
//
//

#import "ZZAI.h"
#include <sqlite3.h>
#import "UserSetting.h"
#import "NSDate+ZZDate.h"

@interface ZZAI () {
    sqlite3 *database;
//    NSMutableDictionary *data;
    NSString *plistPath;
}

@end

@implementation ZZAI

- (void)dealloc {
    
    [plistPath release];
    [super dealloc];
}

- (id)init { 
    
    self = [super init];
    if (self) {
        
//        [UserSetting isFirstTimeInstallApp];
        
//        //把数据库和plist拷贝到用户目录下
//        [self copyFromBundleToDocsWithFileName:DB_NAME_ZZAIDB isPlist:NO];
//        [self copyFromBundleToDocsWithFileName:PLIST_NAME_PROGRESS isPlist:YES];
        
        
        plistPath = [[ZZAcquirePath getDocDirectoryWithFileName:PLIST_NAME_PROGRESS] retain];
        
        //新建音频文件夹
//        [self createUserAudioDirectory];
        
//        [self updateDatabase];
        
    }
    
    return self;
}

- (void)updateDatabase {
    //打开数据库
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseByPath:path];
    
    //把小于40handle值的文章每天减少1
    [self reduceHandleUnderScore:40];
    
    //计算7天以内的计划
    NSDate *oneDate = nil;
    for (int i = 0; i < 7; i ++) {
        oneDate = [NSDate getDateSinceNow:i];
        
        //测试是否有计划安排
        if ([self isExistArrangementByDate:oneDate])
            break;
        else {
            
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
            
            BOOL isFirstTime = [[data objectForKey:ASSISTANT_IS_FIRST_TIME_ARRANGEMENT] boolValue];
            
            //每日学习时间
            int studyTime = [UserSetting studyTime] / 2;
            if (isFirstTime) {
#if COCOS2D_DEBUG
                NSLog(@"第一次计划:%@", oneDate);
#endif
                [data setObject:[NSNumber numberWithBool:NO] forKey:ASSISTANT_IS_FIRST_TIME_ARRANGEMENT];
                [data writeToFile:plistPath atomically:YES];
                
                //第一次运行或者清空学习进度之后，只分配当天的任务即可.
                
                [self setArrangementIntoDate:oneDate byTime:studyTime lowScore:0];
                break;
                
            } else {
#if COCOS2D_DEBUG
                NSLog(@"计划:%@", oneDate);
#endif
                BOOL isSuccess = [self setArrangementIntoDate:oneDate byTime:studyTime lowScore:0];
                if (!isSuccess) {
                    //题库已经用完了，选择是否购买更多题库，还是重置题库？
                    //先从以前的题库中抽取足够安排最近7天内任务的题，进去主界面之后再提示是否购买更多题库
#if COCOS2D_DEBUG
                    NSLog(@"文章已经不够分配了,从做过的题目中选择");
#endif
                    [self setArrangementIntoDate:oneDate byTime:studyTime lowScore:100];
                    
                    //重置没有开通Vip的题目
                    [self resetTitleInfoDatabase];
                    
                    //检查plist中可以购买的内购数量，如果<=0,则没有内购可以买了
//                    int purchaseNum = [[data objectForKey:ASSISTANT_PURCHASE_NUM] intValue];
                    int purchaseNum = [UserSetting purchaseNum];
                    if (purchaseNum > 0) {//还有内购可以购买
                        [UserSetting setIsNeedPurchase:YES];
                        
                    }
                    
                }
            }
        }
    }
    
    //插入今天的最早和最迟启动时间
    [self updateEarlyAndLateTimeOfToday];
    
    //关闭数据库
    [self closeDatabase];
}

- (void)openDatabaseByPath:(NSString *)dbPath {
    if (sqlite3_open([dbPath UTF8String], &database) != SQLITE_OK) {
#if COCOS2D_DEBUG
        NSLog(@"%d", sqlite3_open([dbPath UTF8String], &database));
#endif
        sqlite3_close(database);
        NSAssert(NO, @"Open database failed");
    }
}

- (void)closeDatabase {
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert(NO, @"Close database failed");
    }
}

- (void)updateEarlyAndLateTimeOfToday {
    //更新今天的最早和最后启动时间
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    int earlyHour = [[data objectForKey:ASSISTANT_MOST_EARLY_TIME] intValue];
    int lateHour = [[data objectForKey:ASSISTANT_MOST_LATE_TIME] intValue];
#if COCOS2D_DEBUG
    NSLog(@"今天最早启动时间 %d\n今天最晚启动时间 %d", earlyHour, lateHour);
#endif
    NSDate *todayDate = [NSDate getLocateDate:[NSDate date]];
    int ymd = [NSDate getDateInNumBy:todayDate];
    
    NSString *update = [NSString stringWithFormat:@"UPDATE Progress SET EarlyTime = %d, LateTime = %d WHERE YMD = %d;", earlyHour, lateHour, ymd];
    char *errorMsg = NULL;
    if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
}

//文章已经用尽，重置数据库
- (void)resetTitleInfoDatabase {
    //打开数据库
//    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
//    [self openDatabaseByPath:path];

    NSString *update = @"UPDATE TitleInfo SET Handle = 0 WHERE Vip = 'true';";
    char *errorMsg = NULL;
    if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    
//    [self closeDatabase];

}

- (BOOL)isTodayFirstTimeOpenByLastDate:(NSDate *)lastDate {
    
    //is_today_first_time_open
    int dateA = [NSDate getDateInNumBy:lastDate];
    int dateB = [NSDate getDateInNumBy:[NSDate getLocateDate:[NSDate date]]];
    
    if (dateA != dateB) {
        return YES;
    }
    return NO;
}

//计算两次打开的时间间隔
- (int)intervalOfTwoTimesOpen {
    //从plist中读取上次打开时间，计算与本次打开相差几天
//    NSString *plistPath = [ZZAcquirePath getDocDirectoryWithFileName:PLIST_NAME_PROGRESS];
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSDate *lastDate = (NSDate *)[data objectForKey:ASSISTANT_LAST_OPEN_DATE];
    NSDate *currentDate = [NSDate getLocateDate:[NSDate date]];
    
    //是不是今天的第一次登陆
    BOOL isTodayFirstTime = [self isTodayFirstTimeOpenByLastDate:lastDate];
//    [data setObject:[NSNumber numberWithBool:isTodayFirstTime] forKey:ASSISTANT_IS_TODAY_FIRST_TIME_OPEN];
    [UserSetting setIsTodayFirstTimeOpen:isTodayFirstTime];
    
    //计算上次登录和今天登录的间隔
    int hour = [NSDate getTimeBy:currentDate];
    int interval = [NSDate compareCurrentTime:lastDate];
    if (isTodayFirstTime) {
        //今天的第一次启动
        //记录今天的最早启动时间
        [data setObject:[NSNumber numberWithInt:hour] forKey:ASSISTANT_MOST_EARLY_TIME];
    }
//    else {
//        //过0点就加1，不管到没到24小时
//        ++interval;
//    }
    
    //记录今天的最后启动时间
    [data setObject:[NSNumber numberWithInt:hour] forKey:ASSISTANT_MOST_LATE_TIME];
    
    //把上次打开与这次打开的时间间隔写到plist中
    [data setObject:[NSNumber numberWithInt:interval] forKey:ASSISTANT_LAST_NOW_INTERVAL_DAYS];
    
    //把今天的日期插入plist
    [data setObject:currentDate forKey:ASSISTANT_LAST_OPEN_DATE];
    
    //写回plist
    [data writeToFile:plistPath atomically:YES];
    
    return interval;
}

//handle小于20的文章每天handle会减少1
- (void)reduceHandleUnderScore:(int)lowScore {
    
    //两次打开的间隔
    int interval = [self intervalOfTwoTimesOpen];
    
    //打开数据库
//    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
//    [self openDatabaseByPath:path];
    
    NSString *update = [NSString stringWithFormat:@"UPDATE TitleInfo SET Handle = Handle - %d WHERE Handle <= %d;", interval, lowScore];
    char *errorMsg = NULL;
    if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
//        sqlite3_close(database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);

    }
    
//    [self closeDatabase];
}

//YES:设置成功，NO设置失败，让用户选择是否重置
- (BOOL)setArrangementIntoDate:(NSDate *)oneDate byTime:(int)seconds lowScore:(int)lowScore {
    //打开数据库
//    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
//    [self openDatabaseByPath:path];
    
    //计算出文章
    NSString *getTitles = [NSString stringWithFormat:@"SELECT PartType, TitleNum, QuesNum, SoundTime, TitleName FROM TitleInfo WHERE TestType = %d AND Vip = 'true' AND Handle <= %d ORDER BY PartType, Handle", TEST_TYPE, lowScore];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [getTitles UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, @"查询文章信息失败");
    }
    
    
    //数组结构:titleInfoAll --> titleinfos --> titleDic
    int partTypeTemp = 0, partType, titleNum, quesNum, soundTime;
    NSString *titleName = NULL;
    NSMutableArray *titleInfoAll = [[NSMutableArray alloc] init];
    
    int totalTime = 0;//这个变量用来计算所剩余的总时间是否还够分配本次的任务le
    int titleCount = 0;//这个变量用来计算所剩余的文章数是否还够最低限度
//    bool isFav = false;
    
    NSMutableArray *titleInfos = nil;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        titleCount++;
        
        partType = sqlite3_column_int(stmt, 0);
        titleNum = sqlite3_column_int(stmt, 1);
        quesNum = sqlite3_column_int(stmt, 2);
        soundTime = sqlite3_column_int(stmt, 3);
        titleName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)];
//        isFav = sqlite3_column_blob(stmt, 5);
        
        //剩余总时间累加
        totalTime = totalTime + soundTime;
        
        NSMutableDictionary *titleDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:partType], @"PartType", [NSNumber numberWithInt:titleNum], @"TitleNum", [NSNumber numberWithInt:quesNum], @"QuesNum", [NSNumber numberWithInt:soundTime], @"SoundTime", titleName, @"TitleName", nil];
        
        if (partTypeTemp != partType) {
            titleInfos = [[NSMutableArray alloc] initWithObjects:titleDic, nil];
            [titleDic release];
            
            [titleInfoAll addObject:titleInfos];
            [titleInfos release];
            
            partTypeTemp = partType;
            
        } else {
            [titleInfos addObject:titleDic];
            [titleDic release];
        }
    }
    sqlite3_finalize(stmt);
//    [self closeDatabase];
    
    //备选文章已经不够选出今天的文章了
    if (totalTime < seconds) {
        //重新挑选文章
//        [self resetTitleInfoDatabase];
        [titleInfoAll release];
        return NO;
    }
    /*以下从选出来的备选文章中挑出符合条件的文章*/
    //从数组计算出随机试卷
    int totalSoundTime = 0;
    
    NSString *titleNumStr = [NSString string];
    NSString *titleNameStr = [NSString string];
    NSString *quesNumStr = [NSString string];
    NSString *soundTimeStr = [NSString string];
//    NSString *favoriteStr = [NSString string];
    NSString *rightNumStr = [NSString string];
    
    BOOL isStop = NO;
    while (isStop == NO) {
        for (NSMutableArray *titleInfos in titleInfoAll) {
            
            for (NSMutableDictionary *titleDic in titleInfos) {
                
                totalSoundTime = totalSoundTime + [[titleDic objectForKey:@"SoundTime"] intValue];
                titleNumStr = [titleNumStr stringByAppendingFormat:@"%d%@", [[titleDic objectForKey:@"TitleNum"] intValue], SEPARATE_SYMBOL];
                titleNameStr = [titleNameStr stringByAppendingFormat:@"%@%@", [titleDic objectForKey:@"TitleName"], SEPARATE_SYMBOL];
                quesNumStr = [quesNumStr stringByAppendingFormat:@"%d%@", [[titleDic objectForKey:@"QuesNum"] intValue], SEPARATE_SYMBOL];
                soundTimeStr = [soundTimeStr stringByAppendingFormat:@"%d%@", [[titleDic objectForKey:@"SoundTime"] intValue], SEPARATE_SYMBOL];
                rightNumStr = [rightNumStr stringByAppendingFormat:@"%d%@", 0, SEPARATE_SYMBOL];
                
                [titleInfos removeObject:titleDic];
                
                break;
            }
            
            if (totalSoundTime >= seconds) {
                isStop = YES;
                break;
            }
        }
    }
#if COCOS2D_DEBUG
    NSLog(@"文章号：%@\n文章名：%@\n题目数：%@\n音频时间：%@", titleNumStr, titleNameStr, quesNumStr, soundTimeStr);
#endif
    
    //打开数据库
//    [self openDatabaseByPath:path];
    
    //在Titleinfo中标记已经选出的文章,无论是否练习过，只要选择出来的文章，handle标记为7（没有选择过的文章handle标记为0）
    NSMutableArray *titleNums = (NSMutableArray *)[titleNumStr componentsSeparatedByString:SEPARATE_SYMBOL];
    [titleNums removeLastObject];
    [titleNums enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *update = [NSString stringWithFormat:@"UPDATE TitleInfo SET Handle = 7 WHERE TestType = %d AND TitleNum = %d;", TEST_TYPE, [obj intValue]];
        char *errorMsg = NULL;
        if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
            sqlite3_close(database);
            NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
        }
    }];
    
    //插到progress数据库中
    int dateNum = [NSDate getDateInNumBy:oneDate];
    NSString *insertRanking = [NSString stringWithFormat:@"INSERT OR REPLACE INTO Progress (YMD, TitleNum, TitleKey, QuesNum, SoundTime, Score, EarlyTime, LateTime, StudyTime, RightNum, LastIndex) VALUES (%d, '%@', '%@', '%@', '%@', 0, 12, 12, 0, '%@', 0);", dateNum, titleNumStr, titleNameStr, quesNumStr, soundTimeStr, rightNumStr];
    
    char *errorMsg = NULL;
    if (sqlite3_exec (database, [insertRanking UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    
    //关闭数据库
//    [self closeDatabase];
    [titleInfoAll release];
    return YES;

}

//判断当前要安排的日期是否存在
- (BOOL)isExistArrangementByDate:(NSDate *)date {
    
    int dateNum = [NSDate getDateInNumBy:date];
    
    //打开数据库
//    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
//    [self openDatabaseByPath:path];
    
    //测试当前日期是否存在
    NSString *ymd = [NSString stringWithFormat:@"SELECT YMD FROM Progress WHERE YMD = %d", dateNum];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [ymd UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, @"查询日期失败");
    }
    
    BOOL isExist = (sqlite3_step(stmt) == SQLITE_ROW);
    
    sqlite3_finalize(stmt);
    
    //关闭数据库
//    [self closeDatabase];
    
    return isExist;
    
}
@end
