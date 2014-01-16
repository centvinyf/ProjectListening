//
//  DetailCell.h
//  ProjectListening
//
//  Created by zhaozilong on 13-3-18.
//
//

#import <UIKit/UIKit.h>
#import "NSString+ZZString.h"
#import "TitleInfoClass.h"

@interface DetailCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *detailLabel;
@property (retain, nonatomic) IBOutlet UILabel *infoLabel;
@property (retain, nonatomic) IBOutlet UIImageView *conPointImg;

//- (void)setDetailInfoBy:(NSMutableDictionary *)detailDic;
//- (void)setDetailInfoWithTitleName:(NSString *)titleName quesNum:(int)quesNum soundTime:(int)soundTime rightNum:(int)rightNum;
- (void)setDetailInfoWithTIC:(TitleInfoClass *)TIC;

@end
