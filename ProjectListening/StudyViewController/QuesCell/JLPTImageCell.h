//
//  JLPTImageCell.h
//  ProjectListening
//
//  Created by zhaozilong on 13-5-4.
//
//

#import "ParentCell.h"

#define JLPT_IMG_HEIGHT (IS_IPAD ? 430.0f : 199.0f)

@interface JLPTImageCell : ParentCell
@property (retain, nonatomic) IBOutlet UIImageView *ImgView1;
@property (retain, nonatomic) IBOutlet UIImageView *ImgView2;
@property (retain, nonatomic) IBOutlet UIImageView *ImgView3;
@property (retain, nonatomic) IBOutlet UIImageView *ImgView4;
@property (retain, nonatomic) IBOutlet ZZTextView *ansTextView;

//@property (nonatomic, retain) NSString *ansText;

- (void)setImageWithJLPTTypeTag:(PartTypeTags)jlptType imageArray:(NSArray *)imgArray packName:(NSString *)packName textHeight:(CGFloat)textHeight ansText:(NSString *)ansText;

- (void)setImageBorderByJLPTTag:(PartTypeTags)jlptType;

@end
