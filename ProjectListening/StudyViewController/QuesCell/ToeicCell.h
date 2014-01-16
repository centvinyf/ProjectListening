//
//  ToeicCell.h
//  Toeic2Listening
//
//  Created by zhaozilong on 13-6-5.
//
//

#import "ParentCell.h"
//#define TOEIC_IMG_HEIGHT 199.0f
#define TOEIC_IMG_HEIGHT (IS_IPAD ? 430.0f : 199.0f)

@interface ToeicCell : ParentCell
@property (retain, nonatomic) IBOutlet UIImageView *imgView;
@property (retain, nonatomic) IBOutlet ZZTextView *ansTextView;

- (void)setImageBorderByToeicTag:(PartTypeTags)partType;
- (void)setQuestionWithToeicTypeTag:(PartTypeTags)toeicType imageArray:(NSArray *)imgArray packName:(NSString *)packName textHeight:(CGFloat)textHeight ansText:(NSString *)ansText;
- (void)setAnsTextViewLayoutWithText:(NSString *)ansText;
- (CGFloat)heightForAnswerButton;

@end
