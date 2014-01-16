//
//  ZZWord.h
//  grabWordTest
//
//  Created by zhaozilong on 12-8-12.
//  Copyright (c) 2012年 zhaozilong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZWord : NSObject

//单词第一个字母的坐标
@property CGFloat xBegin;

//单词的最后一个字母的坐标
@property CGFloat xEnd;

@property CGFloat y;

//单词的长度和高度（像素）
@property CGFloat width;
@property CGFloat height;

@property (nonatomic, retain) NSString *word;

- (id)initWithWord:(NSString *)receivedWord xBegin:(CGFloat)receivedXBegin xEnd:(CGFloat)receivedXEnd y:(CGFloat)receivedY width:(CGFloat)receivedWidth height:(CGFloat)receivedHeight;

@end
