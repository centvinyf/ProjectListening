//
//  CourseInfoCell.h
//  JLPT1Listening
//
//  Created by 赵子龙 on 13-12-30.
//
//

#import <UIKit/UIKit.h>

#define cPackName @"id"
#define cPrice @"price"
#define cDesc @"desc"
#define cName @"name"

@interface CourseInfoCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *colorImg;
@property (retain, nonatomic) IBOutlet UIImageView *typeImg;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;

- (void)setInfoDic:(NSDictionary *)infoDic index:(int)index;

@end
