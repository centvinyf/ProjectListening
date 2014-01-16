//
//  LibTitleTableViewController.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-15.
//
//

#import <UIKit/UIKit.h>

@interface LibTitleTableViewController : UITableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil packName:(NSString *)packName;

//有分类功能
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil packName:(NSString *)packName partType:(PartTypeTags)partType;


- (id)initFromSettingsWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@end
