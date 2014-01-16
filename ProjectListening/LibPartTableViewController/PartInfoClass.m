//
//  PartInfoClass.m
//  ToeflListening
//
//  Created by zhaozilong on 13-6-1.
//
//

#import "PartInfoClass.h"

@implementation PartInfoClass

+ (PartInfoClass *)partInfoWithPackName:(NSString *)packName partType:(PartTypeTags)partType titleNum:(int)titleNum rightNum:(int)rightNum quesNum:(int)quesNum {
    
    return [[[self alloc] initWithPackName:packName partType:partType titleNum:titleNum rightNum:rightNum quesNum:quesNum] autorelease];
}

- (id)initWithPackName:(NSString *)packName partType:(PartTypeTags)partType titleNum:(int)titleNum rightNum:(int)rightNum quesNum:(int)quesNum {
    
    self = [super init];
    if (self) {
        
        self.packName = packName;
        self.partType = partType;
        self.titleNumOfPart = titleNum;
        self.rightNumOfPart = rightNum;
        self.quesNumOfPart = quesNum;
        
    }
    
    return self;
}

@end
