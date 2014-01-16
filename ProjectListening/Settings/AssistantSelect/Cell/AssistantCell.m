//
//  AssistantCell.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-21.
//
//

#import "AssistantCell.h"

@implementation AssistantCell

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

- (void)setCellWithAIC:(AssInfoClass *)AIC {
    [_assPic setImage:[UIImage imageNamed:AIC.assImgName]];
    [_assInfoLabel setText:AIC.assInfo];
}

- (void)dealloc {
#if COCOS2D_DEBUG
    NSLog(@"AssistantCell dealloc");
#endif
    
    
    [_assPic release];
    [_assInfoLabel release];
    [super dealloc];
}
@end
