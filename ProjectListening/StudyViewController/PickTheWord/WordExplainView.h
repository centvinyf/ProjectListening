//
//  WordExplainView.h
//  CET4Lite
//
//  Created by Seven Lee on 12-3-16.
//  Copyright (c) 2012年 iyuba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Word.h"
//#import "SevenLabel.h"
//#import "database.h"
#import "Reachability.h"
#import <AVFoundation/AVFoundation.h>
//#import "ZZConfig.h"
#import "StudyViewController.h"


@class StudyViewController;
typedef enum {
    //state = 1为显示词义状态，state = 2 为等待状态， state = 3 为失败状态
    SVWordViewStateDis = 1,
    SVWordViewStateWaiting = 2,
    SVWordViewStateDisFail = 3,
    SVWordViewStateNoProunce = 4,
}SVWordViewState;

//@class WordExplainView;
//@protocol WordExplainViewDelegate <NSObject>
//
//- (void)WordExplainView:(WordExplainView *)wordView addWord:(Word *)thisWord;
//- (void)WordExplainView:(WordExplainView *)wordView playWordSound:(Word *)thisWord;
//
//@end
@interface WordExplainView : UIView{
    IBOutlet UILabel * wordLabel;
    IBOutlet UILabel * defLabel;
    IBOutlet UILabel * WrongLabel;
    IBOutlet UIButton * AddWordButton;
    IBOutlet UIButton * ProunceButton;
    Word * myWord;
    IBOutlet UILabel * WaitingLabel;
    IBOutlet UIActivityIndicatorView * activeView;
//    id<WordExplainViewDelegate> delegate;
//    NSTimer * displayTimer;
    SVWordViewState ShowState;
}
@property (nonatomic, strong) IBOutlet UILabel * wordLabel;
@property (nonatomic, strong) IBOutlet UILabel * defLabel;
@property (nonatomic, strong) IBOutlet UILabel * WaitingLabel;
@property (nonatomic, strong) IBOutlet UILabel * WrongLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * activeView;
@property (nonatomic, strong) IBOutlet UIButton * AddWordButton;
@property (nonatomic, strong) IBOutlet UIButton * ProunceButton;
@property (nonatomic, strong) Word * myWord;
//@property (nonatomic, strong) id<WordExplainViewDelegate> delegate;
@property (nonatomic, assign) StudyViewController *studyVC;

+ (id) ViewWithState:(SVWordViewState)state errMSG:(NSString *)err word:(Word *)word;
+ (void) RemoveView;
- (void) show;
- (id) initWithState:(SVWordViewState)state errMSG:(NSString *)err word:(Word *)word;
- (void) displayThisWord:(Word*)word;
- (IBAction)AddToWords:(id)sender;
- (IBAction)PlayPronciation:(id)sender;
- (IBAction)closeBtnPressed:(id)sender;

- (void) hide:(NSTimer *)timer;


//更新显示状态，state = 1为显示词义状态，state = 2 为等待状态， state = 3 为失败状态
- (void)updateState:(SVWordViewState)state errMSG:(NSString *)err;
//- (void) showWithState:(SVWordViewState)state errMSG:(NSString *)err;
@end
