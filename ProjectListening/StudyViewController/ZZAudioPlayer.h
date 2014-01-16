//
//  ZZAudioPlayer.h
//  Toeic
//
//  Created by zhaozilong on 12-7-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>

//#import "ZZConfig.h"

@protocol ZZAudioPlayerDelegate <NSObject>

@optional
- (void)ZZAudioNextOrPreSentenceBtnPressedByNum:(int)senNum;
- (void)ZZAudioIsPlayingNow;
- (void)ZZAudioPushToVIPPage;

@required
//- (void)ZZAudioNextOrPreTitleBtnPressedByNum:(int)titleNum;
- (void)ZZAudioNextTitleBtnPressed;
- (void)ZZAudioPrevTitleBtnPressed;
- (void)ZZAudioTimePointChangedByNum:(int)senNum;


@end

@interface ZZAudioPlayer : UIView <AVAudioPlayerDelegate, UIScrollViewDelegate> {
    
@private
    //播放器部分
//    UIButton *_playBtn;
//    UISlider *_audioSlider;
//    UIButton *_nextQuesBtn;
//    UIButton *_prevQuesBtn;
//    UIButton *_nextSenBtn;
//    UIButton *_prevSenBtn;
//    UILabel *_audioTimeLabel;
//    UILabel *_audioTotalLabel;
//    NSTimer *_sliderTimer;
}

//播放器部分
@property (nonatomic, retain) IBOutlet UIButton *playBtn;
@property (nonatomic, retain) IBOutlet UISlider *audioSlider;
@property (nonatomic, retain) IBOutlet UIButton *nextQuesBtn;
@property (nonatomic, retain) IBOutlet UIButton *prevQuesBtn;
@property (nonatomic, retain) IBOutlet UIButton *nextSenBtn;
@property (nonatomic, retain) IBOutlet UIButton *prevSenBtn;
@property (nonatomic, retain) IBOutlet UIButton *rateBtn;

@property (nonatomic, retain) NSMutableArray *timingArray;

//@property (assign) BOOL isUpdate;

//@property (nonatomic, retain) UILabel *_audioTimeLabel;
//@property (nonatomic, retain) UILabel *_audioTotalLabel;

@property (nonatomic, assign) id<ZZAudioPlayerDelegate> delegate;

- (IBAction)playBtnPressed:(id)sender;
- (IBAction)nextQuesBtnPressed:(id)sender;
- (IBAction)prevQuesPressed:(id)sender;
- (IBAction)nextSenBtnPressed:(id)sender;
- (IBAction)prevSenBtnPressed:(id)sender;
- (IBAction)sliderChanged:(id)sender;
- (IBAction)rateBtnPressed:(id)sender;

//+ (NSString *)timeToSwitchAdvance:(double)preTime;

//- (void)playSoundByAudioName:(NSString *)audioName timeArray:(NSMutableArray *)timingArray lastTimePoint:(NSTimeInterval)playTime;
- (void)fireSliderTimer:(BOOL)isFire;
- (void)unload;
- (void)initializeAudioPlayer;
- (void)setZZAudioPlayerPause;
- (BOOL)isZZAudioPlaying;

- (void)playSoundWithAudioName:(NSString *)audioName packName:(NSString *)packName isFree:(BOOL)isFree timeArray:(NSMutableArray *)timingArray lastTimePoint:(NSTimeInterval)playTime;

@end
