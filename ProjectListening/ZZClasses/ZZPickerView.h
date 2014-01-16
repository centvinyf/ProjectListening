//
//  ZZPickerView.h
//  ToeflListening
//
//  Created by zhaozilong on 13-5-11.
//
//

#import <UIKit/UIKit.h>

@interface ZZPickerView : UIView
@property (retain, nonatomic) IBOutlet UIPickerView *AMPMPicker;

@property (retain, nonatomic) NSArray *AMPMArray;
@property (retain, nonatomic) NSArray *hourArray;
@property (retain, nonatomic) NSArray *minuteArray;

- (void)setAMPM:(int)ampm hour:(int)hour min:(int)min;
- (NSString *)AMOrPM;
- (NSString *)hour;
- (NSString *)minute;


@end
