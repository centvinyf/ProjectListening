//
//  AssistantLayer.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-18.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "AssistantLayer.h"
#import "StampSprite.h"
#include <sqlite3.h>
#import "UserSetting.h"
#import "CCAnimationHelper.h"
#import "MsgTextView.h"


@interface AssistantLayer() {
    StampSprite *_stamp;
    CCSprite *_assistant;
//    CCLabelTTF *_msgLabel;
    
    sqlite3 *_database;
}

@property (nonatomic, retain) ZZAssistant *ZZAss;
@property (nonatomic, retain) MsgTextView *msgTextView;

@end

@implementation AssistantLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	AssistantLayer *layer = [AssistantLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        //初始化助理的大脑
        _ZZAss = [[ZZAssistant alloc] init];
        
        CCLayerColor *layer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
        [self addChild:layer];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        switch ([UserSetting assistantID]) {
            case 0:
                [frameCache addSpriteFramesWithFile:@"AssistantID_0.plist"];
                break;
                
            case 1:
                [frameCache addSpriteFramesWithFile:@"AssistantID_1.plist"];
                break;
                
            default:
                NSAssert(NO, @"加载纹理错误");
                break;
        }

        
        ccColor4B color;
        
        TestTypeTags testType = TEST_TYPE;
        switch (testType) {
            case TestTypeToefl:
                color = ccc4(84, 207, 223, 255);
                break;
            case TestTypeToeic:
                color = ccc4(17, 174, 225, 255);
                break;
            case TestTypeJLPT1:
                color = ccc4(26, 179, 136, 255);
                break;
            case TestTypeJLPT2:
                color = ccc4(16, 204, 158, 255);
                
                break;
            case TestTypeJLPT3:
                color = ccc4(42, 210, 136, 255);
                break;
                
            case TestTypeHSK1:
            case TestTypeHSK2:
            case TestTypeHSK3:
            case TestTypeHSK4:
            case TestTypeHSK5:
            case TestTypeHSK6:
                color = ccc4(247, 150, 0, 255);
                break;
            case TestTypeTEM4:
                color = ccc4(160, 78, 178, 255);
                break;
            default:
                NSAssert(NO, @"没有正确的考试类型，助理的颜色不对");
                break;
        }
        
        //蓝色背景层
        CCLayerColor *bgColor = nil;
        
        //蓝色背景条
        CCSprite *bgSprite = [CCSprite spriteWithFile:@"blueBG.png"];
        
        
        //助理形象
        NSString *name = @"Tag7_ID0_Index0_frame0.png";
        int userAssID = [UserSetting assistantID];
        switch (userAssID) {
            case 0:
                name = @"Tag7_ID0_Index0_frame0.png";
                break;
            default:
                name = @"Tag7_ID1_Index0_frame0.png";
                break;
        }
        _assistant = [CCSprite spriteWithSpriteFrameName:name];
        
        
        CGPoint bgPos, stampPos, assPos, bgColorPos;
        CGRect rect;
        if (IS_IPAD) {
            if (IOS_NEWER_OR_EQUAL_TO_7) {
                bgColor = [CCLayerColor layerWithColor:color width:768.0f height:238.0f];
            } else {
                bgColor = [CCLayerColor layerWithColor:color width:768.0f height:245.0f];
            }
            
            
            bgPos = ccp(winSize.width / 2, winSize.height - bgSprite.contentSize.height / 2 - 240.0f);
            bgColorPos = ccp(0, 710);
            stampPos = ccp(winSize.width / 2 + 265, 835);
            assPos = ccp(_assistant.contentSize.width / 2, 830);
            rect = CGRectMake(180, 10, 350, 225);
        } else {
            bgColor = [CCLayerColor layerWithColor:color width:320.0f height:97.0f];
            rect = CGRectMake(70, 0, 155, 100);
            
            if (IS_IPHONE_568H) {
                bgPos = ccp(winSize.width / 2, winSize.height - bgSprite.contentSize.height / 2 + 88 - 96);
                bgColorPos = ccp(0, 314 + 88);
                stampPos = ccp(winSize.width / 2 + 110, 360 + 88);
                assPos = ccp(_assistant.contentSize.width / 2, 500 - _assistant.contentSize.height / 2);
             
            } else {
                bgPos = ccp(winSize.width / 2, winSize.height - bgSprite.contentSize.height / 2 - 96);
                bgColorPos = ccp(0, 314);
                stampPos = ccp(winSize.width / 2 + 110, 360);
                assPos = ccp(_assistant.contentSize.width / 2, 413 - _assistant.contentSize.height / 2);
            }
        }
        
        //蓝色背景的位置
        [self addChild:bgColor];
        bgColor.anchorPoint = ccp(0, 0);
        bgColor.position = bgColorPos;
        
        //蓝色背景条
        [self addChild:bgSprite];
        bgSprite.position = bgPos;
        
        if ([UserSetting isSystemOS7]) {
            if (IS_IPAD) {
                bgPos.y -= 70 + 4;
                bgSprite.position = bgPos;
//                bgPos;
            } else {
//                bgPos.y -= 64 + 6;
                bgPos.y -= 64 + 6;
                bgSprite.position = bgPos;
            }
            
        }
        
        //助理位置
        [self addChild:_assistant];
        _assistant.anchorPoint = ccp(0.5, 0.5);
        _assistant.position = assPos;
        
        
        //信息板的设置
        
        if ([UserSetting isSystemOS7]) {
            rect.origin.y += 20;
        }
        _msgTextView = [[MsgTextView alloc] initWithFrame:rect];
        [[[CCDirector sharedDirector] openGLView] addSubview:_msgTextView];
        
        //印章设置
        _stamp = [StampSprite spriteWithParentNode:self position:stampPos];
        
        //更新信息
        [self updateData];

    }
	return self;
}

- (void)updateData {
    //更新显示的文字
    [self updateMsgBoard];
    
    //更新邮戳
    [_stamp updateStamp];
}

- (void)updateAssistantAnimByAMTags:(AMTags)tag {
    
    
    //用不用先停止所有action?
    [_assistant stopAllActions];
    
    int assID = [UserSetting assistantID];
    
    switch (assID) {
        case 0:
            [_msgTextView setTextColor:[UIColor blackColor]];
            break;
            
        case 1:
        default:
            [_msgTextView setTextColor:[UIColor whiteColor]];
            break;
    }
    
    NSString *path = [ZZAcquirePath getDBAssistantFromBundle];
    [self openDatabaseIn:path];
    
    //开始查询
    NSString *sel = [NSString stringWithFormat:@"SELECT count(*) FROM AssistantAnimation WHERE AMTags = %d AND AssistantID = %d", tag, assID];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询AssistantCount信息失败");
    }
    
    int count = 0;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        count = sqlite3_column_int(stmt, 0);
    }
    sqlite3_finalize(stmt);
    
#if COCOS2D_DEBUG
    NSLog(@"AMTags:%d, AssID:%d", tag, assID);
#endif
    
    NSAssert(count != 0, @"没有相应的助理动画");
    
    int index = [ZZAssistant getRandomNumBelow:count];
    sel = [NSString stringWithFormat:@"SELECT AnimName, FrameCount, FrameDelays FROM AssistantAnimation WHERE AMTags = %d AND AssistantID = %d AND AnimIndex = %d", tag, assID, index];
    
    sqlite3_stmt *stmt_anim;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt_anim, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询Assistant信息失败");
    }
    
    int frameCount = 0;
    NSString *animName = @"";
    NSArray *delayArray = nil;
    char *cDelay = NULL;
    while (sqlite3_step(stmt_anim) == SQLITE_ROW) {
        animName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt_anim, 0)];
        frameCount = sqlite3_column_int(stmt_anim, 1);
        cDelay = (char *)sqlite3_column_text(stmt_anim, 2);
        if (cDelay != NULL) {
            NSString *sDelay = [NSString stringWithUTF8String:cDelay];
            if (![sDelay isEqualToString:@""]) {
                delayArray = [sDelay componentsSeparatedByString:@","];
            }
        }
        
        
    }
    sqlite3_finalize(stmt_anim);
    
    [self closeDatabase];
    
    
    //是否存在变帧播放动画情况
    if (delayArray) {
        CCAction *repeat = [CCAnimation animationWithFrame:animName frameCount:frameCount delayArray:delayArray sprite:_assistant];
        [_assistant runAction:repeat];
    } else {
        CCAnimation *animation = [CCAnimation animationWithFrame:animName frameCount:frameCount delay:frameCount * 0.1];
        
        CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
        
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:animate];
        
        [_assistant runAction:repeat];
    }
    
    
    
}

- (void)updateMsgBoard {
    AMTags tag = [_ZZAss getAssistantStatus];
    //    [_RVC setButtonStatusCurrentAMTags:tag];
    [[RootViewController sharedRootViewController] setButtonStatusCurrentAMTags:tag];
    
    NSString *msg = [_ZZAss getAssistantMessageWithTag:tag];
//    [_msgLabel setString:msg];
    [_msgTextView setText:msg];
    [_msgTextView setContentOffset:CGPointZero animated:YES];
    
    //动画写好之后取消注释
    [self updateAssistantAnimByAMTags:tag];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
#if COCOS2D_DEBUG
    NSLog(@"Assistant Layer is dealloc");
#endif
    
    [_ZZAss release];
    [_msgTextView release];
	
	// don't forget to call "super dealloc"
	[super dealloc];
}


- (void)openDatabaseIn:(NSString *)dbPath {
    if (sqlite3_open([dbPath UTF8String], &_database) != SQLITE_OK) {
        //        sqlite3_close(database);
        
        NSAssert(NO, @"Open database failed");
    }
}

- (void)closeDatabase {
    if (sqlite3_close(_database) != SQLITE_OK) {
        NSAssert(NO, @"Close database failed");
    }
}


@end
