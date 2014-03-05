//
//  ZZAudioPlayer.m
//  Toeic
//
//  Created by zhaozilong on 12-7-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ZZAudioPlayer.h"
#import "UserSetting.h"

#define RATE_NORMAL_SPPED 100010
#define RATE_SLOW_SPEED 100005
#define RATE_FAST_SPEED 100020

@interface ZZAudioPlayer () {
    int _currTimeNum;
    NSTimeInterval _lastTime;
    
    BOOL _isUpdateLock;//设置timer暂停状态下是否更新
}

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSTimer *sliderTimer;

@property (nonatomic, retain) UIImage *playImg;
@property (nonatomic, retain) UIImage *playHLImg;
@property (nonatomic, retain) UIImage *pauseImg;
@property (nonatomic, retain) UIImage *pauseHLImg;

@property (nonatomic, retain) UIImage *normalSpeedImg;
@property (nonatomic, retain) UIImage *slowSpeedImg;
@property (nonatomic, retain) UIImage *fastSpeedImg;
@property (nonatomic, retain) UIImage *normalSpeedHLImg;
@property (nonatomic, retain) UIImage *slowSpeedHLImg;
@property (nonatomic, retain) UIImage *fastSpeedHLImg;

@property BOOL isEnterBackground;

@end

@implementation ZZAudioPlayer

//@synthesize playBtn = _playBtn;
//@synthesize nextQuesBtn = _nextQuesBtn;
//@synthesize prevQuesBtn = _prevQuesBtn;
//@synthesize nextSenBtn = _nextSenBtn;
//@synthesize prevSenBtn = _prevSenBtn;
//@synthesize audioSlider = _audioSlider;

#pragma mark - start&over
- (void)unload {
    self.nextQuesBtn = nil;
    self.nextSenBtn = nil;
    self.prevQuesBtn = nil;
    self.prevSenBtn = nil;
    self.playBtn = nil;
    self.rateBtn = nil;
}

- (void)dealloc {
#if COCOS2D_DEBUG
    NSLog(@"ZZAudioPlayer is dealloced");
#endif
    //停止线控
    [self resignFirstResponder];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    //删除消息中心的注册对象
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
    
    [_sliderTimer invalidate], _sliderTimer = nil;
    
    [_timingArray release], _timingArray = nil;
    
    if (_audioPlayer) {
        [_audioPlayer stop];
        [_audioPlayer setDelegate:nil];
        [_audioPlayer release], _audioPlayer = nil;
    }
    
    self.delegate = nil;
    
    [self.playImg release];
    [self.playHLImg release];
    [self.pauseImg release];
    [self.pauseHLImg release];
    [self.normalSpeedImg release];
    [self.slowSpeedImg release];
    [self.fastSpeedImg release];
    [self.normalSpeedHLImg release];
    [self.slowSpeedHLImg release];
    [self.fastSpeedHLImg release];
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        
        //初始化play和pause图标
//        _playImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"]];
//        _pauseImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pause" ofType:@"png"]];
        
        /*
        //自定义Slider样式
        [_audioSlider setThumbImage:[UIImage imageNamed:@"sliderBtn.png"] forState:UIControlStateNormal];
        
        UIImage *stetchLeftTrack = [UIImage imageNamed:@"slider.png"];//[[UIImage imageNamed:@"slider.png"] stretchableImageWithLeftCapWidth:80.0 topCapHeight:0.0];
        
        
        UIImage *stetchRightTrack = [UIImage imageNamed:@"sliderMax.png"];//[[UIImage imageNamed:@"sliderMax.png"] stretchableImageWithLeftCapWidth:80.0 topCapHeight:0.0];
        [_audioSlider setMinimumTrackImage:stetchRightTrack forState:UIControlStateNormal];
        [_audioSlider setMaximumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
        */
        
        
    }
    return self;
}

- (void)awakeFromNib {
    //监听程序中断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    //线控
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    self.isEnterBackground = NO;
}

#pragma mark - method

- (void)initializeAudioPlayer {
    _isUpdateLock = YES;
    
    self.playImg = [UIImage imageNamed:@"play.png"];
    self.playHLImg = [UIImage imageNamed:@"play_hl.png"];
    self.pauseImg = [UIImage imageNamed:@"pause.png"];
    self.pauseHLImg = [UIImage imageNamed:@"pause_hl.png"];
    
    self.normalSpeedImg = [UIImage imageNamed:@"normalSpeed.png"];
    self.slowSpeedImg = [UIImage imageNamed:@"slowSpeed.png"];
    self.fastSpeedImg = [UIImage imageNamed:@"fastSpeed.png"];
    self.normalSpeedHLImg = [UIImage imageNamed:@"normalSpeed_hl.png"];
    self.slowSpeedHLImg = [UIImage imageNamed:@"slowSpeed_hl.png"];
    self.fastSpeedHLImg = [UIImage imageNamed:@"fastSpeed_hl.png"];
    
    //设置调速按钮的状态
    self.rateBtn.tag = RATE_NORMAL_SPPED;
    [self checkRateBtnState];
    
    //自定义Slider样式
//    [_audioSlider setThumbImage:[UIImage imageNamed:@"sliderBtn.png"] forState:UIControlStateNormal];
    
    UIImage *stetchLeftTrack = [UIImage imageNamed:@"sliderMin.png"];//[[UIImage imageNamed:@"slider.png"] stretchableImageWithLeftCapWidth:80.0 topCapHeight:0.0];
    
    
    UIImage *stetchRightTrack = [UIImage imageNamed:@"sliderMax.png"];//[[UIImage imageNamed:@"sliderMax.png"] stretchableImageWithLeftCapWidth:80.0 topCapHeight:0.0];
    
    [_audioSlider setMinimumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    [_audioSlider setMaximumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    if ([UserSetting isSystemOS7]) {
        [_audioSlider setThumbImage:[UIImage imageNamed:@"sliderThumb.png"] forState:UIControlStateNormal];
        
        CGRect frame = _audioSlider.frame;
        frame.origin.y -= 6;
        [_audioSlider setFrame:frame];
    }
    
}

- (void)checkRateBtnState {
    if (self.rateBtn.tag == RATE_NORMAL_SPPED) {
        [self.rateBtn setImage:_normalSpeedImg forState:UIControlStateNormal];
        [self.rateBtn setImage:_normalSpeedHLImg forState:UIControlStateHighlighted];
    } else if (self.rateBtn.tag == RATE_SLOW_SPEED) {
        [self.rateBtn setImage:_slowSpeedImg forState:UIControlStateNormal];
        [self.rateBtn setImage:_slowSpeedHLImg forState:UIControlStateHighlighted];
    } else {
        [self.rateBtn setImage:_fastSpeedImg forState:UIControlStateNormal];
        [self.rateBtn setImage:_fastSpeedHLImg forState:UIControlStateHighlighted];
    }
}

- (void)recheckRateBtnState {
    if (self.rateBtn.tag == RATE_NORMAL_SPPED) {
        [self.audioPlayer setRate:1.0f];
    } else if (self.rateBtn.tag == RATE_SLOW_SPEED) {
        [self.audioPlayer setRate:0.7f];
    } else {
        [self.audioPlayer setRate:1.3f];
    }
}

- (void)playSoundByAudioName:(NSString *)audioName timeArray:(NSMutableArray *)timingArray lastTimePoint:(NSTimeInterval)playTime {
    
    _lastTime = -1.0;
    
    //时间点数组
    _timingArray = [timingArray copy];
    
    //如果上一个音频没播放完，先停止
    if (_audioPlayer) {
        [_audioPlayer stop];
        [_audioPlayer setDelegate:nil];
        [_audioPlayer release], _audioPlayer = nil;
    }    
    //加载音频
    NSURL *audioDir = [NSURL fileURLWithPath:[ZZAcquirePath getBundleDirectoryWithFileName:audioName]];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioDir error:NULL];
    [_audioPlayer setDelegate:self];
    
    //设置slider初值
//    _audioSlider.maximumValue = _audioPlayer.duration;
//    NSLog(@"play 之前%f,,,%f", _audioSlider.maximumValue, _audioPlayer.duration);
    
    [_audioPlayer prepareToPlay];
    
    //显示音频总时间
//    [_audioTotalLabel setText:[NSString stringWithFormat:@"/%@", [ZZAudioPlayer timeToSwitchAdvance:_audioPlayer.duration]]];
    
    [_audioPlayer play];
    [_playBtn setImage:_pauseImg forState:UIControlStateNormal];
    [_playBtn setImage:_pauseHLImg forState:UIControlStateHighlighted];
//    [_audioPlayer setRate:2.0f];
    
    //记录上次播放时间
    [_audioPlayer setCurrentTime:playTime];
    
    //设置slider初值
    _audioSlider.maximumValue = _audioPlayer.duration;
}

- (void)playSoundWithAudioName:(NSString *)audioName packName:(NSString *)packName isFree:(BOOL)isFree timeArray:(NSMutableArray *)timingArray lastTimePoint:(NSTimeInterval)playTime  {
    
    _currTimeNum = 0;
    
    _lastTime = -1.0;
    
    //时间点数组
    _timingArray = [timingArray copy];
    
    //如果上一个音频没播放完，先停止
    if (_audioPlayer) {
        [_audioPlayer stop];
        [_audioPlayer setDelegate:nil];
        [_audioPlayer release], _audioPlayer = nil;
    }
    
    
    NSString *audioPath = nil;
    if (isFree) {//音频再bundle下
        
        if ([TestType isToeic]) {
            //音频都是1_01.m4a的形式的
            NSString *name = [packName stringByReplacingOccurrencesOfString:@"Test" withString:@""];
            audioName = [name stringByAppendingFormat:@"_%@", audioName];
        }else
            
        
        audioPath = [ZZAcquirePath getBundleDirectoryWithFileName:audioName];
        
    } else {
        audioPath = [ZZAcquirePath getAudioDocDirectoryWithFileName:[NSString stringWithFormat:@"%@/%@", packName, audioName]];
    }
    
    //加载音频
    NSURL *audioDir = [NSURL fileURLWithPath:audioPath];
    
    //静音播放
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error:nil];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioDir error:NULL];
    [_audioPlayer setDelegate:self];
    
    //设置slider初值
    //    _audioSlider.maximumValue = _audioPlayer.duration;
    //    NSLog(@"play 之前%f,,,%f", _audioSlider.maximumValue, _audioPlayer.duration);
    
    [_audioPlayer setEnableRate:YES];
    [_audioPlayer prepareToPlay];
    
    //显示音频总时间
    //    [_audioTotalLabel setText:[NSString stringWithFormat:@"/%@", [ZZAudioPlayer timeToSwitchAdvance:_audioPlayer.duration]]];
    
    [_audioPlayer play];
    [self recheckRateBtnState];
    [_playBtn setImage:_pauseImg forState:UIControlStateNormal];
    [_playBtn setImage:_pauseHLImg forState:UIControlStateHighlighted];
//    [_audioPlayer setRate:0.7f];
    //1.3;  0.7;  1.0f
//    [_audioPlayer set]
    
    //记录上次播放时间
    [_audioPlayer setCurrentTime:playTime];
    
    //设置slider初值
    _audioSlider.maximumValue = _audioPlayer.duration;
}

-(void) PlayCsoundwithAudioName:(NSString *)audioName packName:(NSString *)packName isFree:(BOOL)isFree timeArray:(NSMutableArray *)timingArray lastTimePoint:(NSTimeInterval)playTime  {
    
    _currTimeNum = 0;
    
    _lastTime = -1.0;
    
    //时间点数组
    _timingArray = [timingArray copy];
    
    //如果上一个音频没播放完，先停止
    if (_audioPlayer) {
        [_audioPlayer stop];
        [_audioPlayer setDelegate:nil];
        [_audioPlayer release], _audioPlayer = nil;
    }
    NSString *audioPath = nil;
    if (isFree) {//音频再bundle下
        
                audioPath = [ZZAcquirePath getBundleDirectoryWithFileName:audioName];
//        packName = [packName stringByReplacingOccurrencesOfString:@"年" withString:@""];
//        packName = [packName stringByReplacingOccurrencesOfString:@"月" withString:@""];
       // audioPath = [ZZAcquirePath getAudioDocDirectoryWithFileName:[NSString stringWithFormat:@"%@/%@", packName, audioName]];

    } else {
//        packName = [packName stringByReplacingOccurrencesOfString:@"年" withString:@""];
//        packName = [packName stringByReplacingOccurrencesOfString:@"月" withString:@""];
//        audioPath = [ZZAcquirePath getAudioDocDirectoryWithFileName:audioName];
        audioPath = [ZZAcquirePath getAudioDocDirectoryWithFileName:[NSString stringWithFormat:@"%@/%@", packName, audioName]];
    }
    
    //加载音频
    NSURL *audioDir = [NSURL fileURLWithPath:audioPath];
    
    //静音播放
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error:nil];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioDir error:NULL];
    [_audioPlayer setDelegate:self];
    
    //设置slider初值
    //    _audioSlider.maximumValue = _audioPlayer.duration;
    //    NSLog(@"play 之前%f,,,%f", _audioSlider.maximumValue, _audioPlayer.duration);
    
    [_audioPlayer setEnableRate:YES];
    [_audioPlayer prepareToPlay];
    
    //显示音频总时间
    //    [_audioTotalLabel setText:[NSString stringWithFormat:@"/%@", [ZZAudioPlayer timeToSwitchAdvance:_audioPlayer.duration]]];
    
    [_audioPlayer play];
    [self recheckRateBtnState];
    [_playBtn setImage:_pauseImg forState:UIControlStateNormal];
    [_playBtn setImage:_pauseHLImg forState:UIControlStateHighlighted];
    //    [_audioPlayer setRate:0.7f];
    //1.3;  0.7;  1.0f
    //    [_audioPlayer set]
    
    //记录上次播放时间
    [_audioPlayer setCurrentTime:playTime];
    
    //设置slider初值
    _audioSlider.maximumValue = _audioPlayer.duration;
}



// Update the slider about the music time
- (void)updateSlider {
    
	//设置slider初值
//    _audioSlider.maximumValue = _audioPlayer.duration;
	
    
    NSTimeInterval currTime = (int)_audioPlayer.currentTime;
    if (_audioPlayer.playing) {
        
        _audioSlider.value = _audioPlayer.currentTime;
        
        _isUpdateLock = YES;
    } else {
        if (!_isUpdateLock) {
            currTime = [[_timingArray objectAtIndex:_currTimeNum] doubleValue];
            _audioSlider.value = currTime;
            _audioPlayer.currentTime = currTime;
        }
    }
//    if (_timingArray == nil) {
//        return;
//    }
    int count = [_timingArray count];
    for (int i = 0; i < count; i++) {
        NSTimeInterval thisTime = [[_timingArray objectAtIndex:i] doubleValue];
        NSTimeInterval nextTime = 0;
        int next;
        if (i == count - 1) {
//            next = count - 1;
//            nextTime = [[_timingArray objectAtIndex:next] doubleValue];
            if (currTime >= thisTime && _lastTime != thisTime) {
//                NSLog(@"最后一句~~~~~~~");
                _currTimeNum = i;
                [self.delegate ZZAudioTimePointChangedByNum:_currTimeNum];
                
                _lastTime = thisTime;
            }
        } else {
            next = i + 1;
            nextTime = [[_timingArray objectAtIndex:next] doubleValue];
            if (currTime >= thisTime && currTime < nextTime && _lastTime != thisTime) {
                _currTimeNum = i;
                [self.delegate ZZAudioTimePointChangedByNum:_currTimeNum];
                
                _lastTime = thisTime;
            }
        }
    }
}

- (void)fireSliderTimer:(BOOL)isFire {
    if (isFire && _sliderTimer == nil) {
        _sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    } else {
        [_sliderTimer invalidate], _sliderTimer = nil;
    }
    
}

- (BOOL)isZZAudioPlaying {
    if (_audioPlayer.playing) {
        return YES;
    }
    return NO;
}

/*
+ (NSString *)timeToSwitchAdvance:(double)preTime {
	NSInteger currTime=round(preTime);
    //    int value_h= timeCount/(60*60);
    int value_m= currTime%(60*60)/60;
    int value_s= currTime%(60*60)%60%60;
    //	int value_m = (int)preTime / 60;
    //    int value_s = (int)preTime % 60;
    
    NSString *minString;
    NSString *secString;
    
    if (value_m<10){
        minString=[NSString stringWithFormat:@"%d:",value_m];
    }
    else {
        minString=[NSString stringWithFormat:@"%d:",value_m];
    }
	
    if (value_s<10){
        secString=[NSString stringWithFormat:@"0%d",value_s];
    }
    else {
        secString=[NSString stringWithFormat:@"%d",value_s];
    }
    
    //当前播放时间字符串MM:SS
    NSString *nowCurrTime=[minString stringByAppendingString:secString];
	return (nowCurrTime);
}
 */

#pragma mark - buttonPressed

- (IBAction) sliderChanged:(UISlider *)sender{
	
	//	Fast skip the music when user scroll the UISlider
    [_audioPlayer setCurrentTime:sender.value];
    _isUpdateLock = YES;
    
    //时间实时变化
//    _audioTimeLabel.text = [ZZAudioPlayer timeToSwitchAdvance:_audioPlayer.currentTime];
	
}

- (void)setZZAudioPlayerPause {
    
    if (_audioPlayer.playing) {
        [_audioPlayer pause];
        //更换播放按钮图标
        [_playBtn setImage:_playImg forState:UIControlStateNormal];
        [_playBtn setImage:_playHLImg forState:UIControlStateHighlighted];
        
    }
}

- (IBAction)playBtnPressed:(id)sender {
    
    if (_audioPlayer.playing == YES) {
        [_audioPlayer pause];
//        [self fireSliderTimer:NO];
        //更换播放按钮图标
        [_playBtn setImage:_playImg forState:UIControlStateNormal];
        [_playBtn setImage:_playHLImg forState:UIControlStateHighlighted];
        
    } else {
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
//        [self fireSliderTimer:YES];
        //更换播放按钮图标
        [_playBtn setImage:_pauseImg forState:UIControlStateNormal];
        [_playBtn setImage:_pauseHLImg forState:UIControlStateHighlighted];
        
        [self.delegate ZZAudioIsPlayingNow];
    }
    
}

- (IBAction)nextSenBtnPressed:(id)sender {
    NSTimeInterval time = 0.0;
    if (_audioPlayer.playing) {
        if (_currTimeNum == [_timingArray count] - 2) {
            time = [[_timingArray objectAtIndex:++_currTimeNum] doubleValue];
            [_audioPlayer setCurrentTime:time];
            
        } else if (_currTimeNum < [_timingArray count] - 1) {
            time = [[_timingArray objectAtIndex:_currTimeNum + 1] doubleValue];
            [_audioPlayer setCurrentTime:time];
        }
    } else {
        
        if (_currTimeNum < [_timingArray count] - 1) {
            _currTimeNum++;
            _isUpdateLock = NO;
        }
    }
}

- (IBAction)prevSenBtnPressed:(id)sender {
    NSTimeInterval time = 0.0;
    if (_audioPlayer.playing) {
        if (_currTimeNum > 0) {
            time = [[_timingArray objectAtIndex:_currTimeNum - 1] doubleValue];
            [_audioPlayer setCurrentTime:time];
        }
    } else {
        if (_currTimeNum > 0) {
            _currTimeNum--;
            _isUpdateLock = NO;
        }
    }
    
}

- (IBAction)nextQuesBtnPressed:(id)sender {
    [self.delegate ZZAudioNextTitleBtnPressed];
}

- (IBAction)prevQuesPressed:(id)sender {
    [self.delegate ZZAudioPrevTitleBtnPressed];
}

- (IBAction)rateBtnPressed:(id)sender {
    if (![UserSetting isPurchasedVIPMode]) {
        [self.delegate ZZAudioPushToVIPPage];
        return;
    }
    
    if (self.rateBtn.tag == RATE_NORMAL_SPPED) {
        self.rateBtn.tag = RATE_SLOW_SPEED;
        self.audioPlayer.rate = 0.7f;
    } else if (self.rateBtn.tag == RATE_SLOW_SPEED) {
        self.rateBtn.tag = RATE_FAST_SPEED;
        self.audioPlayer.rate = 1.3f;
    } else {
        self.rateBtn.tag = RATE_NORMAL_SPPED;
        self.audioPlayer.rate = 1.0f;
    }
    
    [self checkRateBtnState];
}

#pragma mark - audioPlayerDelegate
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
//    NSLog(@"有人给我来电话了");
    if (_audioPlayer) {
        [_audioPlayer pause];
        //更换播放按钮图标
        [_playBtn setImage:_playImg forState:UIControlStateNormal];
        [_playBtn setImage:_playHLImg forState:UIControlStateHighlighted];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_playBtn setImage:_playImg forState:UIControlStateNormal];
    [_playBtn setImage:_playHLImg forState:UIControlStateHighlighted];
//    _audioSlider.maximumValue = _audioPlayer.duration;
    _audioSlider.value = 0;
//    [self fireSliderTimer:NO];
    
    if (self.isEnterBackground) {
        [self nextQuesBtnPressed:nil];
    }
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    
}

#pragma mark - appDelegate
- (void)applicationWillEnterForeground:(UIApplication *)application {
    //    NSLog(@"applicationWillEnterForeground");
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    //标志进入后台
    self.isEnterBackground = YES;
    
    [self becomeFirstResponder];
    
    //未开启后台播放的话，进入后台之后暂停播放
    if (![UserSetting isBackgroundPlayEnabled]) {
        [self setZZAudioPlayerPause];
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    self.isEnterBackground = NO;
}

#pragma mark - Line Control Function
///*
//线控控制
- (BOOL)canBecomeFirstResponder {
    return YES;
}

//- (BOOL)canResignFirstResponder {
//    return YES;
//}
//*/

///*
//线控控制
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playBtnPressed:nil];
                break;
            case UIEventSubtypeRemoteControlPlay:
            case UIEventSubtypeRemoteControlPause:
                if ([UserSetting isSystemOS7]) {
                    [self playBtnPressed:nil];
                }
                break;
            case UIEventSubtypeRemoteControlStop:
            {
            	//todo stop event
//                [self playBtnPressed:nil];
                break;
            }
                
            case UIEventSubtypeRemoteControlNextTrack:
            {
                //todo play next song
                [self nextSenBtnPressed:nil];
                break;
            }
                
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                //todo play previous song
                [self prevSenBtnPressed:nil];
                break;
            }
            default:
                break;
        }
    }
}
//*/
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


@end
