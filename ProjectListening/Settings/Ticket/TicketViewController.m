//
//  TicketViewController.m
//  ToeflListeningPro
//
//  Created by zhaozilong on 13-6-24.
//
//

#import "TicketViewController.h"
#import "Reachability.h"
#import "LoginViewController.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "SevenNavigationBar.h"
#import "UserInfo.h"
#import "Tickets.h"

@interface TicketViewController ()

@end

@implementation TicketViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    nibNameOrNil = @"TicketViewController";
    if (IS_IPAD) {
        nibNameOrNil = @"TicketViewController-iPad";
    }
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"TICKET_MANAGE", nil);
        
        [self setHidesBottomBarWhenPushed:YES];
        
        //此处为arc，但是backbtn release了
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
        
        
        
    }
    return self;
}

- (void)backToTop {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [self isNeedRequestTicket];
}

- (void)viewDidAppear:(BOOL)animated {
//    [self isNeedRequestTicket];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.HUD = nil;
    
    if ([TestType systemLanguage] == LanguageCN) {
        [self.NALabel setHidden:YES];
    } else {
        [self.NALabel setHidden:NO];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_ticketBtn release];
    [_NALabel release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTicketBtn:nil];
    [self setNALabel:nil];
    [super viewDidUnload];
}

- (IBAction)ticketBtnPressed:(id)sender {
    if (![UserInfo userLoggedIn]) {
        LoginViewController *myLog = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [myLog setHidesBottomBarWhenPushed:YES];
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:myLog];
        
        CGRect rect = (IS_IPAD ? CGRectMake(0, 0, 768, 44) : CGRectMake(0, 0, 320, 44));
        SevenNavigationBar * navBar = [[SevenNavigationBar alloc] initWithFrame:rect];
        UIBarButtonItem * back = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:myLog action:@selector(Cancel:)];
        UINavigationItem * item = [[UINavigationItem alloc] initWithTitle:@"用户登录"];
        navBar.tintColor = [TestType colorWithTestType];
        
        item.leftBarButtonItem = back;
        NSArray * array = [NSArray arrayWithObject:item];
        [navBar setItems:array];
        [nav.navigationBar addSubview:navBar];
        //            [myLog.view addSubview:navBar];
        myLog.PresOrPush = YES;
        
        [self presentModalViewController:nav animated:YES];
    }
    else {
        _HUD = [[[MBProgressHUD alloc] initWithView:self.view.window] autorelease];
        [self.view.window addSubview:_HUD];
        
        _HUD.dimBackground = YES;
        
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        _HUD.delegate = nil;
        
        // Show the HUD while the provided method executes in a new thread
        [_HUD showWhileExecuting:@selector(getTicketNumRequest) onTarget:self withObject:nil animated:YES];
    }
}

- (void)isNeedRequestTicket {
    NSString *ticketNum = [Tickets toeicTicket];
    if (ticketNum != nil && ![ticketNum isEqualToString:@""] && [UserInfo userLoggedIn]) {
        [self.ticketBtn setEnabled:NO];
        [self.ticketBtn setTitle:ticketNum forState:UIControlStateDisabled];
    } else {
        [self.ticketBtn setEnabled:YES];
        [self.ticketBtn setTitle:@"点击领取报名优惠券" forState:UIControlStateNormal];
        
    }
}

- (void)getTicketNumRequest {
    
    BOOL succeed = YES;
    
    _HUD.mode = MBProgressHUDModeDeterminate;
    _HUD.labelText = @"同步中...";
    float progress = 0.1f;
    _HUD.progress = progress;
    //加系统联网图标
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSString *realUsername = [UserInfo loggedRealUserName];
    NSString *url = [NSString stringWithFormat:@"http://app.iyuba.com/toeicListening/toeicCode.jsp?userId=%@&platform=ios", realUsername];
#if COCOS2D_DEBUG
    NSLog(@"%@", url);
#endif

    
    NSString * response = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    if (response) {
        DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:response options:0 error:nil];
        NSArray *items = [doc nodesForXPath:@"response" error:nil];
        if (items) {
            for (DDXMLElement *obj in items) {
                NSInteger res = [[[obj elementForName:@"result"] stringValue] integerValue];

                if (res == 1) {
                    NSString *ticketNum = [[obj elementForName:@"code"] stringValue];
                    if ([ticketNum length] > 0 && ticketNum != nil) {
                        [self.ticketBtn setEnabled:NO];
                        [self.ticketBtn setTitle:ticketNum forState:UIControlStateDisabled];
                        [Tickets setToeicTicket:ticketNum];
                    } else {
                        [self.ticketBtn setEnabled:YES];
                        [self.ticketBtn setTitle:@"获取失败,请重试。" forState:UIControlStateNormal];
                    }
                }
            }
        }
    }
    else {
        succeed = NO;
    }

    _HUD.progress = 1.0f;
    if (succeed) {
        _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        _HUD.mode = MBProgressHUDModeCustomView;
        _HUD.labelText = NSLocalizedString(@"SYNC_DONE", nil);
    }
    else {
        _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-X.png"]];
        _HUD.mode = MBProgressHUDModeCustomView;
        _HUD.labelText = @"同步失败，网络不给力啊";
    }
    sleep(1);
    
    //加系统联网图标
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

}


@end
