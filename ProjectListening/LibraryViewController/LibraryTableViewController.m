//
//  LibraryTableViewController.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-15.
//
//

#import "LibraryTableViewController.h"
#import "LibraryCell.h"
#import "LibTitleTableViewController.h"
#import "LibPartTableViewController.h"
#import "InStoreViewController.h"
#import "VIPStoreViewController.h"
#import "UserInfo.h"
#import "UserSetting.h"

@interface LibraryTableViewController () {
    sqlite3 *_database;
    int _currDownloadIndex;
}
@property (nonatomic, retain) NSMutableArray *packInfoArray;
@property (nonatomic, retain) NSMutableArray *downloadQueue;
@property (nonatomic, assign) MrDownload *MrD;
@property (nonatomic, assign) BOOL IsFromOpenCourse;

@end

@implementation LibraryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //监听程序中断
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    
    return self;
}



- (void)dealloc {
    
    [_downloadQueue release];
    [_packInfoArray release];
    
    //删除消息中心的注册对象
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
//    self.navigationItem.title = @"题库";
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self updatePackInfoClasses];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [self updateProgressToPackInfoDB];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"TAB_LIB", nil)];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _currDownloadIndex = -1;
    
    _downloadQueue = [[NSMutableArray alloc] init];
    
    _packInfoArray = [[NSMutableArray alloc] init];
    
    //初始化PIC数组
    [self setPackInfoClasses];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 2;
//}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (![UserSetting isPurchasedVIPMode]) {
        
        return (IS_IPAD ? 150 : 77);
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIImageView *imgView = nil;
    UIButton *button = nil;
    if (![UserSetting isPurchasedVIPMode]) {
        
        static NSString *VIPSectionIdentifier = @"VIPSectionHeader";
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        
        if (version >= 6.0)
        {
            // iPhone 6.0 code here
            button = [tableView dequeueReusableHeaderFooterViewWithIdentifier:VIPSectionIdentifier];
            if (!button) {
//                imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pac kNameLineVIP.png"]] autorelease];
                button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setImage:[UIImage imageNamed:@"packNameLineVIP.png"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"packNameLineVIP_hl.png"] forState:UIControlStateHighlighted];
                [button addTarget:self action:@selector(pushVIPModeViewController) forControlEvents:UIControlEventTouchUpInside];
            }
        } else {
//            imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"packNameLineVIP.png"]] autorelease];
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"packNameLineVIP.png"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"packNameLineVIP_hl.png"] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(pushVIPModeViewController) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    
    return button;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (IS_IPAD) {
        return 150;
    } else {
        return 77;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_packInfoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"LibraryCell";
    LibraryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        int nibIndex = (IS_IPAD ? 1 : 0);
        cell = (LibraryCell *)[[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:nibIndex];
        cell.parentVC = self;
        [cell addDownloadBtnStatusToCell];
    }
    int row = indexPath.row;
    PackInfoClass *PIC = [_packInfoArray objectAtIndex:row];
    
    [cell setCellStatusByTag:PIC.PICStatus row:row];
    [cell setLabelInfoWithPIC:PIC];
    [cell setDownloadProgress:PIC.progress];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PackInfoClass *PIC = [_packInfoArray objectAtIndex:indexPath.row];
    
    if (PIC.PICStatus == PICStatusFree) {
        if ([TestType isToefl]) {//托福的题目不需要分类
            LibTitleTableViewController *detailViewController = [[LibTitleTableViewController alloc] initWithNibName:@"LibTitleTableViewController" bundle:nil packName:PIC.packName];
            
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];

        } else {
            LibPartTableViewController *partViewController = [[LibPartTableViewController alloc] initWithNibName: @"LibPartTableViewController" bundle:nil packName:PIC.packName];
            
            [self.navigationController pushViewController:partViewController animated:YES];
            [partViewController release];
        }
        
        // ...
        // Pass the selected object to the new view controller.
                
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }

    
}

#pragma mark - My Methods
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

- (void)updatePackInfoClasses {
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:dbPath];
    
    for (PackInfoClass *PIC in _packInfoArray) {
        NSString *sel = [NSString stringWithFormat:@"SELECT sum(QuesNum), sum(RightNum), count(*) FROM TitleInfo WHERE PackName = '%@'", PIC.packName];
        
        sqlite3_stmt *stmt_sum;
        if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt_sum, nil) != SQLITE_OK) {
            sqlite3_close(_database);
            NSAssert(NO, @"查询sum(QuesNum)失败");
        }
        
        int totalQuesNum = 0;
        int totalRightNum = 0;
        int totalTitleNum = 0;
        while (sqlite3_step(stmt_sum) == SQLITE_ROW) {
            totalQuesNum = sqlite3_column_int(stmt_sum, 0);
            totalRightNum = sqlite3_column_int(stmt_sum, 1);
            totalTitleNum = sqlite3_column_int(stmt_sum, 2);
        }
        sqlite3_finalize(stmt_sum);
        
        PIC.totalQuesNum = totalQuesNum;
        PIC.totalRightNum = totalRightNum;
        PIC.totalTitleNum = totalTitleNum;
    }
    
    
    //更新下载状态
    //开始查询
    NSString *sel = [NSString stringWithFormat:@"SELECT PackName, IsVip, IsDownload, IsFree, Progress FROM PackInfo ORDER BY id"];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询PackInfo失败");
    }
    
//    NSString *packName = @"null";
    BOOL isVip, isDownload, isFree;
    float progress;
    int count = 0;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
//        packName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
        
        NSString *isVipStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 1)];
        isVip = (([isVipStr isEqualToString:@"true"] || [isVipStr isEqualToString:@"True"]) ? YES : NO);
        
        NSString *isDownloadStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 2)];
        isDownload = (([isDownloadStr isEqualToString:@"true"] || [isDownloadStr isEqualToString:@"True"]) ? YES : NO);
        
        NSString *isFreeStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 3)];
        isFree = (([isFreeStr isEqualToString:@"true"] || [isFreeStr isEqualToString:@"True"]) ? YES : NO);
        
        progress = sqlite3_column_double(stmt, 4);
        
        PackInfoClass *PIC = [_packInfoArray objectAtIndex:count++];
        [PIC setIyubaVipWithIsDownload:isDownload isFree:isFree isVip:isVip progress:progress];
    }
    sqlite3_finalize(stmt);
    
    [self closeDatabase];
}

- (void)setPackInfoClasses {
    
    //清空之前的数组
    [_packInfoArray removeAllObjects];
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:dbPath];
    
    //开始查询
    NSString *sel = [NSString stringWithFormat:@"SELECT PackName, IsVip, IsDownload, IsFree, Progress FROM PackInfo ORDER BY id"];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询PackInfo失败");
    }
    
    NSString *packName = @"null";
    BOOL isVip, isDownload, isFree;
    float progress;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        packName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
        NSString *isVipStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 1)];
        isVip = (([isVipStr isEqualToString:@"true"] || [isVipStr isEqualToString:@"True"]) ? YES : NO);
        
        NSString *isDownloadStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 2)];
        isDownload = (([isDownloadStr isEqualToString:@"true"] || [isDownloadStr isEqualToString:@"True"]) ? YES : NO);
        
        NSString *isFreeStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 3)];
        isFree = (([isFreeStr isEqualToString:@"true"] || [isFreeStr isEqualToString:@"True"]) ? YES : NO);
        
        progress = sqlite3_column_double(stmt, 4);
        
        PackInfoClass *PIC = [PackInfoClass packInfoWithPackName:packName isVip:isVip isDownload:isDownload progress:progress isFree:isFree];
        PIC.lastProgress = progress;
        
        [_packInfoArray addObject:PIC];
        
    }
    sqlite3_finalize(stmt);
    
    
    for (PackInfoClass *PIC in _packInfoArray) {
        sel = [NSString stringWithFormat:@"SELECT sum(QuesNum), sum(RightNum), count(*) FROM TitleInfo WHERE PackName = '%@'", PIC.packName];
        
        sqlite3_stmt *stmt_sum;
        if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt_sum, nil) != SQLITE_OK) {
            sqlite3_close(_database);
            NSAssert(NO, @"查询sum(QuesNum)失败");
        }
        
        int totalQuesNum = 0;
        int totalRightNum = 0;
        int totalTitleNum = 0;
        while (sqlite3_step(stmt_sum) == SQLITE_ROW) {
            totalQuesNum = sqlite3_column_int(stmt_sum, 0);
            totalRightNum = sqlite3_column_int(stmt_sum, 1);
            totalTitleNum = sqlite3_column_int(stmt_sum, 2);
        }
        sqlite3_finalize(stmt_sum);
        
        PIC.totalQuesNum = totalQuesNum;
        PIC.totalRightNum = totalRightNum;
        PIC.totalTitleNum = totalTitleNum;
        
        //把文章号找出
        sel = [NSString stringWithFormat:@"SELECT TitleNum FROM TitleInfo WHERE PackName = '%@'", PIC.packName];
        
        sqlite3_stmt *stmt_titleNum;
        if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt_titleNum, nil) != SQLITE_OK) {
            sqlite3_close(_database);
            NSAssert(NO, @"查询TitleNum失败");
        }
        
        int titleNum = 0;
        while (sqlite3_step(stmt_titleNum) == SQLITE_ROW) {
            titleNum = sqlite3_column_int(stmt_titleNum, 0);
            [PIC.titleNumArray addObject:[NSNumber numberWithInt:titleNum]];
        }
        sqlite3_finalize(stmt_titleNum);
    }

    //关闭数据库
    [self closeDatabase];
}

- (void)pushVIPModeViewController {
    [ZZPublicClass pushToPurchasePage:self];
}

- (void)pushPurchaseViewController {
    InStoreViewController *ISVC = [[InStoreViewController alloc] initWithNibName:@"InStoreViewController" bundle:nil];
    [ISVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:ISVC animated:YES];
    [ISVC release];
}

#pragma mark - Download Methods
- (void)downloadOrStopDownloadByRow:(int)index {
    
    LibraryCell *cell = (LibraryCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    PackInfoClass *PIC = [_packInfoArray objectAtIndex:index];
    
    if (_currDownloadIndex == -1) {//当前没有下载中的cell,下载这个cell
        //下载index的音频
        _currDownloadIndex = index;
        
        int num = [self indexIsExistInArray:_downloadQueue withNum:index];
        if (num == -1) {
            [_downloadQueue addObject:[NSNumber numberWithInt:_currDownloadIndex]];
        }
        
        self.MrD = [[MrDownload alloc] initWithPackName:PIC.packName titleNumArray:PIC.titleNumArray cellRow:index];
        self.MrD.delegate = self;
        [self.MrD startDownload];
        
        //更改cell中下载按钮的状态为开始下载状态
        PIC.PICStatus = PICStatusDownloading;
        [cell setCellStatusByTag:PIC.PICStatus row:index];
        
    } else if (_currDownloadIndex != index) {// 说明当前有下载中的cell，把这个下载请求加入队列
        //先判断数组中是否有index的这个元素,
        int num = [self indexIsExistInArray:_downloadQueue withNum:index];
        if (num == -1) {
            //没有的话,把index的下载请求加入下载数组中
            [_downloadQueue addObject:[NSNumber numberWithInt:index]];
            
            //更改cell下载按钮为等待下载状态
            PIC.PICStatus = PICStatusWaiting;
            [cell setCellStatusByTag:PIC.PICStatus row:index];
        } else {
            //有的话,把index从队列中删除
            [_downloadQueue removeObjectAtIndex:num];
            
            //更改cell下载按钮为停止下载状态
            PIC.PICStatus = PICStatusStop;
            [cell setCellStatusByTag:PIC.PICStatus row:index];
        }
        
    } else {//当前下载的cell就是选中的这个cell,停止这个cell的下载
        
        //停止下载这个index的音频
        [self.MrD stopDownload];
        
        if (self.MrD) {
            self.MrD.delegate = nil;
//            [self.MrD release], self.MrD = nil;
            [self.MrD release];
        }
        
        //从数组中删除第一个元素
        [_downloadQueue removeObjectAtIndex:0];
        
        //更改cell下载按钮状态为停止下载
        PIC.PICStatus = PICStatusStop;
        [cell setCellStatusByTag:PIC.PICStatus row:index];
        
        //记录上次下载的进度条
        PIC.lastProgress = PIC.progress;
        
        //寻找下一个等待下载的cell
        _currDownloadIndex = -1;
        int num = [self indexIsExistNextDownloadNumBy:_downloadQueue];
        if (num != -1) {
            [self downloadOrStopDownloadByRow:num];
        }
    }
}

- (int)indexIsExistNextDownloadNumBy:(NSMutableArray *)array {
    int num = -1;
    for (NSNumber *number in array) {
        num = [number intValue];
        break;
    }
    
    return num;
}

- (int)indexIsExistInArray:(NSMutableArray *)array withNum:(int)num {
    int returnNum = -1;
    int count = [array count];
    for (int i = 0; i < count; i++) {
        int num2 = [[array objectAtIndex:i] intValue];
        if (num == num2) {
            returnNum = i;
            break;
        }
    }
    
    return returnNum;
}

- (void)updateProgressToPackInfoDB {
    //更改数据库中的Progress字段
    
    NSString *update = @"";
    
    int count = [_packInfoArray count];
    PackInfoClass *PIC = nil;
    for (int i = 0; i < count; i++) {
        PIC = [_packInfoArray objectAtIndex:i];
        if (PIC.progress < 1.0f) {
            update = [update stringByAppendingFormat:@"UPDATE PackInfo SET Progress = %f WHERE PackName = '%@';", PIC.progress, PIC.packName];
        }
    }
    
    if (![update isEqualToString:@""]) {
        NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
        [self openDatabaseIn:dbPath];
        char *errorMsg = NULL;
        if (sqlite3_exec (_database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
            sqlite3_close(_database);
            NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
        }
        
        [self closeDatabase];
    }
    
}

#pragma mark - MrDownload delegate
- (void)MrDownloadDidFailWithMessage:(NSString *)msg cellRow:(int)row {
    
    [self downloadOrStopDownloadByRow:row];
    
    //下载失败，弹出信息
    PackInfoClass *PIC = [_packInfoArray objectAtIndex:row];
    NSString *name = PIC.packName;
    NSString *dfStr = NSLocalizedString(@"DOWNLOAD_FAILED", @"试题下载失败,请稍后再试");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:[NSString stringWithFormat:@"%@%@", name, dfStr] delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    [alert performSelector:@selector(dismissWithClickedButtonIndex:animated:) withObject:nil afterDelay:2.0f];
    [alert release];
    
}

- (void)MrDownloadDidFinishWithCellRow:(int)row {
    
    //继续下一个下载
    [self downloadOrStopDownloadByRow:row];

    //更新cell状态
    LibraryCell *cell = (LibraryCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    PackInfoClass *PIC = [_packInfoArray objectAtIndex:row];
    PIC.PICStatus = PICStatusFree;
    [cell setCellStatusByTag:PIC.PICStatus row:row];
    
    
    //更改PackInfo数据库中的isDownload字段,更新TitleInfo数据库中的isVIP字段
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:dbPath];
    
    NSString *update = [NSString stringWithFormat:@"UPDATE PackInfo SET IsDownload = 'true' WHERE PackName = '%@'; UPDATE TitleInfo SET Vip = 'true' WHERE PackName = '%@';", PIC.packName, PIC.packName];
    
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    
    [self closeDatabase];
    
}

- (void)MrDownloadProgress:(CGFloat)progress cellRow:(int)row {
    //更新cell状态
    LibraryCell *cell = (LibraryCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    PackInfoClass *PIC = [_packInfoArray objectAtIndex:row];
    
//    PIC.progress = (PIC.progress * PIC.progress) + (progress * (1 - PIC.progress));
//    [cell setDownloadProgress:PIC.progress];
    
    PIC.progress = PIC.lastProgress + (progress * (1 - PIC.lastProgress));
    [cell setDownloadProgress:PIC.progress];
}

#pragma mark - appDelegate
- (void)applicationWillEnterForeground:(UIApplication *)application {
    //    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
#if COCOS2D_DEBUG
    NSLog(@"LibraryTableVC---applicationDidEnterBackground");
#endif
    [self updateProgressToPackInfoDB];
    
    if (_currDownloadIndex != -1) {
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UIApplication  *app = [UIApplication sharedApplication];
        UIBackgroundTaskIdentifier bgTask = 0;
        
#if COCOS2D_DEBUG
        NSTimeInterval ti = [[UIApplication sharedApplication]backgroundTimeRemaining];
        NSLog(@"backgroundTimeRemaining: %f", ti); // just for debug
#endif
        bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:bgTask];
        }];

    }
    
}

@end
