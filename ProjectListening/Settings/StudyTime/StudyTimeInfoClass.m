//
//  StudyTimeInfoClass.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-21.
//
//

#import "StudyTimeInfoClass.h"

@implementation StudyTimeInfoClass

- (void)dealloc {
    
    
    self.studyTimeInfo = nil;
    self.studyTimeImg = nil;
    [super dealloc];
}

+ (StudyTimeInfoClass *)studyTimeInfoWithTime:(int)time img:(NSString *)imgName timeInfo:(NSString *)timeInfo {
    return [[[self alloc] initWithTime:time img:imgName timeInfo:timeInfo] autorelease];
}

- (id)initWithTime:(int)time img:(NSString *)imgName timeInfo:(NSString *)timeInfo {
    
    self = [super init];
    if (self) {
        self.studyTime = time;
        self.studyTimeImg = imgName;
        self.studyTimeInfo = timeInfo;
    }
    return self;
}

@end
