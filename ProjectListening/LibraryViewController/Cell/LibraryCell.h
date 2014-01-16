//
//  LibraryCell.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-15.
//
//

#import <UIKit/UIKit.h>
#import "PackInfoClass.h"
#import "LibraryTableViewController.h"

@interface LibraryCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *packNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *detailLabel;
@property (retain, nonatomic) IBOutlet UIView *downloadView;
@property (retain, nonatomic) IBOutlet UIButton *downloadBtn;
@property (retain, nonatomic) IBOutlet UIProgressView *progressView;

@property (assign) PICStatusTags PICTag;
@property (assign) int currRow;
@property (assign, nonatomic) LibraryTableViewController *parentVC;

- (IBAction)downloadBtnPressed:(id)sender;

- (void)setCellStatusByTag:(PICStatusTags)tag row:(int)row;
- (void)setLabelInfoWithPIC:(PackInfoClass *)PIC;
- (void)setDownloadProgress:(CGFloat)progress;

- (void)addDownloadBtnStatusToCell;

@end
