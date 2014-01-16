//
//  StudyViewController.h
//  ProjectListening
//
//  Created by ; on 13-3-25.
//
//

#import <UIKit/UIKit.h>
#import "ZZAudioPlayer.h" 
#import "WordExplainView.h"
#import "SevenNavigationBar.h"
#import "GADBannerView.h"

typedef enum {
    EnterTypePlan,
    EnterTypeLibrary,
    EnterTypeFavorite,
    EnterTypeMAX,
} EnterTypeTags;

@class TextView, WordExplainView;

@interface StudyViewController : UIViewController <UITableViewDataSource, UITableViewDataSource, ZZAudioPlayerDelegate, WordDelegate, AVAudioPlayerDelegate, UIScrollViewDelegate, GADBannerViewDelegate>
//@property (retain, nonatomic) IBOutlet TextView *syncView;
@property (retain, nonatomic) IBOutlet UITableView *questionTable;
@property (retain, nonatomic) IBOutlet UITableView *textTable;
@property (assign, nonatomic) IBOutlet ZZAudioPlayer *audioPlayer;
@property (retain, nonatomic) IBOutlet UIImageView *grayLineView;
//@property (retain, nonatomic) IBOutlet UIView *wordView;
@property (retain, nonatomic) AVAudioPlayer *quesAudioPlayer;
@property (retain, nonatomic) IBOutlet SevenNavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) WordExplainView *WordView;

@property (assign) int firstIndex;
@property (assign) int currentIndex;
@property (assign) int lastIndex;

@property (assign) int totalTime;
@property (assign) int YMD;

@property (assign) EnterTypeTags enterType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil articles:(NSMutableArray *)articles currIndex:(int)currIndex totalTime:(int)totalTime ymd:(int)ymd enterTypeTags:(EnterTypeTags)enterType;

- (void)showOrHideTextTable;
- (void)updateUserSelectArrayByQuesIndex:(int)quesIndex ansBtnIndex:(int)selectIndex;
//- (void)updateFavoriteSentencesBySenIndex:(int)senIndex;
- (NSString *)getWordTranslateBy:(NSString *)EnStr;
- (void)catchAWordToShow:(NSString *)word;
- (void)playQuesAudioByQuesIndex:(int)quesIndex msgIsFromZZAudioPlayer:(BOOL)isFromZZAP;

- (void)ZZAudioContinuePlayOrNot;
- (void)hideWordExplainView;

@end
