//
//  PartInfoClass.h
//  ToeflListening
//
//  Created by zhaozilong on 13-6-1.
//
//

#import <Foundation/Foundation.h>

@interface PartInfoClass : NSObject

@property (nonatomic, retain) NSString *packName;
@property (assign) PartTypeTags partType;
@property (assign) int titleNumOfPart;
@property (assign) int rightNumOfPart;
@property (assign) int quesNumOfPart;

+ (PartInfoClass *)partInfoWithPackName:(NSString *)packName partType:(PartTypeTags)partType titleNum:(int)titleNum rightNum:(int)rightNum quesNum:(int)quesNum;


@end
