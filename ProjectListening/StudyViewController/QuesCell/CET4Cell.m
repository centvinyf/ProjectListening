//
//  CET4Cell.m
//  JLPT1Listening
//
//  Created by Sylar on 14-2-10.
//
//

#import "CET4Cell.h"


@implementation CET4Cell

- (void)dealloc {
    [_AudioPlayButton release];
    [_QuestionDisplayTextView release];
    [_AnswerField release];
    [_ConfirmButton release];
    [super dealloc];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setQuestionTextViewBy:(NSString *)str quesIndex:(int)quesIndex {
    
    CGFloat height = [ZZPublicClass getTVHeightByStr:str constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
    CGRect frame = _QuestionDisplayTextView.frame;
    frame.size.height = height;
    frame.origin.y = 0;
    _QuestionDisplayTextView.frame = frame;
    
    [_QuestionDisplayTextView setText:str];
    [_QuestionDisplayTextView setContentOffset:CGPointMake(0, 5)];
    
    //设置问题题号
    self.quesIndex = quesIndex ;
}

- (void)addWordToFavorite:(id)sender {
    NSLog(@"%@", [_QuestionDisplayTextView.text substringWithRange:_QuestionDisplayTextView.selectedRange]);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (IBAction)ConfirmButtonPressed:(UIButton *)sender {
}
@end
