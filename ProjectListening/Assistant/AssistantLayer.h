//
//  AssistantLayer.h
//  ProjectListening
//
//  Created by zhaozilong on 13-3-18.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "RootViewController.h"
#import "ZZAssistant.h"

@class RootViewController;
@interface AssistantLayer : CCLayer {
    
}
//@property (nonatomic, assign) RootViewController *RVC;

+(CCScene *) scene;

- (void)updateData;

@end
