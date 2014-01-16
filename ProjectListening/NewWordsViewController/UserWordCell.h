//
//  UserWordCell.h
//  CET4Lite
//
//  Created by Seven Lee on 12-3-21.
//  Copyright (c) 2012年 iyuba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CET4Constents.h"

@interface UserWordCell : UITableViewCell{
    IBOutlet UILabel * WordLabel;
    IBOutlet UILabel * DefLabel;
    IBOutlet UIButton * PlaySoundButton;
    IBOutlet UILabel *pronLabel;
}
@property (retain, nonatomic) IBOutlet UILabel *pronLabel;
@property (nonatomic, strong) IBOutlet UILabel * WordLabel;
@property (nonatomic, strong) IBOutlet UILabel * DefLabel;
@property (nonatomic, strong) IBOutlet UIButton * PlaySoundButton;
@end
