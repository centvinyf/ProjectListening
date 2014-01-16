//
//  LibraryCell.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-15.
//
//

#import "LibraryCell.h"

#define dStatusImgWaiting @"waitingBtn.png"
#define dStatusImgDownloading_0 @"downloadBtn_0.png"
#define dStatusImgDownloading_1 @"downloadBtn_1.png"
#define dStatusImgDownloading_2 @"downloadBtn_2.png"
#define dStatusImgPurchase @"purchaseBtn.png"

@interface LibraryCell()
@property (nonatomic, retain) NSArray *imgArray;

@end

@implementation LibraryCell

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
            [_parentVC pushPurchaseViewController];
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

- (void)setLabelInfoWithPIC:(PackInfoClass *)PIC {
    
    
    NSString *name = nil;
    if ([TestType isToefl] || [TestType isToeic]) {
        name = [NSString stringWithFormat:@"%@(%d%@)", PIC.packName, PIC.totalTitleNum, NSLocalizedString(@"HOW_MANY_ARTICLE", @"篇听力")];
    } else {
//        name = [NSString stringWithFormat:@"%@(%d%@)", PIC.packName, PIC.totalTitleNum, NSLocalizedString(@"HOW_MANY_QUESTION", @"道题")];
        
        name = [NSString stringWithFormat:@"%@", PIC.packName];
    } 
    [_packNameLabel setText:name];
    
    NSString *info = nil;
//    if (PIC.totalRightNum == 0) {
//        info = [NSString stringWithFormat:@"共计%d问题", PIC.totalQuesNum];
//    } else {
//        info = [NSString stringWithFormat:@"共计%d问题-答对%d题", PIC.totalQuesNum, PIC.totalRightNum/*, (float)PIC.totalRightNum * 100 / PIC.totalQuesNum*/];
//    }
    NSString *rate = NSLocalizedString(@"CORRECT_RATE", @"正确比例:");
    NSString *question = NSLocalizedString(@"QUESTION", @"题");
    info = [NSString stringWithFormat:@"%@%d/%d%@", rate, PIC.totalRightNum, PIC.totalQuesNum, question/*, (float)PIC.totalRightNum * 100 / PIC.totalQuesNum*/];
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



- (void)dealloc {
    self.parentVC = nil;
    [self.packNameLabel release];
    [self.detailLabel release];
    [self.downloadView release];
    [self.downloadBtn release];
    [self.progressView release];
    [super dealloc];
}
@end
