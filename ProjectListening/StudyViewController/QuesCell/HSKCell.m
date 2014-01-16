//
//  HSKCell.m
//  HSK6ListeningFREE
//
//  Created by iyuba on 13-8-3.
//
//

//判断题
//PartType6011
//PartType6021
//PartType6032
//PartType6041

#import "HSKCell.h"

@implementation HSKCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImageBorderByHSKTag:(PartTypeTags)partType {
    
    CGFloat r = 8.0f;
    CGFloat bw = 0.2f;
    switch (partType) {
        case PartType6011:
        case PartType6012:
        case PartType6013:
        case PartType6021:
        case PartType6022:
        case PartType6031:
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

- (void)setQuestionWithHSKTypeTag:(PartTypeTags)HSKType imageName:(NSString *)imgName packName:(NSString *)packName textHeight:(CGFloat)textHeight ansText:(NSString *)ansText {
    
    self.partType = HSKType;
    switch (self.partType) {
        case PartType6011:
        case PartType6012:
        case PartType6013:
        case PartType6021:
        case PartType6022:
        case PartType6031:
            [self.imgView setImage:[UIImage imageWithContentsOfFile:[ZZAcquirePath getBundleDirectoryWithFileName:imgName]]];
            break;
        case PartType6032:
        case PartType6041:
//            self.textHeight = textHeight;
//            [self setAnsTextViewLayoutWithText:quesText];
//            break;
        case PartType6014:
        case PartType6023:
        case PartType6024:
        case PartType6033:
        case PartType6034:
        case PartType6042:
        case PartType6043:
        case PartType6051:
        case PartType6052:
        case PartType6061:
        case PartType6062:
        case PartType6063:
            //选项TV
            self.textHeight = textHeight;
            [self setAnsTextViewLayoutWithText:ansText];
            break;
            
        default:
            break;
    }
}

- (void)setAnsTextViewLayoutWithText:(NSString *)ansText {
    CGRect aFrame = self.answerTV.frame;
    aFrame.size.height = self.textHeight;
    self.answerTV.frame = aFrame;
    [self.answerTV setText:ansText];
    [self.answerTV setContentOffset:CGPointMake(0, 5)];
}

- (CGFloat)heightForAnswerButton {
    CGFloat height = HSK_IMG_HEIGHT;
    switch (self.partType) {
        case PartType6011:
        case PartType6012:
        case PartType6013:
        case PartType6021:
        case PartType6022:
        case PartType6031:
            height = HSK_IMG_HEIGHT;
            break;
            
        case PartType6014:
        case PartType6023:
        case PartType6024:
        case PartType6032:
        case PartType6033:
        case PartType6034:
        case PartType6041:
        case PartType6042:
        case PartType6043:
        case PartType6051:
        case PartType6052:
        case PartType6061:
        case PartType6062:
        case PartType6063:
            height = self.textHeight;
            break;
            
        default:
            break;
    }
    
    return height;
}

- (void)dealloc {
    [_imgView release];
    [_answerTV release];
    [super dealloc];
}
@end
