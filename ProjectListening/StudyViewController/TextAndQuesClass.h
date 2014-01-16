//
//  TextAndQuesClass.h
//  ProjectListening
//
//  Created by zhaozilong on 13-3-27.
//
//

#import <Foundation/Foundation.h>

@interface TextAndQuesClass : NSObject

//info
@property (assign) int testType;
@property (assign) int partType;
@property (assign) TestTypeTags testTypeTag;
@property (assign) PartTypeTags partTypeTag;
@property (assign) int titleNum;
@property (assign) int quesNum;
@property (retain, nonatomic) NSString *titleName;
@property (retain, nonatomic) NSString *imgName;
@property (assign) BOOL isFavorite;
@property (assign) BOOL isCNExplain;
@property (assign) BOOL isJPExplain;
@property (assign) BOOL isENExplain;
@property (assign) BOOL isCNText;
@property (assign) BOOL isJPText;
@property (assign) BOOL isENText;


//当前所属PackName
@property (nonatomic, retain)NSString *packName;
@property (assign) BOOL isVip;
@property (assign) BOOL isFree;

//text
@property (retain, nonatomic) NSMutableArray *senArray;
@property (retain, nonatomic) NSMutableArray *timingArray;
@property (retain, nonatomic) NSString *soundName;

//question
@property (retain, nonatomic) NSMutableArray *quesTextArray;
@property (retain, nonatomic) NSArray *quesImgNameArray;
@property (retain, nonatomic) NSMutableArray *quesSoundNameArray;

//answer
@property (retain, nonatomic) NSMutableArray *ansNumArray;
@property (retain, nonatomic) NSMutableArray *ansTextArray;
@property (retain, nonatomic) NSMutableArray *answerArray;
@property (retain, nonatomic) NSMutableArray *ansIsSingleArray;

//select
@property (retain, nonatomic) NSMutableArray *selectArray;



//favorite sentence
//@property (retain, nonatomic) NSMutableArray *favSenArray;

+ (TextAndQuesClass *)textAndQuesClassWithTestType:(TestTypeTags)testType titleNum:(int)titleNum quesNum:(int)quesNum;

@end
