//
//  StampSprite.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-19.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "StampSprite.h"
#include <sqlite3.h>

#import "NSDate+ZZDate.h"
#import "UserSetting.h"

@interface StampSprite() {
    
    CCLabelTTF *_averageLabel;
    CCLabelTTF *_foYY_0;
    CCLabelTTF *_foYY_1;
    CCLabelTTF *_foMM;
    CCLabelTTF *_foDD;
    CCLabelTTF *_loYY_0;
    CCLabelTTF *_loYY_1;
    CCLabelTTF *_loMM;
    CCLabelTTF *_loDD;
    
    CCLabelAtlas *_score;
    
    sqlite3 *database;
    
}

@end

@implementation StampSprite

+ (StampSprite *)spriteWithParentNode:(CCNode *)parentNode position:(CGPoint)point {
    return [[[self alloc] initWithParentNode:parentNode position:point] autorelease];
}

- (id)initWithParentNode:(CCNode *)parentNode position:(CGPoint)point {
    self = [super init];
    if (self) {
        
//        self.anchorPoint = ccp(0, 0);
        [parentNode addChild:self];
        self.position = point;
        
//        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"stamp.png"];
        CGSize texSize = texture.contentSize;
        CGRect texRect = CGRectMake(0, 0, texSize.width, texSize.height);
        CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:texRect];
        [self setDisplayFrame:frame];
        
        //设置字体
        _score = [CCLabelAtlas labelWithString:@"99" charMapFile:@"scoreFont.png" itemWidth:(IS_IPAD ? 38 : 19) itemHeight:64 startCharMap:'0'];
        _score.anchorPoint = ccp(0.5, 0.5);
        [_score setRotation:20];
        [self addChild:_score];
        [_score setPosition:(IS_IPAD ? ccp(120, 135) : ccp(44, 39))];
        
        //每天平均学习时间的label
        _averageLabel = [CCLabelTTF labelWithString:@"100 mins/day" dimensions:(IS_IPAD ? CGSizeMake(140, 30) : CGSizeMake(60, 30)) alignment:NSTextAlignmentCenter fontName:@"MarkerFelt-Thin" fontSize:(IS_IPAD ? 25 : 9)];
        [_averageLabel setRotation:(IS_IPAD ? 20 : 20)];
        [self addChild:_averageLabel];
        [_averageLabel setPosition:(IS_IPAD ? ccp(105, 90) : ccp(40, 25))];
        
        int ymdFontSize = (IS_IPAD ? 18 : 9);
        _foYY_0 = [CCLabelTTF labelWithString:@"20" fontName:@"MarkerFelt-Thin" fontSize:ymdFontSize];
        [self addChild:_foYY_0];
        _foYY_1 = [CCLabelTTF labelWithString:@"13" fontName:@"MarkerFelt-Thin" fontSize:ymdFontSize];
        [self addChild:_foYY_1];
        _foMM = [CCLabelTTF labelWithString:@".03" fontName:@"MarkerFelt-Thin" fontSize:ymdFontSize];
        [self addChild:_foMM];
        _foDD = [CCLabelTTF labelWithString:@".09" fontName:@"MarkerFelt-Thin" fontSize:ymdFontSize];
        [self addChild:_foDD];
        
        [_foYY_0 setPosition:(IS_IPAD ? ccp(20, 120) : ccp(10, 40))];
        [_foYY_0 setRotation:(IS_IPAD ? 84 : 74)];
        
        [_foYY_1 setPosition:(IS_IPAD ? ccp(23, 100) : ccp(13, 30))];
        [_foYY_1 setRotation:(IS_IPAD ? 78 : 72)];
        
        [_foMM setPosition:(IS_IPAD ? ccp(29, 80) : ccp(19, 21))];
        [_foMM setRotation:(IS_IPAD ? 72 : 52)];
        
        [_foDD setPosition:(IS_IPAD ? ccp(40, 60) : ccp(28, 13))];
        [_foDD setRotation:(IS_IPAD ? 62 : 38)];
        
        _loYY_0 = [CCLabelTTF labelWithString:@"- 20" fontName:@"MarkerFelt-Thin" fontSize:ymdFontSize];
        [self addChild:_loYY_0];
        _loYY_1 = [CCLabelTTF labelWithString:@"15" fontName:@"MarkerFelt-Thin" fontSize:ymdFontSize];
        [self addChild:_loYY_1];
        _loMM = [CCLabelTTF labelWithString:@".11" fontName:@"MarkerFelt-Thin" fontSize:ymdFontSize];
        [self addChild:_loMM];
        _loDD = [CCLabelTTF labelWithString:@".19" fontName:@"MarkerFelt-Thin" fontSize:ymdFontSize];
        [self addChild:_loDD];
        
        [_loYY_0 setPosition:(IS_IPAD ? ccp(63, 35) : ccp(43, 8))];
        [_loYY_0 setRotation:(IS_IPAD ? 35 : 5)];
        
        [_loYY_1 setPosition:(IS_IPAD ? ccp(87, 22) : ccp(56, 8))];
        [_loYY_1 setRotation:(IS_IPAD ? 28 : -8)];

        [_loMM setPosition:(IS_IPAD ? ccp(110, 18) : ccp(67, 12))];
        [_loMM setRotation:(IS_IPAD ? 10 : -34)];

        [_loDD setPosition:(IS_IPAD ? ccp(135, 20) : ccp(76, 19))];
        [_loDD setRotation:(IS_IPAD ? -10 : -42)];
        
//        [self updateStamp];
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

//加权计算平均分数，老方法舍弃
- (void)updateStampOlderMethod {
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:dbPath];
    
    //开始查询
    NSString *sel = [NSString stringWithFormat:@"SELECT Score, StudyTime FROM Progress ORDER BY YMD DESC"];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, @"查询信息失败");
    }
    
    int scoreBase = 8;
    int totalScoreBase = 1;
    int totalScore = 0;
    int averageTime = 0;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        totalScoreBase += scoreBase;
        if (scoreBase <= 1) {
            totalScore += sqlite3_column_int(stmt, 0);
        } else {
            totalScore += (sqlite3_column_int(stmt, 0) * scoreBase--);
        }
        averageTime += sqlite3_column_int(stmt, 1);
    }
    sqlite3_finalize(stmt);
    
    //总得分
    int averageScore = totalScore / totalScoreBase;
    
    NSString *plistPath = [ZZAcquirePath getDocDirectoryWithFileName:PLIST_NAME_PROGRESS];
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSDate *foDay =[data objectForKey:ASSISTANT_FIRST_OPEN_DATE];
//    NSLog(@"%@", foDay);
    int days = [NSDate compareCurrentTime:foDay];
    if (days <= 0) {
        days = 1;
    }
    averageTime = averageTime / days;
    
    [_score setString:[NSString stringWithFormat:@"%d", averageScore]];
    [_averageLabel setString:[NSString stringWithFormat:@"%d mins/day", averageTime]];
    
    int fodate = [NSDate getDateInNumBy:foDay];
    int foyear0 = fodate / 1000000;
    int foyear1 = (fodate / 10000) % 100;
    int fomonth = (fodate / 100) % 100;
    int foday = fodate % 100;
    
    int lodate = [NSDate getDateInNumBy:[NSDate getLocateDate:[NSDate date]]];
    int loyear0 = lodate / 1000000;
    int loyear1 = (lodate / 10000) % 100;
    int lomonth = (lodate / 100) % 100;
    int loday = lodate % 100;
    
    [_foYY_0 setString:[NSString stringWithFormat:@"%d", foyear0]];
    
    if (foyear1 < 10) {
        [_foYY_1 setString:[NSString stringWithFormat:@"0%d", foyear1]];
    } else {
        [_foYY_1 setString:[NSString stringWithFormat:@"%d", foyear1]];
    }
    
    if (fomonth < 10) {
        [_foMM setString:[NSString stringWithFormat:@".0%d", fomonth]];
    } else {
        [_foMM setString:[NSString stringWithFormat:@".%d", fomonth]];
    }
    
    if (foday < 10) {
        [_foDD setString:[NSString stringWithFormat:@".0%d", foday]];
    } else {
        [_foDD setString:[NSString stringWithFormat:@".%d", foday]];
    }
    
    //截止时间
    [_loYY_0 setString:[NSString stringWithFormat:@"- %d", loyear0]];
    
    if (loyear1 < 10) {
        [_loYY_1 setString:[NSString stringWithFormat:@"0%d", loyear1]];
    } else {
        [_loYY_1 setString:[NSString stringWithFormat:@"%d", loyear1]];
    }
    
    if (lomonth < 10) {
        [_loMM setString:[NSString stringWithFormat:@".0%d", lomonth]];
    } else {
        [_loMM setString:[NSString stringWithFormat:@".%d", lomonth]];
    }
    
    if (loday < 10) {
        [_loDD setString:[NSString stringWithFormat:@".0%d", loday]];
    } else {
        [_loDD setString:[NSString stringWithFormat:@".%d", loday]];
    }
    
    //关闭数据库
    [self closeDatabase];
}

- (void)updateStamp {
    int assID = [UserSetting assistantID];
    ccColor3B color;
    switch (assID) {
        case 0:
            color = ccc3(0, 0, 0);
            break;
            
        case 1:
        default:
            color = ccc3(255, 255, 255);
            break;
    }
    
    [self setColor:color];
    CCArray *sArray = [self children];
    for (CCSprite *sprite in sArray) {
        [sprite setColor:color];
    }
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:dbPath];
    
    //开始查询
    NSString *sel = [NSString stringWithFormat:@"SELECT Score, StudyTime FROM Progress ORDER BY YMD DESC"];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, @"查询信息失败");
    }
    
    int totalScore = 0;
    int averageTime = 0;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        totalScore += sqlite3_column_int(stmt, 0);
        averageTime += sqlite3_column_int(stmt, 1);
    }
    sqlite3_finalize(stmt);
    
    NSString *plistPath = [ZZAcquirePath getDocDirectoryWithFileName:PLIST_NAME_PROGRESS];
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSDate *foDay =[data objectForKey:ASSISTANT_FIRST_OPEN_DATE];
//    NSLog(@"%@", foDay);
    int days = [NSDate compareCurrentTime:foDay];
    if (days <= 0) {
        days = 1;
    }
    averageTime = averageTime / days;
    
    [_score setString:[NSString stringWithFormat:@"%d", totalScore]];
    
//    NSLog(@"%d", averageTime);
    NSString *aveTimeStr = [NSString timeToSwitchAdvance:averageTime];
//    NSLog(@"Time is %@", aveTimeStr);
    
    [_averageLabel setString:[NSString stringWithFormat:@"%@/day", aveTimeStr]];
    
    _score.scaleX = (65 / _score.boundingBox.size.width);
    
    int fodate = [NSDate getDateInNumBy:foDay];
    int foyear0 = fodate / 1000000;
    int foyear1 = (fodate / 10000) % 100;
    int fomonth = (fodate / 100) % 100;
    int foday = fodate % 100;
    
    int lodate = [NSDate getDateInNumBy:[NSDate getLocateDate:[NSDate date]]];
    int loyear0 = lodate / 1000000;
    int loyear1 = (lodate / 10000) % 100;
    int lomonth = (lodate / 100) % 100;
    int loday = lodate % 100;
    
    [_foYY_0 setString:[NSString stringWithFormat:@"%d", foyear0]];
    
    if (foyear1 < 10) {
        [_foYY_1 setString:[NSString stringWithFormat:@"0%d", foyear1]];
    } else {
        [_foYY_1 setString:[NSString stringWithFormat:@"%d", foyear1]];
    }
    
    if (fomonth < 10) {
        [_foMM setString:[NSString stringWithFormat:@".0%d", fomonth]];
    } else {
        [_foMM setString:[NSString stringWithFormat:@".%d", fomonth]];
    }
    
    if (foday < 10) {
        [_foDD setString:[NSString stringWithFormat:@".0%d", foday]];
    } else {
        [_foDD setString:[NSString stringWithFormat:@".%d", foday]];
    }
    
    //截止时间
    [_loYY_0 setString:[NSString stringWithFormat:@"- %d", loyear0]];
    
    if (loyear1 < 10) {
        [_loYY_1 setString:[NSString stringWithFormat:@"0%d", loyear1]];
    } else {
        [_loYY_1 setString:[NSString stringWithFormat:@"%d", loyear1]];
    }
    
    if (lomonth < 10) {
        [_loMM setString:[NSString stringWithFormat:@".0%d", lomonth]];
    } else {
        [_loMM setString:[NSString stringWithFormat:@".%d", lomonth]];
    }
    
    if (loday < 10) {
        [_loDD setString:[NSString stringWithFormat:@".0%d", loday]];
    } else {
        [_loDD setString:[NSString stringWithFormat:@".%d", loday]];
    }
    
    //关闭数据库
    [self closeDatabase];
}


@end
