//
//  CourseViewController.m
//  ToeicListeningFREE
//
//  Created by 赵子龙 on 13-12-19.
//
//

#import "CourseViewController.h"
#import "CouseClass.h"
#import "NSString+ZZString.h"

#include <sqlite3.h>


#define RATE_NORMAL_SPPED 100010
#define RATE_SLOW_SPEED 100005
#define RATE_FAST_SPEED 100020

@interface CourseViewController () {
    int _currTimeNum;
    NSTimeInterval _lastTime;
    
    sqlite3 *_database;
    
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

@property (nonatomic, retain) CouseClass *cc;

@property (nonatomic, retain) NSString *audioName;
@property (assign) int titleId;
@property (assign) int packId;

@property (assign) NSTimeInterval lastPlayTime;
@property (assign) int lastPageNum;

@end

@implementation CourseViewController

- (void)dealloc {
    
#if COCOS2D_DEBUG
    NSLog(@"CourseViewController is dealloced");
#endif
    //停止线控
    [self resignFirstResponder];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    //删除消息中心的注册对象
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_audioPlayer) {
        [_audioPlayer stop];
        [_audioPlayer setDelegate:nil];
        [_audioPlayer release], _audioPlayer = nil;
    }
    
    
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
    
    [self.CPView release];
    [self.playBtn release];
    [self.nextBtn release];
    [self.prevBtn release];
    [self.speedBtn release];
    [self.homeBtn release];
    [self.audioSlider release];
    [self.picImgView release];
    
    [self.cc release];
    
    [_pageLabel release];
    [_timeLabel release];
    [super dealloc];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil packId:(int)packId titleId:(int)titleId audioName:(NSString *)audioName lastPlayTime:(NSTimeInterval)lastPlayTime lastPageNum:(int)lastPageNum
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.titleId = titleId;
        self.audioName = audioName;
        self.packId = packId;
        
        self.lastPlayTime = lastPlayTime;
        self.lastPageNum = lastPageNum;
        
        
        //监听程序中断
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        
        //线控
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self becomeFirstResponder];
        
//        self.isEnterBackground = NO;
        
        
    }
    return self;
}

- (void)initializeAudioPlayer {
    _isUpdateLock = YES;
    
    self.playImg = [UIImage imageNamed:@"CoursePlay.png"];
    self.playHLImg = [UIImage imageNamed:@"CoursePlay_HL.png"];
    self.pauseImg = [UIImage imageNamed:@"CousePause.png"];
    self.pauseHLImg = [UIImage imageNamed:@"CousePause_HL.png"];
    
    self.normalSpeedImg = [UIImage imageNamed:@"CourseSpeedNormal.png"];
    self.slowSpeedImg = [UIImage imageNamed:@"CourseSpeedSlow.png"];
    self.fastSpeedImg = [UIImage imageNamed:@"CourseSpeedFast.png"];
    self.normalSpeedHLImg = [UIImage imageNamed:@"CourseSpeedNormal_HL.png"];
    self.slowSpeedHLImg = [UIImage imageNamed:@"CourseSpeedSlow_HL.png"];
    self.fastSpeedHLImg = [UIImage imageNamed:@"CourseSpeedFast_HL.png"];
    
    //设置调速按钮的状态
    self.speedBtn.tag = RATE_NORMAL_SPPED;
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //设置屏幕常亮Off
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //设置屏幕常亮OffOrOn
    [[UIApplication sharedApplication] setIdleTimerDisabled:[UserSetting screenKeepLightStatus]];
    
    self.navigationController.navigationBarHidden = YES;
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    self.navigationController.view.transform = CGAffineTransformIdentity;
    self.navigationController.view.transform = CGAffineTransformMakeRotation(M_PI*(90)/180.0);
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.navigationController.view.bounds = CGRectMake(0, 0, rect.size.height, rect.size.width);
    [UIView commitAnimations];
    [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated:YES];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initializeAudioPlayer];
    
    //course类
    self.cc = [CouseClass CouseClassWithTitleId:self.titleId audioName:self.audioName packId:self.packId];
//    self.cc = [CouseClass CouseClassWithTitleId:1 audioName:@"Class001.mp3"];
    
    
    //线控
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    //增加左右滑动换句子手势
    //向左
    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeLeft:)] autorelease];
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:oneFingerSwipeLeft];
    //向右
    UISwipeGestureRecognizer *oneFingerSwipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeRight:)] autorelease];
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:oneFingerSwipeRight];

    
    UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTap:)] autorelease];
    
    [[self view] addGestureRecognizer:oneFingerTap];
    
    self.picImgView.userInteractionEnabled = YES;
    [self.picImgView addGestureRecognizer:oneFingerTap];
    
    [self playSoundWithAudioName:self.audioName isFree:YES timeArray:self.cc.timeArray lastTimePoint:self.lastPlayTime];
    
    //加载图片
    NSString *imgName = [NSString stringWithFormat:@"%@.jpg", [self.cc.picNameArray objectAtIndex:0]];
//    NSLog(@"%@", self.cc.picNameArray);
    NSString *picPath = [[ZZAcquirePath getCourseDocDirectoryWithPackId:self.packId titleId:self.titleId] stringByAppendingPathComponent:imgName];
    
    [self.picImgView setImage:[UIImage imageWithContentsOfFile:picPath]];

    
    [self fireSliderTimer:YES];
}

- (void)oneFingerSwipeLeft:(UISwipeGestureRecognizer *)recognizer {
    
    [self nextBtnPressed:nil];
}

- (void)oneFingerSwipeRight:(UISwipeGestureRecognizer *)recognizer {
    
    [self prevBtnPressed:nil];
    
}

- (void)oneFingerTap:(UITapGestureRecognizer *)recognizer {
    
    if (self.CPView.hidden) {
        self.CPView.hidden = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    } else {
        self.CPView.hidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
   
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation { return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight); }
//
//- (NSUInteger)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscapeRight; }


- (void)viewDidUnload {

    [self setCPView:nil];
    [self setHomeBtn:nil];
    [self setPrevBtn:nil];
    [self setPlayBtn:nil];
    [self setNextBtn:nil];
    [self setSpeedBtn:nil];
    [self setAudioSlider:nil];
    [self setPicImgView:nil];
    [self setPageLabel:nil];
    [self setTimeLabel:nil];
    [super viewDidUnload];
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

- (void)updateLastTimePointToPackInfo {
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBClassFromDocuments];
    [self openDatabaseIn:dbPath];
    
    
    //更新下载状态
    NSString *update = [NSString stringWithFormat:@"UPDATE PackInfo SET LastPlayTime = '%f', LastPageNum = %d WHERE PackId = %d AND TitleId = %d;", self.lastPlayTime, self.lastPageNum, self.packId, self.titleId];
    
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
//        sqlite3_close(_database);
//        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }

    [self closeDatabase];
        
}

- (IBAction)backToTop:(id)sender {
    
    //把播放时间和播放页数记录到数据库中
    [self updateLastTimePointToPackInfo];
    
    [_sliderTimer invalidate], _sliderTimer = nil;
    
//    if (_audioPlayer) {
//        [_audioPlayer stop];
//        [_audioPlayer setDelegate:nil];
//        [_audioPlayer release], _audioPlayer = nil;
//    }
    
    
    
    
    [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait animated:YES];
    self.navigationController.navigationBarHidden = NO;
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    self.navigationController.view.transform = CGAffineTransformIdentity;
    self.navigationController.view.transform = CGAffineTransformMakeRotation(M_PI*(0)/180.0);
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.navigationController.view.bounds = CGRectMake(0, 0, rect.size.width, rect.size.height);
    
    
    [UIView commitAnimations];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)prevBtnPressed:(id)sender {
    
    NSTimeInterval time = 0.0;
    if (_audioPlayer.playing) {
        if (_currTimeNum > 0) {
            time = [[self.cc.timeArray objectAtIndex:_currTimeNum - 1] doubleValue];
            [_audioPlayer setCurrentTime:time];
        }
    } else {
        if (_currTimeNum > 0) {
            _currTimeNum--;
            _isUpdateLock = NO;
        }
    }
    
}

- (IBAction)playBtnPressed:(id)sender {
    
    if (_audioPlayer.playing == YES) {
        [_audioPlayer pause];
        //更换播放按钮图标
        [_playBtn setImage:_playImg forState:UIControlStateNormal];
        [_playBtn setImage:_playHLImg forState:UIControlStateHighlighted];
        
    } else {
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
        //更换播放按钮图标
        [_playBtn setImage:_pauseImg forState:UIControlStateNormal];
        [_playBtn setImage:_pauseHLImg forState:UIControlStateHighlighted];
        
//        [self ZZAudioIsPlayingNow];
    }
}

//- (void)ZZAudioIsPlayingNow {
//    
//    if (_currQuesPlayIndex != -1) {
//        //当前有问题音频在播放,停止问题音频的播放
//        [self playQuesAudioByQuesIndex:_currQuesPlayIndex msgIsFromZZAudioPlayer:YES];
//    }
//}

- (IBAction)nextBtnPressed:(id)sender {
    
    NSTimeInterval time = 0.0;
    if (_audioPlayer.playing) {
        if (_currTimeNum == [self.cc.timeArray count] - 2) {
            time = [[self.cc.timeArray objectAtIndex:++_currTimeNum] doubleValue];
            [_audioPlayer setCurrentTime:time];
            
        } else if (_currTimeNum < [self.cc.timeArray count] - 1) {
            time = [[self.cc.timeArray objectAtIndex:_currTimeNum + 1] doubleValue];
            [_audioPlayer setCurrentTime:time];
        }
    } else {
        
        if (_currTimeNum < [self.cc.timeArray count] - 1) {
            _currTimeNum++;
            _isUpdateLock = NO;
        }
    }
}

- (IBAction)speedBtnPressed:(id)sender {
    
//    if (![UserSetting isPurchasedVIPMode]) {
//        [self.delegate ZZAudioPushToVIPPage];
//        return;
//    }
    
    if (self.speedBtn.tag == RATE_NORMAL_SPPED) {
        self.speedBtn.tag = RATE_SLOW_SPEED;
        self.audioPlayer.rate = 0.7f;
    } else if (self.speedBtn.tag == RATE_SLOW_SPEED) {
        self.speedBtn.tag = RATE_FAST_SPEED;
        self.audioPlayer.rate = 1.3f;
    } else {
        self.speedBtn.tag = RATE_NORMAL_SPPED;
        self.audioPlayer.rate = 1.0f;
    }
    
    [self checkRateBtnState];
    
}

- (IBAction)sliderChanged:(id)sender {
    UISlider *slider = sender;
    //	Fast skip the music when user scroll the UISlider
    [_audioPlayer setCurrentTime:slider.value];
    _isUpdateLock = YES;
}

- (void)setZZAudioPlayerPause {
    
    if (_audioPlayer.playing) {
        [_audioPlayer pause];
        //更换播放按钮图标
        [_playBtn setImage:_playImg forState:UIControlStateNormal];
        [_playBtn setImage:_playHLImg forState:UIControlStateHighlighted];
        
    }
}

- (void)checkRateBtnState {
    if (self.speedBtn.tag == RATE_NORMAL_SPPED) {
        [self.speedBtn setImage:_normalSpeedImg forState:UIControlStateNormal];
        [self.speedBtn setImage:_normalSpeedHLImg forState:UIControlStateHighlighted];
    } else if (self.speedBtn.tag == RATE_SLOW_SPEED) {
        [self.speedBtn setImage:_slowSpeedImg forState:UIControlStateNormal];
        [self.speedBtn setImage:_slowSpeedHLImg forState:UIControlStateHighlighted];
    } else {
        [self.speedBtn setImage:_fastSpeedImg forState:UIControlStateNormal];
        [self.speedBtn setImage:_fastSpeedHLImg forState:UIControlStateHighlighted];
    }
}

- (void)recheckRateBtnState {
    if (self.speedBtn.tag == RATE_NORMAL_SPPED) {
        [self.audioPlayer setRate:1.0f];
    } else if (self.speedBtn.tag == RATE_SLOW_SPEED) {
        [self.audioPlayer setRate:0.7f];
    } else {
        [self.audioPlayer setRate:1.3f];
    }
}

- (void)playSoundWithAudioName:(NSString *)audioName isFree:(BOOL)isFree timeArray:(NSMutableArray *)timingArray lastTimePoint:(NSTimeInterval)playTime  {
    
    _currTimeNum = self.lastPageNum;
    [self.pageLabel setText:[NSString stringWithFormat:@"%d/%d", _currTimeNum + 1, [timingArray count]]];
    
    _lastTime = -1.0;
    
    //如果上一个音频没播放完，先停止
    if (_audioPlayer) {
        [_audioPlayer stop];
        [_audioPlayer setDelegate:nil];
        [_audioPlayer release], _audioPlayer = nil;
    }
    
    
    NSString *audioPath = [[ZZAcquirePath getCourseDocDirectoryWithPackId:self.packId titleId:self.titleId] stringByAppendingPathComponent:audioName];
    
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
    
    [self.timeLabel setText:[NSString stringWithFormat:@"%@/%@", [NSString playTimeToSwitchAdvance:playTime], [NSString playTimeToSwitchAdvance:_audioPlayer.duration]]];
}

// Update the slider about the music time
- (void)updateSlider {
    
	//设置slider初值
    //    _audioSlider.maximumValue = _audioPlayer.duration;
	
    
    NSTimeInterval currTime = (int)_audioPlayer.currentTime;
    self.lastPlayTime = _audioPlayer.currentTime;
    [self.timeLabel setText:[NSString stringWithFormat:@"%@/%@", [NSString playTimeToSwitchAdvance:currTime], [NSString playTimeToSwitchAdvance:_audioPlayer.duration]]];
    
    if (_audioPlayer.playing) {
        
        _audioSlider.value = _audioPlayer.currentTime;
        
        _isUpdateLock = YES;
    } else {
        if (!_isUpdateLock) {
            currTime = [[self.cc.timeArray objectAtIndex:_currTimeNum] doubleValue];
            _audioSlider.value = currTime;
            _audioPlayer.currentTime = currTime;
        }
    }

    int count = [self.cc.timeArray count];
    for (int i = 0; i < count; i++) {
        NSTimeInterval thisTime = [[self.cc.timeArray objectAtIndex:i] doubleValue];
        NSTimeInterval nextTime = 0;
        int next;
        if (i == count - 1) {

            if (currTime >= thisTime && _lastTime != thisTime) {
                //                NSLog(@"最后一句~~~~~~~");
                _currTimeNum = i;
                [self ZZAudioTimePointChangedByNum:_currTimeNum];
                
                _lastTime = thisTime;
            }
        } else {
            next = i + 1;
            nextTime = [[self.cc.timeArray objectAtIndex:next] doubleValue];
            if (currTime >= thisTime && currTime < nextTime && _lastTime != thisTime) {
                _currTimeNum = i;
                [self ZZAudioTimePointChangedByNum:_currTimeNum];
                
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

#pragma mark - ZZAudioPlayer delegate
- (void)ZZAudioTimePointChangedByNum:(int)senNum {
    self.lastPageNum = senNum;
    
    NSString *imgName = [NSString stringWithFormat:@"%@.jpg", [self.cc.picNameArray objectAtIndex:senNum]];
    NSString *picPath = [[ZZAcquirePath getCourseDocDirectoryWithPackId:self.packId titleId:self.titleId] stringByAppendingPathComponent:imgName];
    
    [self.picImgView setImage:[UIImage imageWithContentsOfFile:picPath]];
    
    
    [self.pageLabel setText:[NSString stringWithFormat:@"%d/%d", senNum + 1, [self.cc.timeArray count]]];
    
    
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
    
    self.lastPageNum = 0;
    self.lastPlayTime = 0;
    //    [self fireSliderTimer:NO];
    
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
//    self.isEnterBackground = YES;
    
    //把播放时间和播放页数记录到数据库中
    [self updateLastTimePointToPackInfo];
    
    [self becomeFirstResponder];
    
    //未开启后台播放的话，进入后台之后暂停播放
    if (![UserSetting isBackgroundPlayEnabled]) {
        [self setZZAudioPlayerPause];
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
//    self.isEnterBackground = NO;
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
                [self nextBtnPressed:nil];
                break;
            }
                
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                //todo play previous song
                [self prevBtnPressed:nil];
                break;
            }
            default:
                break;
        }
    }
}
@end
