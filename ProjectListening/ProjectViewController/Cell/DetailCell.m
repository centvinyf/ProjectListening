//
//  DetailCell.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-18.
//
//

#import "DetailCell.h"

@implementation DetailCell

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

- (void)setDetailInfoWithTIC:(TitleInfoClass *)TIC {
    [_detailLabel setText:[NSString stringWithFormat:@"%@", TIC.titleName]];
    
    NSString *info = nil;
//    if (TIC.rightNum == 0) {
//        info = [NSString stringWithFormat:@"%d道问题-时长%@", TIC.quesNum, TIC.soundTime];
//    } else {
//        info = [NSString stringWithFormat:@"%d道问题-答对%d题-时长%@", TIC.quesNum, TIC.rightNum, TIC.soundTime];
//    }
    NSString *rate = NSLocalizedString(@"CORRECT_RATE", @"正确比例:");
    NSString *question = NSLocalizedString(@"QUESTION", @"题");
    NSString *time = NSLocalizedString(@"TIME", @"时长");
    info = [NSString stringWithFormat:@"%@%d/%d%@-%@%@", rate, TIC.rightNum, TIC.quesNum, question, time, TIC.soundTime];
    
    [_infoLabel setText:info];
}

- (void)setDetailInfoWithTitleName:(NSString *)titleName quesNum:(int)quesNum soundTime:(int)soundTime rightNum:(int)rightNum {
    [_detailLabel setText:[NSString stringWithFormat:@"%@", titleName]];
    
    NSString *info = nil;
//    if (rightNum == 0) {
//        info = [NSString stringWithFormat:@"%d道问题-时长%@", quesNum, [NSString hmsToSwitchAdvance:soundTime]];
//    } else {
//        info = [NSString stringWithFormat:@"%d道问题-答对%d题-时长%@", quesNum, rightNum, [NSString hmsToSwitchAdvance:soundTime]];
//    }
    NSString *rate = NSLocalizedString(@"CORRECT_RATE", @"正确比例:");
    NSString *question = NSLocalizedString(@"QUESTION", @"题");
    NSString *time = NSLocalizedString(@"TIME", @"时长");
    info = [NSString stringWithFormat:@"%@%d/%d%@-%@%@", rate, rightNum, quesNum, question, time, [NSString hmsToSwitchAdvance:soundTime]];
    [_infoLabel setText:info];
}

- (void)setDetailInfoBy:(NSMutableDictionary *)detailDic {
    NSString *titleName = [detailDic objectForKey:@"titleName"];
    int quesNum = [[detailDic objectForKey:@"quesNum"] intValue];
    int soundTime = [[detailDic objectForKey:@"soundTime"] intValue];
    int rightNum = [[detailDic objectForKey:@"rightNum"] intValue];
    
    [_detailLabel setText:[NSString stringWithFormat:@"%@", titleName]];
    
    NSString *info = nil;
//    if (rightNum == 0) {
//        info = [NSString stringWithFormat:@"%d道问题-时长%@", quesNum, [NSString hmsToSwitchAdvance:soundTime]];
//    } else {
//        info = [NSString stringWithFormat:@"%d道问题-答对%d题-时长%@", quesNum, rightNum, [NSString hmsToSwitchAdvance:soundTime]];
//    }
    NSString *rate = NSLocalizedString(@"CORRECT_RATE", @"正确比例:");
    NSString *question = NSLocalizedString(@"QUESTION", @"题");
    NSString *time = NSLocalizedString(@"TIME", @"时长");
    info = [NSString stringWithFormat:@"%@%d/%d%@-%@%@", rate, rightNum, quesNum, question, time, [NSString hmsToSwitchAdvance:soundTime]];
    [_infoLabel setText:info];
    
}

- (void)dealloc {
    [_detailLabel release];
    [_infoLabel release];
    [_conPointImg release];
    [super dealloc];
}
@end
