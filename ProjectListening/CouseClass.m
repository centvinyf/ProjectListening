//
//  CouseClass.m
//  ToeicListeningFREE
//
//  Created by 赵子龙 on 13-12-24.
//
//

#import "CouseClass.h"
#include <sqlite3.h>

@interface CouseClass () {
    sqlite3 *_database;
}

@end

@implementation CouseClass

- (void)dealloc {
    
    [_timeArray release];
    [_picNameArray release];
    
    [super dealloc];
}

+ (CouseClass *)CouseClassWithTitleId:(int)titleId audioName:(NSString *)audioName packId:(int)packId {
    return [[[self alloc] initWithTitleId:titleId audioName:audioName packId:packId] autorelease];
}

- (id)initWithTitleId:(int)titleId audioName:(NSString *)audioName packId:(int)packId {
    self = [super init];
    if (self) {
        
        
        self.audioName = audioName;
        self.titleId = titleId;
        _timeArray = [[NSMutableArray alloc] init];
        _picNameArray = [[NSMutableArray alloc] init];
        
        NSString *path = [ZZAcquirePath getDBClassFromDocuments];
//        NSString *path = [ZZAcquirePath getBundleDirectoryWithFileName:@"Class.sqlite"];
        [self openDatabaseIn:path];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT Seconds, PicName FROM Text WHERE TitleId = %d AND PackId = %d ORDER BY Seconds", titleId, packId];
        
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, nil) != SQLITE_OK) {
            sqlite3_close(_database);
            NSAssert(NO, @"查询CourseText信息失败");
        }
        
        int seconds;
        char *cPicName = NULL;
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            seconds = sqlite3_column_int(stmt, 0);
            [_timeArray addObject:[NSNumber numberWithInt:seconds]];
            
            cPicName = (char *)sqlite3_column_text(stmt, 1);
            if (cPicName != NULL) {
                NSString *picName = [NSString stringWithUTF8String:cPicName];
                [_picNameArray addObject:picName];
            } else {
//                NSAssert(NO, @"没有这张图片啊");
                NSLog(@"没有这张图片");
            }
        }
        
        sqlite3_finalize(stmt);
        
        [self closeDatabase];
    }
    
    return self;
    
}

- (void)openDatabaseIn:(NSString *)dbPath {
    if (sqlite3_open([dbPath UTF8String], &_database) != SQLITE_OK) {
        //        sqlite3_close(database);
        
        NSAssert(NO, @"Open database failed");
    }
}

- (void)closeDatabase {
    if (sqlite3_close(_database) != SQLITE_OK) {
        NSAssert(NO, @"Close database failed");
    }
}

@end
