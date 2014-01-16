//
//  ParentCell.h
//  ProjectListening
//
//  Created by zhaozilong on 13-5-4.
//
//

#import <UIKit/UIKit.h>
#import "StudyViewController.h"
#import "ZZTextView.h"

//typedef enum {
//    JLPTTypeBigImg,
//    JLPTTypeFourLine,
//    JLPTTypeFourSquare,
//    JLPTTypeNoImg,
//}JLPTTypeTags;

@interface ParentCell : UITableViewCell

@property (assign, nonatomic) StudyViewController *parentVC;

//@property (retain, nonatomic) NSMutableArray *btnArray;
@property (retain, nonatomic) NSMutableArray *answerArray;
@property (retain, nonatomic) NSMutableArray *selectArray;
@property (assign) PartTypeTags partType;

@property (assign) int quesIndex;
@property (assign) CGFloat textHeight;

- (CGFloat)heightForAnswerButton;

- (void)setAnswerBtnLayoutByNum:(int)btnNum answers:(NSMutableArray *)answerArray selects:(NSMutableArray *)selectArray;
- (void)answerBtnPressed:(UIButton *)sender;

- (void)addAnswerBtnToCell:(int)btnNum;
//判断题的时候用这个方法
- (void)addRightOrWrongBtnToCell;



@end
