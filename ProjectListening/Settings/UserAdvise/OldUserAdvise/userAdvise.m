//
//  userAdvise.m
//  JLPT3Listening
//
//  Created by zhaozilong on 12-3-17.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "userAdvise.h"
#import <QuartzCore/QuartzCore.h>

#define FEEDBACK_URL_UID_PLATFORM_APP_TYPE_EMAIL_CONTEXT_FORMAT @"http://172.16.94.220:8081/iyubaApi/v2/api.iyuba?protocol=91001&uid= &platform=  &app=  &type= &email= &context= &format="

@interface userAdvise ()
@property (nonatomic, retain) UIAlertView *indicator;
@property (nonatomic, retain) NSURLConnection *iconnection;

@end

@implementation userAdvise

//@synthesize indicator = _indicator;
//@synthesize iconnection;

//extern KeychainItemWrapper *keychain;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (void)dealloc {
#if COCOS2D_DEBUG    
    NSLog(@"UserAdviseViewConttroller dealloc");
#endif
	[email release];
	[advise release];
	
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"userAdvise" bundle:nil];
    
    if (self) {
        // Custom initialization.
//        [self setHidesBottomBarWhenPushed:YES];
        
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
    }
    return self;
}

- (void)backToTop {
    [self.navigationController popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    //加submit按钮
//    submit = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"USER_ADVISE_SEND",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(submitButtonPressed:)];
//    self.navigationItem.rightBarButtonItem = submit;
//    [submit release];
    
    [ZZPublicClass setRightButtonOnTargetNav:self action:@selector(submitButtonPressed:) title:NSLocalizedString(@"SEND", nil)];
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
	
	advise.layer.cornerRadius = 6;
	advise.layer.masksToBounds = YES;
	
	[email becomeFirstResponder];
	
	advise.delegate = self;
    
}

- (void)textViewDidChange:(UITextView *)textView {
	
	if ([advise.text length] == 0)
        self.navigationItem.rightBarButtonItem.enabled = NO;
    else
        self.navigationItem.rightBarButtonItem.enabled = YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	
	email = nil;
	advise = nil;
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated {
//    self.navigationItem.title = NSLocalizedString(@"NAV_TITLE_FEEDBACK",nil);
//    self.navigationItem.title = @"意见薄";
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"USER_ADVISE", nil)];
	
}

- (void)viewWillDisappear:(BOOL)animated {
//    if (_indicator) {
//        [_indicator indicatorStopAnimating], _indicator = nil;
//    }
    
    [self stopDownload];
}

- (void)stopDownload {
	if (_iconnection)
        [_iconnection cancel];
    
	if (mp3Data) {
        [mp3Data release], mp3Data = nil;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (void)submitButtonPressed:(UIBarButtonItem *)sender {
    
    [email resignFirstResponder];
    [advise resignFirstResponder];
	
	//判断网络状态
	NetworkStatus NetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
	//没有网的情况
	if (NetStatus == NotReachable) {
//        [[[Indicator alloc] initWithDisappearAlertMessage:NSLocalizedString(@"INDICATOR_NET_ERROR",nil) interval:1 onView:self.view] autorelease];
        
        [self setDisappearIndicatorWithInterval:2 msg:@"网络链接失败，请稍后再试"];
		
		
	}	
	else {
		NSString *match = [email.text stringByMatching:@"^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\\.([a-zA-Z]{2,4})$"];
        
        ////////////////
        
        NSString *jlpt = @"toeic";
        NSString *newAdvise = [advise.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        newAdvise = [newAdvise stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userID"] != nil) {//不用发email
            NSString *UID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
            // 准备开始下载的地址
            NSString *address = [NSString stringWithFormat:
                                 @"http://api.iyuba.com/mobile/ios/%@/feedback.xml?uid=%@&content=%s", jlpt, UID, [newAdvise UTF8String]];
            
            //初始化,准备下载
            mp3Data = [[NSMutableData alloc] init];
            NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
            //向服务器发送请求
            _iconnection = [NSURLConnection connectionWithRequest:URLRequest delegate:self];
            [sender setEnabled:NO];
            
            //加系统联网图标
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            //加等待图标
            [self isSetIndicatorShow:YES];
//            _indicator = [[Indicator alloc] initWithBeAddedOnView:self.view];
//            [_indicator indicatorStartAnimating];
            
            [email resignFirstResponder];
            [advise resignFirstResponder];
        }
        else {//需要发email
            if ([match length] == [email.text length] && [email.text length] != 0) {
                //直接发送
                //NSLog(@"反馈和email都有，直接发送了");
                
                // 准备开始下载的地址
                NSString *address = [NSString stringWithFormat:
                                     @"http://api.iyuba.com/mobile/ios/%@/feedback.xml?email=%s&content=%s", jlpt, [email.text UTF8String],  [newAdvise UTF8String]];
//                NSLog(@"%@", address);
                //初始化,准备下载
                mp3Data = [[NSMutableData alloc] init];
                NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
                //向服务器发送请求
                _iconnection = [NSURLConnection connectionWithRequest:URLRequest delegate:self];
                [sender setEnabled:NO];
                
                //加系统联网图标
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                
                //加等待图标
                [self isSetIndicatorShow:YES];
                
                [email resignFirstResponder];
                [advise resignFirstResponder];
                
                
            }
            else {

                [self setDisappearIndicatorWithInterval:2 msg:@"邮箱格式错误, 请从新填入"];
                
                [email becomeFirstResponder];
                [email setText:@""];
                [sender setEnabled:YES];
            }

        }
        
	}
		
}

#pragma mark -
#pragma mark connectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response  {
	
	[mp3Data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[mp3Data appendData:data];
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	DDXMLDocument *xml = [[DDXMLDocument alloc] initWithData:mp3Data options:0 error:nil];
	NSArray *items = [xml nodesForXPath:@"response" error:nil];
    
    //去掉等待图标
	[self isSetIndicatorShow:NO];
    
	if (items) {
		for (DDXMLElement *obj in items) {
			NSString *isOK = [[obj elementForName:@"status"] stringValue] ;
//			UIAlertView *alert = nil;
			if ([isOK isEqualToString:@"NG"]) {
//				NSString *msg = [[obj elementForName:@"msg"] stringValue] ;
				[self setDisappearIndicatorWithInterval:2 msg:@"发送失败，请稍后再试"];
//                [submit setEnabled:YES];
                [self.navigationItem.rightBarButtonItem setEnabled:YES];
				
			} else {
				[self setDisappearIndicatorWithInterval:2 msg:@"发送成功，谢谢反馈"];
			}
		}
	}
	[xml release];
    
    
    //隐藏系统联网图标
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    _iconnection = nil;
    
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [self isSetIndicatorShow:NO];
    
	[self setDisappearIndicatorWithInterval:2 msg:@"发送失败，请稍后再试"];
	
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    [self stopDownload];
}

#pragma mark -
#pragma mark My Methods

- (void)setDisappearIndicatorWithInterval:(float)showTime msg:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
    [alertView show];
    [alertView performSelector:@selector(dismissWithClickedButtonIndex:animated:) withObject:nil afterDelay:showTime];
    
    [alertView release];
    
    
}

- (void)isSetIndicatorShow:(BOOL)isShow {
    
    if (isShow) {
        _indicator = [[UIAlertView alloc] initWithTitle:nil message:@"请稍后..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_indicator addSubview:indicatorView];
        [indicatorView startAnimating];
        CGRect rect = indicatorView.frame;
        rect.origin.x += 125;
        rect.origin.y += 50;
        [indicatorView setFrame:rect];
        [indicatorView release];
        [_indicator show];
        [_indicator release];
        
        [_indicator performSelector:@selector(dismissWithClickedButtonIndex:animated:) withObject:nil afterDelay:30];
    } else {
        [_indicator dismissWithClickedButtonIndex:nil animated:YES];
    }
}

@end
