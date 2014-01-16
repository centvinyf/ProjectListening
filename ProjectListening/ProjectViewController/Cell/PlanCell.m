//
//  PlanCell.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-18.
//
//

#import "PlanCell.h"
#import "NSDate+ZZDate.h"

@implementation PlanCell

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

- (void)setPlanInfoWithPIC:(PlanInfoClass *)PIC {
    int ymd = PIC.YMD;
    int mm = (ymd % 10000) / 100;
    int dd = (ymd % 10000) % 100;
    
    int totalTime = PIC.totalTime;
    
    int totalQuesNum = PIC.totalQuesNum;
    
    int totalTitleNum = PIC.totalTitleNum;
    
    int totalRightNum = PIC.totalRightNum;
    
    int todayInt = [NSDate getDateInNumBy:[NSDate getLocateDate:[NSDate date]]];
    if (todayInt == ymd) {
        [_dateLabel setText:NSLocalizedString(@"TODAY_TASK", nil)];
    } else {
        NSString *month = NSLocalizedString(@"MONTH", nil);
        NSString *day = NSLocalizedString(@"DAY", nil);
        NSString *task = NSLocalizedString(@"TASK", nil);
        [_dateLabel setText:[NSString stringWithFormat:@"%d%@%d%@%@:", mm, month, dd, day, task]];
    }
    
    NSString *info = nil;
//    if (totalRightNum == 0) {
//        info = [NSString stringWithFormat:@"%d篇听力-共%d道问题",totalTitleNum, totalQuesNum];
//    } else {
//        info = [NSString stringWithFormat:@"%d篇听力-共%d道问题-答对%d题",totalTitleNum, totalQuesNum, totalRightNum];
//    }
    NSString *rate = NSLocalizedString(@"CORRECT_RATE", @"正确比例:");
    NSString *question = nil;
    if ([TestType systemLanguage] == LanguageEN) {
        question = NSLocalizedString(@"", @"题");
    } else {
        question = NSLocalizedString(@"QUESTION", @"题");
    }
//    NSString *question = NSLocalizedString(@"QUESTION", @"题");
    NSString *howmayArticle = NSLocalizedString(@"HOW_MANY_ARTICLE", @"篇听力");
    info = [NSString stringWithFormat:@"%d%@-%@%d/%d%@", totalTitleNum, howmayArticle, rate, totalRightNum, totalQuesNum, question];
    [_planLabel setText:info];
    NSString *totalTimeStr = NSLocalizedString(@"TOTAL_TIME", @"总时长:");
    [_timeLabel setText:[NSString stringWithFormat:@"%@%@", totalTimeStr, [NSString hmsToSwitchAdvance:totalTime]]];
    
    
    NSString *imgName = nil;
    NSString *imgHiglightName = nil;
    UIImage *imgTrophy = [UIImage imageNamed:@"black.png"];;
    int score = PIC.score;
    int today = [NSDate getDateInNumBy:[NSDate getLocateDate:[NSDate date]]];
//    NSLog(@"%@", [NSDate getLocateDate:[NSDate date]]);
    if (today == ymd && score <= 0) {
        
        imgName = @"blueBtn.png";
        imgHiglightName = @"blueBtn_hl.png";
        
        [_planBtn setTitle:nil forState:UIControlStateNormal];
    } else {
        if (score < 0) {
            imgName = @"redBtn.png";
            imgHiglightName = @"redBtn_hl.png";
        } else if (score < 60) {
            imgName = @"redBtn.png";
            imgHiglightName = @"redBtn_hl.png";
        } else if (score < 70) {
            imgName = @"greenBtn.png";
            imgHiglightName = @"greenBtn_hl.png";
        } else if (score < 80) {
            imgName = @"greenBtn.png";
            imgHiglightName = @"greenBtn_hl.png";
            imgTrophy = [UIImage imageNamed:@"bronze.png"];
        } else if (score < 90) {
            imgName = @"greenBtn.png";
            imgHiglightName = @"greenBtn_hl.png";
            imgTrophy = [UIImage imageNamed:@"sliver.png"];
        } else {
            imgName = @"greenBtn.png";
            imgHiglightName = @"greenBtn_hl.png";
            imgTrophy = [UIImage imageNamed:@"gold.png"];
        }
        
        [_planBtn setTitle:[NSString stringWithFormat:@"%d", score] forState:UIControlStateNormal];
    }
    
    [_trophyImg setImage:imgTrophy];
    
    [_planBtn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [_planBtn setBackgroundImage:[UIImage imageNamed:imgHiglightName] forState:UIControlStateHighlighted];
}

- (void)setPlanInfoBy:(NSMutableDictionary *)dataDic {
    int ymd = [[dataDic objectForKey:@"date"] intValue];
    int mm = (ymd % 10000) / 100;
    int dd = (ymd % 10000) % 100;
    
    int totalTime = [[dataDic objectForKey:@"totalTime"] intValue];
    
    int totalQuesNum = [[dataDic objectForKey:@"totalQuesNum"] intValue];
    
    int totalTitleNum = [[dataDic objectForKey:@"totalTitleNum"] intValue];
    
    int totalRightNum = [[dataDic objectForKey:@"totalRightNum"] intValue];
    
    
    [_dateLabel setText:[NSString stringWithFormat:@"%d.%d 任务:", mm, dd]];
     
    NSString *info = nil;
//    if (totalRightNum == 0) {
//        info = [NSString stringWithFormat:@"%d篇听力-共%d道问题",totalTitleNum, totalQuesNum];
//    } else {
//        info = [NSString stringWithFormat:@"%d篇听力-共%d道问题-答对%d题",totalTitleNum, totalQuesNum, totalRightNum];
//    }
    NSString *rate = NSLocalizedString(@"CORRECT_RATE", @"正确比例:");
    NSString *question = NSLocalizedString(@"QUESTION", @"题");
    NSString *howmayArticle = NSLocalizedString(@"HOW_MANY_ARTICLE", @"篇听力");
    info = [NSString stringWithFormat:@"%d%@-%@%d/%d%@",totalTitleNum, howmayArticle, rate, totalRightNum, totalQuesNum, question];
    [_planLabel setText:info];
    NSString *totalTimeStr = NSLocalizedString(@"TOTAL_TIME", @"总时长:");
    [_timeLabel setText:[NSString stringWithFormat:@"%@%@", totalTimeStr, [NSString hmsToSwitchAdvance:totalTime]]];
    
    
    NSString *imgName = nil;
    NSString *imgHiglightName = nil;
    UIImage *imgTrophy = [UIImage imageNamed:@"black.png"];;
    int score = [[dataDic objectForKey:@"score"] intValue];
    int today = [NSDate getDateInNumBy:[NSDate getLocateDate:[NSDate date]]];
    if (today == ymd && score <= 0) {
        
        imgName = @"blueBtn.png";
        imgHiglightName = @"blueBtn_hl.png";
        
        [_planBtn setTitle:nil forState:UIControlStateNormal];
    } else {
        if (score < 0) {
            imgName = @"redBtn.png";
            imgHiglightName = @"redBtn_hl.png";
        } else if (score < 60) {
            imgName = @"redBtn.png";
            imgHiglightName = @"redBtn_hl.png";
        } else if (score < 70) {
            imgName = @"greenBtn.png";
            imgHiglightName = @"greenBtn_hl.png";
        } else if (score < 80) {
            imgName = @"greenBtn.png";
            imgHiglightName = @"greenBtn_hl.png";
            imgTrophy = [UIImage imageNamed:@"bronze.png"];
        } else if (score < 90) {
            imgName = @"greenBtn.png";
            imgHiglightName = @"greenBtn_hl.png";
            imgTrophy = [UIImage imageNamed:@"sliver.png"];
        } else {
            imgName = @"greenBtn.png";
            imgHiglightName = @"greenBtn_hl.png";
            imgTrophy = [UIImage imageNamed:@"gold.png"];
        }

        [_planBtn setTitle:[NSString stringWithFormat:@"%d", score] forState:UIControlStateNormal];
    }
    
    [_trophyImg setImage:imgTrophy];
    
    [_planBtn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [_planBtn setBackgroundImage:[UIImage imageNamed:imgHiglightName] forState:UIControlStateHighlighted];
    
    
}

- (void)changeArrowWithUp:(BOOL)up
{
    if (up) {
        self.arrowImageView.image = [UIImage imageNamed:@"UpAccessory.png"];
    }else
    {
        self.arrowImageView.image = [UIImage imageNamed:@"DownAccessory.png"];
    }
}

- (void)dealloc {
    [_planBtn release];
    [_planLabel release];
    [_trophyImg release];
    [_timeLabel release];
    [_dateLabel release];
    [_arrowImageView release];
    [super dealloc];
}
- (IBAction)planButtonPressed:(id)sender {
    [_parentVC pushStudyViewControllerBySection:_currPlanSection index:1 isContinue:YES];
}
@end
