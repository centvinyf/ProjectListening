//
//  TitleInfoClass.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-16.
//
//

#import "TitleInfoClass.h"
#import "NSString+ZZString.h"

@implementation TitleInfoClass

- (void)dealloc {
    
//    [self.titleName release], self.titleName = nil;
//    [self.soundTime release], self.soundTime = nil;
    [super dealloc];
}

+ (TitleInfoClass *)titleInfoWithTitleName:(NSString *)name titleNum:(int)titleNum quesNum:(int)quesNum soundTime:(int)soundTime rightNum:(int)rightNum  {
    
    return [[[self alloc] initWithTitleName:name titleNum:titleNum quesNum:quesNum soundTime:soundTime rightNum:rightNum] autorelease];
}

- (id)initWithTitleName:(NSString *)name titleNum:(int)titleNum quesNum:(int)quesNum soundTime:(int)soundTime rightNum:(int)rightNum {
    
    self = [super init];
    if (self) {
        
        self.titleName = name;
        self.soundTime = [NSString hmsToSwitchAdvance:soundTime];
        self.titleNum = titleNum;
        self.quesNum = quesNum;
        self.rightNum = rightNum;
        
    }
    
    return self;
}

+ (TitleInfoClass *)titleInfoWithTestType:(int)testType partType:(int)partType titleNum:(int)titleNum packName:(NSString *)packName quesNum:(int)quesNum  soundTime:(int)soundTime vip:(BOOL)vip EnText:(BOOL)EnText CnText:(BOOL)CnText JpText:(BOOL)JpText EnEx:(BOOL)EnEx CnEx:(BOOL)CnEx JpEx:(BOOL)JpEx titleName:(NSString *)name handle:(int)handle favorite:(BOOL)favorite rightNum:(int)rightNum studyTime:(int)studyTime {
    
    return [[[self alloc] initWithTestType:testType partType:partType titleNum:titleNum packName:packName quesNum:quesNum soundTime:soundTime vip:vip EnText:EnText CnText:CnText JpText:JpText EnEx:EnEx CnEx:CnEx JpEx:JpEx titleName:name handle:handle favorite:favorite rightNum:rightNum studyTime:studyTime] autorelease];
}

- (id)initWithTestType:(int)testType partType:(int)partType titleNum:(int)titleNum packName:(NSString *)packName quesNum:(int)quesNum soundTime:(int)soundTime vip:(BOOL)vip EnText:(BOOL)EnText CnText:(BOOL)CnText JpText:(BOOL)JpText EnEx:(BOOL)EnEx CnEx:(BOOL)CnEx JpEx:(BOOL)JpEx titleName:(NSString *)name handle:(int)handle favorite:(BOOL)favorite rightNum:(int)rightNum studyTime:(int)studyTime {
    
    self = [super init];
    if (self) {
        
        self.testType = testType;
        self.partType = partType;
        self.titleNum = titleNum;
        self.packName = packName;
        self.quesNum = quesNum;
        self.sTime = soundTime;
        self.vip = vip;
        self.EnText = EnText;
        self.CnText = CnText;
        self.JpText = JpText;
        self.EnExplain = EnEx;
        self.CnExplain = CnEx;
        self.JpExplain = JpEx;
        self.titleName = name;
        self.handle = handle;
        self.favorite = favorite;
        self.rightNum = rightNum;
        self.studyTime = studyTime;
        
    }
    
    return self;
}


@end
