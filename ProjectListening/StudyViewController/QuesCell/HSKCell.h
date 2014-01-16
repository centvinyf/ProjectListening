//
//  HSKCell.h
//  HSK6ListeningFREE
//
//  Created by iyuba on 13-8-3.
//
//

#import "ParentCell.h"

#define HSK_IMG_HEIGHT (IS_IPAD ? 430.0f : 199.0f)

@interface HSKCell : ParentCell
@property (retain, nonatomic) IBOutlet UIImageView *imgView;
@property (retain, nonatomic) IBOutlet ZZTextView *answerTV;

- (void)setImageBorderByHSKTag:(PartTypeTags)partType;
- (void)setQuestionWithHSKTypeTag:(PartTypeTags)HSKType imageName:(NSString *)imgName packName:(NSString *)packName textHeight:(CGFloat)textHeight ansText:(NSString *)ansText;
- (void)setAnsTextViewLayoutWithText:(NSString *)ansText;
- (CGFloat)heightForAnswerButton;


@end
