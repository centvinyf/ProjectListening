//
//  CET4Cell.h
//  JLPT1Listening
//
//  Created by Sylar on 14-2-10.
//
//

#import <Foundation/Foundation.h>
#import "QuesCell.h"

@interface CET4Cell : QuesCell



@property  (assign) int quesIndex;

@property (retain, nonatomic) NSMutableArray * CorrectAnswer;
@property (retain, nonatomic) NSMutableArray * KeyWord1;
@property (retain, nonatomic) NSMutableArray * KeyWord2;
@property (retain, nonatomic) NSMutableArray * KeyWord3;
@property (retain, nonatomic) NSMutableArray * UserAnswer;
@property (retain, nonatomic) NSMutableArray * IsAnswerAWord;
@property (retain, nonatomic) IBOutlet UIButton *AudioPlayButton;
@property (retain, nonatomic) IBOutlet UITextView *QuestionDisplayTextView;
@property (retain, nonatomic) IBOutlet UITextField *AnswerField;
@property (retain, nonatomic) IBOutlet UIButton *ConfirmButton;
- (IBAction)ConfirmButtonPressed:(UIButton *)sender;

- (void)setQuesTVBy:(NSString *)str quesIndex:(int)quesIndex;

@end
