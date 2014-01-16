//
//  CourseInfoCell.m
//  JLPT1Listening
//
//  Created by 赵子龙 on 13-12-30.
//
//

#import "CourseInfoCell.h"




@implementation CourseInfoCell

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

- (void)setInfoDic:(NSDictionary *)infoDic index:(int)index {
    [self.titleLabel setText:[infoDic objectForKey:cName]];
    [self.dateLabel setText:[infoDic objectForKey:cDesc]];
    
    NSString *colorName = nil;
    if (index % 5 == 0) {
        colorName = @"CourseGreen.png";
    } else if (index % 5 == 1) {
        colorName = @"CourseBlue.png";
    } else if (index % 5 == 2) {
        colorName = @"CoursePurple.png";
    } else if (index % 5 == 3) {
        colorName = @"CoursePink.png";
    } else {
        colorName = @"CourseOrange.png";
    }
    [self.colorImg setImage:[UIImage imageNamed:colorName]];
    
    NSString *typeName = @"CourseTypeListening.png";
    [self.typeImg setImage:[UIImage imageNamed:typeName]];
}

- (void)dealloc {
    [_colorImg release];
    [_typeImg release];
    [_titleLabel release];
    [_dateLabel release];
    [super dealloc];
}
@end
