//
//  ZZAcquirePath.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-9.
//
//

#import "ZZAcquirePath.h"

@implementation ZZAcquirePath

//获取bundle目录
+ (NSString *)getBundleDirectoryWithFileName:(NSString *)fileName {
    return [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
}

+ (NSString *)getDocDirectoryWithFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userDbDir = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
    return userDbDir;
}

//音频目录
+ (NSString *)getAudioDocDirectoryWithFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userDbDir = [NSString stringWithFormat:@"%@/audio/%@", documentsDirectory, fileName];
    return userDbDir;
}

//课程目录
+ (NSString *)getCourseDocDirectoryWithPackId:(int)pacId titleId:(int)titleId {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userDbDir = [NSString stringWithFormat:@"%@/course/%d/%d", documentsDirectory, pacId, titleId];
    return userDbDir;
}

+ (NSString *)getPlistStudyTimeFromBundle {
    return [ZZAcquirePath getBundleDirectoryWithFileName:PLIST_NAME_STUDYTIME];
}

+ (NSString *)getPlistAssistantFromBundle {
    return [ZZAcquirePath getBundleDirectoryWithFileName:PLIST_NAME_ASSISTANT];
}

+ (NSString *)getPlistUserAdviseFromDocuments {
    return [ZZAcquirePath getDocDirectoryWithFileName:PLIST_NAME_USERADVISE];
}

+ (NSString *)getPlistProductsFromBundle {
    return [ZZAcquirePath getBundleDirectoryWithFileName:PLIST_NAME_PRODUCTS];
}

+ (NSString *)getPlistProgressFromDocuments {
    return [ZZAcquirePath getDocDirectoryWithFileName:PLIST_NAME_PROGRESS];
}

+ (NSString *)getDBTextAnswerExplainFromBundle {
    return [ZZAcquirePath getBundleDirectoryWithFileName:DB_NAME_TEXT_ANSWER];
}

+ (NSString *)getDBAssistantFromBundle {
    return [ZZAcquirePath getBundleDirectoryWithFileName:DB_NAME_ASSISTANT];
}

+ (NSString *)getDBWORDSFromBundle {
    return [ZZAcquirePath getBundleDirectoryWithFileName:DB_NAME_WORDS];
}

+ (NSString *)getDBZZAIdbFromDocuments {
    return [ZZAcquirePath getDocDirectoryWithFileName:DB_NAME_ZZAIDB];
}

+ (NSString *)getDBZZAIdbFromBundle {
    return [ZZAcquirePath getBundleDirectoryWithFileName:DB_NAME_ZZAIDB];
}

+ (NSString *)getDBClassFromDocuments {
    return [ZZAcquirePath getDocDirectoryWithFileName:@"Class.sqlite"];
}

@end
