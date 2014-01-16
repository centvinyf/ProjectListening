//
//  CET4Constents.h
//  CET4Lite
//
//  Created by Seven Lee on 12-4-26.
//  Copyright (c) 2012年 iyuba. All rights reserved.
//

#ifndef CET4Lite_CET4Constents_h
#define CET4Lite_CET4Constents_h


#define kSpeakBackgroundWidth   238
#define kSpeakBackgroundHeight  65
#define kEdgeInsetsTopReal      35
#define kEdgeInsetsTop          6
#define kEdgeInsetsBottom       6
#define kEdgeInsetsLeft         29
#define kEdgeInsetsRight        6
#define kMinContentHeight       55
#define kPictureWidth           40
#define kPictureHeight          65


//数据库中表格名字,做CET6时直接更换
#define kTableNameAnswera   @"answera4"
#define kTableNameAnswerb   @"answerb4"
#define kTableNameAnswerc   @"answerc4"
#define kTableNameTexta     @"texta4"
#define kTableNameTextb     @"textb4"
#define kTableNameTextc     @"textc4"
#define kTableNameExplain   @"explain4"

#define DOCUMENTS_FOLDER [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define CACHES_FOLDER [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]


#define kNumberofKeywords 3         //keywords的个数

#define kUserDefaultKeyLastChosen @"UserLastChosen"
#define kLoggedUserKey @"LoggedUser"
#define kLoggedRealUsernameKey @"LoggedRealUsername"
#define kLoggedUserID   @"LoggedUserID"
#define kMyAppService    @"com.seven.CET4Lite"
#define kLoggedUserIsVIP @"LoggedUserIsVIP"
#define kLoggedUserVIPTime @"LoggedUserVIPTime"

#define kCurrentVersion @"CurrentVersion"
#define kVersionNo 1.6
#define kScoreTableCellReuseID @"ScoreTableCell"
#define kUsrWordCellReuseID @"UserWordCell"
#define kYearChooseCellReuseID @"YearChooseCell"

#define kMyAppleID @"523099688"
#define kMYFLURRY_KEY @"J1F3VBKT1IF2G7MUCWPD"

#define kMyAppStoreLink [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@/",kMyAppleID]
#define kMyWebLink @"http://itunes.apple.com/cn/app/ying-yu-si-ji-ting-li/id523099688?ls=0&mt=8"
#define kMyRenRenImage @"http://app.iyuba.com/ios/icons/cet4icon.png"

#endif
