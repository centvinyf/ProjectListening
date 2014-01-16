//
//  ZZPublicClass.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-20.
//
//

#import "ZZPublicClass.h"
#import "NSDate+ZZDate.h"
#import "UserSetting.h"
#include <sqlite3.h>
#include <sys/xattr.h>
#import "VIPStoreViewController.h"
#import "SevenNavigationBar.h"
#import "StudyViewController.h"

@implementation ZZPublicClass

+ (void)setBackButtonOnTargetNav:(id)controller action:(SEL)action {
    //设置navbar上的按钮Back按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:controller action:action forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"backBtn.png"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"backBtn_hl.png"] forState:UIControlStateHighlighted];
    [backBtn setFrame:CGRectMake(0, 0, 32, 30)];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [[controller navigationItem] setLeftBarButtonItem:backItem];
    [backItem release];
}

//iPad上得Title文字是灰色的，不知道为什么
+ (void)setTitleOnTargetNav:(id)controller title:(NSString *)title {
    if (IS_IPAD) {
        //设置navbar上的Title
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        [titleLabel setText:title];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [[controller navigationItem] setTitleView:titleLabel];
        [titleLabel release];
    } else {
        [[controller navigationItem] setTitle:title];
    }
    
}

+ (void)setRightButtonOnTargetNav:(id)controller action:(SEL)action title:(NSString *)title {
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:controller action:action];
    editItem.tintColor = [TestType colorWithTestType];
    [[controller navigationItem] setRightBarButtonItem:editItem];
    [editItem release];
//    self.navigationItem.rightBarButtonItem = editItem;
}

+ (void)copyFromBundleToDocsWithFileName:(NSString *)fileName isPlist:(BOOL)isPlist {
    //拷贝文件到Documents文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    if(![fileManager fileExistsAtPath:filePath]) //如果不存在
    {
#if COCOS2D_DEBUG
        NSLog(@"File is not exist");
#endif
        //        NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"ZZAIdb" ofType:@"sqlite"]; //获取程序包中相应文件的路径
        NSString *dataPath =  [[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/%@",fileName];
        NSError *error;
        if([fileManager copyItemAtPath:dataPath toPath:filePath error:&error]) //拷贝
        {
#if COCOS2D_DEBUG
            NSLog(@"copy file success");
#endif
            
            if (isPlist) {
                //把今天的日期拷贝到plist中
                NSMutableDictionary *data = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
                [data setObject:[NSDate getLocateDate:[NSDate date]] forKey:ASSISTANT_LAST_OPEN_DATE];
                [data setObject:[NSDate getLocateDate:[NSDate date]] forKey:ASSISTANT_FIRST_OPEN_DATE];
                
                //把当前的时间写进plist中
                int hour = [NSDate getTimeBy:[NSDate getLocateDate:[NSDate date]]];
                [data setObject:[NSNumber numberWithInt:hour] forKey:ASSISTANT_MOST_EARLY_TIME];
                [data setObject:[NSNumber numberWithInt:hour] forKey:ASSISTANT_MOST_LATE_TIME];
                if (![data writeToFile:filePath atomically:YES]) {
#if COCOS2D_DEBUG
                    NSLog(@"写入plist失败");
#endif
                }
            }
        } else {
#if COCOS2D_DEBUG
            NSLog(@"%@",error);
#endif
        }
    }
    
}

+ (void)createUserAudioDirectory {
    
    sqlite3 *database;
    
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    if (sqlite3_open([dbPath UTF8String], &database) != SQLITE_OK) {
#if COCOS2D_DEBUG
        NSLog(@"%d", sqlite3_open([dbPath UTF8String], &database));
#endif
        sqlite3_close(database);
        NSAssert(NO, @"Open database failed");
    }
    
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
//        NSString *audioDir = [ZZAcquirePath getDocDirectoryWithFileName:[NSString stringWithFormat:@"audio/%@", name]];
        NSString *audioDir = [ZZAcquirePath getAudioDocDirectoryWithFileName:name];
        if ([fm fileExistsAtPath:audioDir] == NO) {
            [fm createDirectoryAtPath:audioDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    sqlite3_finalize(stmt);
    
    //关闭数据库
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert(NO, @"Close database failed");
    }
    
    
    if ([fm fileExistsAtPath:audioRootDir] == NO) {
        NSAssert(NO, @"ERROR, 创建目录失败");
//        exit(0);
    }
    
    
    //不备份到icloud
    NSURL *URL = [NSURL URLWithString:audioRootDir];
    const char* filePath = [[URL path] fileSystemRepresentation];
	
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
	
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    if ((result == 0) == NO) {
#if COCOS2D_DEBUG
        NSLog(@"Not to back up Failed");
#endif
    }
	
}

+ (void)createCoursePathInUserDirectoryWithPackId:(int)packId titleId:(int)titleId {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    
    NSString *courseDir = [ZZAcquirePath getCourseDocDirectoryWithPackId:packId titleId:titleId];
    if ([fm fileExistsAtPath:courseDir] == NO) {
        [fm createDirectoryAtPath:courseDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
    //不备份到icloud
    NSString *audioRootDir = [ZZAcquirePath getDocDirectoryWithFileName:@"course"];
    NSURL *URL = [NSURL URLWithString:audioRootDir];
    const char* filePath = [[URL path] fileSystemRepresentation];
	
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
	
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    if ((result == 0) == NO) {
#if COCOS2D_DEBUG
        NSLog(@"Not to back up Failed");
#endif
    }
	
}

+ (CGFloat)getTVHeightByStr:(NSString *)text constraintWidth:(CGFloat)width isBold:(BOOL)isBold {
    
//    NSAttributedString *aText = [[NSAttributedString alloc] initWithString:text];
    
    int fontSize = [UserSetting textFontSizeFake];
    
    CGSize constraint = CGSizeMake(width, 20000.0f);
    
    UIFont *font = nil;
    if (isBold) {
        //改字体改字体
        font = [UIFont fontWithName:FONT_NAME_BOLD size:fontSize];
    } else {
        //改字体改字体
        font = [UIFont fontWithName:FONT_NAME size:fontSize];
    }
    
    
    CGFloat height;
    
    if ([UserSetting isSystemOS7]) {
    
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              font, NSFontAttributeName,
                                              nil];
        
        CGRect frame = [text boundingRectWithSize:constraint
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:attributesDictionary
                                          context:nil];
        
        
        height = frame.size.height;
    } else {
        CGSize size = [text sizeWithFont:font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        height = size.height;
    } 
    
    
    return height + CELL_CONTENT_MARGIN;
}

+ (void)rateThisApp {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", APP_ID]]];
}

+ (void)pushToPurchasePage:(UIViewController *)parentVC {
//    parentVC.navigationController.navigationBarHidden = YES;
    NSString *nibName = (IS_IPAD ? @"VIPStoreViewController-iPad" : @"VIPStoreViewController");
    VIPStoreViewController *storeVC = [[VIPStoreViewController alloc] initWithNibName:nibName bundle:nil];

    UINavigationController * nav = [[[UINavigationController alloc] initWithRootViewController:storeVC] autorelease];
    CGRect rect = (IS_IPAD ? CGRectMake(0, 0, 768, 44) : CGRectMake(0, 0, 320, 44));
    SevenNavigationBar * navBar = [[[SevenNavigationBar alloc] initWithFrame:rect] autorelease];
    UIBarButtonItem * back = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil) style:UIBarButtonItemStylePlain target:storeVC action:@selector(Cancel:)];
    UINavigationItem * item = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"UPGRADE_VIP", nil)];
    navBar.tintColor = [TestType colorWithTestType];
    
    item.rightBarButtonItem = back;
    NSArray * array = [NSArray arrayWithObject:item];
    [navBar setItems:array];
    [nav.navigationBar addSubview:navBar];
    
    [parentVC presentModalViewController:nav animated:YES];
}


@end
