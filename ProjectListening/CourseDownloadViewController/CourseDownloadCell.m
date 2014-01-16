//
//  CourseDownloadCell.m
//  JLPT1Listening
//
//  Created by 赵子龙 on 13-12-31.
//
//

#import "CourseDownloadCell.h"

#import "NSString+ZZString.h"

#define dStatusImgWaiting @"waitingBtn.png"
#define dStatusImgDownloading_0 @"downloadBtn_0.png"
#define dStatusImgDownloading_1 @"downloadBtn_1.png"
#define dStatusImgDownloading_2 @"downloadBtn_2.png"
#define dStatusImgPurchase @"purchaseBtn.png"

@interface CourseDownloadCell()

@property (nonatomic, retain) NSArray *imgArray;

@end

@implementation CourseDownloadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setDownloadProgress:(CGFloat)progress {
    
    [_progressView setProgress:progress];
}

- (IBAction)downloadBtnPressed:(id)sender {
    
    switch (_PICTag) {
        case PICStatusPurchase:
            //去内购界面
            [_parentVC purchaseSingleCourseWithPICIndex:_currRow];
            break;
            
        case PICStatusDownload:
        case PICStatusDownloading:
        case PICStatusWaiting:
        case PICStatusStop:
            //去下载
            [_parentVC downloadOrStopDownloadByRow:_currRow];
            break;
            
        default:
            break;
    }
}

- (void)setCellStatusByTag:(PICStatusTags)tag row:(int)row {
    _currRow = row;
    _PICTag = tag;
    switch (tag) {
        case PICStatusPurchase:
            [_downloadView setHidden:NO];
            [_progressView setHidden:YES];
            [self setDownloadBtnImgWithName:dStatusImgPurchase];
            [self setSelectionStyle:UITableViewCellSelectionStyleNone];
            break;
            
        case PICStatusDownload:
        case PICStatusStop:
            [_downloadView setHidden:NO];
            [_progressView setHidden:NO];
            [self stopButtonAimation];
            [self setDownloadBtnImgWithName:dStatusImgDownloading_0];
            [self setSelectionStyle:UITableViewCellSelectionStyleNone];
            break;
            
        case PICStatusDownloading:
            [_downloadView setHidden:NO];
            [_progressView setHidden:NO];
            [self startButtonAimation];
            [self setSelectionStyle:UITableViewCellSelectionStyleNone];
            break;
            
        case PICStatusWaiting:
            [_downloadView setHidden:NO];
            [_progressView setHidden:NO];
            [self setDownloadBtnImgWithName:dStatusImgWaiting];
            [self setSelectionStyle:UITableViewCellSelectionStyleNone];
            break;
            
        case PICStatusFree:
            [_downloadView setHidden:YES];
            [self setSelectionStyle:UITableViewCellSelectionStyleGray];
            break;
            
        default:
            break;
    }
}

- (void)setDownloadBtnImgWithName:(NSString *)name {
    UIImage *img = [UIImage imageNamed:name];
    [_downloadBtn setImage:img forState:UIControlStateNormal];
    [_downloadBtn setImage:img forState:UIControlStateHighlighted];
    [_downloadBtn setImage:img forState:UIControlStateSelected];
}

- (void)setLabelInfoWithPIC:(PackageClass *)PIC {
    
    
    NSString *name = [NSString stringWithFormat:@"%@", PIC.packName];
    [_packNameLabel setText:name];
    
    
    NSString *info = nil;
    if (PIC.lastPlayTime <= 0) {
        info = @"";
    } else {
        info = [NSString stringWithFormat:@"上次学习到%@", [NSString hmsToSwitchAdvance:PIC.lastPlayTime]];
        
    }
    [_detailLabel setText:info];
}

- (void)addDownloadBtnStatusToCell {
    
    UIImage * img0 = [UIImage imageNamed:dStatusImgDownloading_0];
    UIImage * img1 = [UIImage imageNamed:dStatusImgDownloading_1];
    UIImage * img2 = [UIImage imageNamed:dStatusImgDownloading_2];
    _imgArray = [[NSArray alloc] initWithObjects:img0,img1,img2, nil];
    //    [_downloadBtn setImage:img0 forState:UIControlStateNormal];
    //    [_downloadBtn setImage:img0 forState:UIControlStateHighlighted];
    //    [_downloadBtn setImage:img0 forState:UIControlStateSelected];
    //    [_quesPlayBtn.imageView setAnimationImages:_imgArray];
    //    [_quesPlayBtn.imageView setAnimationRepeatCount:-1];
    //    [_quesPlayBtn.imageView setAnimationDuration:0.5];
    //    [_downloadBtn setImage:[_imgArray objectAtIndex:0] forState:UIControlStateNormal];
    //    [_downloadBtn setImage:[_imgArray objectAtIndex:0] forState:UIControlStateHighlighted];
    //    [_downloadBtn setImage:[_imgArray objectAtIndex:0] forState:UIControlStateSelected];
    
}

- (void)startButtonAimation {
    [_downloadBtn setImage:[_imgArray objectAtIndex:0] forState:UIControlStateNormal];
    [_downloadBtn setImage:[_imgArray objectAtIndex:0] forState:UIControlStateHighlighted];
    [_downloadBtn setImage:[_imgArray objectAtIndex:0] forState:UIControlStateSelected];
    [_downloadBtn.imageView setAnimationImages:_imgArray];
    [_downloadBtn.imageView setAnimationDuration:0.5f];
    [_downloadBtn.imageView setAnimationRepeatCount:-1];
    [_downloadBtn.imageView startAnimating];
}

- (void)stopButtonAimation {
    [_downloadBtn.imageView stopAnimating];
}



- (void)setCellColorWithIndex:(int)index {
    
    NSString *colorName = nil;
    if (index % 5 == 0) {
        colorName = @"CourseGreen.png";
    } else if (index % 5 == 1) {
        colorName = @"CourseBlue.png";
    } else if (index % 5 == 2) {
        colorName = @"CoursePurple.png";
    } else if (index % 5 == 3) {
        colorName = @"CoursePink.png";
    } else {
        colorName = @"CourseOrange.png";
    }
    [self.colorImg setImage:[UIImage imageNamed:colorName]];
    
    NSString *typeName = @"CourseTypeListening.png";
    [self.typeImg setImage:[UIImage imageNamed:typeName]];
}



- (void)dealloc {
    self.parentVC = nil;
    [self.packNameLabel release];
    [self.detailLabel release];
    [self.downloadView release];
    [self.downloadBtn release];
    [self.progressView release];
    [_colorImg release];
    [_typeImg release];
    [super dealloc];
}

@end
