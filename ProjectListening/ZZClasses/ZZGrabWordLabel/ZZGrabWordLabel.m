//
//  ZZGrabWordLabel.m
//  grabWordTest
//
//  Created by zhaozilong on 12-8-12.
//  Copyright (c) 2012年 zhaozilong. All rights reserved.
//

#import "ZZGrabWordLabel.h"

#define SPACE @" "

@implementation ZZGrabWordLabel

@synthesize _string;
@synthesize _ifont;
@synthesize _wordClassMutArray;
@synthesize _wordMutArray;
@synthesize _widthOfLabel;
@synthesize _numOfWords;

#pragma mark --------start&over----------

- (void)dealloc {
    
    [_wordClassMutArray release], _wordClassMutArray = nil;
    [_wordMutArray release], _wordMutArray = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame string:(NSString *)receivedString font:(UIFont *)receivedFont
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _string = receivedString;
        _ifont = receivedFont;
        
        _wordClassMutArray = [[NSMutableArray alloc] init];
        
        //单词分开
        NSArray *strArray = [_string componentsSeparatedByString:SPACE];
        _wordMutArray = [[NSMutableArray alloc] initWithArray:strArray];
        
        //单词的数量
        _numOfWords = [_wordMutArray count];
        
        //Label相应触摸事件
        [self setUserInteractionEnabled:YES];
        [self setLineBreakMode:UILineBreakModeWordWrap];
        _widthOfLabel = self.frame.size.width;
        
        //赋值font， string
        [self setFont:_ifont];
        [self setText:_string];
        
        //生成单词数组
        [self findTheWordsWithString:_string];

    }
    return self;
}

#pragma mark -------set words----------
- (int)getLinesWithString:(NSString *)string {
    
    //空格的宽度
    CGFloat spaceWidth = [SPACE sizeWithFont:_ifont].width;
    
    NSString *word = nil;
    CGSize wordSize = {0, 0};
    CGFloat xBegin = 0;
    CGFloat xEnd = 0;
    CGFloat width = 0;
    
    int column = 0;
    for (int i = 0; i < _numOfWords; i++) {
        
        word = [_wordMutArray objectAtIndex:i];
        wordSize = [word sizeWithFont:_ifont];
        width = wordSize.width;
        
        xEnd = xBegin + width;
//        NSLog(@"%@的长度是%f,begin is %f, end is %f", word, width, xBegin, xEnd);
        
        //如果这个单词的最后一个单词的x坐标大于label的长度，则代表这个单词是下一行的第一个单词
        if (xEnd > _widthOfLabel) {
//            NSLog(@"*****出界的单词是%@", word);
            column++;//行数加1
            xBegin = 0;//单词的横坐标归零
            xEnd = width;//xEnd也需要从新计算
            
        }
        
        //下一个单词的首字母位置
        xBegin = xBegin + width + spaceWidth;
        
    }
    
    return column + 1;
    
}


- (void)findTheWordsWithString:(NSString *)string {
    
    //计算string的长度和高度
    CGSize stringSize = [string sizeWithFont:_ifont];
    
    //本段话的行数
    int lines = [self getLinesWithString:string];
    [self setNumberOfLines:lines];
    
    NSString *wordString = nil;
    CGSize wordSize = {0, 0};
    CGFloat xBegin = 0;
    CGFloat xEnd = 0;
    CGFloat width = 0;
    CGFloat height = stringSize.height;
    //初始纵坐标
    CGFloat y = (self.frame.size.height - lines * stringSize.height) / 2;
    
    CGFloat spaceWidth = [SPACE sizeWithFont:_ifont].width;
    
    ZZWord *tempWord = nil;
    for (int i = 0; i < _numOfWords; i++) {
        
        wordString = [_wordMutArray objectAtIndex:i];
        wordSize = [wordString sizeWithFont:_ifont];
        width = wordSize.width;
        xEnd = xBegin + width;
        
        //如果这个单词的最后一个单词的x坐标大于label的长度，则代表这个单词是下一行的第一个单词
        /*********大于还是大于等于？？？？*********************/
        if (xEnd > _widthOfLabel) {
            xBegin = 0;//单词的横坐标归零
            xEnd = width;//xEnd也需要从新计算
            
            //获取下一行的纵坐标
            y = y + stringSize.height;
        }
        
        //初始化Word
        tempWord = [[ZZWord alloc] initWithWord:wordString xBegin:xBegin xEnd:xEnd y:y width:width height:height];
        
        //word加入单词数组
        [_wordClassMutArray addObject:tempWord];
        [tempWord release];
        
        //下一个单词的首字母位置
        xBegin = xBegin + width + spaceWidth;
        
    }

    
}

#pragma mark -------grab words-----------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    [self grabTheWordWithRect:touchPoint];
}


- (void)grabTheWordWithRect:(CGPoint)point {
    
    NSString *wordString = nil;
    CGFloat xBegin = 0;
    CGFloat xEnd = 0;
    CGFloat y = 0;
    CGFloat yEnd = 0;
    
    
    
    for (int i = 0; i < _numOfWords; i++) {
        
        //招到对应的word类
        ZZWord *word = [_wordClassMutArray objectAtIndex:i];
        
        //单词的属性
        xBegin = word.xBegin;
        xEnd = word.xEnd;
        y = word.y;
        wordString = word.word;
        yEnd = y + word.height;
        
        //找到单词
        if (point.y > y && point.y < yEnd) {
            if (point.x > xBegin && point.x < xEnd) {
                NSLog(@"%@, xBegin = %f, xEnd = %f, y = %f", wordString, xBegin, xEnd, y);
                break;
            }
        }
        
    }
    
}

- (void)putTheViewToTheWord:(CGRect)rect {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -------get word's attribute----------
+ (int)getLinesWithString:(NSString *)string font:(UIFont *)iFont widthLimit:(CGFloat)widthLimit {
    
    //单词分开
    NSArray *strArray = [string componentsSeparatedByString:SPACE];
    NSMutableArray *wordMutArray = [[NSMutableArray alloc] initWithArray:strArray];
    
    //单词的数量
    int numOfWords = [wordMutArray count];
    
    //空格的宽度
    CGFloat spaceWidth = [SPACE sizeWithFont:iFont].width;
    
    NSString *word = nil;
    CGSize wordSize = {0, 0};
    CGFloat xBegin = 0;
    CGFloat xEnd = 0;
    CGFloat width = 0;
    
    int column = 0;
    for (int i = 0; i < numOfWords; i++) {
        
        word = [wordMutArray objectAtIndex:i];
        wordSize = [word sizeWithFont:iFont];
        width = wordSize.width;
        
        xEnd = xBegin + width;
        //        NSLog(@"%@的长度是%f,begin is %f, end is %f", word, width, xBegin, xEnd);
        
        //如果这个单词的最后一个单词的x坐标大于label的长度，则代表这个单词是下一行的第一个单词
        if (xEnd > widthLimit) {
            //            NSLog(@"*****出界的单词是%@", word);
            column++;//行数加1
            xBegin = 0;//单词的横坐标归零
            xEnd = width;//xEnd也需要从新计算
            
        }
        
        //下一个单词的首字母位置
        xBegin = xBegin + width + spaceWidth;
        
    }
    
    return column + 1;
    
}

+ (CGFloat)getHeightOfFont:(UIFont *)iFont withString:(NSString *)string {
    
    return [string sizeWithFont:iFont].height;
}


@end
