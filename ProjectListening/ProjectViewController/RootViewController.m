//
//  RootViewController.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-4.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//

//
// RootViewController + iAd
// If you want to support iAd, use this class as the controller of your iAd
//

#import "RootViewController.h"
#import "cocos2d.h"
#import "GameConfig.h"
#include <sqlite3.h>
#import "ZZAI.h"
#import "PlanCell.h"
#import "DetailCell.h"
#import "UserSetting.h"
#import "FirstView.h"
#import "TitleInfoClass.h"
#import "PlanInfoClass.h"

#import "StudyViewController.h"
#import "InStoreViewController.h"
#import "UserAdviseViewController.h"

#import "UpdateTitleInfo.h"

@interface RootViewController ()<UITableViewDataSource, UITableViewDelegate> {
//    NSMutableArray *_dataList;
    
    sqlite3 *_database;
    
    int _planNum;
    
    ZZAI *_AI;
    
    BOOL _isUpdated;
    
    //是否显示中文信息, 中国版本独有
    BOOL _isChinese;
    
    BOOL _isCocos2DForegroud;
}
@property (assign)BOOL isOpen;
@property (nonatomic,retain)NSIndexPath *selectIndex;

@property (nonatomic,retain)IBOutlet UITableView *expansionTableView;
@property (nonatomic, retain) NSMutableArray *dataList;
//@property (nonatomic, retain) NSMutableArray *detailArray;
@end

@implementation RootViewController

static RootViewController *instanceOfRootViewController;

@synthesize isOpen = _isOpen ,selectIndex = _selectIndex;

+ (RootViewController *)sharedRootViewController {
    NSAssert(instanceOfRootViewController != nil, @"RootViewController instance not yet initialized!");
	return instanceOfRootViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //单件类
        instanceOfRootViewController = self;
        
        //第一次运行
        if ([UserSetting isFirstTimeInstallApplication]) {
            //把数据库和plist拷贝到用户目录下
            [ZZPublicClass copyFromBundleToDocsWithFileName:DB_NAME_ZZAIDB isPlist:NO];
            [ZZPublicClass copyFromBundleToDocsWithFileName:PLIST_NAME_PROGRESS isPlist:YES];
            //新建音频文件夹
            [ZZPublicClass createUserAudioDirectory];
            
            //初始化一些数据
            [UserSetting setIsNeedPurchase:NO];
            [UserSetting setIsNeedFeedback:YES];
            [UserSetting setIsNeedRate:YES];
            
            int studyTime = [UserSetting studyTimeByNum:0];
            [UserSetting setStudyTime:studyTime];
            [UserSetting setAssistantID:1];
            
            [UserSetting setScreenKeepLight:YES];
            [UserSetting setTextKeepSync:YES];
            [UserSetting setSwipeGestureEnabled:NO];
            
            //设置初始的purchaseNum值,根据plist中的信息
            [UserSetting setPurchaseNum:[UserSetting totalPurchaseNum]];
        }
        
        //这个版本的第一次运行
        if ([UserSetting isThisVersionFirstTimeRun]) {
            
#if 0
            //新版本更新数据库
            [UpdateTitleInfo updateTitleInfoTable];
            [UpdateTitleInfo updatePackInfoTable];
#endif
            
            [UserSetting setOpenTimes:0];
            
            //Toefl 1.1.0版本之后，如果不是Pro版本的话，把全部的题目解锁，因为有内置广告了
            if (!IS_PRO_Ver) {
                [RootViewController unlockAllPackInfo];
            }
            
            //为了解决JLPT3的选择1个小时学习时间的BUG
            if ([TestType isJLPTN3]) {
                int studyTime = [UserSetting studyTime];
                if (studyTime == 7200) {
                    [UserSetting setStudyTime:[UserSetting studyTimeByNum:2]];
                }
            }
            
            //托福的用户更新1.1.0版本如果之前已经购买过题库的话可以开启VIP功能
            if ([TestType isToefl] && !IS_PRO_Ver && [UserSetting purchaseNum] < 2) {
                [UserSetting setPurchaseVIPMode:YES];
            }
            
            
            //复制Class数据库到用户名录下
            [ZZPublicClass copyFromBundleToDocsWithFileName:DB_NAME_CLASS isPlist:NO];

        }

        //监听程序中断
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
    }
    
    return self;
}

- (void)setupCocos2D {   
    EAGLView *glView = [EAGLView viewWithFrame:self.view.bounds
                                   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
                                   depthFormat:0                        // GL_DEPTH_COMPONENT16_OES
                        ];
    glView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:glView atIndex:0];
    [[CCDirector sharedDirector] setOpenGLView:glView];
    if( ! [[CCDirector sharedDirector] enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
    
    CCScene *scene = [AssistantLayer scene];
    
    [[CCDirector sharedDirector] runWithScene:scene];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    ///1
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
    
    //如果已经选择完助理,可以正常使用了
    if (![UserSetting isStartOfEverythingNew]) {
        [self updateExpandTableView];
        [self updateAssistant];
    }
    
    
    _isCocos2DForegroud = YES;
    if ([[CCDirector sharedDirector] isPaused]) {
        [[CCDirector sharedDirector] resume];
    }
}

//- (void)viewWillDisappear:(BOOL)animated {
//    
//    
//    NSLog(@"viewWillDisappear");
//}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    _isCocos2DForegroud = NO;
    [[CCDirector sharedDirector] pause];
    
    
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([UserSetting isSystemOS7]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        CGRect frame = self.expansionTableView.frame;
        frame.origin.y += 20;
        frame.size.height -= 20;
        [self.expansionTableView setFrame:frame];
        
        frame = self.yesBtn.frame;
        frame.origin.y += 20;
        [self.yesBtn setFrame:frame];
        
        frame = self.skipBtn.frame;
        frame.origin.y += 20;
        [self.skipBtn setFrame:frame];
    }
    ///1
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    //如果已经选择完助理,可以正常使用了
    if (![UserSetting isStartOfEverythingNew]) {
        //安排计划
        _AI = [[ZZAI alloc] init];
        [_AI updateDatabase];
        _isUpdated = YES;//防止不会连着更新两次
    } else {
        //没有设置完助理,显示选择计划界面
        FirstView *fView = nil;
        if (IS_IPAD) {
            fView = [[[NSBundle mainBundle] loadNibNamed:@"FirstView-iPad" owner:nil options:nil] objectAtIndex:0];
        } else if (IS_IPHONE_568H) {
            fView = [[[NSBundle mainBundle] loadNibNamed:@"FirstView" owner:nil options:nil] objectAtIndex:1];
        } else {
            fView = [[[NSBundle mainBundle] loadNibNamed:@"FirstView" owner:nil options:nil] objectAtIndex:0];
        }
        fView.tag = 1234;
        
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        if (!window) {
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        }
        [[[window subviews] objectAtIndex:0] addSubview:fView];
        
    }
    
    //cocos2d Layer
    [self setupCocos2D];

    
    self.expansionTableView.sectionFooterHeight = 0;
    self.expansionTableView.sectionHeaderHeight = 0;
    self.isOpen = NO;
    
}

#pragma mark - FirstView Methods
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

//更新题库用
//- (void)updateTitleAndPackDatabase {
//    NSString *path = [ZZAcquirePath getDBZZAIdbFromBundle];
//    [self openDatabaseIn:path];
//    
//    NSString *getPlan = [NSString stringWithFormat:@"SELECT YMD, TitleNum, TitleKey, QuesNum, SoundTime, Score, RightNum, LastIndex FROM Progress ORDER BY YMD DESC;"];
//    
//    sqlite3_stmt *stmt;
//    if (sqlite3_prepare_v2(database, [getPlan UTF8String], -1, &stmt, nil) != SQLITE_OK) {
//        sqlite3_close(database);
//        NSAssert(NO, @"查询Plan信息失败");
//    }
//    
//    [self closeDatabase];
//}

//第一次开启应用，选择完助理和时间之后，去掉导航页面
- (void)startOfEverythingNew {
    [UserSetting setStartOfEverythingNewFalse];
    
    _AI = [[ZZAI alloc] init];
    [_AI updateDatabase];
    _isUpdated = YES;//防止不会连着更新两次
    
    [self updateExpandTableView];
    [self updateAssistant];
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    FirstView *fView = (FirstView *)[[[window subviews] objectAtIndex:0] viewWithTag:1234];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:window cache:YES];
    [fView removeFromSuperview];
    [UIView setAnimationDelegate:self];
// 动画完毕后调用某个方法
    //[UIView setAnimationDidStopSelector:@selector(animationFinished:)];
    [UIView commitAnimations];
    
    
}

#pragma mark - appDelegate

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"RootVC---applicationDidEnterBackground");
//    _isStartAnimation = YES;
}

- (void)apllicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"RootVC---applicationWillEnterForeground");
    
    
    
    
//    [[CCDirector sharedDirector] stopAnimation];
//    _isStartAnimation = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
#if COCOS2D_DEBUG
    NSLog(@"RootVC---applicationDidBecomeActive");
#endif
    
    if (!_isCocos2DForegroud) {
        [[CCDirector sharedDirector] pause];
    }
}



#pragma mark - My Method
- (void)pushStudyViewControllerBySection:(NSInteger)section index:(NSInteger)row isContinue:(BOOL)isContinue {
//    NSMutableDictionary *dic = [_dataList objectAtIndex:section];
//    NSMutableArray *list = [dic objectForKey:@"details"];
//    int totalTime = [[dic objectForKey:@"totalTime"] intValue];
//    int ymd = [[dic objectForKey:@"date"] intValue];
    
    PlanInfoClass *PIC = [_dataList objectAtIndex:section];
    NSMutableArray *list = PIC.detailArray;
    int totalTime = PIC.totalTime;
    int ymd = PIC.YMD;
    
    int continueIndex = row;
    if (isContinue) {
        continueIndex = PIC.lastIndex;
        if (continueIndex == 0) {
            continueIndex = 1;
        }
        
    }
    
    StudyViewController *svc = [[[StudyViewController alloc] initWithNibName:(IS_IPAD ? @"StudyViewController-iPad" : @"StudyViewController") bundle:nil articles:list currIndex:continueIndex totalTime:totalTime ymd:ymd enterTypeTags:EnterTypePlan] autorelease];
    [svc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:svc animated:YES];
    
}

- (void)updateExpandTableView {
    
    //确保启动程序的时候只更新一次
    if (_isUpdated) {
        _isUpdated = NO;
    } else {
        [_AI updateDatabase];
    }
    
    //把数据存到字典数组中
    [self.dataList removeAllObjects];
    self.dataList = [RootViewController getDataList];
    
    //cell的数量
    _planNum = [_dataList count];
    
    //更新表格
    [_expansionTableView reloadData];
}

- (void)updateAssistant {
    CCScene * scene = [[CCDirector sharedDirector] runningScene];

    AssistantLayer *ass = (AssistantLayer *)[scene.children objectAtIndex:0];
    [ass updateData];
    
}

- (IBAction)skipBtnPressed:(id)sender {
    
    switch (_currAMTag) {
        case AMTagsNeedPurchase:
            //不再显示内购信息, 把需要内购设置NO
            [self IsPurchase:NO];
            [self updateAssistant];
            [_yesBtn setHidden:YES];
            [_skipBtn setHidden:YES];
            break;
            
        case AMTagsNeedRate:
            //不再显示评价信息,同上
            [self IsRate:NO];
            [self updateAssistant];
            [_yesBtn setHidden:YES];
            [_skipBtn setHidden:YES];
            break;
            
        case AMTagsLongTimeNoSee:
            //不再显示反馈
            [self IsFeedback:NO];
            [self updateAssistant];
            [_yesBtn setHidden:YES];
            [_skipBtn setHidden:YES];
            break;
            
        default:
            
            break;
    }
    
    
}

- (IBAction)yesBtnPressed:(id)sender {
    switch (_currAMTag) {
        case AMTagsNeedPurchase:
            //跳到内购界面
            [self IsPurchase:YES];
            break;
            
        case AMTagsNeedRate:
            //去评价
            [self IsRate:YES];
            break;
            
        case AMTagsLongTimeNoSee:
            //反馈
            [self IsFeedback:YES];
            break;
            
//        case AMTagsSayings:
//            //显示中文或英文
//            [self IsSayingChinese];
//            break;
            
//        case AMTagsJokes:
//            //显示中文或英文
//            [self IsJokerChinese];
//            break;
            
        default:
            
            break;
    }

}

- (void)IsRate:(BOOL)isRate {
    if (isRate) {
        //跳到rate界面
        [ZZPublicClass rateThisApp];
        
    }
    //以后不再显示评价信息
    [UserSetting setIsNeedRate:NO];
}

- (void)IsPurchase:(BOOL)isPurchase {
    if (isPurchase) {
        //跳到purchase界面
        InStoreViewController *inStoreVC = [[InStoreViewController alloc] initWithNibName:@"InStoreViewController" bundle:nil];
        [self.navigationController pushViewController:inStoreVC animated:YES];
        [inStoreVC release];
    } else {
        //以后不再显示内购信息
        [UserSetting setIsNeedPurchase:NO];
    }
}

- (void)IsFeedback:(BOOL)isFeedback {
    if (isFeedback) {
        //跳到isFeedback界面
        UserAdviseViewController *userAdviseVC = [[UserAdviseViewController alloc] init];
        [self.navigationController pushViewController:userAdviseVC animated:YES];
        [userAdviseVC release];
    }
    //以后不再显示isFeedback信息
    [UserSetting setIsNeedFeedback:NO];
}

- (void)IsSayingChinese {
    if (_isChinese) {
        //切换中文
    } else {
        //切换英文
    }
}

- (void)IsJokerChinese {
    if (_isChinese) {
        //切换中文
    } else {
        //切换英文
    }
}

- (void)setButtonStatusCurrentAMTags:(AMTags)tag {
    _currAMTag = tag;
    
    //如果是本地化中文的话，
    _isChinese = NO;
    
    switch (_currAMTag) {
        case AMTagsNeedPurchase:
        case AMTagsNeedRate:
        case AMTagsLongTimeNoSee:
            [_yesBtn setHidden:NO];
            [_skipBtn setHidden:NO];
            break;
            
//        case AMTagsSayings:
//            [_yesBtn setHidden:NO];
//            [_skipBtn setHidden:YES];
//            break;
//            
//        case AMTagsJokes:
//            [_yesBtn setHidden:NO];
//            [_skipBtn setHidden:YES];
//            break;
            
        default:
            [_yesBtn setHidden:YES];
            [_skipBtn setHidden:YES];
            break;
    }
}

+ (void)unlockAllPackInfo {
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    
    sqlite3 *database;
    if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, @"Open database failed");
    }
    
    //计算出Plan
    NSString *update = [NSString stringWithFormat:@"UPDATE PackInfo SET IsVip = 'true';"];
    
    char *errorMsg = NULL;
    if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    
    //关闭数据库
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert(NO, @"Close database failed");
    }
}

+ (NSMutableArray *)getDataList {
    sqlite3 *database;
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, @"Open database failed");
    }
    
    //计算出Plan
    NSString *getPlan = [NSString stringWithFormat:@"SELECT YMD, TitleNum, TitleKey, QuesNum, SoundTime, Score, RightNum, LastIndex FROM Progress ORDER BY YMD DESC;"];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [getPlan UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, @"查询Plan信息失败");
    }
    
    
    //dataArray --> dataDic --> {月份，总音频时间，总题数，总文章数，详细文章信息数组}
    //details --> detailDic --> {题号，文章名，小题数量，音频时间}
    NSString *titleNum = nil;
    NSString *titleName = nil;
    NSString *quesNum = nil;
    NSString *soundtime = nil;
    NSString *rightNum = nil;
    NSNumber *ymd = 0, *score = 0;
    int totalTime = 0, totalQuesNum = 0, totalRightNum = 0;
    int lastIndex = 0;
    
    int count = 0;
    NSMutableArray *dataArray = [[[NSMutableArray alloc] init] autorelease];
//    NSMutableDictionary *dataDic = nil;
    while (sqlite3_step(stmt) == SQLITE_ROW && count++ <= 6) {
        
        totalTime = 0;
        totalQuesNum = 0;
        
        ymd = sqlite3_column_int(stmt, 0);
        
        titleNum = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
        NSMutableArray *titleNums = (NSMutableArray *)[titleNum componentsSeparatedByString:SEPARATE_SYMBOL];
        [titleNums removeLastObject];
        
        titleName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
        NSMutableArray *titleNames = (NSMutableArray *)[titleName componentsSeparatedByString:SEPARATE_SYMBOL];
        [titleNames removeLastObject];
        
        quesNum = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
        NSMutableArray *quesNums = (NSMutableArray *)[quesNum componentsSeparatedByString:SEPARATE_SYMBOL];
        [quesNums removeLastObject];
        
        soundtime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)];
        NSMutableArray *soundtimes = (NSMutableArray *)[soundtime componentsSeparatedByString:SEPARATE_SYMBOL];
        [soundtimes removeLastObject];
        
        score = sqlite3_column_int(stmt, 5);
        
        rightNum = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)];
        NSMutableArray *rightNums = (NSMutableArray *)[rightNum componentsSeparatedByString:SEPARATE_SYMBOL];
        [rightNums removeLastObject];
        
        lastIndex = sqlite3_column_int(stmt, 7);
        
        int titleCount = [titleNums count];
        NSMutableArray *details = [[NSMutableArray alloc] init];
        for (int i = 0; i < titleCount; i++) {
            int tNum = [[titleNums objectAtIndex:i] intValue];
            NSString *tName = [titleNames objectAtIndex:i];
            int qNum = [[quesNums objectAtIndex:i] intValue];
            totalQuesNum += qNum;
            int sTime = [[soundtimes objectAtIndex:i] intValue];
            totalTime += sTime;
            int rNum = [[rightNums objectAtIndex:i] intValue];
            totalRightNum += rNum;
            
//            NSMutableDictionary *detailDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:tNum], @"titleNum", tName, @"titleName", [NSNumber numberWithInt:qNum], @"quesNum", [NSNumber numberWithInt:sTime], @"soundTime", [NSNumber numberWithInt:rNum], @"rightNum", nil];
//            [details addObject:detailDic];
            
            TitleInfoClass *TIC = [TitleInfoClass titleInfoWithTitleName:tName titleNum:tNum quesNum:qNum soundTime:sTime rightNum:rNum];
            [details addObject:TIC];
        }
        

//        dataDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:ymd, @"date", [NSNumber numberWithInt:totalTime], @"totalTime", [NSNumber numberWithInt:totalQuesNum], @"totalQuesNum", [NSNumber numberWithInt:titleCount], @"totalTitleNum", score, @"score", details, @"details", [NSNumber numberWithInt:totalRightNum], @"totalRightNum", nil];
//        [details release];
//        [dataArray addObject:dataDic];
        
        PlanInfoClass *PIC = [PlanInfoClass planInfoWithYMD:ymd totalTime:totalTime totalQuesNum:totalQuesNum totalTitleNum:titleCount score:score totalRightNum:totalRightNum lastIndex:lastIndex];
        PIC.detailArray = details;
        [details release];
        [dataArray addObject:PIC];
        
    }
    sqlite3_finalize(stmt);
    
    //关闭数据库
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert(NO, @"Close database failed");
    }
    
    return dataArray;
}
/*
- (void)createUserAudioDirectory {
    
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseByPath:path];
    
    //计算出Plan
    NSString *getCount = [NSString stringWithFormat:@"SELECT PackName FROM PackInfo ORDER BY id"];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [getCount UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(NO, @"查询PackInfo数量信息失败");
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *audioRootDir = [ZZAcquirePath getDocDirectoryWithFileName:@"audio"];
    //    int count = 0;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        //        count++;
        NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
        NSString *audioDir = [ZZAcquirePath getDocDirectoryWithFileName:[NSString stringWithFormat:@"audio/%@", name]];
        
        if ([fm fileExistsAtPath:audioDir] == NO) {
            [fm createDirectoryAtPath:audioDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    sqlite3_finalize(stmt);
    
    //关闭数据库
    //    [self closeDatabase];
    
    
    
    
    if ([fm fileExistsAtPath:audioRootDir] == NO) {
        NSAssert(NO, @"ERROR, 创建目录失败");
        //        exit(0);
    }
    
    //    [packNameArray release], packNameArray = nil;
    
    if ([self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:audioRootDir]] == NO) {
        NSLog(@"Not to back up Failed");
    }
	
}

#pragma mark - iCloud
// not to back up to iCloud
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
	
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
	
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}
 */


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dataList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isOpen) {
        if (self.selectIndex.section == section) {
            PlanInfoClass *PIC = [_dataList objectAtIndex:section];
            return PIC.detailArray.count + 1;
//            return [[[_dataList objectAtIndex:section] objectForKey:@"details"] count] + 1;
        }
    }
    return 1;
}
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isOpen && self.selectIndex.section == indexPath.section && indexPath.row!=0) {
        return (IS_IPAD ? 70 : 40);
        
    } else {
        return (IS_IPAD ? 180 : 102);
        
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isOpen && self.selectIndex.section == indexPath.section && indexPath.row!=0) {
        
        int num = [indexPath section];
        UIColor *color = nil;
        if (num % 2 == 1) {
            color = [UIColor colorWithRed:(CGFloat)232 / 255 green:(CGFloat)239 / 255 blue:(CGFloat)234 / 255 alpha:1.0];
        } else {
            color = [UIColor colorWithRed:(CGFloat)242 / 255 green:(CGFloat)250 / 255 blue:(CGFloat)245 / 255 alpha:1.0];
        }
        [cell setBackgroundColor:color];
    } else {
        int num = [indexPath section];
        UIColor *color = nil;
        if (num % 2 == 1) {
            color = [UIColor colorWithRed:(CGFloat)232 / 255 green:(CGFloat)239 / 255 blue:(CGFloat)234 / 255 alpha:1.0];
        } else {
            color = [UIColor colorWithRed:(CGFloat)242 / 255 green:(CGFloat)250 / 255 blue:(CGFloat)245 / 255 alpha:1.0];
        }
        [cell setBackgroundColor:color];

    }
    
        
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    int section = indexPath.section;
    if (self.isOpen && self.selectIndex.section == section && row!=0) {
        static NSString *CellIdentifier = @"DetailCell";
        DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            int nibIndex = (IS_IPAD ? 1 : 0);
            cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:nibIndex];
        }
        
        PlanInfoClass *PIC = [_dataList objectAtIndex:self.selectIndex.section];
        NSMutableArray *detailArray = PIC.detailArray;
        TitleInfoClass *TIC = [detailArray objectAtIndex:row - 1];
        [cell setDetailInfoWithTIC:TIC];
        
        int lastIndex = PIC.lastIndex;
        if (lastIndex == row) {
            [cell.conPointImg setHidden:NO];
        } else {
            [cell.conPointImg setHidden:YES];
        }
        
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"PlanCell";
        PlanCell *cell = (PlanCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            int nibIndex = (IS_IPAD ? 1 : 0);
            cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:nibIndex];
            cell.parentVC = self;
        }
        PlanInfoClass *PIC = [_dataList objectAtIndex:section];
        [cell setPlanInfoWithPIC:PIC];
        cell.currPlanSection = section;
        [cell changeArrowWithUp:([self.selectIndex isEqual:indexPath]?YES:NO)];
        return cell;
    }
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if ([indexPath isEqual:self.selectIndex]) {
            self.isOpen = NO;
            [self didSelectCellRowFirstDo:NO nextDo:NO];
            self.selectIndex = nil;
            
        } else {
            if (!self.selectIndex) {
                self.selectIndex = indexPath;
                [self didSelectCellRowFirstDo:YES nextDo:NO];
                
            } else {
                
                [self didSelectCellRowFirstDo:NO nextDo:YES];
            }
        }
        
    } else {
        [self pushStudyViewControllerBySection:indexPath.section index:indexPath.row isContinue:NO];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    self.isOpen = firstDoInsert;
    
    PlanCell *cell = (PlanCell *)[self.expansionTableView cellForRowAtIndexPath:self.selectIndex];
    [cell changeArrowWithUp:firstDoInsert];
    
    [self.expansionTableView beginUpdates];
    
    int section = self.selectIndex.section;
    PlanInfoClass *PIC = [_dataList objectAtIndex:section];
    int contentCount = PIC.detailArray.count;
    
	NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
	for (NSUInteger i = 1; i < contentCount + 1; i++) {
		NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
		[rowToInsert addObject:indexPathToInsert];
	}
	
	if (firstDoInsert)
    {   [self.expansionTableView insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	else
    {
        [self.expansionTableView deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
    
	[rowToInsert release];
	
	[self.expansionTableView endUpdates];
    if (nextDoInsert) {
        self.isOpen = YES;
        self.selectIndex = [self.expansionTableView indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
    if (self.isOpen) [self.expansionTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - Other System Method

// Override to allow orientations other than the default portrait orientation
//valid for iOS 4 and 5, IMPORTANT, for iOS6 also modify supportedInterfaceOrientations
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	//
	// There are 2 ways to support auto-rotation:
	//  - The OpenGL / cocos2d way
	//     - Faster, but doesn't rotate the UIKit objects
	//  - The ViewController way
	//    - A bit slower, but the UiKit objects are placed in the right place
	//
	
#if GAME_AUTOROTATION==kGameAutorotationNone
	//
	// EAGLView won't be autorotated.
	// Since this method should return YES in at least 1 orientation, 
	// we return YES only in the Portrait orientation
	//
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
	
#elif GAME_AUTOROTATION==kGameAutorotationCCDirector
	//
	// EAGLView will be rotated by cocos2d
	//
	// Sample: Autorotate only in landscape mode
	//
	if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
		[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeRight];
	} else if( interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeLeft];
	}
	
	// Since this method should return YES in at least 1 orientation, 
	// we return YES only in the Portrait orientation
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
	
#elif GAME_AUTOROTATION == kGameAutorotationUIViewController
	//
	// EAGLView will be rotated by the UIViewController
	//
	// Sample: Autorotate only in portrait mode
	//
	// return YES for the supported orientations
	
	return ( UIInterfaceOrientationIsPortrait( interfaceOrientation ) );
	
#else
#error Unknown value in GAME_AUTOROTATION
	
#endif // GAME_AUTOROTATION
	
	// Shold not happen
	return NO;
}

// these methods are needed for iOS 6
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

-(NSUInteger)supportedInterfaceOrientations{
    //Modify for supported orientations, put your masks here, trying to mimic behavior of shouldAutorotate..
    #if GAME_AUTOROTATION==kGameAutorotationNone
	    return UIInterfaceOrientationMaskPortrait;
    #elif GAME_AUTOROTATION==kGameAutorotationCCDirector
    	NSAssert(NO, @"RootviewController: kGameAutorotation isn't supported on iOS6");
	    return UIInterfaceOrientationMaskLandscape;
    #elif GAME_AUTOROTATION == kGameAutorotationUIViewController
    	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    	//for both landscape orientations return UIInterfaceOrientationLandscape
    #else 
    #error Unknown value in GAME_AUTOROTATION
	
	#endif // GAME_AUTOROTATION
}

#if GAME_AUTOROTATION==kGameAutorotationUIViewController
- (BOOL)shouldAutorotate {
    return YES;
}
#else 
- (BOOL)shouldAutorotate {
    return NO;
}
#endif

//__IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
#else //deprecated in iOS6, so call only < 6. 
- (void)viewDidUnload {
    [self setSkipBtn:nil];
    [self setYesBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [[CCDirector sharedDirector] end];
}

#endif //__IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
#endif

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    //删除消息中心的注册对象
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    instanceOfRootViewController = nil;
    [_AI release];
    [_skipBtn release];
    [_yesBtn release];
    [super dealloc];
}
@end
