//
//  UserInfo.m
//  CET4Lite
//
//  Created by Seven Lee on 12-9-25.
//  Copyright (c) 2012年 iyuba. All rights reserved.
//

#import "UserInfo.h"
#import "CET4Constents.h"
#import "Tickets.h"

@implementation UserInfo
//判断是否登陆
+ (BOOL)userLoggedIn {
    NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedUserKey];
    
    if ( username && ![username isEqualToString:@""]) {
        return YES;
    }
    else {
        return NO;
    }
}

//如果登陆，取回用户id
+ (NSString*)loggedUserID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedUserID];
}

//判断vip是否有效
+ (BOOL)isVIPValid {
    if ([UserInfo isVIP]) {
        NSDate * receiver = [NSDate date];
        NSDate * anotherDate = [NSDate dateWithTimeIntervalSince1970:[UserInfo VIPExpireTime]];
        /*
         The receiver and anotherDate are exactly equal to each other, NSOrderedSame
         The receiver is later in time than anotherDate, NSOrderedDescending
         The receiver is earlier in time than anotherDate, NSOrderedAscending.
         */
        if ([receiver compare:anotherDate] != NSOrderedDescending) {
            return YES;
        }
        else
            return NO;
    }
    else{
        return NO;
    }
}

/*******暂时对我私有方法********/
+(BOOL)isVIP {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kLoggedUserIsVIP];
}

+(double)VIPExpireTime {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kLoggedUserVIPTime];
}

+ (NSString *)loggedRealUserName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedRealUsernameKey];
}

+(void)setLoggedRealUserName:(NSString *)name {
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:kLoggedRealUsernameKey];
}

+(NSString*)loggedUserName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedUserKey];
}

+(void)setLoggedUserName:(NSString *)name {
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:kLoggedUserKey];
}
+(void)setLoggedUserID:(NSString *)_id {
    [[NSUserDefaults standardUserDefaults] setObject:_id forKey:kLoggedUserID];
}
+(void)logOut {
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kLoggedUserID];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kLoggedUserKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kLoggedRealUsernameKey];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoggedUserIsVIP];
    [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:kLoggedUserVIPTime];
    
    //清除相应优惠券信息
    [Tickets clearTicketInfomation];
    
    
}
+(void)setIsVIP:(BOOL)vip {
    [[NSUserDefaults standardUserDefaults] setBool:vip forKey:kLoggedUserIsVIP ];
}
+ (void)setVIPExpireTime:(double)time {
    [[NSUserDefaults standardUserDefaults] setDouble:time forKey:kLoggedUserVIPTime];
}
@end
