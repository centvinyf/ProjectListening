//
//  TitleInfoClass.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-16.
//
//

#import <Foundation/Foundation.h>

@interface TitleInfoClass : NSObject

@property (nonatomic, retain) NSString *titleName;
@property (nonatomic, retain) NSString *soundTime;
@property (assign) int titleNum;
@property (assign) int quesNum;
@property (assign) int rightNum;

+ (TitleInfoClass *)titleInfoWithTitleName:(NSString *)name titleNum:(int)titleNum quesNum:(int)quesNum soundTime:(int)soundTime rightNum:(int)rightNum;

//数据库
@property int testType;
@property int partType;
@property (nonatomic, retain) NSString *packName;
@property int sTime;
@property BOOL vip;
@property BOOL EnText;
@property BOOL CnText;
@property BOOL JpText;
@property BOOL EnExplain;
@property BOOL CnExplain;
@property BOOL JpExplain;
@property int handle;
@property BOOL favorite;
@property int studyTime;

+ (TitleInfoClass *)titleInfoWithTestType:(int)testType partType:(int)partType titleNum:(int)titleNum packName:(NSString *)packName quesNum:(int)quesNum  soundTime:(int)soundTime vip:(BOOL)vip EnText:(BOOL)EnText CnText:(BOOL)CnText JpText:(BOOL)JpText EnEx:(BOOL)EnEx CnEx:(BOOL)CnEx JpEx:(BOOL)JpEx titleName:(NSString *)name handle:(int)handle favorite:(BOOL)favorite rightNum:(int)rightNum studyTime:(int)studyTime;

@end
