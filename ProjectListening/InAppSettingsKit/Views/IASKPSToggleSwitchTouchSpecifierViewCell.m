//
//  IASKPSToggleSwitchTouchSpecifierViewCell.m
//  ToeflListening
//
//  Created by zhaozilong on 13-5-9.
//
//

#import "IASKPSToggleSwitchTouchSpecifierViewCell.h"

@implementation IASKPSToggleSwitchTouchSpecifierViewCell

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

- (void)dealloc {
    [_label release];
    [_timeLabel release];
    [_toggle release];
    [super dealloc];
}
@end
