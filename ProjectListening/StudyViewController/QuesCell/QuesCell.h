//
//  QuesCell.h
//  ProjectListening
//
//  Created by zhaozilong on 13-3-27.
//
//

#import <UIKit/UIKit.h>
#import "StudyViewController.h"
#import "NSString+ZZString.h"
//#import "DACircularProgressView.h"
#import "ZZTextView.h"

//#define FONT_SIZE 16.0f



@interface QuesCell : UITableViewCell
@property (retain, nonatomic) IBOutlet ZZTextView *quesTV;
@property (retain, nonatomic) IBOutlet ZZTextView *boldQuesTV;
@property (retain, nonatomic) IBOutlet UIButton *quesPlayBtn;

@property (assign, nonatomic) StudyViewController *parentVC;
//@property (retain, nonatomic) NSMutableArray *btnArray;
@property (retain, nonatomic) NSMutableArray *answerArray;
@property (retain, nonatomic) NSMutableArray *selectArray;
@property (assign) int quesIndex;
@property (assign) CGFloat textHeight;
//@property (nonatomic, retain) DACircularProgressView *progressView;

- (IBAction)quesPlayBtnPressed:(id)sender;
//- (void)setQuesTVBy:(NSString *)str quesIndex:(int)quesIndex;
- (void)setQuesTVBy:(NSString *)quesStr answer:(NSString *)answerStr quesIndex:(int)quesIndex;
- (void)setAnswerBtnLayoutByNum:(int)btnNum height:(CGFloat)height answers:(NSMutableArray *)answerArray selects:(NSMutableArray *)selectArray;
- (void)addAnswerBtnToCell:(int)btnNum;
- (void)addQuesPlayBtnToCell;
- (void)isQuesAudioPlaying:(BOOL)isPlaying;

//- (void)setQuesTVAndAnswerTVParentVC;

@end
