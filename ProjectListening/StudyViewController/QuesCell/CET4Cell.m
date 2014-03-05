//
//  CET4Cell.m
//  JLPT1Listening
//
//  Created by Sylar on 14-2-18.
//
//

#import "CET4Cell.h"



@implementation CET4Cell




-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //Initialization code
        _NumberOfCorrectKeyWords = 0;
        _NumberOfKeyWords = 0;
    }
    return self;

}

//按下Done键关闭键盘

- (IBAction)TextFieldDoneEditing:(id)sender {
    if ([sender isFirstResponder]) {
          [sender resignFirstResponder];
    }else{
        [sender becomeFirstResponder];
        [sender resignFirstResponder];
    }
  
}


-(void)setQuestionTextView: (NSString *)QuestionScript quesIndex:(int)quesIndex{
    
    CGFloat height = [ZZPublicClass getTVHeightByStr:QuestionScript constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
    CGRect frame = _QuestionTextView.frame;
    frame.size.height = height;
    frame.origin.y = 5;
    _QuestionTextView.frame = frame ;
    
    [_QuestionTextView setText:QuestionScript];
// [_QuestionTextView setContentOffset:CGPointMake(0, 5)];
//    NSLog(@"height:%f",_QuestionTextView.frame.origin.y);
   //保存问题textfield的高度
    _quesHeight = height ;
    //设置问题的题号
    _QuesIndex= quesIndex;
    self.textHeight = height;

}

- (void)addQuesPlayBtnToCell {
    
    
    UIImage * img0 = [UIImage imageNamed:@"quesPlay0.png"];
    UIImage * img1 = [UIImage imageNamed:@"quesPlay1.png"];
    UIImage * img2 = [UIImage imageNamed:@"quesPlay2.png"];
    UIImage * img3 = [UIImage imageNamed:@"quesPlay3.png"];
    _imgArray = [[NSArray alloc ]initWithObjects:img0,img1,img2, img3, nil];
    [_QuesPlayButton setImage:img3 forState:UIControlStateNormal];
    [_QuesPlayButton setImage:img3 forState:UIControlStateHighlighted];
    [_QuesPlayButton setImage:img3 forState:UIControlStateSelected];
    [_QuesPlayButton setImage:[_imgArray objectAtIndex:3] forState:UIControlStateNormal];
    
}

-(void)setEnterFieldHeight{
   
    CGRect frame = _AnswerField.frame;
    frame.origin.y = _quesHeight;
    _AnswerField.frame = frame;
    //CGFloat height = 0;
   CGFloat height = _AnswerField.frame.origin.y+_AnswerField.frame.size.height;
    
    //保存输入框的高度
    _enterHeight = height;
    self.textHeight = _enterHeight;
    
    //预留出解析的可能最大行数
    NSString *helper = @"\n\n\n\n\n";
    CGFloat Plusheight = [ZZPublicClass getTVHeightByStr:helper constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
    self.textHeight +=  Plusheight;

}

-(void) setQuesPlayButtonHeight{

    CGRect frame = _QuesPlayButton.frame;
    frame.origin.y = 5;
    _QuesPlayButton.frame = frame;

}

-(void)setDoneButtonHeight{
    
    
    CGRect frame = _DoneButton.frame;
    frame.origin.y=_quesHeight;
    _DoneButton.frame = frame;
    

}

-(void) SetHelperTextView:(NSString *)HelperScript numOfCorrectKey:(int)numOfCorrectKey{
   
    CGFloat height= [ZZPublicClass getTVHeightByStr:HelperScript constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
    CGRect frame = _HelperTextView.frame;
    frame.size.height = height;
    frame.origin.y = _enterHeight+5 ;
    
    _HelperTextView.frame =frame ;
    [_HelperTextView setText:HelperScript];
    [_HelperTextView setContentOffset:CGPointMake(0, 5)];
    
    self.textHeight = _enterHeight+height;
    
    
}

-(void)setKeyWords:(NSString *)keyWords{
    _KeyWords = keyWords;
}
-(void)setCorrectAnswer:(NSString *)correctAnswer{
    _CorrectAnswer = correctAnswer;

}
-(void)setQuestionText:(NSString *)questionText{

    _QuestionText = questionText;
}
-(void)setHelperText:(NSString *)helperText{
    _HelperText=helperText;
}
-(void)setUserAnswer:(NSString *)userAnswer{
    _UserAnswer = userAnswer;
}


-(void)isQuesAudioPlaying:(BOOL)IsPlaying{
    _isPlaying = IsPlaying;
    if (_isPlaying) {
        [self startQuestionButtonAimation];
    } else {
        [self stopQuestionButtonAimation];
    }

}

/*- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}*/

- (IBAction)QuesPlayButtonPressed:(id)sender {
    [_ParentVC playQuesAudioByQuesIndex:_QuesIndex msgIsFromZZAudioPlayer:NO];
    
    if (_isPlaying) {
        _isPlaying = NO;
    } else {
        _isPlaying = YES;
    }
    [self isQuesAudioPlaying:_isPlaying];
}

-(void) setAnswerFieldBytext : (NSString *)text
{
    _AnswerField.text = text;

}
-(void)setHelperTextBytext : (NSString *)text
{
    _HelperTextView.text = text;
    [_HelperTextView setTextColor:[UIColor colorWithRed:233/255.0 green:86/255.0 blue:86/255.0 alpha:1]];
    CGFloat height= [ZZPublicClass getTVHeightByStr:text constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
    CGRect frame = _HelperTextView.frame;
    frame.size.height = height;
    frame.origin.y = _enterHeight+5 ;
}

- (IBAction)ConfirmButtonPressed:(id)sender {
    
    NSArray *KeyWordsArray = nil;
    _UserAnswer = [NSString stringWithUTF8String:(char *)[_AnswerField.text UTF8String]];
    [_ParentVC updateUserAnswerArrayByQuesIndex:_QuesIndex :_UserAnswer];
    if (_NumberOfKeyWords==0)//如果没有关键词
    {
        if ([_UserAnswer isEqualToString: _CorrectAnswer])//如果完全答对
        {
            NSString *helpertext = NSLocalizedString(@"CONGRATULATIONS", Nil);
            [self SetHelperTextView:helpertext numOfCorrectKey:0];
            _HelperText = helpertext;
            [_ParentVC updateHelperTextArrayByQuesIndex:_QuesIndex :helpertext];
           // 正确颜色
            [_HelperTextView setTextColor:[UIColor colorWithRed:145/255.0 green:192/255.0 blue:77/255.0 alpha:1]];
            
            [_ParentVC updateUserSelectArrayByQuesIndex:_QuesIndex ansBtnIndex:0];
        }else//如果没有答对
        {
        
            NSString *helpertext = NSLocalizedString(@"SORRY_FIGHT", nil);
            [self SetHelperTextView:helpertext numOfCorrectKey:0];
            _HelperText = helpertext;
            [_ParentVC updateHelperTextArrayByQuesIndex:_QuesIndex :helpertext];
            [_HelperTextView setTextColor:[UIColor colorWithRed:233/255.0 green:86/255.0 blue:86/255.0 alpha:1]];
        }
    }else//如果有关键词
    {
        KeyWordsArray = [_KeyWords componentsSeparatedByString:SEPARATE_SYMBOL];
        
        
        for (int i = 0; i<_NumberOfKeyWords; i++) {
             NSRange range = [_UserAnswer rangeOfString:[KeyWordsArray objectAtIndex:i]];
            if (range.length>0)//如果用户的答案中包含关键词
            {
                _NumberOfCorrectKeyWords++;
            }
        }
        
        if (_NumberOfCorrectKeyWords)//如果至少答对了一个关键词
        {
          
            NSString *helpertext1 = NSLocalizedString(@"RIGHTNUMBER", nil);
            NSString *helpertext2 = NSLocalizedString(@"KEY_WORDS_ARE", nil);
            NSString *helpertext = [NSString stringWithFormat:@"%@ %d\n%@\n",helpertext1,_NumberOfCorrectKeyWords,helpertext2];
            for (int i = 0; i<_NumberOfKeyWords; i++) {
                NSString *currentKeyWord = [NSString stringWithFormat:@"%@\n",[KeyWordsArray objectAtIndex:i]];
                helpertext = [helpertext stringByAppendingString:currentKeyWord];
            }
            
            [self SetHelperTextView:helpertext numOfCorrectKey:_NumberOfKeyWords];
            _HelperText = helpertext;
            [_ParentVC updateHelperTextArrayByQuesIndex:_QuesIndex :helpertext];
            [_HelperTextView setTextColor:[UIColor colorWithRed:145/255.0 green:192/255.0 blue:77/255.0 alpha:1]];

        }else//如果一个关键词都没答对
        {
            NSString *helpertext = NSLocalizedString(@"SORRY_FIGHT", nil);
            [self SetHelperTextView:helpertext numOfCorrectKey:0];
            _HelperText = helpertext;
            [_ParentVC updateHelperTextArrayByQuesIndex:_QuesIndex :helpertext];
             [_HelperTextView setTextColor:[UIColor colorWithRed:233/255.0 green:86/255.0 blue:86/255.0 alpha:1]];
        }
        
    }
    self.textHeight +=_HelperTextView.frame.size.height;
    
}


- (void)startQuestionButtonAimation {
    [_QuesPlayButton.imageView setAnimationImages:_imgArray];
    [_QuesPlayButton.imageView setAnimationDuration:1.0f];
    [_QuesPlayButton.imageView setAnimationRepeatCount:-1];
    [_QuesPlayButton.imageView startAnimating];

}

- (void)stopQuestionButtonAimation {
    [_QuesPlayButton.imageView stopAnimating];

}

- (void)addWordToFavorite:(id)sender {
    NSLog(@"%@", [_QuestionTextView.text substringWithRange:_QuestionTextView.selectedRange]);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



- (void)dealloc {
    
    
    [_QuesPlayButton release];
    [_QuestionTextView release];
    [_AnswerField release];
    [_HelperTextView release];
    [_DoneButton release];
    [super dealloc];
}
@end
