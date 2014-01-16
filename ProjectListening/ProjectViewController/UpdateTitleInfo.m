//
//  UpdateTitleInfo.m
//  ToeflListening
//
//  Created by iyuba on 13-8-9.
//
//

#import "UpdateTitleInfo.h"
#include <sqlite3.h>
#import "TitleInfoClass.h"
#import "PackInfoClass.h"

@implementation UpdateTitleInfo

+ (void)updateTitleInfoTable {
    
    NSMutableArray *TICs = [[NSMutableArray alloc] init];
    
    NSString *path = [ZZAcquirePath getDBZZAIdbFromBundle];
    
    sqlite3 *database;
    if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
        //        sqlite3_close(database);
        
        NSAssert(NO, @"Open database failed");
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT TestType,PartType,TitleNum,PackName,QuesNum,SoundTime,Vip,EnText,CnText,JpText,EnExplain,CnExplain,JpExplain,TitleName,Handle,Favorite,RightNum,StudyTime FROM TitleInfo;"];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, @"查询TitleInfo信息失败");
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        
        int testType = sqlite3_column_int(stmt, 0);
        int partType = sqlite3_column_int(stmt, 1);
        int titleNum = sqlite3_column_int(stmt, 2);
        int quesNum = sqlite3_column_int(stmt, 4);
        int soundTime = sqlite3_column_int(stmt, 5);
        int handle = sqlite3_column_int(stmt, 14);
        int rightNum = sqlite3_column_int(stmt, 16);
        int studyTime = sqlite3_column_int(stmt, 17);
        
        char *cPackName = (char *)sqlite3_column_text(stmt, 3);
        char *cTitleName = (char *)sqlite3_column_text(stmt, 13);
        NSString *packName = nil;
        NSString *titleName = nil;
        if (cPackName != NULL) {
            packName = [NSString stringWithUTF8String:cPackName];
        }
        
        if (cTitleName != NULL) {
            titleName = [NSString stringWithUTF8String:cTitleName];
        }
        
        NSString *isVipStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 6)];
        BOOL isVip = ([isVipStr isEqualToString:@"true"] ? YES : NO);
        
        NSString *isEnText = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 7)];
        BOOL isEnT = ([isEnText isEqualToString:@"true"] ? YES : NO);
        
        NSString *isCnText = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 8)];
        BOOL isCnT = ([isCnText isEqualToString:@"true"] ? YES : NO);
        
        NSString *isJpText = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 9)];
        BOOL isJpT = ([isJpText isEqualToString:@"true"] ? YES : NO);
        
        NSString *isEnEx = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 10)];
        BOOL isEnE = ([isEnEx isEqualToString:@"true"] ? YES : NO);
        
        NSString *isCnEx = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 11)];
        BOOL isCnE = ([isCnEx isEqualToString:@"true"] ? YES : NO);
        
        NSString *isJpEx = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 12)];
        BOOL isJpE = ([isJpEx isEqualToString:@"true"] ? YES : NO);
        
        NSString *isFavorite = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 15)];
        BOOL isFav = ([isFavorite isEqualToString:@"true"] ? YES : NO);
        
        
        TitleInfoClass *TIC = [TitleInfoClass titleInfoWithTestType:testType partType:partType titleNum:titleNum packName:packName quesNum:quesNum soundTime:soundTime vip:isVip EnText:isEnT CnText:isCnT JpText:isJpT EnEx:isEnE CnEx:isCnE JpEx:isJpE titleName:titleName handle:handle favorite:isFav rightNum:rightNum studyTime:studyTime];
        
        [TICs addObject:TIC];
    }
    sqlite3_finalize(stmt);
    
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert(NO, @"Close database failed");
    }
    
    [self insertTitleInfoTable:TICs];
    
}

+ (void)insertTitleInfoTable:(NSMutableArray *)TICs {
    
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    
    sqlite3 *database;
    if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
        //        sqlite3_close(database);
        
        NSAssert(NO, @"Open database failed");
    }
    
    NSString *sql = nil;
    for (TitleInfoClass *TIC in TICs) {
        NSString *vip = (TIC.vip ? @"true" : @"false");
        NSString *EnT = (TIC.EnText ? @"true" : @"false");
        NSString *CnT = (TIC.CnText ? @"true" : @"false");
        NSString *JpT = (TIC.JpText ? @"true" : @"false");
        NSString *EnE = (TIC.EnExplain ? @"true" : @"false");
        NSString *CnE = (TIC.CnExplain ? @"true" : @"false");
        NSString *JpE = (TIC.JpExplain ? @"true" : @"false");
        NSString *fav = (TIC.favorite ? @"true" : @"false");
        sql = [NSString stringWithFormat:@"INSERT INTO TitleInfo (TestType,PartType,TitleNum,PackName,QuesNum,SoundTime,Vip,EnText,CnText,JpText,EnExplain,CnExplain,JpExplain,TitleName,Handle,Favorite,RightNum,StudyTime) VALUES (%d,%d,%d,\"%@\",%d,%d,\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",%d,\"%@\",%d,%d);", TIC.testType, TIC.partType, TIC.titleNum, TIC.packName, TIC.quesNum, TIC.sTime, vip, EnT, CnT, JpT, EnE, CnE, JpE, TIC.titleName, TIC.handle, fav, TIC.rightNum, TIC.studyTime];
        
        
        char *errorMsg = NULL;
        if (sqlite3_exec (database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
            NSLog(@"%s", errorMsg);
            //        sqlite3_close(database);
            //        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
        }
    }
    
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert(NO, @"Close database failed");
    }
    
}

+ (void)updatePackInfoTable {
    
    NSMutableArray *PICs = [[NSMutableArray alloc] init];
    
    NSString *path = [ZZAcquirePath getDBZZAIdbFromBundle];
    
    sqlite3 *database;
    if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
        //        sqlite3_close(database);
        
        NSAssert(NO, @"Open database failed");
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT PackName, isVip, IsDownload, Progress, id, IsFree, ProductID FROM PackInfo;"];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, @"查询PackInfo信息失败");
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        
        float progress = sqlite3_column_double(stmt, 3);
        int idNum = sqlite3_column_int(stmt, 4);
        
        char *cPackName = (char *)sqlite3_column_text(stmt, 0);
        char *cProductID = (char *)sqlite3_column_text(stmt, 6);
        NSString *packName = nil;
        NSString *productID = nil;
        if (cPackName != NULL) {
            packName = [NSString stringWithUTF8String:cPackName];
        }
        
        if (cProductID != NULL) {
            productID = [NSString stringWithUTF8String:cProductID];
        }
        
        NSString *isVipStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 1)];
        BOOL isVip = ([isVipStr isEqualToString:@"true"] ? YES : NO);
        
        NSString *isDownloadStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 2)];
        BOOL isDown = ([isDownloadStr isEqualToString:@"true"] ? YES : NO);
        
        NSString *isFreeStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 5)];
        BOOL isFree = ([isFreeStr isEqualToString:@"true"] ? YES : NO);
            
        
        PackInfoClass *PIC = [PackInfoClass packInfoWithPackName:packName isVip:isVip isDownload:isDown progress:progress idNum:idNum isFree:isFree productID:productID];
        
        [PICs addObject:PIC];
    }
    
    sqlite3_finalize(stmt);
    
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert(NO, @"Close database failed");
    }
    
    [self insertPackInfoTable:PICs];
    
}

+ (void)insertPackInfoTable:(NSMutableArray *)PICs {
    
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    
    sqlite3 *database;
    if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
        //        sqlite3_close(database);
        
        NSAssert(NO, @"Open database failed");
    }
    
    NSString *sql = nil;
    for (PackInfoClass *PIC in PICs) {
        NSString *isVip = (PIC.isVip ? @"true" : @"false");
        NSString *isDownload = (PIC.isDownload ? @"true" : @"false");
        NSString *isFree = (PIC.isFree ? @"true" : @"false");
        
        sql = [NSString stringWithFormat:@"INSERT INTO PackInfo (PackName,IsVip,IsDownload,Progress,id,IsFree,ProductID) VALUES (\"%@\",\"%@\",\"%@\",%f,%d,\"%@\",\"%@\");", PIC.packName, isVip, isDownload, PIC.progress, PIC.idNum, isFree, PIC.productID];
        
        
        char *errorMsg = NULL;
        if (sqlite3_exec (database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
            NSLog(@"%s", errorMsg);
            //        sqlite3_close(database);
            //        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
        }
    }
    
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert(NO, @"Close database failed");
    }
    
}


@end
