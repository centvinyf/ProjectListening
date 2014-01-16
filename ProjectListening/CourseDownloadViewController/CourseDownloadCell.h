//
//  CourseDownloadCell.h
//  JLPT1Listening
//
//  Created by 赵子龙 on 13-12-31.
//
//

#import <UIKit/UIKit.h>

#import "PackageClass.h"
#import "CourseDownloadViewController.h"

@interface CourseDownloadCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *colorImg;
@property (retain, nonatomic) IBOutlet UIImageView *typeImg;

@property (retain, nonatomic) IBOutlet UILabel *packNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *detailLabel;
@property (retain, nonatomic) IBOutlet UIView *downloadView;
@property (retain, nonatomic) IBOutlet UIButton *downloadBtn;
@property (retain, nonatomic) IBOutlet UIProgressView *progressView;

@property (assign) PICStatusTags PICTag;
@property (assign) int currRow;
@property (assign, nonatomic) CourseDownloadViewController *parentVC;

- (IBAction)downloadBtnPressed:(id)sender;

- (void)setCellStatusByTag:(PICStatusTags)tag row:(int)row;
- (void)setLabelInfoWithPIC:(PackageClass *)PIC;
- (void)setDownloadProgress:(CGFloat)progress;

- (void)addDownloadBtnStatusToCell;


- (void)setCellColorWithIndex:(int)index;

@end
