//
//  AssistantCell.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-21.
//
//

#import <UIKit/UIKit.h>
#import "AssInfoClass.h"

@interface AssistantCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *assPic;
@property (retain, nonatomic) IBOutlet UILabel *assInfoLabel;

- (void)setCellWithAIC:(AssInfoClass *)AIC;

@end
