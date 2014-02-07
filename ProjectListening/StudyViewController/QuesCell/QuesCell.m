//
//  QuesCell.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-27.
//
//

#import "QuesCell.h"

#define TAG_QUES_TAG 1111
#define TAG_ANSWER_TAG 2222

@interface QuesCell ()
@property (nonatomic, retain) NSArray *imgArray;
@property (assign) BOOL isPlaying;

@end

@implementation QuesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setQuesTVBy:(NSString *)str quesIndex:(int)quesIndex {
    
    CGFloat height = [ZZPublicClass getTVHeightByStr:str constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
    CGRect frame = _quesTV.frame;
    frame.size.height = height;
    frame.origin.y = 0;
    _quesTV.frame = frame;
    
    [_quesTV setText:str];
    [_quesTV setContentOffset:CGPointMake(0, 5)];
    
    //设置问题题号
    _quesIndex = quesIndex;
}

- (void)setQuesTVBy:(NSString *)quesStr answer:(NSString *)answerStr quesIndex:(int)quesIndex {
    //问题TV
    CGFloat qHeight = [ZZPublicClass getTVHeightByStr:quesStr constraintWidth:QUES_WIDTH_LIMIT isBold:YES];
    CGRect qFrame = _boldQuesTV.frame;
    qFrame.size.height = qHeight;
    qFrame.origin.y = 0;
    _boldQuesTV.frame = qFrame;
    [_boldQuesTV setText:quesStr];
    [_boldQuesTV setContentOffset:CGPointMake(0, 5)];
    
    //选项TV
    CGFloat aHeight = [ZZPublicClass getTVHeightByStr:answerStr constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
    CGRect aFrame = _quesTV.frame;
    aFrame.size.height = aHeight;
    aFrame.origin.y = qFrame.size.height;
    _quesTV.frame = aFrame;
    [_quesTV setText:answerStr];
    [_quesTV setContentOffset:CGPointMake(0, 5)];
    
    //设置问题题号
    _quesIndex = quesIndex;
}

- (void)setAnswerBtnLayoutByNum:(int)btnNum height:(CGFloat)height answers:(NSMutableArray *)answerArray selects:(NSMutableArray *)selectArray {
    
    _textHeight = height;
    
    //设置正确答案数组
    _answerArray = answerArray;
    
    //设置用户选项数组
    _selectArray = selectArray;
    
    UIButton *btn = nil;
    for (int i = 0; i < btnNum; i++) {
        btn = (UIButton *)[self viewWithTag:i + 10];
        [btn setEnabled:YES];
        //记录用户选择过的选项
        if ([[_selectArray objectAtIndex:i] boolValue]) {
            [btn setEnabled:NO];
            for (NSNumber *answer in _answerArray) {
                [btn setBackgroundImage:[UIImage imageNamed:@"ansBtnWrong.png"] forState:UIControlStateDisabled];
                if ([answer intValue] == i + 1) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"ansBtnRight.png"] forState:UIControlStateDisabled];
                    break;
                }
            }
        }
        
        //设置btn的位置
        CGFloat x = 0.0f, y = 0.0f;
        CGFloat margin = 0.0f;
        if (btnNum <= 4) {
            margin = (self.frame.size.width - btnNum * CELL_ANSBTN_WIDTH) / (btnNum + 1);
            x = margin * (i + 1) + CELL_ANSBTN_WIDTH * i;
            y = _textHeight + CELL_CONTENT_MARGIN;
        } else {
            margin = (self.frame.size.width - 4 * CELL_ANSBTN_WIDTH) / 5;
            x = margin * ((i % 4) + 1) + CELL_ANSBTN_WIDTH * (i % 4);
            y = _textHeight + margin * (i / 4) + CELL_ANSBTN_HEIGHT * (i / 4) + CELL_CONTENT_MARGIN;
        }
        CGRect frame = CGRectMake(x, y, CELL_ANSBTN_WIDTH, CELL_ANSBTN_HEIGHT);
        [btn setFrame:frame];
    }
}

//- (void)setQuesTVAndAnswerTVParentVC {
//    _quesTV.parentVC = _parentVC;
//    _boldQuesTV.parentVC = _parentVC;
//    
//}

- (void)addQuesPlayBtnToCell {
    
    //Toeic没有题目播放按钮
    if (![TestType isToefl] && ![TestType isCET4]) {
        [self.quesPlayBtn setHidden:YES];
        return;
    }
    
    UIImage * img0 = [UIImage imageNamed:@"quesPlay0.png"];
    UIImage * img1 = [UIImage imageNamed:@"quesPlay1.png"];
    UIImage * img2 = [UIImage imageNamed:@"quesPlay2.png"];
    UIImage * img3 = [UIImage imageNamed:@"quesPlay3.png"];
    _imgArray = [[NSArray alloc ]initWithObjects:img0,img1,img2, img3, nil];
    [_quesPlayBtn setImage:img3 forState:UIControlStateNormal];
    [_quesPlayBtn setImage:img3 forState:UIControlStateHighlighted];
    [_quesPlayBtn setImage:img3 forState:UIControlStateSelected];
//    [_quesPlayBtn setContentMode:UIViewContentModeScaleToFill];
    [_quesPlayBtn setImage:[_imgArray objectAtIndex:3] forState:UIControlStateNormal];
    
}

- (IBAction)quesPlayBtnPressed:(id)sender {
    
    [_parentVC playQuesAudioByQuesIndex:_quesIndex msgIsFromZZAudioPlayer:NO];
    
    if (_isPlaying) {
        _isPlaying = NO;
    } else {
        _isPlaying = YES;
    }
    [self isQuesAudioPlaying:_isPlaying];
    
}

- (void)isQuesAudioPlaying:(BOOL)isPlaying {
    _isPlaying = isPlaying;
    if (_isPlaying) {
        [self startQuestionButtonAimation];
    } else {
        [self stopQuestionButtonAimation];
    }
}

- (void)startQuestionButtonAimation {
    [_quesPlayBtn.imageView setAnimationImages:_imgArray];
    [_quesPlayBtn.imageView setAnimationDuration:1.0f];
    [_quesPlayBtn.imageView setAnimationRepeatCount:-1];
    [_quesPlayBtn.imageView startAnimating];
//    [_quesPlayBtn setContentMode:UIViewContentModeScaleToFill];
}

- (void)stopQuestionButtonAimation {
    [_quesPlayBtn.imageView stopAnimating];
//    [_quesPlayBtn setContentMode:UIViewContentModeScaleToFill];
}


- (void)addAnswerBtnToCell:(int)btnNum {
    UIButton *btn = nil;
    
    for (int i = 0; i < btnNum; i++) {
        char abcd = 'A' + i;
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"ansBtn.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"ansBtn_hl.png"] forState:UIControlStateHighlighted];
        [btn setTitle:[NSString stringWithFormat:@"%c", abcd] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont fontWithName:@"Chalkboard SE" size:(IS_IPAD ? 35 : 19)]];
        btn.tag = i + 10;
        [self addSubview:btn];
        [btn addTarget:self action:@selector(answerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)answerBtnPressed:(UIButton *)sender {
    
    [sender setEnabled:NO];
    
//    NSLog(@"第%d题，我选择了%c", _quesIndex, 'A' + sender.tag - 10);
    [_parentVC updateUserSelectArrayByQuesIndex:_quesIndex ansBtnIndex:sender.tag - 10];
    
    for (NSNumber *answer in _answerArray) {
        
        [sender setBackgroundImage:[UIImage imageNamed:@"ansBtnWrong.png"] forState:UIControlStateDisabled];
        if ([answer intValue] == sender.tag - 10 + 1) {
            [sender setBackgroundImage:[UIImage imageNamed:@"ansBtnRight.png"] forState:UIControlStateDisabled];
            
            break;
        }
    }
    
}

- (void)addWordToFavorite:(id)sender {
    NSLog(@"%@", [_quesTV.text substringWithRange:_quesTV.selectedRange]);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_quesTV release];
//    [_progressView release];
    [_quesPlayBtn release];
    [_boldQuesTV release];
    [super dealloc];
}
@end
