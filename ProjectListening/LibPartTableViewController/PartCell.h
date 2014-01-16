//
//  PartCell.h
//  ToeflListening
//
//  Created by zhaozilong on 13-6-1.
//
//

#import <UIKit/UIKit.h>

@interface PartCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *partLabel;
@property (retain, nonatomic) IBOutlet UILabel *detailLabel;

- (void)setLabelInfoWithQuesNum:(int)QuesNum rightNum:(int)rightNum partType:(PartTypeTags)partType;

@end
