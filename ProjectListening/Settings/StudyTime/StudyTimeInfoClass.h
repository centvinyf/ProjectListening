//
//  StudyTimeInfoClass.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-21.
//
//

#import <Foundation/Foundation.h>

@interface StudyTimeInfoClass : NSObject


@property (assign)int studyTime;
@property (nonatomic, retain)NSString *studyTimeImg;
@property (nonatomic, retain)NSString *studyTimeInfo;

+ (StudyTimeInfoClass *)studyTimeInfoWithTime:(int)time img:(NSString *)imgName timeInfo:(NSString *)timeInfo;

@end
