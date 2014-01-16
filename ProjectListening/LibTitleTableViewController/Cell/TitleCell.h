//
//  TitleCell.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-15.
//
//

#import <UIKit/UIKit.h>

@interface TitleCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *titleInfoLabel;
@property (retain, nonatomic) IBOutlet UILabel *detailLabel;

- (void)setLabelInfoTitleName:(NSString *)titleName quesNum:(int)quesNum rightNum:(int)rightNum soundTime:(NSString *)soundTime;

@end
