//
//  UserInfo.h
//  CET4Lite
//
//  Created by Seven Lee on 12-9-25.
//  Copyright (c) 2012年 iyuba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

+(BOOL)userLoggedIn;
+(NSString*)loggedUserName;
+(NSString *)loggedRealUserName;
+(NSString*)loggedUserID;
+(void)setLoggedUserName:(NSString *)name;
+(void)setLoggedRealUserName:(NSString *)name;
+(void)setLoggedUserID:(NSString *)_id;
+(void)logOut;
+(void)setIsVIP:(BOOL)vip;
+(void)setVIPExpireTime:(double)time;
+(BOOL)isVIP;
+(double)VIPExpireTime;
+ (BOOL)isVIPValid;
@end
