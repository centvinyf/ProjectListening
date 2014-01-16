//
//  Sentence.h
//  CET4Lite
//
//  Created by Seven Lee on 12-9-14.
//  Copyright (c) 2012年 iyuba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Sentence : NSObject{
    NSString * _english;
    NSString * _chinese;
}
@property (nonatomic, strong) NSString * english;
@property (nonatomic, strong) NSString * chinese;
- (id)initWithEnglish:(NSString *)en Chinese:(NSString *)ch;
@end
