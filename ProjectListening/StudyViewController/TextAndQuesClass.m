//
//  TextAndQuesClass.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-27.
//
//

#import "TextAndQuesClass.h"

@implementation TextAndQuesClass

+ (TextAndQuesClass *)textAndQuesClassWithTestType:(TestTypeTags)testType titleNum:(int)titleNum quesNum:(int)quesNum {
    return [[[self alloc] initWithTestType:testType titleNum:titleNum quesNum:quesNum] autorelease];
}

- (id)initWithTestType:(TestTypeTags)testType titleNum:(int)titleNum quesNum:(int)quesNum {
    self = [super init];
    if (self) {
        self.testTypeTag = testType;
        _testType = testType;
        _titleNum = titleNum;
        _quesNum = quesNum;
//        _soundName = soundName;
//        _imgName = imgName;
        
        _senArray = [[NSMutableArray alloc] init];
        _timingArray = [[NSMutableArray alloc] init];
        
        _quesTextArray = [[NSMutableArray alloc] init];
//        _quesImgNameArray = [[NSArray alloc] init];
        
        //answer
        _ansNumArray = [[NSMutableArray alloc] init];
        _ansTextArray = [[NSMutableArray alloc] init];
        _answerArray = [[NSMutableArray alloc] init];
        _quesSoundNameArray = [[NSMutableArray alloc] init];
//        _ansIsSingleArray = [[NSMutableArray alloc] init];
        
        //select
        _selectArray = [[NSMutableArray alloc] init];
        
        //favorite sentence
//        _favSenArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}



- (void)dealloc {
#if COCOS2D_DEBUG    
    NSLog(@"TAQ dealloc");
#endif
    [_senArray release];
    [_timingArray release], _timingArray = nil;
//    [_quesImgNameArray release];
    self.quesImgNameArray = nil;
    [_quesTextArray release];
    [_ansNumArray release];
    [_ansIsSingleArray release];
    [_quesSoundNameArray release];
    [_ansTextArray release];
//    [_ansIsSingleArray release];
    [_selectArray release];
//    [_favSenArray release];
    
    [super dealloc];
}




@end
