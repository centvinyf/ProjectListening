//
//  CourseViewController.h
//  ToeicListeningFREE
//
//  Created by 赵子龙 on 13-12-19.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>
#import "UserSetting.h"

//#import "CourseDetailClass.h"

@interface CourseViewController : UIViewController <AVAudioPlayerDelegate>
@property (retain, nonatomic) IBOutlet UIView *CPView;
@property (retain, nonatomic) IBOutlet UIButton *homeBtn;
@property (retain, nonatomic) IBOutlet UIButton *prevBtn;
@property (retain, nonatomic) IBOutlet UIButton *playBtn;
@property (retain, nonatomic) IBOutlet UIButton *nextBtn;
@property (retain, nonatomic) IBOutlet UIButton *speedBtn;
@property (retain, nonatomic) IBOutlet UISlider *audioSlider;
@property (retain, nonatomic) IBOutlet UIImageView *picImgView;
@property (retain, nonatomic) IBOutlet UILabel *pageLabel;

@property (retain, nonatomic) IBOutlet UILabel *timeLabel;

//@property (nonatomic, retain) NSMutableArray *timingArray;

- (IBAction)backToTop:(id)sender;
- (IBAction)prevBtnPressed:(id)sender;
- (IBAction)playBtnPressed:(id)sender;
- (IBAction)nextBtnPressed:(id)sender;
- (IBAction)speedBtnPressed:(id)sender;
- (IBAction)sliderChanged:(id)sender;

- (void)fireSliderTimer:(BOOL)isFire;
- (void)initializeAudioPlayer;
- (void)setZZAudioPlayerPause;
- (BOOL)isZZAudioPlaying;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil packId:(int)packId titleId:(int)titleId audioName:(NSString *)audioName lastPlayTime:(NSTimeInterval)lastPlayTime lastPageNum:(int)lastPageNum;


@end
