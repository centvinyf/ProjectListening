//
//  ParentCell.m
//  ProjectListening
//
//  Created by zhaozilong on 13-5-4.
//
//

#import "ParentCell.h"

@implementation ParentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    
    }
    return self;
}

- (CGFloat)heightForAnswerButton {
    return 0.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setAnswerBtnLayoutByNum:(int)btnNum answers:(NSMutableArray *)answerArray selects:(NSMutableArray *)selectArray {
    
    _textHeight = [self heightForAnswerButton];
    
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

- (void)addRightOrWrongBtnToCell {
    UIButton *btn = nil;
    
    for (int i = 0; i < 2; i++) {
        NSString *RightOrWrong = nil;
        if (i % 2 == 0) {
            RightOrWrong = @"√";
        } else {
            RightOrWrong = @"×";
        }
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"ansBtn.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"ansBtn_hl.png"] forState:UIControlStateHighlighted];
        [btn setTitle:RightOrWrong forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont fontWithName:@"Chalkboard SE" size:(IS_IPAD ? 35 : 19)]];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.tag = i + 10;
        [self addSubview:btn];
        [btn addTarget:self action:@selector(answerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
}


- (void)addAnswerBtnToCell:(int)btnNum {
    UIButton *btn = nil;
    
    for (int i = 0; i < btnNum; i++) {
        char abcd;
        if ([TestType isJLPT]) {
            abcd = '1' + i;
        } else {
            abcd = 'A' + i;
        }
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"ansBtn.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"ansBtn_hl.png"] forState:UIControlStateHighlighted];
        [btn setTitle:[NSString stringWithFormat:@"%c", abcd] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont fontWithName:@"Chalkboard SE" size:(IS_IPAD ? 35 : 19)]];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.tag = i + 10;
        [self addSubview:btn];
        [btn addTarget:self action:@selector(answerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)answerBtnPressed:(UIButton *)sender {
    
    [sender setEnabled:NO];
    
    [_parentVC updateUserSelectArrayByQuesIndex:_quesIndex ansBtnIndex:sender.tag - 10];
    
    for (NSNumber *answer in _answerArray) {
        
        [sender setBackgroundImage:[UIImage imageNamed:@"ansBtnWrong.png"] forState:UIControlStateDisabled];
        if ([answer intValue] == sender.tag - 10 + 1) {
            [sender setBackgroundImage:[UIImage imageNamed:@"ansBtnRight.png"] forState:UIControlStateDisabled];
            
            break;
        }
    }
    
}


@end
