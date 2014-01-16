//
//  ZZConfig.h
//  ProjectListening
//
//  Created by zhaozilong on 13-3-6.
//
//

#ifndef ProjectListening_ZZConfig_h
#define ProjectListening_ZZConfig_h

//判断设备是IPHONE还是IPAD
#define IS_IPAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define IS_IPHONE_568H [[UIScreen mainScreen] bounds].size.height == 568.000000

//Separated
#define SEPARATE_SYMBOL @"++"

//bool
#define ASSISTANT_IS_FIRST_TIME_ARRANGEMENT @"is_first_time_arrangement"

//data
#define ASSISTANT_MOST_LATE_TIME @"most_late_time"
#define ASSISTANT_MOST_EARLY_TIME @"most_early_time"
#define ASSISTANT_LAST_NOW_INTERVAL_DAYS @"last_now_interval_days"
//#define ASSISTANT_PURCHASE_NUM @"purchase_num"
#define ASSISTANT_LAST_OPEN_DATE @"last_open_date"
#define ASSISTANT_FIRST_OPEN_DATE @"first_open_date"

//后添加的
#define DB_NAME_ASSISTANT @"Assistant.sqlite"
#define PLIST_NAME_PROGRESS @"Progress.plist"
#define PLIST_NAME_PRODUCTS @"Products.plist"
#define PLIST_NAME_USERADVISE @"UserAdvise.plist"
#define PLIST_NAME_TEST_INFO @"TestInfo.plist"
#define PLIST_NAME_ASSISTANT @"Assistant.plist"
#define PLIST_NAME_STUDYTIME @"StudyTime.plist"

#define PLIST_NAME_CLASS_INFO @"ClassInfo.plist"
#define DB_NAME_CLASS @"Class.sqlite"

#define IOS_NEWER_OR_EQUAL_TO_7 ( [ [ [ UIDevice currentDevice ] systemVersion ] floatValue ] >= 7.0 )

#endif
