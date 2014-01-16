//
//  TestType.h
//  ProjectListening
//
//  Created by zhaozilong on 13-5-20.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    DictTypeEN_CN = 10,
    DictTypeEN_JP,
    DictTypeEN_EN,
    DictTypeJP_CN,
    DictTypeJP_EN,
    DictTypeJP_TCN,
    DictTypeJP_KR,
    DictTypeCN_EN,
    DictTypeCN_JP,
    DictTypeCN_KR,
    DictTypeMAX,
}DictTypeTags;

typedef enum {
    LanguageCN,
    LanguageEN,
    LanguageJP,
    LanguageMAX,
}LanguageTags;

typedef enum {
    TestTypeToeic = 101,
    TestTypeToefl = 102,
    TestTypeTEM4 = 103,
    TestTypeJLPT1 = 111,
    TestTypeJLPT2 = 112,
    TestTypeJLPT3 = 113,
    TestTypeHSK1 = 601,
    TestTypeHSK2 = 602,
    TestTypeHSK3 = 603,
    TestTypeHSK4 = 604,
    TestTypeHSK5 = 605,
    TestTypeHSK6 = 606,
    TestTypeCET4 = 941,
    
//    TestTypeTEM8 = 601,
    TestTypeMAX,
}TestTypeTags;

typedef enum {
    PartType201 = 201,
    PartType202,
    PartType203,
    PartType301 = 301,
    PartType302,
    PartType303,
    PartType304,
    PartType305,//有图文字题 暂时空
    PartType306,//问题1
    PartType307,//问题2
    PartType308,//问题3
    PartType309,//问题4
    PartType310,//问题5
    PartType401 = 401,
    PartType402,
    PartType403,
    PartType404,
    PartType6011 = 6011,                        //图，判断
    PartType6012,                   //图，选择
    PartType6013,                   //图，选择
    PartType6014,       //问题，选择
    PartType6021 = 6021,                        //图，判断
    PartType6022,                   //图，选择
    PartType6023,       //问题，选择
    PartType6024,       //问题，选择
    PartType6031 = 6031,            //图，选择
    PartType6032,           //问题，判断
    PartType6033,       //问题，选择
    PartType6034,       //问题，选择
    PartType6041 = 6041,    //问题，判断
    PartType6042,       //问题，选择
    PartType6043,       //问题，选择
    PartType6051 = 6051,//问题，选择
    PartType6052,       //问题，选择
    PartType6061 = 6061,//问题，选择
    PartType6062,       //问题，选择
    PartType6063,       //问题，选择
    PartType9401 = 9401,//四级partA
    PartTypeMAX,
}PartTypeTags;

//UPDATE Text SET PartType = 6061 WHERE PartType = 601;
//UPDATE Answer SET PartType = 6061 WHERE PartType = 601;
//UPDATE Text SET PartType = 6062 WHERE PartType = 602;
//UPDATE Answer SET PartType = 6062 WHERE PartType = 602;
//UPDATE Text SET PartType = 6063 WHERE PartType = 603;
//UPDATE Answer SET PartType = 6063 WHERE PartType = 603;
//UPDATE TitleInfo SET PartType = 6061 WHERE PartType = 601;
//UPDATE TitleInfo SET PartType = 6062 WHERE PartType = 602;
//UPDATE TitleInfo SET PartType = 6063 WHERE PartType = 603;

@interface TestType : NSObject

+ (BOOL)isJapaneseTest;
+ (BOOL)isEnglishTest;
+ (BOOL)isChineseTest;

+ (BOOL)isJLPT;
+ (BOOL)isHSK;

+ (BOOL)isTEM4;
+ (BOOL)isToefl;
+ (BOOL)isToeic;
+ (BOOL)isHSK1;
+ (BOOL)isHSK2;
+ (BOOL)isHSK3;
+ (BOOL)isHSK4;
+ (BOOL)isHSK5;
+ (BOOL)isHSK6;
+ (BOOL)isJLPTN1;
+ (BOOL)isJLPTN2;
+ (BOOL)isJLPTN3;

+ (UIColor *)colorWithTestType;
+ (NSString *)partNameWithPartType:(PartTypeTags)partType;

+ (LanguageTags)systemLanguage;

+ (BOOL)isHasTestInfo;
+ (NSString *)testInfoID;

+ (NSString *)courseID;

+ (BOOL)isHasOpeningCourse;

+ (NSString *)iyubaApplicationID;

@end
