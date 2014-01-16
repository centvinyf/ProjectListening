//
//  UserAdviseViewController.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-20.
//
//

#import "UserAdviseViewController.h"
#import "RegexKitLite.h"
#import "DDXML.h"
#import "DDXMLElement.h"
#import "DDXMLElementAdditions.h"
#import "Reachability.h"
#import "UserInfo.h"
#import "UserSetting.h"

#define FEEDBACK_URL_UID_PLATFORM_APP_TYPE_EMAIL_CONTENT_FORMAT @"http://172.16.94.220:8081/iyubaApi/v2/api.iyuba?protocol=91001&uid= &platform=  &app=  &type= &email= &content= &format="

/*
 *
 *
 *
 *http://test.iyuba.com/iyubaApi/v2/api.iyuba?protocol=91001&app=toefl&email=zhaozilong@yahoo.cn &content=test&format=xml
 *附带的参数
 *type 默认 mobile
 *platform 默认ios
 *app
 *uid 如果匿名值为0 此时必须有邮箱参数
 *email 如果有uid可有可不有
 *content 反馈内容
 *format
 *内网没问题了再用外网的：
 *http://apis.iyuba.com/v2/api.iyuba?protocol=91001
 http://172.16.94.220:8081/iyubaApi/v2/api.iyuba?protocol=91001&app=toefl&email=zhaozilong@yahoo.cn &content=test&format=xml
 
 返回格式 {"result":911, "message":""}
 
 
 <response>
 <result>911</result>
 <message/>
 </response>
 
 911成功
 910失败
 */
#define kSaidText   @"kSaidText"
#define kSaidIsUser @"kSaidIsUser"

typedef enum {
    UserInfoStatusID,
    UserInfoStatusEmail,
    UserInfoStatusNone,
} UserInfoStatusTags;

@interface UserAdviseViewController () {
    UserInfoStatusTags _infoStatus;
    BOOL _isSending;
    
    int _comeInMsgNum;
    int _outMsgNum;
}

@property (strong, nonatomic) UIBarButtonItem *submit;
@property (strong, nonatomic) NSMutableData *mp3Data;
@property (nonatomic, strong) UIAlertView *indicator;
@property (nonatomic, strong) NSURLConnection *iconnection;

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *userEmail;

@end

@implementation UserAdviseViewController

- (id)init {
    self = [super init];
    if (self) {
        [self setHidesBottomBarWhenPushed:YES];
        
        //是否是在发送状态
        _isSending = NO;
        
        _userID = nil;
        _userEmail = nil;
        //判断用户是否已经登陆
        if ([UserInfo userLoggedIn]) {
            _userID = [UserInfo loggedUserID];
            _infoStatus = UserInfoStatusID;
        } else if ([UserSetting isUserEmail]) {
            //判断是否有email
            _userEmail = [UserSetting userEmail];
            _infoStatus = UserInfoStatusEmail;
        } else {
            _infoStatus = UserInfoStatusNone;
        }
    }
    
    return self;
}

- (void)backToTop {

    if (_isSending) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MESSAGE", nil) message:NSLocalizedString(@"SENDING_NOT_BACK", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"GIVE_UP_SENDING", nil), nil];
        
        [alert show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
//        [self stopDownload];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - View lifecycle

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopDownload];
    
    _outMsgNum = self.messages.count;
    switch (_infoStatus) {
        case UserInfoStatusNone:
            if (_outMsgNum != _comeInMsgNum + 2) [UserSetting writeUserAdviseToPlist:self.messages];
            break;
            
        default:
            if (_outMsgNum != _comeInMsgNum + 1) [UserSetting writeUserAdviseToPlist:self.messages];
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    
    [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
    
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"USER_ADVISE", nil)];
    
    self.messages = [[NSMutableArray alloc] init];
    
    //先把之前的对话都列出来
    [UserSetting setUserAdviseMsgArray:self.messages];
    _comeInMsgNum = self.messages.count;
    
    [self setMessageArrayWithStatus:_infoStatus];
    
    if ([UserSetting isSystemOS7]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
}


- (void)setMessageArrayWithStatus:(UserInfoStatusTags)tag {
    
    NSMutableDictionary *dic = nil;
    if (tag == UserInfoStatusNone) {
        //没有登陆也没有email, 需要输入email再返回意见
        dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"MSG_1", @"欢迎来到意见薄, 我们会认真阅读您的反馈"), kSaidText, [NSNumber numberWithBool:NO], kSaidIsUser, nil];
        [self.messages addObject:dic];
        
        dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"MSG_2", @"请输入您的Email地址方便我们联系您, 您的Email地址不会被透露"), kSaidText, [NSNumber numberWithBool:NO], kSaidIsUser, nil];
        [self.messages addObject:dic];
    } else if (tag == UserInfoStatusID) {
        //登陆成功，有ID，直接输入就可以
//        dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"亲爱的爱语吧用户, 欢迎来到意见薄, 我们会认真阅读您的反馈", kSaidText, [NSNumber numberWithBool:NO], kSaidIsUser, nil];
        NSString *said = [NSString stringWithFormat:@"%@%@, %@", NSLocalizedString(@"MSG_5", @"亲爱的"), [UserInfo loggedUserName], NSLocalizedString(@"MSG_3", @"欢迎来到意见薄, 我们会认真阅读您的反馈")];
        dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:said, kSaidText, [NSNumber numberWithBool:NO], kSaidIsUser, nil];
        [self.messages addObject:dic];
    } else {
        //没有登陆，有email，直接输入就可以
        dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"MSG_4", @"亲爱的用户, 欢迎来到意见薄, 爱语吧团队会认真阅读您对我们提出的宝贵建议"), kSaidText, [NSNumber numberWithBool:NO], kSaidIsUser, nil];
        [self.messages addObject:dic];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Messages view controller
- (BubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return (indexPath.row % 2) ? BubbleMessageStyleIncoming : BubbleMessageStyleOutgoing;
    
    NSMutableDictionary *dic = [self.messages objectAtIndex:indexPath.row];
    BOOL isUserSaid = [[dic objectForKey:kSaidIsUser] boolValue];
    return isUserSaid ? BubbleMessageStyleOutgoing : BubbleMessageStyleIncoming;
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dic = [self.messages objectAtIndex:indexPath.row];
    NSString *text = [dic objectForKey:kSaidText];
    return text;
}

- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:text, kSaidText, [NSNumber numberWithBool:YES], kSaidIsUser, nil];
    [self.messages addObject:dic];
    
    [self doSendAction];
    
    [self sendWithInfoStatus:_infoStatus withText:text];
}


#pragma mark - My Methods
- (void)doSendAction {
    if((self.messages.count - 1) % 2)
        [MessageSoundEffect playMessageSentSound];
    else
        [MessageSoundEffect playMessageReceivedSound];
    
    [self finishSend];
}

- (void)sendWithInfoStatus:(UserInfoStatusTags)tag withText:(NSString *)text {
    NSMutableDictionary *dic = nil;
    
    if (tag == UserInfoStatusNone) {
        //判断邮箱格式正确与否
        NSString *match = [text stringByMatching:@"^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\\.([a-zA-Z]{2,4})$"];
        
        if ([match length] == [text length] && [text length] != 0) {
            //邮箱格式正确，可以发建议了,更改用户的发送状态，记录用户的email地址
            _infoStatus = UserInfoStatusEmail;
            [UserSetting setUserEmail:text];
            _userEmail = text;
            
             dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"MSG_6", @"您现在可以填写反馈信息了, 我们会认真阅读您的反馈信息"), kSaidText, [NSNumber numberWithBool:NO], kSaidIsUser, nil];
        } else {
            //邮箱格式不正确，从新输入
            dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"MSG_7", @"邮箱格式不正确, 请重新填写, 感谢"), kSaidText, [NSNumber numberWithBool:NO], kSaidIsUser, nil];
        }
        
        [self.messages addObject:dic];
        [self doSendAction];
        
    } else {
        //先显示请稍等...
        dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"MSG_8", @"正在发送中，请稍后..."), kSaidText, [NSNumber numberWithBool:NO], kSaidIsUser, nil];
        
        [self.messages addObject:dic];
        [self doSendAction];
        
        //直接可以发送
        if (tag == UserInfoStatusID) {
            [self sendAdviseToIyubaWithIsUserID:YES withText:text];
        } else {
            [self sendAdviseToIyubaWithIsUserID:NO withText:text];
        }
        
    }
}

- (void)sendAdviseToIyubaWithIsUserID:(BOOL)isUserID withText:(NSString *)text{
    //判断网络状态
	NetworkStatus NetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    //没有网的情况
    NSMutableDictionary *dic = nil;
	if (NetStatus == NotReachable) {
        //设置发送状态
        _isSending = NO;
        
		dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"MSG_9", @"抱歉, 发送失败, 当前网络出现问题, 请查看您的网络是否开启"), kSaidText, [NSNumber numberWithBool:NO], kSaidIsUser, nil];
        
        [self.messages addObject:dic];
        [self doSendAction];
        
        
    } else {
        
        //设置发送状态
        _isSending = YES;
        
        //修改将要发送的字符串
        NSString *newAdvise = [text stringByAppendingFormat:@"-版本号:%@-设备:%@-系统:%@", [UserSetting applicationVersion], [UserSetting platformString], [UserSetting systemVersion]];
//        newAdvise = [newAdvise stringByReplacingOccurrencesOfString:@" " withString:@""];
        newAdvise = [newAdvise stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSString *address = nil;
        
        if (isUserID) {
            // 准备开始下载的地址

            address = [NSString stringWithFormat:@"http://apis.iyuba.com/v2/api.iyuba?protocol=91001&app=%@&uid=%@&content=%@&format=xml", APP_NAME, _userID, newAdvise];
            
            
        } else {
            // 准备开始下载的地址
            address = [NSString stringWithFormat:@"http://apis.iyuba.com/v2/api.iyuba?protocol=91001&uid=0&app=%@&email=%@&content=%@&format=xml", APP_NAME, _userEmail, newAdvise];
        }
        
        //初始化,准备下载
        _mp3Data = [[NSMutableData alloc] init];
        address = [address stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
        
        //向服务器发送请求
        [_iconnection cancel];
        _iconnection = [NSURLConnection connectionWithRequest:URLRequest delegate:self];
        
        //加系统联网图标
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
    }
}

- (void)stopDownload {
	if (_iconnection)
        [_iconnection cancel], _iconnection = nil;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark -
#pragma mark connectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response  {
	
	[_mp3Data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_mp3Data appendData:data];
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	DDXMLDocument *xml = [[DDXMLDocument alloc] initWithData:_mp3Data options:0 error:nil];
	NSArray *items = [xml nodesForXPath:@"response" error:nil];
    
	if (items) {
		for (DDXMLElement *obj in items) {
			NSString *isOK = [[obj elementForName:@"result"] stringValue] ;
            
            NSMutableDictionary *dic = nil;
			if ([isOK isEqualToString:@"910"]) {
                dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"MSG_10", @"抱歉, 发送失败, 网络问题, 请稍后再试, 或者您也可以先去学习, 一会再给我们发反馈, 万分感谢"), kSaidText, [NSNumber numberWithBool:NO], kSaidIsUser, nil];
                
			} else {
                dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"MSG_11", @"发送成功, 谢谢反馈. 您也许现在应该回去学习外语了, 您的助理还在等着呢"), kSaidText, [NSNumber numberWithBool:NO], kSaidIsUser, nil];
			}
            
            [self.messages addObject:dic];
            [self doSendAction];
		}
	}
    
    //隐藏系统联网图标
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
//    _iconnection = nil;
    
	//设置发送状态
    _isSending = NO;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
//    NSLog(@"%@", error);
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"MSG_10", @"抱歉, 发送失败, 网络问题, 请稍后再试, 或者您也可以先去学习, 一会再给我们发反馈"), kSaidText, [NSNumber numberWithBool:NO], kSaidIsUser, nil];
    
    [self.messages addObject:dic];
    [self doSendAction];
    
    [self stopDownload];
    
    //设置发送状态
    _isSending = NO;
}

@end
