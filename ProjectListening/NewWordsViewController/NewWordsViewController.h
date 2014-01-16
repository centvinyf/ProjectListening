//
//  NewWordsViewController.h
//  CET4Lite
//
//  Created by Seven Lee on 12-2-24.
//  Copyright (c) 2012年 iyuba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"

@interface NewWordsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray * jjjjjjArray;
    IBOutlet UITableView * tabelView;
    MBProgressHUD * HUD;
    NSMutableArray * ToDeleteArray;
    
}
@property (nonatomic, strong) NSMutableArray * jjjjjjArray;
@property (nonatomic, strong) IBOutlet UITableView * tabelView;
@property (nonatomic, strong) NSMutableArray * ToDeleteArray;


- (id)initFromSettingsWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@end
