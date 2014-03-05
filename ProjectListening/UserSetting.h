//
//  UserSetting.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-20.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    TextShowStyleNone,
    TextShowStyleAll,
    TextShowStylePart,
}TextShowStyleTags;

@interface UserSetting : NSObject

+ (BOOL)isUserEmail;
+ (void)setUserEmail:(NSString *)email;
+ (NSString *)userEmail;

+ (void)setUserAdviseMsgArray:(NSMutableArray *)messageArray;
+ (void)writeUserAdviseToPlist:(NSMutableArray *)messageArray;

//考试资讯的读取和录入
+ (NSMutableArray *)testInfoArray;
+ (void)writeTestInfoToPlist:(NSMutableArray *)messageArray;

//移动课堂信息的读取和录入
+ (NSMutableArray *)courseInfoArray;
+ (void)writeCourseInfoToPlist:(NSMutableArray *)messageArray;

+ (BOOL)isThisVersionFirstTimeRun;
+ (BOOL)isFirstTimeInstallApplication;

+ (BOOL)isStartOfEverythingNew;
+ (void)setStartOfEverythingNewFalse;

+ (void)removeAssistantTextureExcept:(int)assID;
+ (void)setAssistantID:(int)num;
+ (int)assistantID;
+ (void)setStudyTime:(int)seconds;
+ (int)studyTime;
+ (int)studyTimeByNum:(int)diffcultyNum;
+ (void)setIsNeedPurchase:(BOOL)isNeed;
+ (BOOL)isNeedPurchase;
+ (void)setIsNeedRate:(BOOL)isRate;
+ (BOOL)isNeedRate;
+ (void)setIsNeedFeedback:(BOOL)isFeedBack;
+ (BOOL)isNeedFeedback;
+ (void)setOpenTimes:(int)times;
+ (int)OpenTimes;
+ (void)setIsTodayFirstTimeOpen:(BOOL)isFirst;
+ (BOOL)isTodayFirstTimeOpen;

+ (void)setAssInfoArray:(NSMutableArray *)AICArray;
+ (void)setStudyTimeInfoArray:(NSMutableArray *)STICArray;
+ (void)setPurchaseNum:(int)num;
+ (int)purchaseNum;
+ (int)totalPurchaseNum;
+ (BOOL)isPurchasedVIPMode;
+ (void)setPurchaseVIPMode:(BOOL)isVipMode;

+ (DictTypeTags)dictType;
+ (NSString *)dictTypeName;
+ (void)setDictType:(DictTypeTags)dictType;
+ (DictTypeTags)dictTypeWithDictName:(NSString *)dictName;
+ (UIColor *)syncTextColor;
+ (int)textFontSizeFake;
+ (int)textFontSizeReal;
+ (TextShowStyleTags)textShowStyle;
+ (void)setScreenKeepLight:(BOOL)isLight;
+ (BOOL)screenKeepLightStatus;
+ (void)setTextKeepSync:(BOOL)isSync;
+ (BOOL)textKeepSync;
+ (BOOL)isSwipeGestureEnabled;
+ (void)setSwipeGestureEnabled:(BOOL)isEnabled;
+ (BOOL)isBackgroundPlayEnabled;
+ (void)setBackgroundPlayEnabled:(BOOL)isEnabled;

//+ (NSString *)stringForPushDate:(NSDate *)date;
//+ (NSDate *)pushDate;
//+ (void)setPushDate:(NSDate *)date;
+ (NSArray *)pushHourAndMinAndAMPM;
+ (void)setPushHour:(NSString *)hour min:(NSString *)min amOrPm:(NSString *)amOrpm;
+ (BOOL)isPushDate;
+ (void)setIsPushDate:(BOOL)isPushDate;

//+ (int)hourForPushDate:(NSArray *)dateArray;
//+ (NSString *)minuteForPushDate:(NSArray *)dateArray;

//+ (NSString *)platform;
+ (NSString *)platformString;
+ (NSString *)systemVersion;
+ (NSString *)applicationVersion;
+ (BOOL)isSystemOS7;

+ (NSString *)token;
+ (void)setToken:(NSString *)token;

+ (BOOL)isSuccessPushToken;
+ (void)setIsSuccessPushToken:(BOOL)isSuccess;

@end
