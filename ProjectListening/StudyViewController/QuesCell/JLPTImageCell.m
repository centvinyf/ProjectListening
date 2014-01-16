//
//  JLPTImageCell.m
//  ProjectListening
//
//  Created by zhaozilong on 13-5-4.
//
//

#import "JLPTImageCell.h"

@implementation JLPTImageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImageBorderByJLPTTag:(PartTypeTags)jlptType {
    
    CGFloat r = 8.0f;
    CGFloat bw = 0.2f;
    switch (jlptType) {
        case PartType301:
            [self.ImgView1.layer setMasksToBounds:YES];
            //设置矩形四个圆角半径
            [self.ImgView1.layer setCornerRadius:r];
            //边框宽度
            [self.ImgView1.layer setBorderWidth:bw];
            break;
            
        case PartType302:
        case PartType303:
            [self.ImgView1.layer setMasksToBounds:YES];
            [self.ImgView2.layer setMasksToBounds:YES];
            [self.ImgView3.layer setMasksToBounds:YES];
            [self.ImgView4.layer setMasksToBounds:YES];
            //设置矩形四个圆角半径
            [self.ImgView1.layer setCornerRadius:r];
            [self.ImgView2.layer setCornerRadius:r];
            [self.ImgView3.layer setCornerRadius:r];
            [self.ImgView4.layer setCornerRadius:r];
            //边框宽度
            [self.ImgView1.layer setBorderWidth:bw];
            [self.ImgView2.layer setBorderWidth:bw];
            [self.ImgView3.layer setBorderWidth:bw];
            [self.ImgView4.layer setBorderWidth:bw];
            break;
            
        case PartType304:
        case PartType305:
        case PartType306:
        case PartType307:
        case PartType308:
        case PartType309:
        case PartType310:
            
            break;
            
        default:
            break;
    }
}

- (void)setImageWithJLPTTypeTag:(PartTypeTags)jlptType imageArray:(NSArray *)imgArray packName:(NSString *)packName textHeight:(CGFloat)textHeight ansText:(NSString *)ansText {
    
    self.partType = jlptType;
    packName = [packName stringByReplacingOccurrencesOfString:@"年" withString:@""];
    packName = [packName stringByReplacingOccurrencesOfString:@"月" withString:@""];
    NSString *imgName = nil;
    switch (jlptType) {
        case PartType301:
            imgName = [NSString stringWithFormat:@"%@_%@", packName, [imgArray objectAtIndex:0]];
            imgName = [imgName stringByReplacingOccurrencesOfString:@"A" withString:@""];
//            NSLog(@"%@", imgName);
            [self.ImgView1 setImage:[UIImage imageWithContentsOfFile:[ZZAcquirePath getBundleDirectoryWithFileName:imgName]]];
            break;
            
        case PartType302:
        case PartType303:
            [self.ImgView1 setImage:[UIImage imageWithContentsOfFile:[ZZAcquirePath getBundleDirectoryWithFileName:[NSString stringWithFormat:@"%@_%@", packName, [imgArray objectAtIndex:0]]]]];
            [self.ImgView2 setImage:[UIImage imageWithContentsOfFile:[ZZAcquirePath getBundleDirectoryWithFileName:[NSString stringWithFormat:@"%@_%@", packName, [imgArray objectAtIndex:1]]]]];
            [self.ImgView3 setImage:[UIImage imageWithContentsOfFile:[ZZAcquirePath getBundleDirectoryWithFileName:[NSString stringWithFormat:@"%@_%@", packName, [imgArray objectAtIndex:2]]]]];
            [self.ImgView4 setImage:[UIImage imageWithContentsOfFile:[ZZAcquirePath getBundleDirectoryWithFileName:[NSString stringWithFormat:@"%@_%@", packName, [imgArray objectAtIndex:3]]]]];
            break;
            
        case PartType304:
        case PartType305:
        case PartType306:
        case PartType307:
        case PartType308:
        case PartType309:
        case PartType310:
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
    CGFloat height = JLPT_IMG_HEIGHT;
    switch (self.partType) {
        case PartType301:
            height = JLPT_IMG_HEIGHT;
            break;
            
        case PartType302:
        case PartType303:
            height = JLPT_IMG_HEIGHT;
            break;
            
        case PartType304:
        case PartType305:
        case PartType306:
        case PartType307:
        case PartType308:
        case PartType309:
        case PartType310:
            height = self.textHeight;
            break;
            
        default:
            break;
    }
    
    return height;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_ImgView1 release];
    [_ImgView2 release];
    [_ImgView3 release];
    [_ImgView4 release];
    [_ansTextView release];
    [super dealloc];
}
@end
