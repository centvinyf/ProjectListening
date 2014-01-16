//
//  ZZWord.m
//  grabWordTest
//
//  Created by zhaozilong on 12-8-12.
//  Copyright (c) 2012年 zhaozilong. All rights reserved.
//

#import "ZZWord.h"

@implementation ZZWord

@synthesize xBegin      = _xBegin;
@synthesize xEnd        = _xEnd;
@synthesize y           = _y;
@synthesize width       = _width;
@synthesize height      = _height;
@synthesize word        = _word;

- (id)initWithWord:(NSString *)receivedWord xBegin:(CGFloat)receivedXBegin xEnd:(CGFloat)receivedXEnd y:(CGFloat)receivedY width:(CGFloat)receivedWidth height:(CGFloat)receivedHeight {
    
    self = [super init];
    
    if (self) {
        _word = receivedWord;
        
        _xBegin = receivedXBegin;
        _xEnd = receivedXEnd;
        
        _y = receivedY;
        
        _width = receivedWidth;
        _height = receivedHeight;
    }
    
    return self;
    
}

@end
