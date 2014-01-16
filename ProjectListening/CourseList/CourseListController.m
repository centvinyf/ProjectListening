//
//  CourseListController.m
//  ToeicListeningFREE
//
//  Created by 赵子龙 on 13-12-29.
//
//

#import "CourseListController.h"
#import "MJRefresh.h"

#import "UserSetting.h"
#import "CourseInfoCell.h"

//#import "CJSONDeserializer.h"

#import "SBJSON.h"
#import "NSString+SBJSON.h"
#import "Reachability.h"
#import "NSString+MD5.h"


//#import "CourseViewController.h"
//#import "CourseDetailClass.h"
#import "CourseDownloadViewController.h"


#define URL @"http://api.iyuba.com.cn/v2/api.iyuba?protocol=20006&pageCounts=20&id=928&sign=50a73a44926eb275f327cc08a0cd8c7d&pageNumber=1"

//http://localhost:8080/PClass/classGetInfo/getCategoryTitle.jsp?id=1&type=2&sign=273b15552253d593eeb02acd46b4525b


#define LAST_BLOG_COUNT @"lastBlogCount"
#define LAST_PAGE_NUMBER @"lastPageNumber"

@interface CourseListController () <MJRefreshBaseViewDelegate> {
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

@end

@implementation CourseListController

- (void)dealloc {
    // 释放资源
    [_footer free];
    [_header free];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"TAB_COURSE", nil)];
    
    
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
    _data = [UserSetting courseInfoArray];
    
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestMoreBlogIsHeader:(BOOL)isHeader {
    
    if (isHeader) {
        self.isHeaderRefreshing = YES;
    } else {
        self.isFooterRefreshing = YES;
    }
    
    NSString *testId = [TestType courseID];//@"1";
    
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
    
//    NSString *sign = [[NSString stringWithFormat:@"20006%@iyubaV2", testId] MD5String];
//    NSString *urlStr = [NSString stringWithFormat:@"http://api.iyuba.com.cn/v2/api.iyuba?protocol=20006&pageCounts=20&id=%@&sign=%@&pageNumber=%d&language=%@", testId, sign, (isHeader ? 1 : (_data.count / 20 + 1)), languageStr];
    
    
    NSString *sign = [[NSString stringWithFormat:@"10102class%@", testId] MD5String];
    NSString *urlStr = [NSString stringWithFormat:@"http://class.iyuba.com/getClass.iyuba?protocol=10102&id=%@&type=1&sign=%@&pageNumber=%d&pageCounts=20", testId, sign, (isHeader ? 1 : (_data.count / 20 + 1))];
    
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

#pragma mark 数据源-代理
/*
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
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CourseInfoCell";
    CourseInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (CourseInfoCell *)[[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil] objectAtIndex:(IS_IPAD ? 1 : 0)];
    }
    
    NSDictionary *infoDic = [_data objectAtIndex:indexPath.row];
//    NSString *subject = [infoDic objectForKey:@"name"];
    
    [cell setInfoDic:infoDic index:indexPath.row];
    
    
    //    cell.imageView.image = [UIImage imageNamed:@"lufy.jpeg"];
    //    cell.textLabel.text = _data[indexPath.row];
    //    cell.detailTextLabel.text = @"上面的是刷新时间";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (IS_IPAD ? 150.0f : 84.0f);
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *infoDic = [_data objectAtIndex:indexPath.row];
    
    NSString *packageId = [infoDic objectForKey:cPackName];
    NSString *desc = [infoDic objectForKey:cDesc];
    
    NSString *CDVCName = nil;
    if (IS_IPAD) {
        CDVCName = @"CourseDownloadViewController-iPad";
    } else {
        CDVCName = @"CourseDownloadViewController";
        
    }
    CourseDownloadViewController *cdvc = [[CourseDownloadViewController alloc] initWithNibName:CDVCName bundle:nil packageID:packageId desc:desc];
    
    [cdvc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:cdvc animated:YES];
    
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
    if (resultCode == 1) {
        
        pageNumber = [[result objectForKey:@"currentPage"] integerValue];
        lastPage = [[result objectForKey:@"lastPage"] integerValue];
        

        //blog内容
        NSArray *tempInfoArray = [result objectForKey:@"data"];
        NSInteger blogCounts = [tempInfoArray count];
        
        if (self.isHeaderRefreshing) {
            self.headerRefreshBlogCounts = blogCounts - self.lastBlogCounts;
            [[NSUserDefaults standardUserDefaults] setInteger:blogCounts forKey:LAST_BLOG_COUNT];
        }
        
        if (self.isHeaderRefreshing) {
            _data = [NSMutableArray arrayWithArray:tempInfoArray];
        }
        
        if (self.isFooterRefreshing) {
            _data = (NSMutableArray *)[_data arrayByAddingObjectsFromArray:tempInfoArray];
        }
        
        [UserSetting writeCourseInfoToPlist:_data];
        
        
        
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
        NSString *updateNum = @"已为您获取最新课程";
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
