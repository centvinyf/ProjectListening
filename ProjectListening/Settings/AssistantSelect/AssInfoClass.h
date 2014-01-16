//
//  AssInfoClass.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-21.
//
//

#import <Foundation/Foundation.h>

@interface AssInfoClass : NSObject

@property (assign) int assID;
@property (nonatomic, retain) NSString *assName;
@property (nonatomic, retain) NSString *assInfo;
@property (nonatomic, retain) NSString *assImgName;

+ (AssInfoClass *)assInfoWithID:(int)aID name:(NSString *)aName info:(NSString *)aInfo imgName:(NSString *)imgName;

@end
