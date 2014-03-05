//
//  TestType.m
//  ProjectListening
//
//  Created by zhaozilong on 13-5-20.
//
//

#import "TestType.h"

@implementation TestType

+ (LanguageTags)systemLanguage {
    NSString *language = NSLocalizedString(@"SYSTEM_LANGUAGE", nil);
    if ([language isEqualToString:@"LanguageCN"]) {
        return LanguageCN;
    } else if ([language isEqualToString:@"LanguageEN"]) {
        return LanguageEN;
    } else if ([language isEqualToString:@"LanguageJP"]) {
        return LanguageJP;
    } else {
        NSAssert(NO, @"没有正确的系统语言信息");
    }
    return LanguageMAX;
}

+ (BOOL)isJapaneseTest {
    return (TEST_TYPE == TestTypeJLPT1 || TEST_TYPE == TestTypeJLPT2 || TEST_TYPE == TestTypeJLPT3);
}

+ (BOOL)isEnglishTest {
    return (TEST_TYPE == TestTypeToefl || TEST_TYPE == TestTypeToeic || TEST_TYPE == TestTypeTEM4 || TEST_TYPE == TestTypeCET4);
}

+ (BOOL)isChineseTest {
    return (TEST_TYPE == TestTypeHSK1 || TEST_TYPE == TestTypeHSK2 || TEST_TYPE == TestTypeHSK3 || TEST_TYPE == TestTypeHSK4 || TEST_TYPE == TestTypeHSK5 || TEST_TYPE == TestTypeHSK6);
}

+ (BOOL)isHSK {
    return (TEST_TYPE == TestTypeHSK1 || TEST_TYPE == TestTypeHSK2 || TEST_TYPE == TestTypeHSK3 || TEST_TYPE == TestTypeHSK4 || TEST_TYPE == TestTypeHSK5 || TEST_TYPE == TestTypeHSK6);
}

+ (BOOL)isHSK1 {
    return (TEST_TYPE == TestTypeHSK1);
}

+ (BOOL)isHSK2 {
    return (TEST_TYPE == TestTypeHSK2);
}

+ (BOOL)isHSK3 {
    return (TEST_TYPE == TestTypeHSK3);
}

+ (BOOL)isHSK4 {
    return (TEST_TYPE == TestTypeHSK4);
}

+ (BOOL)isHSK5 {
    return (TEST_TYPE == TestTypeHSK5);
}

+ (BOOL)isHSK6 {
    return (TEST_TYPE == TestTypeHSK6);
}

+ (BOOL)isJLPT {
    
    return (TEST_TYPE == TestTypeJLPT1 || TEST_TYPE == TestTypeJLPT2 || TEST_TYPE == TestTypeJLPT3);
}

+ (BOOL)isJLPTN1 {
    
    return (TEST_TYPE == TestTypeJLPT1);
}

+ (BOOL)isJLPTN2 {
    
    return (TEST_TYPE == TestTypeJLPT2);
}

+ (BOOL)isJLPTN3 {
    
    return (TEST_TYPE == TestTypeJLPT3);
}

+ (BOOL)isToefl {
    return (TEST_TYPE == TestTypeToefl);
}

+ (BOOL)isToeic {
    return (TEST_TYPE == TestTypeToeic);
}

+ (BOOL)isTEM4 {
    return (TEST_TYPE == TestTypeTEM4);
}

+ (BOOL)isCET4 {
    return (TEST_TYPE == TestTypeCET4);
}

+ (UIColor *)colorWithTestType {
    UIColor *color = nil;
//    CGFloat cRed = 0.0, cGreen = 0.0, cBlue = 0.0;
    TestTypeTags testTypeTag = TEST_TYPE;
    switch (testTypeTag) {
        case TestTypeJLPT1:
            color = [UIColor colorWithRed:0.102 green:0.702 blue:0.533 alpha:1.0];
            break;
            
        case TestTypeJLPT2:
            color = [UIColor colorWithRed:0.059 green:0.800 blue:0.620 alpha:1.0];
            break;
            
        case TestTypeJLPT3:
            color = [UIColor colorWithRed:0.075 green:0.831 blue:0.541 alpha:1.0];
            break;
            
        case TestTypeToefl:
            color = [UIColor colorWithRed:0.263 green:0.741 blue:0.819 alpha:1.0f];
            break;
            
        case TestTypeToeic:
            color = [UIColor colorWithRed:0.067 green:0.682 blue:0.882 alpha:1.0];
            break;
            
        case TestTypeHSK1:
        case TestTypeHSK2:
        case TestTypeHSK3:
        case TestTypeHSK4:
        case TestTypeHSK5:
        case TestTypeHSK6:
            color = [UIColor colorWithRed:0.953 green:0.592 blue:0.000 alpha:1.0];
            break;
            
        case TestTypeTEM4:
            case TestTypeCET4:
            color = [UIColor colorWithRed:0.627 green:0.306 blue:0.694 alpha:1.0];
            break;
            
        default:
            NSAssert(NO, @"没有正确的颜色可以选取");
            break;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        color = [UIColor colorWithRed:0.949 green:0.980 blue:0.961 alpha:1.0];
    }
    
    return color;
}

+ (NSString *)partNameWithPartType:(PartTypeTags)partType {
    NSString *name = nil;
    switch (partType) {
        case PartType201:
            name = NSLocalizedString(@"Section A", nil);
            break;
        case PartType202:
            name = NSLocalizedString(@"Section B", nil);
            break;
        case PartType203:
            name = NSLocalizedString(@"Section C", nil);
            break;
        case PartType301:
        case PartType302:
        case PartType303:
            name = NSLocalizedString(@"パート 1", nil);
            break;
        case PartType304:
        case PartType305:
            name = NSLocalizedString(@"パート 2", nil);
            break;
        case PartType306:
            name = NSLocalizedString(@"問題1 課題理解", nil);
            break;
        case PartType307:
            name = NSLocalizedString(@"問題2 ポイント理解", nil);
            break;
        case PartType308:
            name = NSLocalizedString(@"問題3 概要理解", nil);
            break;
        case PartType309:
            if ([TestType isJLPTN3]) {
                name = NSLocalizedString(@"問題4 発話表現", nil);
            } else {
                name = NSLocalizedString(@"問題4 応答問題", nil);
            }
            break;
        case PartType310:
            if ([TestType isJLPTN3]) {
                name = NSLocalizedString(@"問題5 即時応答", nil);
            } else {
                name = NSLocalizedString(@"問題5 総合理解", nil);
            }
            break;
        case PartType401:
            name = NSLocalizedString(@"Part1", nil);
            break;
        case PartType402:
            name = NSLocalizedString(@"Part2", nil);
            break;
        case PartType403:
            name = NSLocalizedString(@"Part3", nil);
            break;
        case PartType404:
            name = NSLocalizedString(@"Part4", nil);
            break;
            
        case PartType6061:
        case PartType6051:
        case PartType6041:
        case PartType6031:
        case PartType6021:
        case PartType6011:
            name = NSLocalizedString(@"第一部分", nil);
            break;
            
        case PartType6062:
        case PartType6052:
        case PartType6042:
        case PartType6032:
        case PartType6022:
        case PartType6012:
            name = NSLocalizedString(@"第二部分", nil);
            break;
            
        case PartType6063:
        case PartType6043:
        case PartType6033:
        case PartType6023:
        case PartType6013:
            name = NSLocalizedString(@"第三部分", nil);
            break;
            
        case PartType6034:
        case PartType6024:
        case PartType6014:
            name = NSLocalizedString(@"第四部分", nil);
            break;
            
            case PartType9401:
            name = NSLocalizedString(@"Section A", nil);
            break;
            case PartType9402:
            name = NSLocalizedString(@"Section B", nil);
            break;
            case PartType9403:
            name = NSLocalizedString(@"Section C", nil);
            break;
            
        case PartTypeMAX:
            name = NSLocalizedString(@"ALL_TEST_SET", @"全部试题");
            break;
            
        default:
            
            NSAssert(NO, @"没有正确的PartType");
            break;
    }
    
    return name;
}

+ (BOOL)isHasTestInfo {
    TestTypeTags testTypeTag = TEST_TYPE;
    BOOL isHas = NO;
    switch (testTypeTag) {
        case TestTypeJLPT1:
        case TestTypeJLPT2:
        case TestTypeJLPT3:
        case TestTypeToefl:
        case TestTypeToeic:
        case TestTypeCET4:
            isHas = YES;
            break;
            
        case TestTypeHSK1:
        case TestTypeHSK2:
        case TestTypeHSK3:
        case TestTypeHSK4:
        case TestTypeHSK5:
        case TestTypeHSK6:
        case TestTypeTEM4:
//        case TestTypeCET4:
            isHas = NO;
            break;
        default:
            NSAssert(NO, @"没有正确的考试类型");
            break;
    }
    
//    return NO;
    return isHas;
    
}

+ (NSString *)courseID {
    TestTypeTags testTypeTag = TEST_TYPE;
    NSString *courseID = @"928";
    switch (testTypeTag) {
        case TestTypeJLPT1:
            courseID = @"1";
            break;
        case TestTypeJLPT2:
            courseID = @"2";
            break;
        case TestTypeJLPT3:
            courseID = @"3";
            break;
        case TestTypeToefl:
            courseID = @"4";
            break;
        case TestTypeToeic:
            courseID = @"5";
            break;
            
        case TestTypeHSK1:
        case TestTypeHSK2:
        case TestTypeHSK3:
        case TestTypeHSK4:
        case TestTypeHSK5:
        case TestTypeHSK6:
        case TestTypeTEM4:
            case TestTypeCET4:
            courseID = @"0";
            break;
        default:
            NSAssert(NO, @"没有正确的考试类型");
            break;
    }
    
    return courseID;
}


+ (NSString *)testInfoID {
    TestTypeTags testTypeTag = TEST_TYPE;
    NSString *testInfoID = @"928";
    switch (testTypeTag) {
        case TestTypeJLPT1:
            testInfoID = @"275333";
            break;
        case TestTypeJLPT2:
            testInfoID = @"278747";
            break;
        case TestTypeJLPT3:
            testInfoID = @"295454";
            break;
        case TestTypeToefl:
            testInfoID = @"295544";
            break;
        case TestTypeToeic:
            testInfoID = @"295451";
//            testInfoID = @"242141";
        case TestTypeCET4:
            testInfoID= @"242141";
            break;
            
            
            
        case TestTypeHSK1:
        case TestTypeHSK2:
        case TestTypeHSK3:
        case TestTypeHSK4:
        case TestTypeHSK5:
        case TestTypeHSK6:
        case TestTypeTEM4:
           
            testInfoID = @"0";
            break;
        default:
            NSAssert(NO, @"没有正确的考试类型");
            break;
    }
    
    return testInfoID;
}


+ (NSString *)iyubaApplicationID {
    TestTypeTags testTypeTag = TEST_TYPE;
    NSString *appID = @"928";
    switch (testTypeTag) {
        case TestTypeJLPT1:
//            appID = @"542281757";
            appID = @"105";
            break;
        case TestTypeJLPT2:
//            appID = @"542283126";
            appID = @"106";
            break;
        case TestTypeJLPT3:
//            appID = @"542283933";
            appID = @"101";
            break;
        case TestTypeToefl:
            appID = @"139";
            break;
        case TestTypeToeic:
//            appID = @"550041392";
            appID = @"140";
            break;
            
        case TestTypeHSK1:
        case TestTypeHSK2:
        case TestTypeHSK3:
        case TestTypeHSK4:
        case TestTypeHSK5:
        case TestTypeHSK6:
        case TestTypeTEM4:
            case TestTypeCET4:
            appID = @"0";
            break;
        default:
            NSAssert(NO, @"没有正确的考试类型");
            break;
    }
    
    return appID;
}

+ (BOOL)isHasOpeningCourse {
    TestTypeTags testTypeTag = TEST_TYPE;
    switch (testTypeTag) {
        case TestTypeJLPT1:
        case TestTypeJLPT2:
        case TestTypeJLPT3:
            
            return YES;
        case TestTypeToefl:
        case TestTypeToeic:
        case TestTypeHSK1:
        case TestTypeHSK2:
        case TestTypeHSK3:
        case TestTypeHSK4:
        case TestTypeHSK5:
        case TestTypeHSK6:
        case TestTypeTEM4:
            case TestTypeCET4:
            return NO;
        default:
            NSAssert(NO, @"没有正确的考试类型");
            break;
    }
    
    return NO;
}

@end
