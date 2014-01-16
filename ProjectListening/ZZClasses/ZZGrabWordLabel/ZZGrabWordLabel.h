//
//  ZZGrabWordLabel.h
//  grabWordTest
//
//  Created by zhaozilong on 12-8-12.
//  Copyright (c) 2012年 zhaozilong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZWord.h"

//struct ZZWord {
//    CGFloat xBegin;
//    CGFloat yBegin;
//    
//    CGFloat xEnd;
//    CGFloat yEnd;
//    
//    CGFloat width;
//    CGFloat height;
//};

@interface ZZGrabWordLabel : UILabel {
    @private
    NSString *_string;
    UIFont *_ifont;
    NSMutableArray *_wordClassMutArray;
    NSMutableArray *_wordMutArray;
    CGFloat _widthOfLabel;
    int _numOfWords;
}

@property (nonatomic, retain) NSString *_string;
@property (nonatomic, retain) UIFont *_ifont;
@property (nonatomic, retain) NSMutableArray *_wordClassMutArray;
@property (nonatomic, retain) NSMutableArray *_wordMutArray;
@property CGFloat _widthOfLabel;
@property int _numOfWords;

- (id)initWithFrame:(CGRect)frame string:(NSString *)receivedString font:(UIFont *)receivedFont;

//- (int)getLinesWithString:(NSString *)string;

+ (int)getLinesWithString:(NSString *)string font:(UIFont *)iFont widthLimit:(CGFloat)widthLimit;
+ (CGFloat)getHeightOfFont:(UIFont *)iFont withString:(NSString *)string;

@end
