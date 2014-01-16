//
//  InfoTableViewController.m
//  ToeicListening FREE
//
//  Created by 赵子龙 on 13-9-22.
//
//

#import "InfoTableViewController.h"
#import "MJRefresh.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "Reachability.h"
#import "NSString+MD5.h"
//#import "SFHFKeychainUtils.h"
#import "UserSetting.h"
#import "InfoCell.h"

//#import "CJSONDeserializer.h"

#import "SBJSON.h"
#import "NSString+SBJSON.h"
#import "BlogViewController.h"

#import "CourseViewController.h"


#define URL @"http://api.iyuba.com.cn/v2/api.iyuba?protocol=20006&pageCounts=20&id=928&sign=50a73a44926eb275f327cc08a0cd8c7d&pageNumber=1"


#define LAST_BLOG_COUNT @"lastBlogCount"
#define LAST_PAGE_NUMBER @"lastPageNumber"

@interface InfoTableViewController () <MJRefreshBaseViewDelegate> {
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    
    NSMutableArray *_data;
}

@property (assign)int lastBlogCounts;
@property (assign)BOOL isHeaderRefreshing;
@property (assign)BOOL isFooterRefreshing;
@property (assign)int headerRefreshBlogCounts;
@property (assign)int footerRefreshBlogCounts;
@property (assign)int lastPageNumber;
@property (assign)int totalPage;

@property (strong, nonatomic)ASIHTTPRequest *blogRequest;

@property (nonatomic, retain) GADBannerView *adView;

@end

@implementation InfoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

// 打开音响，附有下拉刷新的音效
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"TAB_INFO", nil)];

    
    self.lastBlogCounts = [[NSUserDefaults standardUserDefaults] integerForKey:LAST_BLOG_COUNT];
    self.isHeaderRefreshing = NO;
    self.isFooterRefreshing = NO;
//    self.refreshBlogCounts = 0;
    
    // 下拉刷新
    _header = [[MJRefreshHeaderView alloc] init];
    _header.delegate = self;
    _header.scrollView = self.tableView;
    
    // 上拉加载更多
//    _footer = [[MJRefreshFooterView alloc] init];
//    _footer.delegate = self;
//    _footer.scrollView = self.tableView;
    
    // 假数据
    //读取本地数据
    _data = [UserSetting testInfoArray];
    
    
    Reachability * reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    
//    if (_data.count == 0) {
        if (status == NotReachable) {
            //没有网络情况下
            
            
        } else {
            //有网络情况下
            [self requestMoreBlogIsHeader:YES];
            
#if 0
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            
//            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            [HUD setRemoveFromSuperViewOnHide:YES];
            // Set custom view mode
            HUD.mode = MBProgressHUDModeCustomView;
            
            HUD.delegate = self;
            HUD.labelText = NSLocalizedString(@"Loading...", nil);
            
            [HUD show:YES];
            
#endif
            
            
        }
        
//    }
    

    if (IOS_NEWER_OR_EQUAL_TO_7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)requestMoreBlogIsHeader:(BOOL)isHeader {
    
    if (isHeader) {
        self.isHeaderRefreshing = YES;
    } else {
        self.isFooterRefreshing = YES;
    }
    
    NSString *testId = [TestType testInfoID];//@"928";
    
    NSString *languageStr = nil;
    switch ([TestType systemLanguage]) {
        case LanguageCN:
            languageStr = @"CN";
            break;
            
        case LanguageEN:
            languageStr = @"EN";
            break;
            
        case LanguageJP:
            languageStr = @"JA";
            break;
            
        default:
            break;
    }
    
    NSString *sign = [[NSString stringWithFormat:@"20006%@iyubaV2", testId] MD5String];
    NSString *urlStr = [NSString stringWithFormat:@"http://api.iyuba.com.cn/v2/api.iyuba?protocol=20006&pageCounts=20&id=%@&sign=%@&pageNumber=%d&language=%@", testId, sign, (isHeader ? 1 : (_data.count / 20 + 1)), languageStr];
    
#if COCOS2D_DEBUG
    NSLog(@"url:%@",urlStr);
#endif
    
//    __weak InfoTableViewController * weakSelf = self;

    self.blogRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    self.blogRequest.delegate = self;
    self.blogRequest.timeOutSeconds = 20;
    
//    [self.blogRequest setCompletionBlock:^{
//        [weakSelf getDataByJasonResultWith:weakSelf.blogRequest.responseData];
//    }];
    [self.blogRequest startAsynchronous];
    
}

#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH : mm : ss.SSS";
    if (_header == refreshView) {
        
        [self requestMoreBlogIsHeader:YES];
        
    } else {
        [self requestMoreBlogIsHeader:NO];
    }
}

- (void)dealloc
{
    // 释放资源
    [_footer free];
    [_header free];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 数据源-代理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int num = [indexPath row];
    UIColor *color = nil;
    if (num % 2 == 1) {
        color = [UIColor colorWithRed:(CGFloat)232 / 255 green:(CGFloat)239 / 255 blue:(CGFloat)234 / 255 alpha:1.0];
    } else {
        color = [UIColor colorWithRed:(CGFloat)242 / 255 green:(CGFloat)250 / 255 blue:(CGFloat)245 / 255 alpha:1.0];
    }
    [cell setBackgroundColor:color];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InfoCell";
    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (InfoCell *)[[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil] objectAtIndex:(IS_IPAD ? 1 : 0)];
    }
    
    NSDictionary *infoDic = [_data objectAtIndex:indexPath.row];
    [cell setCellWithDic:infoDic];
    
    
//    cell.imageView.image = [UIImage imageNamed:@"lufy.jpeg"];
//    cell.textLabel.text = _data[indexPath.row];
//    cell.detailTextLabel.text = @"上面的是刷新时间";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *infoDic = [_data objectAtIndex:indexPath.row];
    NSString *title = [infoDic objectForKey:cSUBJECT];
    
    return [InfoTableViewController heightWithText:title constraintWidth:SUBJECT_WIDTH font:[UIFont systemFontOfSize:IOFO_FONT_SIZE]] + 20.0f;
}

+ (CGFloat)heightWithText:(NSString *)text constraintWidth:(CGFloat)width font:(UIFont *)font {
    CGSize constraint = CGSizeMake(width, 20000.0f);
    
    
    CGFloat height;
    
    if ([UserSetting isSystemOS7]) {
        
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              font, NSFontAttributeName,
                                              nil];
        
        CGRect frame = [text boundingRectWithSize:constraint
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:attributesDictionary
                                          context:nil];
        
        
        height = frame.size.height;
    } else {
        CGSize size = [text sizeWithFont:font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        height = size.height;
    }
    
    
    return height + CELL_CONTENT_MARGIN;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
//    CourseViewController *cvc = [[CourseViewController alloc] initWithNibName:@"CourseViewController" bundle:nil];
//    
//    [cvc setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:cvc animated:YES];
    
    
    
    // Navigation logic may go here, for example:
    // Create the next view controller.
    BlogViewController *detailViewController = [[BlogViewController alloc] initWithNibName:@"BlogViewController" bundle:nil];
    NSDictionary *blogDic = [_data objectAtIndex:indexPath.row];
    detailViewController.blogContent = [blogDic objectForKey:cMESSAGE];
    detailViewController.blogTitle = [blogDic objectForKey:cSUBJECT];
    [detailViewController setHidesBottomBarWhenPushed:YES];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark -
#pragma mark Admob

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (![UserSetting isPurchasedVIPMode]) {
        
        return (IS_IPAD ? 90.0 : 48.0);
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //    UIImageView *imgView = nil;
    UIView *admobView = nil;
    if (![UserSetting isPurchasedVIPMode]) {
        
        static NSString *AdmobSectionIdentifier = @"AdmobSectionHeader";
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        
        if (version >= 6.0)
        {
            // iPhone 6.0 code here
            admobView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:AdmobSectionIdentifier];
            if (!admobView) {
                admobView = [self adMobView];
            }
        } else {
            admobView = [self adMobView];
        }
        
    }
    
    return admobView;
    
}

- (UIView *)adMobView {
    
    GADBannerView *admobView = nil;
    
    if (IS_IPAD) {
        admobView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    } else {
        admobView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    }
    
    //    NSLog(@"广告条的高度是%f", _adView.frame.size.height);
    
    admobView.rootViewController = self;
    admobView.adUnitID = ADMOB_ID;
    CGRect rect = admobView.frame;
    CGFloat height = 0;
    CGFloat adHeight = 0;
    if (IS_IPAD) {
        height = 100;
        adHeight = 145;
    } else if (IS_IPHONE_568H) {
        height = -35;
        adHeight = -10;
    } else {
        height = 53;
        adHeight = 78;
    }
    CGPoint point = CGPointMake(self.view.center.x, self.view.frame.size.height - rect.size.height / 2 - height);
    admobView.center = point;
    //    _adView.delegate = self;
    [admobView loadRequest:[GADRequest request]];
    
    //判断网络状态
	NetworkStatus NetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    //没有网的情况
	if (NetStatus == NotReachable) {
        //没有网络的时候显示自己的广告条
        //        UIButton *adBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [adBtn setImage:[UIImage imageNamed:@"adIyuba.png"] forState:UIControlStateNormal];
        //        [adBtn addTarget:self action:@selector(ZZAudioPushToVIPPage) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"adIyuba.png"]];
        CGRect frame = imgView.frame;
        frame.origin = CGPointMake(self.view.frame.origin.x, self.view.frame.size.height - rect.size.height / 2 - adHeight);
        [imgView setFrame:frame];
//        [self.view insertSubview:imgView belowSubview:admobView];
        
        return imgView;
        
    }
    
    return admobView;

}


#pragma mark -
#pragma ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (HUD) {
        HUD.labelText = NSLocalizedString(@"STORE_ALERT_FAIL_TITLE", nil);
        [HUD hide:YES afterDelay:1];
        HUD = nil;
    }
    
    if (self.isHeaderRefreshing) {
        self.isHeaderRefreshing = NO;
    }
    
    if (self.isFooterRefreshing) {
        self.isFooterRefreshing = NO;
    }
    
    // 让刷新控件恢复默认的状态
    [_header endRefreshing];
    if (_footer) {
        [_footer endRefreshing];
    }
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (HUD) {
        [HUD hide:YES];
        HUD = nil;
    }
    
    NSString *responseString = [request responseString];
    NSInteger pageNumber;
    NSInteger lastPage;
    
    NSDictionary * result = [responseString JSONValue];
    NSInteger resultCode = [[result objectForKey:@"result"] integerValue];
    if (resultCode == 251) {
        
        
        
        NSInteger blogCounts = [[result objectForKey:@"blogCounts"] integerValue];
        pageNumber = [[result objectForKey:@"pageNumber"] integerValue];
        lastPage = [[result objectForKey:@"lastPage"] integerValue];
        
        
        if (self.isHeaderRefreshing) {
            self.headerRefreshBlogCounts = blogCounts - self.lastBlogCounts;
            [[NSUserDefaults standardUserDefaults] setInteger:blogCounts forKey:LAST_BLOG_COUNT];
        }
        
        //blog内容
        NSArray *tempInfoArray = [result objectForKey:@"data"];
        //            NSLog(@"%@", tempInfoArray);
        
        if (self.isHeaderRefreshing) {
            _data = [NSMutableArray arrayWithArray:tempInfoArray];
        }
        
        if (self.isFooterRefreshing) {
            _data = (NSMutableArray *)[_data arrayByAddingObjectsFromArray:tempInfoArray];
        }
        
        [UserSetting writeTestInfoToPlist:_data];
        
        
        
    } else {
        //            weakSelf.status = SignUpStatusFailed;
        //            weakSelf.errMessage = NSLocalizedString(@"FAILED_SEND_MSG", @"短信发送失败，请重试");
        //            [weakSelf updateUI];
    }
    
    [self.tableView reloadData];
    
    
    if (self.isHeaderRefreshing) {
        if (!_footer) {
            _footer = [[MJRefreshFooterView alloc] init];
            _footer.delegate = self;
            _footer.scrollView = self.tableView;
            
        }
        self.isHeaderRefreshing = NO;
        
        
//        NSString *updateNum = [NSString stringWithFormat:@"%@:%d", NSLocalizedString(@"更新篇数", nil), self.headerRefreshBlogCounts];
        NSString *updateNum = @"已为您更新到最新";
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        
        [HUD setRemoveFromSuperViewOnHide:YES];
        
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = updateNum;
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.0];
        
    }
    
    if (self.isFooterRefreshing) {
        self.isFooterRefreshing = NO;
    }
    
    if (lastPage == pageNumber && _footer) {
        _footer.delegate = nil;
        //        _footer.scrollView = nil;
        //        [_footer setHidden:YES];
        [_footer free];
        [_footer removeFromSuperview];
        
        _footer = nil;
        
    }
    
    // 让刷新控件恢复默认的状态
    [_header endRefreshing];
    if (_footer) {
        [_footer endRefreshing];
    }
}


@end
