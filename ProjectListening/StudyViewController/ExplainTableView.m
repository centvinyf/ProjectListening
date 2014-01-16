//
//  ExplainTableView.m
//  ProjectListening
//
//  Created by zhaozilong on 13-5-2.
//
//

#import "ExplainTableView.h"
#import "SectionView.h"
#import "ExplainCell.h"
#import "UserSetting.h"

@implementation ExplainTableView

- (void)dealloc {
#if COCOS2D_DEBUG    
    NSLog(@"ExplainTableView dealloc");
#endif
    self.explain = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dataSource = self;
        self.delegate = self;
        
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)setExplainAndRefresh:(NSString *)explain {
    self.explain = explain;
    [self reloadData];
}

#pragma mark - Table view delegate
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIImageView *imgView = nil;
//    static NSString *TextSectionIdentifier = @"ExplainSectionFooter";
//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    
//    if (version >= 6.0)
//    {
//        // iPhone 3.0 code here
//        imgView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:TextSectionIdentifier];
//        if (!imgView) {
//            imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grayLine.png"]] autorelease];
//        }
//    } else {
//        imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grayLine.png"]] autorelease];
//    }
//    
//    return imgView;
//    
//}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    SectionView *TQEView = nil;
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    static NSString *TextSectionIdentifier = @"ExplainSectionHeader";
    
    if (version >= 6.0) {
        TQEView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:TextSectionIdentifier];
        if (!TQEView) {
            TQEView = [[[SectionView alloc] initWithSectionNameTag:SectionNameExplain] autorelease];
        }
    } else {
        TQEView = [[[SectionView alloc] initWithSectionNameTag:SectionNameExplain] autorelease];
    }
    
    
    return TQEView;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

//- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    
//    return 2;
//}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 13;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [ZZPublicClass getTVHeightByStr:self.explain constraintWidth:TEXT_WIDTH_LIMIT isBold:NO];
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int num = [indexPath row];
    UIColor *color = nil;
    if (num % 2 == 0) {
        color = [UIColor colorWithRed:(CGFloat)232 / 255 green:(CGFloat)238 / 255 blue:(CGFloat)234 / 255 alpha:1.0];
    } else {
        color = [UIColor colorWithRed:(CGFloat)241 / 255 green:(CGFloat)250 / 255 blue:(CGFloat)245 / 255 alpha:1.0];
    }
    [cell setBackgroundColor:color];
    
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *ExplainCellIdentifier = @"ExplainCell";
    ExplainCell *cell = [tableView dequeueReusableCellWithIdentifier:ExplainCellIdentifier];
    
    if (!cell) {
        cell = (ExplainCell *)[[[NSBundle mainBundle] loadNibNamed:ExplainCellIdentifier owner:self options:nil] objectAtIndex:(IS_IPAD ? 1 : 0)];
        cell.explainTV.parentVC = self.parentVC;
        
        //改字体改字体
//        [cell.explainTV setFont:[UIFont systemFontOfSize:[UserSetting textFontSizeReal]]];
        cell.explainTV.font = [UIFont fontWithName:FONT_NAME size:[UserSetting textFontSizeReal]];
        
    }
    
    [cell setExplainBy:self.explain];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.parentVC hideWordExplainView];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
