//
//  MrDownload.m
//  ToeicListening
//
//  Created by zhaozilong on 12-8-5.
//
//

#import "MrDownload.h"
#include <sqlite3.h>
#define kDuration 0.5

@interface MrDownload () {
    sqlite3 *_database;
    
    //所有音频数量
    int _allAudioNum;
    
    //本次下载已经下载的音频个数
    int _numOfAlreadyDownAudio;
    
    //本次下载将要下载的音频个数
    int _numOfWillDownAudio;
    
    int _cellRow;
}

@property (nonatomic, retain) NSString *packName;
@property (nonatomic, retain) NSMutableArray *titleNumArray;

@property (nonatomic, retain) NSMutableSet *audioListMutSet;
@property (nonatomic, retain) ASINetworkQueue *netWorkQueue;

@end

@implementation MrDownload

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


- (id)initWithPackName:(NSString *)packName titleNumArray:(NSMutableArray *)titleNumArray cellRow:(int)row {
    self = [super init];
    if (self) {
    
        self.packName = packName;
        _titleNumArray = titleNumArray;
        _cellRow = row;
        
        
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
        
        //设置下载时屏幕常亮On
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        
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


- (void)setAllAudioNameArray:(NSMutableArray *)audioNameArray {
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getBundleDirectoryWithFileName:DB_NAME_TEXT_ANSWER];
    [self openDatabaseIn:dbPath];
    
    NSString *sel = nil;
    for (NSNumber *tn in _titleNumArray) {
        int titleNum = [tn intValue];
        sel = [NSString stringWithFormat:@"SELECT Sound FROM Text WHERE TitleNum = %d AND SenIndex = 1", titleNum];
        
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
            sqlite3_close(_database);
            NSAssert(NO, @"查询Text失败");
        }
        
        NSString *soundName = nil;
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            soundName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
            [audioNameArray addObject:soundName];
        }
        sqlite3_finalize(stmt);
        
        
        /************************不是所有考试听力都通用*******************************/
        if ([TestType isToefl]) {
            //问题音频名称
            sel = [NSString stringWithFormat:@"SELECT Sound FROM Answer WHERE TitleNum = %d", titleNum];
            
            sqlite3_stmt *stmt_ques;
            if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt_ques, nil) != SQLITE_OK) {
                sqlite3_close(_database);
                NSAssert(NO, @"查询PackInfo失败");
            }
            
            while (sqlite3_step(stmt_ques) == SQLITE_ROW) {
                soundName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt_ques, 0)];
                [audioNameArray addObject:soundName];
                
            }
            sqlite3_finalize(stmt_ques);
        }
        
    }
    
    //关闭数据库
    [self closeDatabase];
}

- (void)setDownloadedAudioNameArray:(NSMutableArray *)audioNameArray {
    
    //文件操作
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //获取audio/n路径
//    NSString *audioDir = [ZZAcquirePath getDocDirectoryWithFileName:[NSString stringWithFormat:@"audio/%@", _packName]];
    NSString *audioDir = [ZZAcquirePath getAudioDocDirectoryWithFileName:_packName];
    
    //取出音频的名称到数组中
    NSArray *nameOfAudioInDirArray = [fm contentsOfDirectoryAtPath:audioDir error:NULL];
    for (NSString *str in nameOfAudioInDirArray) {
        str = [str stringByDeletingPathExtension];
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

- (NSURL *)audioURLByAudioName:(NSString *)audioName packName:(NSString *)packName {
    NSURL *audioURL = nil;
    if ([TestType isJLPT]) {
        NSArray *audioNamePartArray = [audioName componentsSeparatedByString:@"_"];
//        NSLog(@"%@", audioNamePartArray);
        NSString *netAudioName = [audioNamePartArray objectAtIndex:2];
        PartTypeTags partType = [[audioNamePartArray objectAtIndex:1] intValue];
        int year = [[audioNamePartArray objectAtIndex:0] intValue];
        if (year > 201000) {
            audioURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%@", AUDIO_DOWNLOAD_URL, year, netAudioName]];
        } else {
            //part1和part2的下载路径不同
            int part = (partType == PartType304) ? 2 : 1;
            audioURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%d/%@", AUDIO_DOWNLOAD_URL, year, part, netAudioName]];
        }
        
    } else if ([TestType isToefl]) {
        audioURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", AUDIO_DOWNLOAD_URL, audioName]];
    } else if ([TestType isToeic]) {
        int testNum = [[packName stringByReplacingOccurrencesOfString:@"Test" withString:@""] intValue];
        audioURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%@", AUDIO_DOWNLOAD_URL, testNum, audioName]];
   
    } else if ([TestType isHSK]) {
        int titleNum = [[audioName stringByDeletingPathExtension] intValue];
        audioURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%@", AUDIO_DOWNLOAD_URL, (titleNum / 100) % 100, audioName]];
    } else if ([TestType isTEM4]) {
        int titleNum = [[audioName stringByDeletingPathExtension] intValue];
        audioURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%@", AUDIO_DOWNLOAD_URL, titleNum / 100, audioName]];
    } else {
        NSAssert(NO, @"没有正确的下载地址");
    }
    
    return audioURL;
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
        NSString *audioName = [waitingDownloadAudioArray objectAtIndex:i];
        audioName = [audioName stringByAppendingString:TEMP_AUDIO_SUFFIX];//.m4a
        
        //下载音频的路径
        NSURL *audioURL = [self audioURLByAudioName:audioName packName:self.packName];
        
        //设置下载路径
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:audioURL];
        request.timeOutSeconds = 30;
        request.numberOfTimesToRetryOnTimeout = 2;
        
        //设置代理
        [request setDelegate:self];
        
        //设置文件保存路径
//        NSString *audioDir = [ZZAcquirePath getDocDirectoryWithFileName:[NSString stringWithFormat:@"audio/%@/%@", _packName, audioName]];
        NSString *audioDir = [ZZAcquirePath getAudioDocDirectoryWithFileName:[NSString stringWithFormat:@"%@/%@", _packName, audioName]];
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

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    [self stopDownload];
    
    //设置下载时屏幕常亮Off
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    [self.delegate MrDownloadDidFailWithMessage:NSLocalizedString(@"INDICATOR_NET_ERROR",nil) cellRow:_cellRow];
    
}

@end
