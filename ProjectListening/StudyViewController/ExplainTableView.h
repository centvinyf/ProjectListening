//
//  ExplainTableView.h
//  ProjectListening
//
//  Created by zhaozilong on 13-5-2.
//
//

#import <UIKit/UIKit.h>
#import "TextAndQuesClass.h"
#import "StudyViewController.h"

@interface ExplainTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign)TextAndQuesClass *TAQ;
@property (nonatomic, retain)NSString *explain;
@property (nonatomic, assign)StudyViewController *parentVC;

- (void)setExplainAndRefresh:(NSString *)explain;

@end
