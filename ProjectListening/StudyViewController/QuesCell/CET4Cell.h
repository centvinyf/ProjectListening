//
//  CET4Cell.h
//  JLPT1Listening
//
//  Created by Sylar on 14-2-18.
//
//

#import <Foundation/Foundation.h>
#import "QuesCell.h"


@interface CET4Cell : QuesCell
{
    int NumberOfKeyWords;//记录Keyword数量，如果答案是单词或者短语则为0
    int QuesIndex;//记录cell的编号
    int NumberOfCorrectKeyWords;//记录用户正确Keywords数量
    int PartType; //记录parttype
    
    NSString *KeyWords ;//记录所有的Keyword，用++分割
    NSString *QuestionText;//问题的文本
    NSString *HelperText;//Helper显示的内容
    NSString *UserAnswer;//记录用户的答案
    NSString *CorrectAnswer;//记录标准答案
    
    NSMutableArray *imgArray;//存放播放按钮图片
    NSMutableArray *answerArray;//存放正确TAG
    NSMutableArray *selectArray;//0为错误9为正确
    
    CGFloat textHeight;//记录cell的高度
    CGFloat quesHeight;//记录questiontextview结束的高度
    CGFloat enterHeight;//记录输入框结束的高度
    
    BOOL isPlaying;//记录播放器状态，0为停止
    
    
}

@property (assign) int NumberOfKeyWords;
@property (assign) int QuesIndex;
@property (assign) int NumberOfCorrectKeyWords;
@property (assign) int PartType;



@property (retain, nonatomic) NSString * KeyWords;
@property (retain, nonatomic) NSString * QuestionText;
@property (retain, nonatomic) NSString * HelperText;
@property (retain, nonatomic) NSString * UserAnswer;
@property (retain, nonatomic) NSString * CorrectAnswer;

@property (nonatomic, retain) NSArray *imgArray;
@property (retain, nonatomic) NSMutableArray *answerArray;
@property (retain, nonatomic) NSMutableArray *selectArray;

@property (assign) CGFloat textHeight;
@property (assign) CGFloat quesHeight;
@property (assign) CGFloat enterHeight;

@property (assign) BOOL isPlaying;


@property (retain, nonatomic) StudyViewController * ParentVC ;

@property (retain, nonatomic) IBOutlet ZZTextView *QuestionTextView;
@property (retain, nonatomic) IBOutlet ZZTextView *HelperTextView;
@property (retain, nonatomic) IBOutlet UITextField *AnswerField;

@property (retain, nonatomic) IBOutlet UIButton *QuesPlayButton;
@property (retain, nonatomic) IBOutlet UIButton *DoneButton;



- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)addWordToFavorite:(id)sender;
- (void)addQuesPlayBtnToCell;
- (void)stopQuestionButtonAimation ;
- (void)startQuestionButtonAimation;
- (void)isQuesAudioPlaying:(BOOL)IsPlaying;

-(void)SetHelperTextView:(NSString *)HelperScript numOfCorrectKey:(int)numOfCorrectKey;
-(void)setDoneButtonHeight;
-(void)setQuesPlayButtonHeight;
-(void)setEnterFieldHeight;
-(void)setQuestionTextView: (NSString *)QuestionScript quesIndex:(int)quesIndex;
-(void) setAnswerFieldBytext : (NSString *)text;
-(void)setHelperTextBytext : (NSString *)text;

-(void)setKeyWords:(NSString *)KeyWords;
-(void)setCorrectAnswer:(NSString *)CorrectAnswer;
-(void)setQuestionText:(NSString *)QuestionText;
-(void)setHelperText:(NSString *)HelperText;
-(void)setUserAnswer:(NSString *)UserAnswer;



- (IBAction)QuesPlayButtonPressed:(id)sender;
- (IBAction)ConfirmButtonPressed:(id)sender;

@end
