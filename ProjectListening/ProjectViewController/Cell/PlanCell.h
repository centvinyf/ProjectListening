//
//  PlanCell.h
//  ProjectListening
//
//  Created by zhaozilong on 13-3-18.
//
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "NSString+ZZString.h"
#import "PlanInfoClass.h"

@interface PlanCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIButton *planBtn;
@property (retain, nonatomic) IBOutlet UILabel *planLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UIImageView *trophyImg;
@property (retain, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (assign, nonatomic) RootViewController *parentVC;

@property (assign) int currPlanSection;

- (IBAction)planButtonPressed:(id)sender;
//- (void)setPlanInfoBy:(NSMutableDictionary *)dataDic;
- (void)setPlanInfoWithPIC:(PlanInfoClass *)PIC;

- (void)changeArrowWithUp:(BOOL)up;

@end
