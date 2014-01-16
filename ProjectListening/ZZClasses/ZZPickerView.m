//
//  ZZPickerView.m
//  ToeflListening
//
//  Created by zhaozilong on 13-5-11.
//
//

#import "ZZPickerView.h"

#define TAG_AMPM 0
#define TAG_HOUR 1
#define TAG_MINUTE 2

@implementation ZZPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)awakeFromNib {
    
//    self.AMPMPicker.tag = TAG_AMPM;
//    self.hourPicker.tag = TAG_HOUR;
//    self.minutePicker.tag = TAG_MINUTE;
    
    //此处可以本地化一下子
    self.AMPMArray = [NSArray arrayWithObjects:@"AM", @"PM", nil];
    self.hourArray = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];
    self.minuteArray = [NSArray arrayWithObjects:@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", nil];
    
    for (int i = 1; i < 3; i++) {
        [self.AMPMPicker selectRow:16384/2 inComponent:i animated:NO];
    }
    
}

- (void)setAMPM:(int)ampm hour:(int)hour min:(int)min {
    [self.AMPMPicker selectRow:ampm inComponent:0 animated:NO];
    [self.AMPMPicker selectRow:8183 + hour inComponent:1 animated:NO];
    [self.AMPMPicker selectRow:8160 + min inComponent:2 animated:NO];
    
    
}

- (NSString *)AMOrPM {
    NSInteger index = [self.AMPMPicker selectedRowInComponent:0];
    
    return [self.AMPMArray objectAtIndex:index];
}

- (NSString *)hour {
    NSInteger index = [self.AMPMPicker selectedRowInComponent:1] % self.hourArray.count;
    return [self.hourArray objectAtIndex:index];
}

- (NSString *)minute {
    NSInteger index = [self.AMPMPicker selectedRowInComponent:2] % self.minuteArray.count;
    return [self.minuteArray objectAtIndex:index];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case TAG_AMPM:
            return self.AMPMArray.count;
            break;
            
        case TAG_HOUR:
            return 16384;
            break;
            
        case TAG_MINUTE:
            return 16384;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case TAG_AMPM:
            return [self.AMPMArray objectAtIndex:row];
            break;
            
        case TAG_HOUR:
            return [self.hourArray objectAtIndex:row % [self.hourArray count]];
            break;
            
        case TAG_MINUTE:
            return [self.minuteArray objectAtIndex:row % [self.minuteArray count]];
            break;
            
        default:
            return @"00";
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
#if COCOS2D_DEBUG
     NSLog(@"zzpickerview is dealloc");
#endif
    [self.AMPMArray release];
    [self.hourArray release];
    [self.minuteArray release];
    [_AMPMPicker release];
    [super dealloc];
}
@end
