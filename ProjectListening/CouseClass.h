//
//  CouseClass.h
//  ToeicListeningFREE
//
//  Created by 赵子龙 on 13-12-24.
//
//

#import <Foundation/Foundation.h>

@interface CouseClass : NSObject

@property (assign)int titleId;
@property (nonatomic, retain)NSMutableArray *timeArray;
@property (nonatomic, retain)NSMutableArray *picNameArray;
@property (nonatomic, retain)NSString *audioName;
@property (assign)int index;

+ (CouseClass *)CouseClassWithTitleId:(int)titleId audioName:(NSString *)audioName packId:(int)packId;


@end
