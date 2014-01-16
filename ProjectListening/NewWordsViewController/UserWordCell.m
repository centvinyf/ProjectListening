//
//  UserWordCell.m
//  CET4Lite
//
//  Created by Seven Lee on 12-3-21.
//  Copyright (c) 2012年 iyuba. All rights reserved.
//

#import "UserWordCell.h"

@implementation UserWordCell
@synthesize WordLabel;
@synthesize DefLabel;
@synthesize PlaySoundButton;
@synthesize pronLabel;

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

@end
