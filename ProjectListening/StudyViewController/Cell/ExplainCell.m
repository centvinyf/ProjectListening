//
//  ExplainCell.m
//  ProjectListening
//
//  Created by zhaozilong on 13-5-2.
//
//

#import "ExplainCell.h"

@implementation ExplainCell

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

- (void)setExplainBy:(NSString *)explain {
    CGFloat height = [ZZPublicClass getTVHeightByStr:explain constraintWidth:TEXT_WIDTH_LIMIT isBold:NO];
    
    CGRect frame = _explainTV.frame;
    frame.size.height = height;
    frame.origin.y = 0;
    _explainTV.frame = frame;
    
    [_explainTV setText:explain];
    [_explainTV setContentOffset:CGPointMake(0, (IS_IPAD ? 0 : 5))];
    
}

- (void)dealloc {
    [_explainTV release];
    [super dealloc];
}
@end
