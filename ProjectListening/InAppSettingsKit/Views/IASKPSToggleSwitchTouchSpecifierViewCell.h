//
//  IASKPSToggleSwitchTouchSpecifierViewCell.h
//  ToeflListening
//
//  Created by zhaozilong on 13-5-9.
//
//

#import <UIKit/UIKit.h>
@class IASKSwitch;

@interface IASKPSToggleSwitchTouchSpecifierViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *label;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet IASKSwitch *toggle;

@end
