//
//  PartCell.m
//  ToeflListening
//
//  Created by zhaozilong on 13-6-1.
//
//

#import "PartCell.h"

@implementation PartCell

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

- (void)setLabelInfoWithQuesNum:(int)QuesNum rightNum:(int)rightNum partType:(PartTypeTags)partType {
    
    NSString *info = [NSString stringWithFormat:@"%@", [TestType partNameWithPartType:partType]];
    [_partLabel setText:info];
    
    NSString *detail = nil;
    
    NSString *rate = NSLocalizedString(@"CORRECT_RATE", @"正确比例:");
    NSString *question = NSLocalizedString(@"QUESTION", @"题");
    detail = [NSString stringWithFormat:@"%@%d/%d%@", rate, rightNum, QuesNum, question];
    [_detailLabel setText:detail];
}

- (void)dealloc {
    [_partLabel release];
    [_detailLabel release];
    [super dealloc];
}
@end
