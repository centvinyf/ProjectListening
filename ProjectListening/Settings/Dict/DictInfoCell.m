//
//  DictInfoCell.m
//  JLPT1ListeningFree
//
//  Created by iyuba on 13-7-26.
//
//

#import "DictInfoCell.h"

@implementation DictInfoCell

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

- (void)setDictNameWithDictName:(NSString *)dictName {
    [self.dictNameLabel setText:dictName];
}

- (void)dealloc {
    [_dictNameLabel release];
    [super dealloc];
}
@end
