//
//  CourseDownloadViewController.m
//  JLPT1Listening
//
//  Created by 赵子龙 on 13-12-31.
//
//

#import "CourseDownloadViewController.h"

#import "CourseDownloadCell.h"
#import "CourseViewController.h"

#import "UserInfo.h"
#import "UserSetting.h"
#import "LoginViewController.h"
#import "SevenNavigationBar.h"


#import "SBJSON.h"
#import "NSString+SBJSON.h"
#import "Reachability.h"
#import "NSString+MD5.h"

#import "DDXML.h"
#import "DDXMLElementAdditions.h"

#define TAG_REQUEST_LIST 1111
#define TAG_REQUEST_PAYMENT 2222
#define TAG_REQUEST_PAYMENT_RECORD 3333

#define TAG_ALERT_PAY_ALL 1234
#define TAG_ALERT_PAY_SINGLE 4321
#define TAG_ALERT_COIN_NOT_ENOUGH 2341
#define TAG_ALERT_DOWNLOAD_ALL 3232
#define TAG_ALERT_BACK_TO_TOP 2424

@interface CourseDownloadViewController (){
    sqlite3 *_database;
    int _currDownloadIndex;
    
//    NSMutableArray *_data;
}
@property (nonatomic, strong) NSMutableArray *packInfoArray;
@property (nonatomic, strong) NSMutableArray *downloadQueue;
@property (nonatomic, strong) MrDownloadCourse *MrD;
@property (assign) BOOL IsFromOpenCourse;

@property (nonatomic, strong)NSString *packageId;
@property (nonatomic, strong)NSString *desc;
@property (nonatomic, strong)ASIHTTPRequest *blogRequest;
@property (nonatomic, strong)ASIHTTPRequest *paymentRecordRequest;
@property (nonatomic, strong)ASIHTTPRequest *paymentRequest;

@property (assign)BOOL isPayAllPack;
@property (assign)int curPayTitleId;

@property (assign)BOOL isThisPageLogin;

@end

@implementation CourseDownloadViewController

- (void)dealloc {
    NSLog(@"CourseDownloadViewController is dealloc");
//    [_downloadQueue release];
//    [_packInfoArray release];
    
    if (self.blogRequest) {
        [self.blogRequest clearDelegatesAndCancel];
//        [self.blogRequest release], self.blogRequest = nil;
    }
    if (self.paymentRecordRequest) {
        [self.paymentRecordRequest clearDelegatesAndCancel];
//        [self.paymentRecordRequest release], self.paymentRecordRequest = nil;
    }
    if (self.paymentRequest) {
        [self.paymentRequest clearDelegatesAndCancel];
//        [self.paymentRequest release], self.paymentRequest = nil;
    }
    
    //删除消息中心的注册对象
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil packageID:(NSString *)packageId desc:(NSString *)desc {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.packageId = packageId;
        self.desc = desc;
        
        self.isPayAllPack = NO;
        self.curPayTitleId = 0;
        
        self.isThisPageLogin = NO;
        
        
        //监听程序中断
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
        
        [ZZPublicClass setRightButtonOnTargetNav:self action:@selector(purchaseAll) title:NSLocalizedString(@"打包下载", nil)];
    }
    
    return self;
}

- (void)makeUserLoginIn {
    
    LoginViewController *myLog = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [myLog setHidesBottomBarWhenPushed:YES];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:myLog];
    
    CGRect rect = (IS_IPAD ? CGRectMake(0, 0, 768, 44) : CGRectMake(0, 0, 320, 44));
    SevenNavigationBar * navBar = [[SevenNavigationBar alloc] initWithFrame:rect];
    UIBarButtonItem * back = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIBarButtonItemStylePlain target:myLog action:@selector(Cancel:)];
    UINavigationItem * item = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"USER_LOGIN", nil)];
    navBar.tintColor = [TestType colorWithTestType];
    
    item.leftBarButtonItem = back;
    NSArray * array = [NSArray arrayWithObject:item];
    [navBar setItems:array];
    [nav.navigationBar addSubview:navBar];
    //            [myLog.view addSubview:navBar];
    myLog.PresOrPush = YES;
    
    [self presentModalViewController:nav animated:YES];
    
    self.isThisPageLogin = YES;
}

//购买所有的课程
- (void)purchaseAll {
    
    //先计算价格，是否全部免费
    int totalPrice = 0;
    for (PackageClass *pic in self.packInfoArray) {
        totalPrice += pic.price;
    }
    
    if (totalPrice == 0) {
        //全部免费,直接下载
        [self pushAlertViewToWraningUserWith:0 isPayAll:YES];
        
    } else {
        if (![UserInfo userLoggedIn]) {
            [self makeUserLoginIn];
        } else {
            
            self.isPayAllPack = YES;
            self.curPayTitleId = 0;
            
            //计算全部未购买的价格
            int price = 0;
            for (PackageClass *pic in self.packInfoArray) {
                if (pic.PICStatus == PICStatusPurchase) {
                    price += pic.price;
                }
            }
            
             [self pushAlertViewToWraningUserWith:price isPayAll:YES];

        }
    }
    
}

- (void)purchaseSingleCourseWithPICIndex:(int)index {
    
    if (![UserInfo userLoggedIn]) {
        [self makeUserLoginIn];
    } else {
        
        PackageClass *PIC = [self.packInfoArray objectAtIndex:index];
        self.isPayAllPack = NO;
        self.curPayTitleId = PIC.titleId;
        
        
        [self pushAlertViewToWraningUserWith:PIC.price isPayAll:NO];
    }
    
}

- (void)pushAlertViewToWraningUserWith:(int)price isPayAll:(BOOL)isPayAll {
    
    UIAlertView *alert = nil;
    
    if (isPayAll) {
        if (price == 0) {
            alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"未下载课程即将开始下载" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"全部下载", nil];
            
            alert.tag = TAG_ALERT_DOWNLOAD_ALL;
        } else {
            alert = [[UIAlertView alloc] initWithTitle:@"确认支付?" message:[NSString stringWithFormat:@"您将购买本课程包中全部内容，共计%d爱语币。", price] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认购买", nil];
            
            alert.tag = TAG_ALERT_PAY_ALL;
        }
        
    } else {
        alert = [[UIAlertView alloc] initWithTitle:@"确认支付?" message:[NSString stringWithFormat:@"您将购买本课程，小计%d爱语币。", price] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认购买", nil];
        
        alert.tag = TAG_ALERT_PAY_SINGLE;
    }
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == TAG_ALERT_PAY_ALL) {//购买全部
        
        if (buttonIndex == 1) {//按了确定按钮
            [self payTheBillWithPIC:nil isPayAllPack:YES];
        } else {
            self.isPayAllPack = NO;
            self.curPayTitleId = 0;
        }
        
    } else if (alertView.tag == TAG_ALERT_PAY_SINGLE){//购买一个
        
        if (buttonIndex == 1) {//按了确定按钮
            PackageClass *curPIC = nil;
            for (PackageClass *PIC in self.packInfoArray) {
                if (PIC.titleId == self.curPayTitleId) {
                    curPIC = PIC;
                }
            }
            
            if (curPIC == nil) {
                NSLog(@"当前没有正确的购买课程出现");
                return;
            }
            
            [self payTheBillWithPIC:curPIC isPayAllPack:NO];
        } else {
            self.isPayAllPack = NO;
            self.curPayTitleId = 0;
        }
        
    } else if (alertView.tag == TAG_ALERT_COIN_NOT_ENOUGH) {
        if (buttonIndex == 1) {//按了确定按钮
            
            NSString *url = [NSString stringWithFormat:@"http://app.iyuba.com/wap/index.jsp?uid=%@&appid=%@", [UserInfo loggedUserID], [TestType iyubaApplicationID]];
            //去爱语吧网站
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];

        }
    } else if (alertView.tag == TAG_ALERT_DOWNLOAD_ALL) {
        if (buttonIndex == 1) {//按了全部下载按钮
            int index = 0;
            for (PackageClass *PIC in self.packInfoArray) {
                if (PIC.PICStatus == PICStatusDownload) {
                    [self downloadOrStopDownloadByRow:index];
                }
                ++index;
            }
        }
    } else if (alertView.tag == TAG_ALERT_BACK_TO_TOP) {
        if (buttonIndex == 1) {
            [self.MrD stopDownload];
            
            //退出的时候保存进度条
            [self updateProgressToPackInfoDB];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

    
}


- (void)backToTop {
    
    //如果有下载，则先提示是否要退出
    if (_currDownloadIndex != -1) {//当前有正在下载的课程，alert一下
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"当前有正在下载的课程，是否立即退出？退出后当前的下载进度会被保存。" delegate:self cancelButtonTitle:@"暂不退出" otherButtonTitles:@"暂停下载，退出", nil];
        
        alert.tag = TAG_ALERT_BACK_TO_TOP;
        [alert show];
    } else {
        
        [self.MrD stopDownload];
        
        //退出的时候保存进度条
        [self updateProgressToPackInfoDB];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    //    self.navigationItem.title = @"题库";
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (self.isThisPageLogin) {
        self.isThisPageLogin = NO;
        //根据登录账号获取购买记录
        [self getUserPaymentRecord];
    }
    
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
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"TAB_COURSE", nil)];
    
    _currDownloadIndex = -1;
    
    _downloadQueue = [[NSMutableArray alloc] init];
    
    _packInfoArray = [[NSMutableArray alloc] init];
    
    //新加的的****************************************
//    _data = [UserSetting testInfoArray];
    
    
    Reachability * reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    
    
    
//    if (_data.count == 0) {
        if (status == NotReachable) {
            //没有网络情况下
            
            //登录了，但是没联网，获取本地的购买记录
            if ([UserInfo userLoggedIn]) {
                [self updateLocalPurchaseIntoPackInfo];
            }
            [self setPackInfoClasses];
            
            //查看右上角的打包下载按钮状态
            [self updateDownloadAllButton];
            
        } else {
            //有网络情况下
            [self requestMoreBlogIsHeader:YES];
            
            //加等待HUB
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            
            [HUD setRemoveFromSuperViewOnHide:YES];
            // Set custom view mode
            HUD.mode = MBProgressHUDModeCustomView;
            
            HUD.delegate = self;
            HUD.labelText = NSLocalizedString(@"Loading...", nil);
            
            [HUD show:YES];
            
            
        }
    
    
        
//    }
    
    if (IOS_NEWER_OR_EQUAL_TO_7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //初始化PIC数组
//    [self setPackInfoClasses];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateDownloadAllButton {
    
    int count = 0;
    for (PackageClass *PIC in self.packInfoArray) {
        if (PIC.PICStatus == PICStatusFree) {
            ++count;
        } else {
            break;
        }
    }
    
    if (self.packInfoArray.count == count) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
}

- (void)updateLocalPurchaseIntoPackInfo {
//    、、、、、、、、
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBClassFromDocuments];
    [self openDatabaseIn:dbPath];
    
    //开始查询
    NSString *sel = [NSString stringWithFormat:@"SELECT TitleId FROM Purchase WHERE UID = %@ AND PackId = %d", [UserInfo loggedUserID], [self.packageId intValue]];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
//        sqlite3_close(_database);
//        NSAssert(NO, @"查询PackInfo失败");

        
        NSLog(@"查询本地数据失败，Code:%d", sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil));
    }
    
    NSMutableArray *titleIdArray = [[NSMutableArray alloc] init];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        
        int titleId = sqlite3_column_int(stmt, 0);
        
        [titleIdArray addObject:[NSNumber numberWithInt:titleId]];
        
    }
    sqlite3_finalize(stmt);
    
    
    //更新
    NSString *update = @"";
    for (NSNumber *titleNumber in titleIdArray) {
        int titleId = [titleNumber intValue];
        if (titleId == 0) {
            update = [update stringByAppendingString:[NSString stringWithFormat:@"UPDATE PackInfo SET IsVip = 'true' WHERE PackId = %@;", self.packageId]];
            break;
        } else {
            update = [update stringByAppendingString:[NSString stringWithFormat:@"UPDATE PackInfo SET IsVip = 'true' WHERE PackId = %@ AND TitleId = %d;", self.packageId, titleId]];
        }
        
    }
    
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
//        sqlite3_close(_database);
//        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
        NSLog(@"%s", errorMsg);
    }
    
    
    //关闭数据库
    [self closeDatabase];
}



#pragma mark -
#pragma mark ASIHTTPRequestDelegate

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (HUD) {
        HUD.labelText = NSLocalizedString(@"STORE_ALERT_FAIL_TITLE", nil);
        [HUD hide:YES afterDelay:1];
        HUD = nil;
    }
    
    if (request.tag == TAG_REQUEST_LIST) {
        //初始化PIC数组
        [self setPackInfoClasses];
        [self.tableView reloadData];
        
        //查看右上角的打包下载按钮状态
        [self updateDownloadAllButton];
        
    } else if (request.tag == TAG_REQUEST_PAYMENT) {
        
        self.isPayAllPack = NO;
        self.curPayTitleId = 0;
        
    } else if (request.tag == TAG_REQUEST_PAYMENT_RECORD) {
        
    }
    
    
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (HUD) {
        [HUD hide:YES];
        HUD = nil;
    }
    
    if (request.tag == TAG_REQUEST_LIST) {//刷新列表用
        NSString *responseString = [request responseString];
//        NSInteger pageNumber;
//        NSInteger lastPage;
        
        NSDictionary * result = [responseString JSONValue];
        NSInteger resultCode = [[result objectForKey:@"result"] integerValue];
        if (resultCode == 1) {//成功
            
            //取得课程信息成功
            NSLog(@"**********获取课程信息成功");
            
            NSArray *courseArray = [result objectForKey:@"data"];
            
            //先将数据写入数据库中
            [self addDataToPackInfoWith:courseArray];
            
            //根据登录账号获取购买记录
            [self getUserPaymentRecord];
            
//            if (![UserInfo userLoggedIn]) {//如果用户没有登录的话，所有收费课程上锁
                [self setPackInfoClasses];
                [self.tableView reloadData];
//            }
            
            
        } else {
            //返回值错误，请稍后再试
            
        }
        
        
    } else if (request.tag == TAG_REQUEST_PAYMENT) {//建立购买连接用
        //获取传下来的信息
        NSData *myData = [request responseData];
        DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:myData options:0 error:nil];
        
        NSArray *items = [doc nodesForXPath:@"response" error:nil];
        if (items) {
            for (DDXMLElement *obj in items) {
                NSString *result = [[obj elementForName:@"result"] stringValue];
                //                s(@"status:%@",status);
                if ([result isEqualToString:@"1"]) {//购买成功
                    
                    NSString *amount = [[obj elementForName:@"amount"] stringValue];
                    
                    if (self.isPayAllPack) {//购买了全部
                        [self addPaymentRecordToPackInfoIsAllPack:YES titleId:0];
                    } else {//购买了一个
                        [self addPaymentRecordToPackInfoIsAllPack:NO titleId:self.curPayTitleId];
                    }
                    
                    //已经购买了，更新界面
                    [self updatePackInfoClasses];
                    [self.tableView reloadData];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"购买成功" message:[NSString stringWithFormat:@"您的爱语币剩余:%@", amount] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
//                    [alert release];
                    
                } else {//购买失败
                    NSString *amount = [[obj elementForName:@"amount"] stringValue];
                    NSString *msg = [[obj elementForName:@"msg"] stringValue];
                    
//                    if ([amount intValue] > 0) {//余额不足
                    
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"购买失败" message:[NSString stringWithFormat:@"%@, 请到vip.iyuba.com充值或立即充值, 当前余额：%d。", msg, [amount intValue]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立即充值", nil];
                        alert.tag = TAG_ALERT_COIN_NOT_ENOUGH;
                        [alert show];
//                        [alert release];
//                    } else {
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"购买失败" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                        [alert show];
////                        [alert release];
//                    }
                    
                    
                }
                
            }
        }
        
        self.isPayAllPack = NO;
        self.curPayTitleId = 0;
        
        //初始化PIC数组
        [self setPackInfoClasses];
        
        [self.tableView reloadData];

    } else if (request.tag == TAG_REQUEST_PAYMENT_RECORD) {
        
        //获取传下来的信息
        NSData *myData = [request responseData];
        DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:myData options:0 error:nil];
        
        NSArray *items = [doc nodesForXPath:@"response" error:nil];
        if (items) {
            for (DDXMLElement *obj in items) {
                NSString *result = [[obj elementForName:@"result"] stringValue];

                if ([result isEqualToString:@"1"]) {
                    NSArray *itemsRecord = [doc nodesForXPath:@"response/data/record" error:nil];
                    NSLog(@"%@", itemsRecord);
                    
                    if (itemsRecord) {
                        
                         [self addPaymentRecordToPackInfoWith:itemsRecord];
                    }
                    
                } else {
                    //获取失败
                }
                
            }
        }
        
        //初始化PIC数组
        [self setPackInfoClasses];
        
        [self.tableView reloadData];
        
    }
    
    
    //查看右上角的打包下载按钮状态
    [self updateDownloadAllButton];
    

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
    NSString *dbPath = [ZZAcquirePath getDBClassFromDocuments];
    [self openDatabaseIn:dbPath];
    
    
    //更新下载状态
    //开始查询
    NSString *sel = [NSString stringWithFormat:@"SELECT PackName, IsVip, IsDownload, IsFree, Progress, TitleId, Price, LastPlayTime, LastPageNum FROM PackInfo ORDER BY TitleId"];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询PackInfo失败");
    }
    
    //    NSString *packName = @"null";
    BOOL isVip, isDownload, isFree;
    float progress;
    int count = 0;
//    int titleId, price;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        //        packName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
        
        NSString *isVipStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 1)];
        isVip = (([isVipStr isEqualToString:@"true"] || [isVipStr isEqualToString:@"True"]) ? YES : NO);
        
        NSString *isDownloadStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 2)];
        isDownload = (([isDownloadStr isEqualToString:@"true"] || [isDownloadStr isEqualToString:@"True"]) ? YES : NO);
        
        NSString *isFreeStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 3)];
        isFree = (([isFreeStr isEqualToString:@"true"] || [isFreeStr isEqualToString:@"True"]) ? YES : NO);
        
        progress = sqlite3_column_double(stmt, 4);
//        titleId = sqlite3_column_int(stmt, 5);
//        price = sqlite3_column_int(stmt, 6);
        
        NSString *lastPlayTimeStr = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 7)];
        NSTimeInterval lastPlayTime = [lastPlayTimeStr doubleValue];
        
        int lastPageNum = sqlite3_column_int(stmt, 8);
        
        if (_packInfoArray.count <= 0) {
            break;
        }
        PackageClass *PIC = [_packInfoArray objectAtIndex:count++];
        PIC.lastPlayTime = lastPlayTime;
        PIC.lastPageNum = lastPageNum;
        [PIC setIyubaVipWithIsDownload:isDownload isFree:isFree isVip:isVip progress:progress];
    }
    sqlite3_finalize(stmt);
    
    [self closeDatabase];
}

- (void)addPaymentRecordToPackInfoIsAllPack:(BOOL)isAllPack titleId:(int)titleId {
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBClassFromDocuments];
    [self openDatabaseIn:dbPath];
    
    NSString *update = @"";
    if (isAllPack) {//全部购买
        update = [update stringByAppendingString:[NSString stringWithFormat:@"UPDATE PackInfo SET IsVip = 'true' WHERE PackId = %@;", self.packageId]];
    } else {
        //单独购买
        update = [update stringByAppendingString:[NSString stringWithFormat:@"UPDATE PackInfo SET IsVip = 'true' WHERE PackId = %@ AND TitleId = %d;", self.packageId, titleId]];
    }
    
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    
    
    //增加本地购买记录
    if (isAllPack) {
        update = @"";
        for (PackageClass *PIC in self.packInfoArray) {
            update = [update stringByAppendingFormat:@"INSERT OR REPLACE INTO Purchase (UID, PackId, TitleId, Price) VALUES (%d, %d, %d, 0);", [[UserInfo loggedUserID] intValue], [self.packageId intValue], PIC.titleId];
        }
        
    } else {
        update = [NSString stringWithFormat:@"INSERT OR REPLACE INTO Purchase (UID, PackId, TitleId, Price) VALUES (%d, %d, %d, 0);", [[UserInfo loggedUserID] intValue], [self.packageId intValue], titleId];
    }
    
    errorMsg = NULL;
    if (sqlite3_exec (_database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        NSLog(@"插入本地购买记录错误");
    }
    
    [self closeDatabase];

}

- (void)addPaymentRecordToPackInfoWith:(NSArray *)dataList {
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBClassFromDocuments];
    [self openDatabaseIn:dbPath];
    
    //先把全部的IsVip全部false
    NSString *update = [NSString stringWithFormat:@"UPDATE PackInfo SET IsVip = 'false' WHERE PackId = %@ AND Price > 0;", self.packageId];
    
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
    }
    
    for (DDXMLElement *obj in dataList) {
        NSString *titleId = [[obj elementForName:@"ProductId"] stringValue];
        NSString *cost = [[obj elementForName:@"Amount"] stringValue];
        
        if (titleId == nil || [titleId isEqualToString:@""]) {
            continue;
        }
        
        //再逐个设置VIPYES
        update = [NSString stringWithFormat:@"UPDATE PackInfo SET IsVip = 'true' WHERE PackId = %@ AND TitleId = %@;", self.packageId, titleId];
        
        char *errorMsg = NULL;
        if (sqlite3_exec (_database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
            NSLog(@"更新错误，根本没有购买这个课程");
        }
        
        
        //增加本地购买记录
        update = [NSString stringWithFormat:@"INSERT OR REPLACE INTO Purchase (UID, PackId, TitleId, Price) VALUES (%d, %d, %d, %d);", [[UserInfo loggedUserID] intValue], [self.packageId intValue], [titleId intValue], [cost intValue]];
        
        errorMsg = NULL;
        if (sqlite3_exec (_database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
            NSLog(@"插入本地购买记录错误");
        }
    }
    
    
    
    [self closeDatabase];
    
}

- (void)addDataToPackInfoWith:(NSArray *)dataList {
    
    
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBClassFromDocuments];
    [self openDatabaseIn:dbPath];
    
    for (NSDictionary *infoDic in dataList) {
        NSInteger titleId = [[infoDic objectForKey:@"id"] integerValue];
        NSInteger cost = [[infoDic objectForKey:@"cost"] integerValue];
//        NSString *desc = [infoDic objectForKey:@"desc"];
        NSString *titleName = [infoDic objectForKey:@"titleName"];
        
        //先搜索有没有
        NSString *query = [NSString stringWithFormat:@"SELECT TitleId FROM PackInfo WHERE PackId = %d AND TitleId = %d", [self.packageId integerValue], titleId];
        
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, nil) != SQLITE_OK) {
            sqlite3_close(_database);
            NSAssert(NO, @"查询PackInfo失败");
        }
        
        BOOL isExist = NO;
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            isExist = YES;
        }
        sqlite3_finalize(stmt);
        
        
        NSString *isFree = @"false";
        NSString *isVip = @"false";
        if (cost <= 0) {
//            isFree = @"true";
            isVip = @"true";
        }
        
        NSString *sql = nil;
        if (isExist) {
            sql  = [NSString stringWithFormat:@"UPDATE PackInfo SET PackName = '%@', IsVip = '%@', Price = %d WHERE PackId = %d AND TitleId = %d;", titleName, isVip, cost, [self.packageId intValue], titleId];
        } else {
           sql  = [NSString stringWithFormat:@"INSERT INTO PackInfo (PackName,IsVip,IsDownload,Progress,IsFree,TitleId,PackId,Price) VALUES (\"%@\",\"%@\",\"false\",0,\"%@\",%d,%d,%d);", titleName, isVip, isFree, titleId, [self.packageId intValue], cost];
        }
        
        
        
        char *errorMsg = NULL;
        if (sqlite3_exec (_database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
            NSLog(@"%s", errorMsg);
            //        sqlite3_close(database);
            //        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
        }
    }
    
    [self closeDatabase];
}

- (void)setPackInfoClasses {
    
    //清空之前的数组
    [_packInfoArray removeAllObjects];
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBClassFromDocuments];
    [self openDatabaseIn:dbPath];
    
    //开始查询
    NSString *sel = [NSString stringWithFormat:@"SELECT PackName, IsVip, IsDownload, IsFree, Progress, TitleId, Price, LastPlayTime, LastPageNum FROM PackInfo ORDER BY TitleId"];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询PackInfo失败");
    }
    
    NSString *packName = @"null";
    BOOL isVip, isDownload, isFree;
    float progress;
    int titleId, price;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        packName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
        NSString *isVipStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 1)];
        isVip = (([isVipStr isEqualToString:@"true"] || [isVipStr isEqualToString:@"True"]) ? YES : NO);
        
        NSString *isDownloadStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 2)];
        isDownload = (([isDownloadStr isEqualToString:@"true"] || [isDownloadStr isEqualToString:@"True"]) ? YES : NO);
        
        NSString *isFreeStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmt, 3)];
        isFree = (([isFreeStr isEqualToString:@"true"] || [isFreeStr isEqualToString:@"True"]) ? YES : NO);
        
        progress = sqlite3_column_double(stmt, 4);
        
        titleId = sqlite3_column_int(stmt, 5);
        price = sqlite3_column_int(stmt, 6);
        
        char *cLastPlayTimeStr = (char *)sqlite3_column_text(stmt, 7);
        NSString *lastPlayTimeStr = @"0";
        if (cLastPlayTimeStr != NULL) {
            lastPlayTimeStr = [NSString stringWithUTF8String:cLastPlayTimeStr];
        }
        NSTimeInterval lastPlaytime = [lastPlayTimeStr doubleValue];
        
        int lastPageNum = sqlite3_column_int(stmt, 8);
        
        
        PackageClass *PIC = [PackageClass packInfoWithPackName:packName isVip:isVip isDownload:isDownload progress:progress isFree:isFree];
        PIC.lastProgress = progress;
        PIC.titleId = titleId;
        PIC.price = price;
        PIC.lastPlayTime = lastPlaytime;
        PIC.lastPageNum = lastPageNum;
        
        [_packInfoArray addObject:PIC];
        
    }
    sqlite3_finalize(stmt);
    
    //关闭数据库
    [self closeDatabase];
}

- (void)pushVIPModeViewController {
    [ZZPublicClass pushToPurchasePage:self];
}

#pragma mark -
#pragma mark Request Method

//根据登录状态获取购买信息
- (void)getUserPaymentRecord {
    
    
    if ([UserInfo userLoggedIn]) {
//        NSString *packageId = self.packageId;//@"1";
        
        NSString *sign = [[NSString stringWithFormat:@"%@%@%@iyuba", [TestType iyubaApplicationID], [UserInfo loggedUserID], self.packageId] MD5String];
        
//        int pageCount = NSIntegerMax;
        
        NSString *urlStr = [NSString stringWithFormat:@"http://app.iyuba.com/pay/apiGetPayRecord.jsp?userId=%@&appId=%@&packageId=%@&sign=%@", [UserInfo loggedUserID], [TestType iyubaApplicationID], self.packageId, sign];
        
#if COCOS2D_DEBUG
        NSLog(@"url:%@",urlStr);
#endif
        
        //    __weak InfoTableViewController * weakSelf = self;
        
        self.paymentRecordRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        self.paymentRecordRequest.delegate = self;
        self.paymentRecordRequest.timeOutSeconds = 20;
        self.paymentRecordRequest.tag = TAG_REQUEST_PAYMENT_RECORD;
        
        [self.paymentRecordRequest startAsynchronous];
        
        
        //加等待HUB
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        
        [HUD setRemoveFromSuperViewOnHide:YES];
        // Set custom view mode
        HUD.mode = MBProgressHUDModeCustomView;
        
        HUD.delegate = self;
        HUD.labelText = NSLocalizedString(@"Loading...", nil);
        
        [HUD show:YES];
    }
    
}

//准备要付款了
- (void)payTheBillWithPIC:(PackageClass *)PIC isPayAllPack:(BOOL)isPayAllPack {
    
    //计算价格
    int price = 0;
    if (isPayAllPack) {
        for (PackageClass *pic in self.packInfoArray) {
            if (pic.PICStatus == PICStatusPurchase) {
                price += pic.price;
            }
        }
        
        if (price == 0) {
            //已经全部购买过了
            NSLog(@"本包的内容已经全部购买过了");
            
            return;
        }
    } else {
        price = PIC.price;
        
    }
    
    
    NSString *sign = [[NSString stringWithFormat:@"%d%@%@%@%diyuba", price, [TestType iyubaApplicationID], [UserInfo loggedUserID], self.packageId, self.curPayTitleId] MD5String];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://app.iyuba.com/pay/payClassApi.jsp?userId=%@&appId=%@&amount=%d&packageId=%@&productId=%d&sign=%@", [UserInfo loggedUserID], [TestType iyubaApplicationID], price, self.packageId, self.curPayTitleId, sign];
    
#if COCOS2D_DEBUG
    NSLog(@"url:%@",urlStr);
#endif
    
    //    __weak InfoTableViewController * weakSelf = self;
    
    self.paymentRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    self.paymentRequest.delegate = self;
    self.paymentRequest.timeOutSeconds = 20;
    self.paymentRequest.tag = TAG_REQUEST_PAYMENT;
    
    [self.paymentRequest startAsynchronous];
    
    //加等待HUB
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    [HUD setRemoveFromSuperViewOnHide:YES];
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Loading...", nil);
    
    [HUD show:YES];
    
}

- (void)requestMoreBlogIsHeader:(BOOL)isHeader {
    
    NSString *packageId = self.packageId;//@"1";
    
    NSString *sign = [[NSString stringWithFormat:@"10102class%@", packageId] MD5String];
    
    int pageCount = NSIntegerMax;
    
    NSString *urlStr = [NSString stringWithFormat:@"http://class.iyuba.com/getClass.iyuba?protocol=10102&id=%@&type=2&sign=%@&pageNumber=1&pageCounts=%d", packageId, sign, pageCount];
    
#if COCOS2D_DEBUG
    NSLog(@"url:%@",urlStr);
#endif
    
    //    __weak InfoTableViewController * weakSelf = self;
    
    self.blogRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    self.blogRequest.delegate = self;
    self.blogRequest.timeOutSeconds = 20;
    self.blogRequest.tag = TAG_REQUEST_LIST;
    
    [self.blogRequest startAsynchronous];
    
}

#pragma mark - Table view data source

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return (IS_IPAD ? 150 : 120);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *infoView = nil;
    CGFloat width = [UIScreen mainScreen].applicationFrame.size.width;
     CGRect frame = CGRectMake(0, 0, width, (IS_IPAD ? 150 : 120));
    
    static NSString *VIPSectionIdentifier = @"VIPSectionHeader";
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (version >= 6.0)
    {
        // iPhone 6.0 code here
        infoView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:VIPSectionIdentifier];
        if (!infoView) {
            
            UITextView *descTextView = [[UITextView alloc] initWithFrame:frame];
            [descTextView setText:self.desc];
//            [descTextView setText:@"日语一级听力更换新题型之后，听力难度增加了，太快了听不懂有木有？题型变化了，反应不过来有木有？本次移动课堂的课程将分别针对课程理解、要点理解、概要理解、即时应答、综合理解等5个N1听力新题型进行全方位的、细致的讲解与分析。带领大家进行逐一击破，日语大神们，快来下载吧！"];
            [descTextView setEditable:NO];
            [descTextView setFont:[UIFont boldSystemFontOfSize:(IS_IPAD ? 25.0 : 16.0)]];
            [descTextView setTextColor:[UIColor whiteColor]];
            if (version >= 7.0) {
                [descTextView setSelectable:NO];
            }
            
            [descTextView setBackgroundColor:[UIColor clearColor]];
            
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CourseIntro.png"]];
            [imgView setFrame:frame];
            
            infoView = [[UIView alloc] initWithFrame:frame];
            [infoView addSubview:imgView];
            [infoView addSubview:descTextView];
            

            
        }
    } else {

        UITextView *descTextView = [[UITextView alloc] initWithFrame:frame];
        [descTextView setText:self.desc];
        [descTextView setEditable:NO];
        [descTextView setFont:[UIFont boldSystemFontOfSize:(IS_IPAD ? 25.0 : 16.0)]];
        [descTextView setTextColor:[UIColor whiteColor]];
        [descTextView setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CourseIntro.png"]];
        [imgView setFrame:frame];
        
        infoView = [[UIView alloc] initWithFrame:frame];
        [infoView addSubview:imgView];
        [infoView addSubview:descTextView];

    }

    
    return infoView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (IS_IPAD) {
        return 150;
    } else {
        return 84;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_packInfoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CourseDownloadCell";
    CourseDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        int nibIndex = (IS_IPAD ? 1 : 0);
        cell = (CourseDownloadCell *)[[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:nibIndex];
        cell.parentVC = self;
        [cell addDownloadBtnStatusToCell];
    }
    int row = indexPath.row;
    PackageClass *PIC = [_packInfoArray objectAtIndex:row];
    
    [cell setCellStatusByTag:PIC.PICStatus row:row];
    [cell setLabelInfoWithPIC:PIC];
    [cell setDownloadProgress:PIC.progress];
    
    //改变cell背景颜色的方法
    [cell setCellColorWithIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PackageClass *PIC = [_packInfoArray objectAtIndex:indexPath.row];
    
    if (PIC.PICStatus == PICStatusFree) {
        
        NSString *CVCNibName = (IS_IPAD ? @"CourseViewController-iPad" : @"CourseViewController");
        
        NSString *audioName = [NSString stringWithFormat:@"%d.m4a", PIC.titleId];
        
        CourseViewController *cvc = [[CourseViewController alloc] initWithNibName:CVCNibName bundle:nil packId:[self.packageId intValue] titleId:PIC.titleId audioName:audioName lastPlayTime:PIC.lastPlayTime lastPageNum:PIC.lastPageNum];
        
        [self.navigationController pushViewController:cvc animated:YES];
        
        // ...
        // Pass the selected object to the new view controller.
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    
}

#pragma mark - Download Methods
- (void)downloadOrStopDownloadByRow:(int)index {
    
    CourseDownloadCell *cell = (CourseDownloadCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    PackageClass *PIC = [_packInfoArray objectAtIndex:index];
    
    if (_currDownloadIndex == -1) {//当前没有下载中的cell,下载这个cell
        //下载index的音频
        _currDownloadIndex = index;
        
        int num = [self indexIsExistInArray:_downloadQueue withNum:index];
        if (num == -1) {
            [_downloadQueue addObject:[NSNumber numberWithInt:_currDownloadIndex]];
        }
        
        self.MrD = [[MrDownloadCourse alloc] initWithPackId:[self.packageId integerValue] titleId:PIC.titleId cellRow:index];
        self.MrD.delegate = self;
//        [self.MrD startDownload];
        
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
//            [self.MrD release];
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
    PackageClass *PIC = nil;
    for (int i = 0; i < count; i++) {
        PIC = [_packInfoArray objectAtIndex:i];
        int titleId = PIC.titleId;
        if (PIC.progress < 1.0f) {
            update = [update stringByAppendingFormat:@"UPDATE PackInfo SET Progress = %f WHERE PackId = %@ AND TitleId = %d;", PIC.progress, self.packageId, titleId];
        }
    }
    
    if (![update isEqualToString:@""]) {
        NSString *dbPath = [ZZAcquirePath getDBClassFromDocuments];
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
    PackageClass *PIC = [_packInfoArray objectAtIndex:row];
    NSString *name = PIC.packName;
    NSString *dfStr = NSLocalizedString(@"DOWNLOAD_FAILED", @"试题下载失败,请稍后再试");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:[NSString stringWithFormat:@"%@%@", name, dfStr] delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    [alert performSelector:@selector(dismissWithClickedButtonIndex:animated:) withObject:nil afterDelay:2.0f];
//    [alert release];
    
}

- (void)MrDownloadDidFinishWithCellRow:(int)row {
    
    //继续下一个下载
    [self downloadOrStopDownloadByRow:row];
    
    //更新cell状态
    CourseDownloadCell *cell = (CourseDownloadCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    PackageClass *PIC = [_packInfoArray objectAtIndex:row];
    PIC.PICStatus = PICStatusFree;
    [cell setCellStatusByTag:PIC.PICStatus row:row];
    
    
    //更改PackInfo数据库中的isDownload字段,更新TitleInfo数据库中的isVIP字段
    NSString *dbPath = [ZZAcquirePath getDBClassFromDocuments];
    [self openDatabaseIn:dbPath];
    
    NSString *update = [NSString stringWithFormat:@"UPDATE PackInfo SET IsDownload = 'true' WHERE PackId = %d AND TitleId = %d;", [self.packageId integerValue], PIC.titleId];
    
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    
    [self closeDatabase];
    
    
    //查看右上角的打包下载按钮状态
    [self updateDownloadAllButton];
    
}

- (void)MrDownloadProgress:(CGFloat)progress cellRow:(int)row {
    //更新cell状态
    CourseDownloadCell *cell = (CourseDownloadCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    PackageClass *PIC = [_packInfoArray objectAtIndex:row];
    
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
