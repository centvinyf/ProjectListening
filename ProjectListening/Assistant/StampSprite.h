//
//  StampSprite.h
//  ProjectListening
//
//  Created by zhaozilong on 13-3-19.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
//#import "ZZConfig.h"
#import "NSString+ZZString.h"

@interface StampSprite : CCSprite {
    
}

+ (StampSprite *)spriteWithParentNode:(CCNode *)parentNode position:(CGPoint)point;
- (void)updateStamp;

@end
