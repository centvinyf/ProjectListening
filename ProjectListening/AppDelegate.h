//
//  AppDelegate.h
//  ProjectListening
//
//  Created by zhaozilong on 13-3-4.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "LeveyTabBar.h"
//#import "LeveyTabBarController.h"
#import "ASIHTTPRequest.h"


@class RootViewController;
//@class LeveyTabBarController;

@interface AppDelegate : NSObject <UIApplicationDelegate, /*UINavigationControllerDelegate, */UITabBarControllerDelegate, ASIHTTPRequestDelegate> {
	UIWindow			*window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

+ (void)createLocalNotification;
+ (void)cancelLocalNotification;

@end
