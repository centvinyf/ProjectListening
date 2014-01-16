//
//  ToeicCell.m
//  Toeic2Listening
//
//  Created by zhaozilong on 13-6-5.
//
//

#import "ToeicCell.h"

@implementation ToeicCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImageBorderByToeicTag:(PartTypeTags)partType {
    
    CGFloat r = 8.0f;
    CGFloat bw = 0.2f;
    switch (partType) {
        case PartType401:
            [self.imgView.layer setMasksToBounds:YES];
            //设置矩形四个圆角半径
            [self.imgView.layer setCornerRadius:r];
            //边框宽度
            [self.imgView.layer setBorderWidth:bw];
            break;
            
        default:
            break;
    }
}

- (void)setQuestionWithToeicTypeTag:(PartTypeTags)toeicType imageArray:(NSArray *)imgArray packName:(NSString *)packName textHeight:(CGFloat)textHeight ansText:(NSString *)ansText {
    
    self.partType = toeicType;
    NSString *imgName = nil;
    switch (toeicType) {
        case PartType401:
            imgName = [imgArray objectAtIndex:0];
            [self.imgView setImage:[UIImage imageWithContentsOfFile:[ZZAcquirePath getBundleDirectoryWithFileName:imgName]]];
            break;
        case PartType402:
            //选项TV
            self.textHeight = textHeight;
            [self setAnsTextViewLayoutWithText:ansText];
            break;
            
        default:
            break;
    }
}

- (void)setAnsTextViewLayoutWithText:(NSString *)ansText {
    CGRect aFrame = self.ansTextView.frame;
    aFrame.size.height = self.textHeight;
    self.ansTextView.frame = aFrame;
    [self.ansTextView setText:ansText];
    [self.ansTextView setContentOffset:CGPointMake(0, 5)];
}

- (CGFloat)heightForAnswerButton {
    CGFloat height = TOEIC_IMG_HEIGHT;
    switch (self.partType) {
        case PartType401:
            height = TOEIC_IMG_HEIGHT;
            break;
            
        case PartType402:
            height = self.textHeight;
            break;
            
        default:
            break;
    }
    
    return height;
}


- (void)dealloc {
    [_imgView release];
    [super dealloc];
}
@end
