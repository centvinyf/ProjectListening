//
//  ZZPublicClass.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-20.
//
//

#import <Foundation/Foundation.h>
//#import "StudyViewController.h"

//#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN (IS_IPAD ? 10.0f : 10.0f)

#define CELL_ANSBTN_WIDTH (IS_IPAD ? 144 : 70)
#define CELL_ANSBTN_HEIGHT (IS_IPAD ? 67 : 30)

#define QUES_WIDTH_LIMIT (IS_IPAD ? 708.0f : 273.0f)
#define TEXT_WIDTH_LIMIT (IS_IPAD ? 745.0f : 310.0f)



@interface ZZPublicClass : NSObject

+ (void)setBackButtonOnTargetNav:(id)controller action:(SEL)action;

+ (void)setRightButtonOnTargetNav:(id)controller action:(SEL)action title:(NSString *)title;

+ (void)setTitleOnTargetNav:(id)controller title:(NSString *)title;

+ (void)copyFromBundleToDocsWithFileName:(NSString *)fileName isPlist:(BOOL)isPlist;

+ (void)createUserAudioDirectory;
+ (void)createCoursePathInUserDirectoryWithPackId:(int)packId titleId:(int)titleId;

+ (CGFloat)getTVHeightByStr:(NSString *)text constraintWidth:(CGFloat)width isBold:(BOOL)isBold;

+ (void)rateThisApp;

+ (void)pushToPurchasePage:(UIViewController *)parentVC;

@end
