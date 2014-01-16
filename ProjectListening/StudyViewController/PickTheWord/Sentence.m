//
//  Sentence.m
//  CET4Lite
//
//  Created by Seven Lee on 12-9-14.
//  Copyright (c) 2012年 iyuba. All rights reserved.
//

#import "Sentence.h"

@implementation Sentence
@synthesize english = _english;
@synthesize chinese = _chinese;
- (id)initWithEnglish:(NSString *)en Chinese:(NSString *)ch{
    if (self = [super init]) {
        self.english = en;
        self.chinese = ch ;
#if COCOS2D_DEBUG
        NSLog(@"sentence.ch:%@",self.chinese);
#endif
    }
    return self;
}
- (NSString *)description{
    return [NSString stringWithFormat:@"English:%@,  Chinese:%@",self.english,self.chinese];
}
@end
