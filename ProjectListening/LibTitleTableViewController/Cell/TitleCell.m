//
//  TitleCell.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-15.
//
//

#import "TitleCell.h"

@implementation TitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLabelInfoTitleName:(NSString *)titleName quesNum:(int)quesNum rightNum:(int)rightNum soundTime:(NSString *)soundTime {
    
    NSString *info = [NSString stringWithFormat:@"%@", titleName];
    [_titleInfoLabel setText:info];
    
    NSString *detail = nil;
//    if (rightNum == 0) {
//        //本地化一下子
//        detail = [NSString stringWithFormat:@"%d道问题-时长:%@", quesNum, soundTime];
//    } else {
//        detail = [NSString stringWithFormat:@"%d道问题-答对%d题-时长:%@", quesNum, rightNum, soundTime];
//    }
    NSString *rate = NSLocalizedString(@"CORRECT_RATE", @"正确比例:");
    NSString *question = NSLocalizedString(@"QUESTION", @"题");
    NSString *time = NSLocalizedString(@"TIME", @"时长:");
    detail = [NSString stringWithFormat:@"%@%d/%d%@-%@%@", rate, rightNum, quesNum, question, time, soundTime];
    [_detailLabel setText:detail];
}

- (void)dealloc {
    [_titleInfoLabel release];
    [_detailLabel release];
    [super dealloc];
}
@end
