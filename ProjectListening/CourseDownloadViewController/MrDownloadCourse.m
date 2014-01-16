//
//  MrDownloadCourse.m
//  JLPT1Listening
//
//  Created by 赵子龙 on 13-12-31.
//
//

#import "MrDownloadCourse.h"
#include <sqlite3.h>
#import "NSString+MD5.h"
#import "SBJSON.h"
#import "NSString+SBJSON.h"
#import "Reachability.h"

#define kDuration 0.5
#define TAG_REQUEST_TEXT 888

@interface MrDownloadCourse () {
    sqlite3 *_database;
    
    //所有音频数量
    int _allAudioNum;
    
    //本次下载已经下载的音频个数
    int _numOfAlreadyDownAudio;
    
    //本次下载将要下载的音频个数
    int _numOfWillDownAudio;
    
    int _cellRow;
}

//@property (nonatomic, retain) NSString *packName;
//@property (nonatomic, retain) NSMutableArray *titleNumArray;

@property (nonatomic, retain) NSMutableSet *audioListMutSet;
@property (nonatomic, retain) ASINetworkQueue *netWorkQueue;

@property (nonatomic, retain) ASIHTTPRequest *textRequest;


@property (assign) int packId;
@property (assign) int titleId;

@end

@implementation MrDownloadCourse

- (void)dealloc {
#if COCOS2D_DEBUG
    NSLog(@"MrDownload is dealloc");
#endif
    
    //    [self.packName release];
    if (_audioListMutSet) {
        [_audioListMutSet release], _audioListMutSet = nil;
    }
    
    
    self.delegate = nil;
    [_netWorkQueue release], _netWorkQueue = nil;
    [super dealloc];
}

- (id)initWithPackId:(int)packId titleId:(int)titleId cellRow:(int)row {
    
    self = [super init];
    if (self) {
        //    self.packName = packName;
        //    _titleNumArray = titleNumArray;
        _cellRow = row;
        self.packId = packId;
        self.titleId = titleId;
        
        //如果下载原本text当中没有数据，则先下载text
        //如果有数据则直接下载图片和音频
        
        if ([self isHasText]) {
            [self getAudioAndPicByTitleId:self.packId packId:self.titleId];
        } else {//没有text
            [self getTextByPackId:self.packId titleId:self.titleId];
        }
        
        
        
    }
    return self;
}

- (BOOL)isHasText {
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBClassFromDocuments];
    [self openDatabaseIn:dbPath];
    
    
    NSString *sel = [NSString stringWithFormat:@"SELECT * FROM Text WHERE TitleId = %d AND PackId = %d", self.titleId, self.packId];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询CourseText失败");
    }
    
    BOOL isHasData = NO;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        isHasData = YES;
    }
    sqlite3_finalize(stmt);
    
    //关闭数据库
    [self closeDatabase];
    
    return isHasData;
}

- (void)getTextByPackId:(int)packId titleId:(int)titleId {
    NSString *sign = [[NSString stringWithFormat:@"10003class%d", titleId] MD5String];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://class.iyuba.com/getClass.iyuba?protocol=10003&id=%d&sign=%@", titleId, sign];
    
#if COCOS2D_DEBUG
    NSLog(@"url:%@",urlStr);
#endif
    
    self.textRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    self.textRequest.delegate = self;
    self.textRequest.timeOutSeconds = 20;
    self.textRequest.tag = TAG_REQUEST_TEXT;
    
    [self.textRequest startAsynchronous];
}

- (void)getAudioAndPicByTitleId:(int)titleId packId:(int)packId {
    //所有音频的数组
    NSMutableArray *allAudioNameArray = [[NSMutableArray alloc] init];
    [self setAllAudioNameArray:allAudioNameArray];
    self.audioListMutSet = [NSMutableSet setWithArray:allAudioNameArray];
    _allAudioNum = [self.audioListMutSet count];
    [allAudioNameArray release];
    
    
    //已经下载的音频的数组
    NSMutableArray *downloadedAudioNameArray = [[NSMutableArray alloc] init];
    [self setDownloadedAudioNameArray:downloadedAudioNameArray];
    NSMutableSet *downloadedSet = [NSMutableSet setWithArray:downloadedAudioNameArray];
    [downloadedAudioNameArray release];
    
    //与所有音频名称做对比，找出还没有被下载下来的音频列表
    [_audioListMutSet minusSet:downloadedSet];
    
    _numOfAlreadyDownAudio = 0;//初始化本次已经下载的音频数量，每次都初始化为0
    _numOfWillDownAudio = [_audioListMutSet count];//即将被下载的音频数量
    
    
    //初始化下载队列
    _netWorkQueue = [[ASINetworkQueue alloc] init];
    [_netWorkQueue reset];
    [_netWorkQueue setShowAccurateProgress:YES];
    [_netWorkQueue setMaxConcurrentOperationCount:5];
    
    //把音频的request加入到下载队列当中
    [self requestAddToQueue];
    
    [self startDownload];
    
    //设置下载时屏幕常亮On
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
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


- (void)setAllAudioNameArray:(NSMutableArray *)audioNameArray {
    
    //加音频名称
    NSString *audioName = [NSString stringWithFormat:@"%d.m4a", self.titleId];
    [audioNameArray addObject:audioName];
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBClassFromDocuments];
    [self openDatabaseIn:dbPath];
    
    
    NSString *sel = [NSString stringWithFormat:@"SELECT PicName FROM Text WHERE TitleId = %d AND PackId = %d", self.titleId, self.packId];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询CourseText失败");
    }
    
    NSString *imgName = nil;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        
        imgName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
        imgName = [imgName stringByAppendingString:@".jpg"];
        
        [audioNameArray addObject:imgName];
    }
    sqlite3_finalize(stmt);
    
    //关闭数据库
    [self closeDatabase];

}

- (void)setDownloadedAudioNameArray:(NSMutableArray *)audioNameArray {
    
    //文件操作
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //创建下载路径
    [ZZPublicClass createCoursePathInUserDirectoryWithPackId:self.packId titleId:self.titleId];
    
    
    NSString *courseDir = [ZZAcquirePath getCourseDocDirectoryWithPackId:self.packId titleId:self.titleId];
    
    //取出音频的名称到数组中
    NSArray *nameOfAudioInDirArray = [fm contentsOfDirectoryAtPath:courseDir error:NULL];
    for (NSString *str in nameOfAudioInDirArray) {
//        str = [str stringByDeletingPathExtension];
        [audioNameArray addObject:str];
    }
    
}

- (void)startDownload {
    
    //判断网络状态
	NetworkStatus NetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
	//没有网的情况
	if (NetStatus == NotReachable) {
		
        [self.delegate MrDownloadDidFailWithMessage:NSLocalizedString(@"INDICATOR_NET_NOT_CONNECT",nil) cellRow:_cellRow];
        
	} else {
        //开始下载
        [_netWorkQueue go];
    }
    
}

- (void)stopDownload {
    //    [_netWorkQueue cancelAllOperations];
    
    //    [_netWorkQueue reset];
    //    [_netWorkQueue setDelegate:nil];
    
    for (ASIHTTPRequest *request in [_netWorkQueue operations]) {
        if ([request isKindOfClass:[ASIHTTPRequest class]]) {
            [request clearDelegatesAndCancel];
        }
    }
    
}

- (NSURL *)getURLByFileName:(NSString *)fileName {
    
    int courseAppId = [[TestType courseID] intValue];
    int packId = self.packId;
    int titleId = self.titleId;
    
    NSURL *downloadURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://class.iyuba.com/resource/%d/%d/%d/%@", courseAppId, packId, titleId, fileName]];
    
    return downloadURL;
}


- (void)requestAddToQueue {
    
    
    //等待被下载的音频列表
    NSArray *waitingDownloadAudioArray = [_audioListMutSet allObjects];
    
    //测试引用计数
    //    NSLog(@"waitingDownloadAudioArray is %d", [waitingDownloadAudioArray retainCount]);
    
    //把所有音频的request都加入到队列当中，准备下载
    int audioNum = [waitingDownloadAudioArray count];
    for (int i = 0; i < audioNum; i++) {
        
        //下载音频的名字
        NSString *fileName = [waitingDownloadAudioArray objectAtIndex:i];
//        audioName = [audioName stringByAppendingString:TEMP_AUDIO_SUFFIX];//.m4a
        
        //下载音频的路径
        NSURL *downloadURL = [self getURLByFileName:fileName];
        NSLog(@"%@", downloadURL);
        
        //设置下载路径
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:downloadURL];
        request.timeOutSeconds = 30;
        request.numberOfTimesToRetryOnTimeout = 2;
        
        //设置代理
        [request setDelegate:self];
        
        //设置文件保存路径
        NSString *audioDir = [ZZAcquirePath getCourseDocDirectoryWithPackId:self.packId titleId:self.titleId];
        audioDir = [audioDir stringByAppendingFormat:@"/%@", fileName];
        
        NSLog(@"%@", audioDir);
        
        [request setDownloadDestinationPath:audioDir];
        [request setShouldContinueWhenAppEntersBackground:YES];
        
        //设置文件临时保存路径
        //        NSString *tmpDir = [NSTemporaryDirectory() stringByAppendingPathComponent:audioName];
        //        [request setTemporaryFileDownloadPath:tmpDir];
        
        //设置进度条代理
        //        [request setDownloadProgressDelegate:self];
        
        //是否支持断点下载
        //        [request setAllowResumeForFileDownloads:YES];
        
        //设置基本信息
        //        [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:book.bookID],@"bookID",nil]];
        
        //添加到下载队列
        [_netWorkQueue addOperation:request];
        [_netWorkQueue setDownloadProgressDelegate:self];
        [request release];
        
    }
    
}

- (void)setProgress:(CGFloat)progress {
    //    NSLog(@"%f", progress);
    //    CGFloat tprogress = (_allAudioNum - (_numOfWillDownAudio - _numOfAlreadyDownAudio)) / _allAudioNum;
    [self.delegate MrDownloadProgress:progress cellRow:_cellRow];
}

#pragma mark ------ASIHTTPRequestDelegate---------
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
    //    NSLog(@"%@", responseHeaders);
    
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    //设置下载时屏幕常亮Off
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if (request.tag == TAG_REQUEST_TEXT) {
        //text下载成功，加入数据库中
        
        NSString *responseString = [request responseString];
        //        NSInteger pageNumber;
        //        NSInteger lastPage;
        
        NSDictionary * result = [responseString JSONValue];
        NSInteger resultCode = [[result objectForKey:@"result"] integerValue];
        if (resultCode == 1) {//成功
            
            //取得课程信息成功
//            NSLog(@"*********获取课程text信息成功");
            
            NSArray *textArray = [result objectForKey:@"data"];
            
            //先将数据写入数据库中
            [self addDataToTextWith:textArray];
            
            //继续获取图片以及音频文件
            [self getAudioAndPicByTitleId:self.titleId packId:self.packId];
            
            
        } else {
            //返回值错误，请稍后再试
            [self.delegate MrDownloadDidFailWithMessage:NSLocalizedString(@"INDICATOR_NET_ERROR",nil) cellRow:_cellRow];
            
        }
        
    } else {
        _numOfAlreadyDownAudio++;
        
        //如果本次已经下载的音频数量等于本次将要下载的音频数量的话，说明下载已经完成，
        if (_numOfAlreadyDownAudio == _numOfWillDownAudio) {
            
            
            //释放
            if (_audioListMutSet) {
                [_audioListMutSet release], _audioListMutSet = nil;
            }
            
            //委托，试题下载完成
            [self.delegate MrDownloadDidFinishWithCellRow:_cellRow];
        }

    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    if (request.tag == TAG_REQUEST_TEXT) {
        //text下载失败
        
        
    } else {
        [self stopDownload];
    }
    
    
    
    //设置下载时屏幕常亮Off
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    [self.delegate MrDownloadDidFailWithMessage:NSLocalizedString(@"INDICATOR_NET_ERROR",nil) cellRow:_cellRow];
    
}

- (void)addDataToTextWith:(NSArray *)dataList {
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBClassFromDocuments];
    [self openDatabaseIn:dbPath];
    
    NSString *sql = @"";
    for (NSDictionary *infoDic in dataList) {
//        NSInteger textId = [[infoDic objectForKey:@"id"] integerValue];
        NSString *imgName = [infoDic objectForKey:@"imageName"];
        NSInteger seconds = [[infoDic objectForKey:@"seconds"] integerValue];
//        NSString *titleName = [infoDic objectForKey:@"titleName"];
        
        
        sql = [sql stringByAppendingFormat:@"INSERT INTO Text (TitleId, Seconds, PicName, PackId) VALUES (%d,%d,\"%@\",%d);", self.titleId, seconds, imgName, self.packId];
    }
    
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        NSLog(@"%s", errorMsg);
        //        sqlite3_close(database);
        //        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    
    [self closeDatabase];
}

@end
