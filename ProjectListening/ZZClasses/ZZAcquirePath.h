//
//  ZZAcquirePath.h
//  ProjectListening
//
//  Created by zhaozilong on 13-3-9.
//
//

#import <Foundation/Foundation.h>

@interface ZZAcquirePath : NSObject

+ (NSString *)getBundleDirectoryWithFileName:(NSString *)fileName;
+ (NSString *)getDocDirectoryWithFileName:(NSString *)fileName;

+ (NSString *)getAudioDocDirectoryWithFileName:(NSString *)fileName;
+ (NSString *)getCourseDocDirectoryWithPackId:(int)pacId titleId:(int)titleId;

+ (NSString *)getPlistUserAdviseFromDocuments;
+ (NSString *)getPlistProgressFromDocuments;

+ (NSString *)getPlistStudyTimeFromBundle;
+ (NSString *)getPlistAssistantFromBundle;
+ (NSString *)getPlistProductsFromBundle;

+ (NSString *)getDBTextAnswerExplainFromBundle;
+ (NSString *)getDBAssistantFromBundle;
+ (NSString *)getDBWORDSFromBundle;

+ (NSString *)getDBZZAIdbFromDocuments;
+ (NSString *)getDBZZAIdbFromBundle;

+ (NSString *)getDBClassFromDocuments;

@end
