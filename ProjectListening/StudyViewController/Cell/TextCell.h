//
//  TextCell.h
//  ProjectListening
//
//  Created by zhaozilong on 13-3-26.
//
//

#import <UIKit/UIKit.h>
#import "StudyViewController.h"
#import "NSString+ZZString.h"
#import "ZZTextView.h"

@interface TextCell : UITableViewCell
@property (retain, nonatomic) IBOutlet ZZTextView *syncTV;
//@property (retain, nonatomic) IBOutlet UIButton *switchBtn;
@property (retain, nonatomic) IBOutlet UIButton *favBtn;

@property (assign, nonatomic) StudyViewController *parentVC;
@property (assign) int senIndex;


//- (IBAction)switchBtnPressed:(id)sender;
- (IBAction)favBtnPressed:(id)sender;

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier parentVC:(StudyViewController *)svc;

- (void)setSyncTVLayoutWithText:(NSString *)text;
- (void)setSyncSingleTVLayoutWithText:(NSString *)text;


@end
