//
//  ExplainCell.h
//  ProjectListening
//
//  Created by zhaozilong on 13-5-2.
//
//

#import <UIKit/UIKit.h>
#import "ZZTextView.h"

@interface ExplainCell : UITableViewCell
@property (retain, nonatomic) IBOutlet ZZTextView *explainTV;

- (void)setExplainBy:(NSString *)explain;

@end
