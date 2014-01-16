//
//  ProductCell.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-17.
//
//

#import "ProductCell.h"

@implementation ProductCell

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

- (void)setImgViewWithImgName:(NSString *)name {
    [_productImgView setImage:[UIImage imageNamed:name]];
//    [_productImgView setHighlighted:YES];
    [_productImgView setHighlightedImage:[UIImage imageNamed:[name stringByReplacingOccurrencesOfString:@".png" withString:@"_hl.png"]]];
}

- (void)dealloc {
    [_productImgView release];
    [_discountImgView release];
    [super dealloc];
}
@end
