//
//  InfoCell.m
//  ToeicListeningFREE
//
//  Created by 赵子龙 on 13-9-24.
//
//

#import "InfoCell.h"
#import "InfoTableViewController.h"

@interface InfoCell ()
@property (retain, nonatomic) IBOutlet UILabel *TitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *detailLabel;


@end

@implementation InfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCellWithDic:(NSDictionary *)infoDic {
    
    NSString *subject = [infoDic objectForKey:cSUBJECT];
    CGRect frame = self.TitleLabel.frame;
    frame.size.height = [InfoTableViewController heightWithText:subject constraintWidth:SUBJECT_WIDTH font:[UIFont systemFontOfSize:IOFO_FONT_SIZE]];
    [self.TitleLabel setFrame:frame];
    [self.TitleLabel setText:subject];
    [self.TitleLabel setFont:[UIFont systemFontOfSize:IOFO_FONT_SIZE]];
    
    
    frame = self.detailLabel.frame;
    frame.origin.y = self.TitleLabel.frame.origin.y + self.TitleLabel.frame.size.height;
    [self.detailLabel setFrame:frame];
    NSInteger time = [[infoDic objectForKey:cDATELINE] floatValue];
    NSDate *publishDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *dateStr = [publishDate description];
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
    
    int viewNum = [[infoDic objectForKey:cVIEWNUM] integerValue];
    [self.detailLabel setText:[NSString stringWithFormat:@"%@-查看次数:%d", dateStr, viewNum]];
}

#define cBLOGID     @"blogid"
#define cDATELINE   @"dateline"
#define cFAVTIMES   @"favtimes"
#define cIDS        @"ids"
#define cMESSAGE    @"message"
#define cNOREPLY    @"noreply"
#define cPASSWORD   @"password"
#define cREPLYNUM   @"replynum"
#define cSHARETIMES @"sharetimes"
#define cSUBJECT    @"subject"
#define cVIEWNUM    @"viewnum"

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_TitleLabel release];
    [_detailLabel release];
    [super dealloc];
}
@end
