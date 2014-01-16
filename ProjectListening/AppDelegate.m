//
//  AppDelegate.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-4.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "RootViewController.h"
#import "LibraryTableViewController.h"
#import "NewWordsViewController.h"
#import "InAppSettingsKit/Controllers/IASKAppSettingsViewController.h"
#import "UserSetting.h"
#import "NSDate+ZZDate.h"
#import "Flurry/Flurry.h"
#import "InfoTableViewController.h"
//#import "OpenCourseTableViewController.h"

#include <sqlite3.h>
#import "NewWordsViewController.h"
#import "CourseListController.h"

#define TAG_NAV_1 111
#define TAG_NAV_2 222
#define TAG_NAV_3 333
#define TAG_NAV_4 444
#define TAG_NAV_5 555
#define TAG_NAV_6 666

@interface AppDelegate ()

//@property (nonatomic, retain) LeveyTabBarController *leveyTabBarController;
@property (nonatomic, retain) UITabBarController *rootTabBarController;

@property (nonatomic, retain) UIViewController *firstRunViewController;

@end

@implementation AppDelegate

@synthesize window;
//@synthesize leveyTabBarController;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

//Flurry捕获异常
void uncaughtExceptionHandler(NSException *exception) {
	[Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
	// Init the window
//	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
    /*
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
     */
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];
	
    //加tabbar
    RootViewController              *vc_1 = nil;
	LibraryTableViewController      *vc_2 = nil;
	NewWordsViewController          *vc_3_1 = nil;
    CourseListController            *vc_3_2 = nil;
	InfoTableViewController         *vc_4 = nil;
    IASKAppSettingsViewController   *vc_5 = nil;
//    LibraryTableViewController   *vc_6 = nil;
    
    NSString *RVCNibName = nil;
    NSString *LTVCNibName = nil;
    NSString *NVCNibName = nil;
    NSString *IVCNibName = nil;
    NSString *OCTVCName = nil;
    if (IS_IPAD) {
        RVCNibName = @"RootViewController-iPad";
        LTVCNibName = @"LibraryTableViewController-iPad";
        NVCNibName = @"NewWordsViewController-iPad";
        IVCNibName = @"InfoTableViewController-iPad";
        OCTVCName = @"CourseListController-iPad";
    } else {
        RVCNibName = @"RootViewController";
        LTVCNibName = @"LibraryTableViewController";
        NVCNibName = @"NewWordsViewController";
        IVCNibName = @"InfoTableViewController";
        OCTVCName = @"CourseListController";
    }
    vc_1 = [[RootViewController alloc] initWithNibName:RVCNibName bundle:nil];
    vc_2 = [[LibraryTableViewController alloc] initWithNibName:LTVCNibName bundle:nil];
    
    if ([TestType isHasOpeningCourse]) {
        vc_3_2 = [[CourseListController alloc] initWithNibName:OCTVCName bundle:nil];
    } else {
        vc_3_1 = [[NewWordsViewController alloc] initWithNibName:NVCNibName bundle:nil];
    }
    
    vc_5 = [[IASKAppSettingsViewController alloc] init];
//    vc_6 = [[LibraryTableViewController alloc] initWithNibName:LTVCNibName bundle:nil];
    
    
    //助理1
	UINavigationController *nav_1 = [[UINavigationController alloc] initWithRootViewController:vc_1];
	[vc_1 release];
    nav_1.navigationBar.tag = TAG_NAV_1;
    nav_1.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [nav_1.navigationBar setBackgroundImage:[UIImage imageNamed:@"navStyle.png"] forBarMetrics:UIBarMetricsDefault];
    
    
    //题库2
    UINavigationController *nav_2 = [[UINavigationController alloc] initWithRootViewController:vc_2];
	[vc_2 release];
    nav_2.navigationBar.tag = TAG_NAV_2;
    nav_2.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [nav_2.navigationBar setBackgroundImage:[UIImage imageNamed:@"navStyle.png"] forBarMetrics:UIBarMetricsDefault];

    
    
    //收藏3或者公开课3
    UINavigationController *nav_3 = nil;
    if ([TestType isHasOpeningCourse]) {
        nav_3 = [[UINavigationController alloc] initWithRootViewController:vc_3_2];
        [vc_3_2 release];//ARC不需要release
    } else {
        nav_3 = [[UINavigationController alloc] initWithRootViewController:vc_3_1];
        [vc_3_1 release];//ARC不需要release
    }
    
    nav_3.navigationBar.tag = TAG_NAV_3;
    nav_3.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [nav_3.navigationBar setBackgroundImage:[UIImage imageNamed:@"navStyle.png"] forBarMetrics:UIBarMetricsDefault];
    
    
    
    //设置5
    UINavigationController *nav_5 = [[UINavigationController alloc] initWithRootViewController:vc_5];
	[vc_5 release];
    nav_5.navigationBar.tag = TAG_NAV_5;
    nav_5.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [nav_5.navigationBar setBackgroundImage:[UIImage imageNamed:@"navStyle.png"] forBarMetrics:UIBarMetricsDefault];
    
    
    NSArray *ctrlArr = nil;
    
    if ([TestType isHasTestInfo]) {
        vc_4 = [[InfoTableViewController alloc] initWithNibName:IVCNibName bundle:nil];
        //资讯4
        UINavigationController *nav_4 = [[UINavigationController alloc] initWithRootViewController:vc_4];
        [vc_4 release];
        nav_4.navigationBar.tag = TAG_NAV_4;
        nav_4.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
        [nav_4.navigationBar setBackgroundImage:[UIImage imageNamed:@"navStyle.png"] forBarMetrics:UIBarMetricsDefault];
        
        
//        //设置6
//        UINavigationController *nav_6 = [[UINavigationController alloc] initWithRootViewController:vc_6];
//        [vc_6 release];
//        nav_6.navigationBar.tag = TAG_NAV_6;
//        nav_6.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
//        [nav_6.navigationBar setBackgroundImage:[UIImage imageNamed:@"navStyle.png"] forBarMetrics:UIBarMetricsDefault];
        
        
        ctrlArr = [NSArray arrayWithObjects:nav_1, nav_2, nav_3, nav_4, nav_5, nil];
        [nav_1 release];
        [nav_2 release];
        [nav_3 release];
        [nav_4 release];
        [nav_5 release];
    } else {
        ctrlArr = [NSArray arrayWithObjects:nav_1, nav_2, nav_3, nav_5, nil];
        [nav_1 release];
        [nav_2 release];
        [nav_3 release];
        [nav_5 release];
    }
    
	
    
    _rootTabBarController = [[UITabBarController alloc] init];
    [_rootTabBarController setViewControllers:ctrlArr];
    [_rootTabBarController setDelegate:self];
    UIImage *tabarImg = nil;
    
    if ([TestType isHasTestInfo]) {
        if ([UserSetting isSystemOS7] && IS_IPAD) {
            tabarImg = [UIImage imageNamed:@"c-2-1-ios7-5.png"];
        } else {
            tabarImg = [UIImage imageNamed:@"c-2-1-5.png"];
        }
    } else {
        if ([UserSetting isSystemOS7] && IS_IPAD) {
            tabarImg = [UIImage imageNamed:@"c-2-1-ios7.png"];
        } else {
            tabarImg = [UIImage imageNamed:@"c-2-1.png"];
        }
    }
    
    [_rootTabBarController.tabBar setBackgroundImage:tabarImg];
    [self appearenceTabbar:_rootTabBarController];
    [self.window addSubview:_rootTabBarController.view];
    
    
    [self.window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
    
    [AppDelegate cancelLocalNotification];
    [AppDelegate createLocalNotification];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    //FlurryAnalytics:begin receiving basic metric data
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[Flurry startSession:FLURRY_ID];
    
    //这种方式后台，可以连续播放非网络请求歌曲。遇到网络请求歌曲就废，需要后台申请task
    /*
     * AudioSessionInitialize用于处理中断处理，
     * AVAudioSession主要调用setCategory和setActive方法来进行设置，
     * AVAudioSessionCategoryPlayback一般用于支持后台播放
     */
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    [session setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    NSError *activationError = nil;
    [session setActive:YES error:&activationError];
    
//    if ([UserSetting isSystemOS7]) {
    
//        UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 20)];
//        [self.window addSubview:statusView];
//        [statusView release];
//        statusView.backgroundColor = [UIColor blackColor];
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    }

    
    
    //获取token
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
    
}

/**
 *  向服务器发送token值
 */
- (void)pushToken:(NSString *) token
{
    NSString *url = [NSString stringWithFormat:@"http://apps.iyuba.com/voa/phoneToken.jsp?token=%@&appID=%@",token, [TestType iyubaApplicationID]];
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    request.delegate = self;
    [request startAsynchronous];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"token获取成功");
    
    BOOL isSuccess = [UserSetting isSuccessPushToken];
    if (!isSuccess) {
        NSString * tokenAsString = [[[deviceToken description]
                                     stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                    stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        [UserSetting setToken:tokenAsString];
        
        [self pushToken:tokenAsString];
        
//        NSLog(@"@@@@@@@@@@@@***%@", tokenAsString);
    }
    
    
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    NSLog(@"token获取失败");
}

#if 0
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //这种方式后台，可以连续播放非网络请求歌曲。遇到网络请求歌曲就废，需要后台申请task
    /*
     * AudioSessionInitialize用于处理中断处理，
     * AVAudioSession主要调用setCategory和setActive方法来进行设置，
     * AVAudioSessionCategoryPlayback一般用于支持后台播放
     */
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    [session setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    NSError *activationError = nil;
    [session setActive:YES error:&activationError];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        
        self.window.clipsToBounds =YES;
        
        self.window.frame =  CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height-20);
    }
    
    
    return YES;
}
#endif


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
    
    
    
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
//	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

/*
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //	if ([viewController isKindOfClass:[SecondViewController class]])
    //	{
    //        [leveyTabBarController hidesTabBar:NO animated:YES];
    //	}
    if (navigationController.navigationBar.tag == TAG_NAV_3) {
        if ([viewController isKindOfClass:[NewWordsViewController class]]) {
//            [UIView  beginAnimations:nil context:NULL];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//            [UIView setAnimationDuration:0.75];
//            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
//            [UIView commitAnimations];
//            
//            [UIView beginAnimations:nil context:NULL];
//            [UIView setAnimationDelay:0.375];
//            [self.navigationController popViewControllerAnimated:NO];
//            [UIView commitAnimations];
        }
    }
    
    
    if (viewController.hidesBottomBarWhenPushed)
    {
//        [_leveyTabBarController hidesTabBar:YES animated:YES];
    }
    else
    {
//        [_leveyTabBarController hidesTabBar:NO animated:YES];
    }
}
*/

- (BOOL)tabBarController:(UITabBarController *)theTabBarController shouldSelectViewController:(UIViewController *)viewController
{
    
    if (theTabBarController.selectedViewController == viewController && [viewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *v = (UINavigationController *)viewController;
        if (v.navigationBar.tag == TAG_NAV_3) {
            return NO;
        }
    }
 
    
    return YES;
    
}

- (void)appearenceTabbar:(UITabBarController *)tabbar{
    
    
    //本地化一下子
    NSString *plan = NSLocalizedString(@"TAB_PLAN", nil);
    NSString *library = NSLocalizedString(@"TAB_LIB", nil);
    NSString *favorites = NSLocalizedString(@"TAB_FAV", nil);
    NSString *more = NSLocalizedString(@"TAB_MORE", nil);
    NSArray *nameArray = nil;
    NSArray *imgNameArray = nil;
    
    NSString *tabarImgName = nil;
    NSString *barIndicator = nil;
    if ([TestType isHasTestInfo]) {
        if ([UserSetting isSystemOS7] && IS_IPAD) {
            tabarImgName = @"c-2-1-ios7-5.png";
        } else {
            tabarImgName = @"c-2-1-5.png";
        }
        barIndicator = @"barIndicator-5.png";
        
        NSString *information = NSLocalizedString(@"TAB_INFO", nil);
        
        if ([TestType isHasOpeningCourse]) {
            NSString *course = NSLocalizedString(@"TAB_COURSE", nil);
            nameArray = [NSArray arrayWithObjects:plan, library, course, information, more, nil];
            imgNameArray = [NSArray arrayWithObjects:@"tab_plan", @"tab_lib", @"tab_course", @"tab_info", @"tab_more", nil];
        } else {
            nameArray = [NSArray arrayWithObjects:plan, library, favorites, information, more, nil];
            imgNameArray = [NSArray arrayWithObjects:@"tab_plan", @"tab_lib", @"tab_fav", @"tab_info", @"tab_more", nil];
        }
        
        
    } else {
        if ([UserSetting isSystemOS7] && IS_IPAD) {
            tabarImgName = @"c-2-1-ios7.png";
        } else {
            tabarImgName = @"c-2-1.png";
        }
        barIndicator = @"barIndicator.png";
        
        if ([TestType isHasOpeningCourse]) {
            NSString *course = NSLocalizedString(@"TAB_COURSE", nil);
            nameArray = [NSArray arrayWithObjects:plan, library, favorites, course, more, nil];
            imgNameArray = [NSArray arrayWithObjects:@"tab_plan", @"tab_lib", @"tab_fav", @"tab_course", @"tab_more", nil];
        } else {
            nameArray = [NSArray arrayWithObjects:plan, library, favorites, more, nil];
            imgNameArray = [NSArray arrayWithObjects:@"tab_plan", @"tab_lib", @"tab_fav", @"tab_more", nil];
        }
    }
    
    [tabbar.tabBar setBackgroundImage:[UIImage imageNamed:tabarImgName]];
    [tabbar.tabBar setSelectionIndicatorImage:[UIImage imageNamed:barIndicator]];
    
    
    
    NSArray * controllers = tabbar.viewControllers;
    for (int i = 0; i < controllers.count; i++) {
        UIViewController * controller = [controllers objectAtIndex:i];
        controller.tabBarItem = [[[UITabBarItem alloc] initWithTitle:[nameArray objectAtIndex:i] image:nil tag:0] autorelease];
        NSString *UnselectedName = [NSString stringWithFormat:@"%@.png", [imgNameArray objectAtIndex:i]];
        NSString *SelectedName = [NSString stringWithFormat:@"%@_HL.png", [imgNameArray objectAtIndex:i]];
        
        [[controller tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:SelectedName] withFinishedUnselectedImage:[UIImage imageNamed:UnselectedName]];
        [[controller tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         [UIColor whiteColor], UITextAttributeTextColor, [UIFont fontWithName:@"Verdana-Bold" size:10], UITextAttributeFont,
                                                         nil] forState:UIControlStateNormal];
        
    }
}

+ (void)cancelLocalNotification {
    // 获得 UIApplication
//    UIApplication *app = [UIApplication sharedApplication];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

+ (void)createLocalNotification {
    
    if (![UserSetting isPushDate]) {
        return;
    }
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif) {
        
        NSArray *pushDateArray = [UserSetting pushHourAndMinAndAMPM];
        int hour = [[pushDateArray objectAtIndex:0] intValue];
        int min = [[pushDateArray objectAtIndex:1] intValue];
        NSString *amOrPm = [pushDateArray objectAtIndex:2];
        if ([amOrPm isEqualToString:@"PM"]) {
            hour += 12;
        }
        
//        NSString *dateStr = [NSString stringWithFormat:@"0001-01-01 %d:%d:00", hour, min];//传入时间
        //将传入时间转化成需要的格式
//        NSDateFormatter *format=[[NSDateFormatter alloc] init];
//        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        NSDate *fromdate=[format dateFromString:dateStr];
//        [format release];
//        NSLog(@"Local fromdate=%@",[NSDate getLocateDate:fromdate]);
//        NSLog(@"fromdate=%@",fromdate);

        
        NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
        [components setHour:hour];
        [components setMinute:min];
        
        //本地化一下子
        NSCalendar *localCalendar = [NSCalendar currentCalendar];
        
        NSDate *date = [localCalendar dateFromComponents:components];
        
        localNotif.fireDate = date;
        
        
#if COCOS2D_DEBUG
        NSLog(@"hour is %d, min is %d\n下次推送时间是%@", hour, min, localNotif.fireDate);
#endif
        
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        
        localNotif.repeatInterval = NSDayCalendarUnit;
        
        //本地化一下子
        NSString *pushStr = nil;
        switch ([UserSetting assistantID]) {
            case 0://大椰
                pushStr = NSLocalizedString(@"NOTIF_KEN", @"alertBody");
                break;
                
            case 1://小桃
                pushStr = NSLocalizedString(@"NOTIF_KATE", @"alertBody");
                break;
                
            default:
                pushStr = NSLocalizedString(@"NOTIF_NORMAL", @"alertBody");
                break;
        }
        localNotif.alertBody = pushStr;
        localNotif.alertAction = NSLocalizedString(@"STORE_ALERT_CON_OK", @"alertAction");
        
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        
        localNotif.applicationIconBadgeNumber = 1;
        
        NSDictionary *info = [NSDictionary dictionaryWithObject:@"name"forKey:@"key"];
        localNotif.userInfo = info;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
    [localNotif release];
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateActive) {
//        NSLog(@"received a local notification while running in the foreground");
    } else if (application.applicationState == UIApplicationStateInactive) {
//        NSLog(@"received a local notification while running in the background");
    }
    
//    [self handleLocalNotificaion:notification];
    
}

#if 0
- (void)handleLocalNotificaion:(UILocalNotification*)localNotification
{
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if (localNotification == nil) return;
    
    NSString* soundName = localNotification.soundName;
    if (soundName != nil) {
        [self playSoundWithName:soundName];
    }
    
}


- (void)playSoundWithName:(NSString*)soundName
{
    NSString* extension = [soundName pathExtension];
    NSRange extensionRange = [soundName rangeOfString:extension];
    NSString* fileName = [soundName substringToIndex:(extensionRange.location-1)];
    
    // Get the URL to the sound file to play
    CFURLRef soundFileURLRef  = CFBundleCopyResourceURL(CFBundleGetMainBundle(),
                                                        ( CFStringRef)(fileName),
                                                        ( CFStringRef)(extension),
                                                        NULL);
    
    SystemSoundID soundFileObject;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject);
    
    AudioServicesPlaySystemSound(soundFileObject);
}
#endif

//- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//{
//    // Override point for customization after application launch.
//    [self performSelectorOnMainThread:@selector(launchWithOptions:) withObject:launchOptions waitUntilDone:NO];
//    return YES;
//}
//                                                
//                                                
//- (void)launchWithOptions:(NSDictionary *)launchOptions {
//        UILocalNotification* localNotification = nil;
//    
//        localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
//        [self handleLocalNotificaion:localNotification];
//}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    [UserSetting setIsSuccessPushToken:NO];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [UserSetting setIsSuccessPushToken:YES];
    NSLog(@"Token上传成功");
}

@end
