//
//  PlanInfoClass.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-24.
//
//

#import "PlanInfoClass.h"

@implementation PlanInfoClass

+ (PlanInfoClass *)planInfoWithYMD:(int)YMD totalTime:(int)tTime totalQuesNum:(int)tQuesNum totalTitleNum:(int)tTitleNum score:(int)score totalRightNum:(int)tRightNum lastIndex:(int)lastIndex {
    return [[[self alloc] initWithYMD:YMD totalTime:tTime totalQuesNum:tQuesNum totalTitleNum:tTitleNum score:score totalRightNum:tRightNum lastIndex:lastIndex] autorelease];
}

- (id)initWithYMD:(int)YMD totalTime:(int)tTime totalQuesNum:(int)tQuesNum totalTitleNum:(int)tTitleNum score:(int)score totalRightNum:(int)tRightNum lastIndex:(int)lastIndex {
    self = [super init];
    if (self) {
        self.YMD = YMD;
        self.totalTime = tTime;
        self.totalQuesNum = tQuesNum;
        self.totalTitleNum = tTitleNum;
        self.score = score;
        self.totalRightNum  = tRightNum;
        self.lastIndex = lastIndex;
    }
    
    return self;
}

@end
