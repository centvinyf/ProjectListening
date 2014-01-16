//
//  PlanInfoClass.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-24.
//
//

#import <Foundation/Foundation.h>

@interface PlanInfoClass : NSObject

@property (assign) int YMD;
@property (assign) int totalTime;
@property (assign) int totalQuesNum;
@property (assign) int totalTitleNum;
@property (assign) int score;
@property (assign) int totalRightNum;
@property (nonatomic, retain) NSMutableArray *detailArray;
@property (assign) int lastIndex;

+ (PlanInfoClass *)planInfoWithYMD:(int)YMD totalTime:(int)tTime totalQuesNum:(int)tQuesNum totalTitleNum:(int)tTitleNum score:(int)score totalRightNum:(int)tRightNum lastIndex:(int)lastIndex;

@end
