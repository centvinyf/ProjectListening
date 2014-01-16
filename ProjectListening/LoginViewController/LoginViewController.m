//
//  LoginViewController.m
//  CET4Lite
//
//  Created by Seven Lee on 12-4-16.
//  Copyright (c) 2012年 iyuba. All rights reserved.
//

#import "LoginViewController.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "Reachability.h"
#import "UserInfo.h"
#import "NSString+MD5.h"
#import "SFHFKeychainUtils.h"
#import "RegisterViewController.h"
#import "SVRegistByPhoneViewController.h"
#import "UserSetting.h"

@interface LoginViewController ()

@property (nonatomic, retain)ASIHTTPRequest *YuBiRequest;
@property (nonatomic, retain)ASIHTTPRequest *LoginRequest;

@end

@implementation LoginViewController
@synthesize PassWordTextField;
@synthesize UsrNameTextField;
@synthesize CurrentUsrLabel;
@synthesize LoginView;
@synthesize LogoutView;
@synthesize navBar;
@synthesize PresOrPush;
@synthesize RemPasswordBtn;
@synthesize YuBLabel;

/*
 
 "http://app.iyuba.com/pay/apiPayByDate.jsp?userId="
 + userId + "&amount=" + amount（花了多少爱与比） +"&month=" +month + "&appId=" + appId
 + "&productId=0&sign=" + sign
 
 
 */

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSString * nibName = (IS_IPAD ? @"LoginViewController-iPad" : @"LoginViewController");
    self = [super initWithNibName:nibName bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        LoggedIn = [UserInfo userLoggedIn];
        self.PresOrPush = NO; // default push
        
        [self setHidesBottomBarWhenPushed:YES];
        
        //此处为arc，但是backbtn release了
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
        
    }
    return self;
}

- (void)backToTop {
    HUD.delegate = nil;
    if (_YuBiRequest) {
        _YuBiRequest.delegate = nil;
        [_YuBiRequest clearDelegatesAndCancel], _YuBiRequest = nil;
    }
    
    if (self.LoginRequest) {
        self.LoginRequest.delegate = nil;
        [self.LoginRequest clearDelegatesAndCancel], self.LoginRequest = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    
    [self setCurLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.usernameLabel = nil;
    self.passwordLabel = nil;
    self.loginBtn = nil;
    self.registerBtn = nil;
    self.logoutBtn = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    self.navigationController.navigationBarHidden = YES;
//    self.title = @"用户登录";
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"USER_LOGIN", nil)];
    self.CurrentUsrLabel.text = [UserInfo loggedUserName];
//    [UserInfo setLoggedUserName:self.CurrentUsrLabel.text];
//    self.CurrentUsrLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedUserKey];
    NSString * user = [UserInfo loggedUserName];
    //    NSString * user = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedUserKey];
    if ([user isEqualToString:@""] || user == nil) {
        LoggedIn = NO;
        self.LogoutView.hidden = YES;
        self.LoginView.hidden = NO;
    }
    else {
        LoggedIn = YES;
        [self LoginViewWillAppear:user];
        self.LoginView.hidden = YES;
        self.LogoutView.hidden = NO;
        self.CurrentUsrLabel.text = user;
    }
    
    //本地化设置
    [self setLocalizedLayout];
    
    if ([UserSetting isSystemOS7]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.view.backgroundColor = [UIColor blackColor];
    }
    
//    [self.registerBtn setHidden:YES];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    
    [super viewWillAppear:animated];
}

- (void)setLocalizedLayout {
    //界面的本地化设置
    [self.usernameLabel setText:NSLocalizedString(@"USERNAME_OR_EMAIL", nil)];
    [self.passwordLabel setText:NSLocalizedString(@"PASSWORD", nil)];
    [self.UsrNameTextField setPlaceholder:NSLocalizedString(@"INSERT_USERNAME", nil)];
    [self.PassWordTextField setPlaceholder:NSLocalizedString(@"INSERT_PASSWORD", nil)];
    [self.curLabel setText:NSLocalizedString(@"CURRENT_USER", nil)];
    
    //按钮
    [self.RemPasswordBtn setTitle:NSLocalizedString(@"REMEBER_PASSWORD", nil) forState:UIControlStateNormal];
    [self.RemPasswordBtn setTitle:NSLocalizedString(@"REMEBER_PASSWORD", nil) forState:UIControlStateHighlighted];
    [self.RemPasswordBtn setTitle:NSLocalizedString(@"REMEBER_PASSWORD", nil) forState:UIControlStateSelected];
    [self.loginBtn setTitle:NSLocalizedString(@"LOGIN", nil) forState:UIControlStateNormal];
    [self.loginBtn setTitle:NSLocalizedString(@"LOGIN", nil) forState:UIControlStateHighlighted];
    [self.registerBtn setTitle:NSLocalizedString(@"REGISTER", nil) forState:UIControlStateNormal];
    [self.registerBtn setTitle:NSLocalizedString(@"REGISTER", nil) forState:UIControlStateHighlighted];
    [self.logoutBtn setTitle:NSLocalizedString(@"LOGOUT", nil) forState:UIControlStateNormal];
    [self.logoutBtn setTitle:NSLocalizedString(@"LOGOUT", nil) forState:UIControlStateHighlighted];
    
    
}

- (void)LoginViewWillAppear:(NSString *) user{
    self.CurrentUsrLabel.text = user;
    self.YuBLabel.text = @"正在获取...";
    Reachability * reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status == NotReachable) {
        self.YuBLabel.text = @"无网络连接";
    }
    else {
        NSString * userID = [UserInfo loggedUserID];
//        NSString * userID = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedUserID];
        NSString *url = [NSString stringWithFormat:@"http://app.iyuba.com/pay/checkApi.jsp?userId=%@",userID];
        ASIHTTPRequest * request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
        _YuBiRequest = request;
        request.delegate = self;
        [request setUsername:@"yub"];
        [request startAsynchronous];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)RemeberSNPressed:(UIButton *)sender{
    sender.selected = !sender.selected;
}
- (IBAction)Login:(UIButton *)sender{
    if (self.PassWordTextField.text.length > 0 && self.UsrNameTextField.text.length > 0) {
        NSString * username = self.UsrNameTextField.text;
        NSString * password = [self.PassWordTextField.text MD5String];
        NSString * sign = [[NSString stringWithFormat:@"11001%@%@iyubaV2",username,password] MD5String];
        NSString *token = [UserSetting token];
        NSString * urlStr = [NSString stringWithFormat:@"http://api.iyuba.com.cn/v2/api.iyuba?protocol=11001&username=%@&password=%@&sign=%@&format=xml&token=%@", username, password, sign, token];
//        NSString * urlstr = [NSString stringWithFormat:@"http://api.iyuba.com/mobile/ios/cet6/login.xml?username=%@&password=%@&md5status=0",self.UsrNameTextField.text,self.PassWordTextField.text];
#if COCOS2D_DEBUG
        NSLog(@"url:%@",urlStr);
#endif
        ASIHTTPRequest * request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        self.LoginRequest = request;
        request.delegate = self;
        request.timeOutSeconds = 20;
        [request setUsername:@"log"];
        [request startSynchronous];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NO_INFO", nil) message:NSLocalizedString(@"REQUEST_USER_INFO", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
    }
}
- (IBAction)GoToRegister:(UIButton *)sender{
    self.CurrentUsrLabel.text = @"";
    [UserInfo logOut];
//    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kLoggedUserKey];
//    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kLoggedUserID];
    self.LogoutView.hidden = YES;
    self.LoginView.hidden = NO;
//    RegisterViewController * regi = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    
    SVRegistByPhoneViewController *regi = [[SVRegistByPhoneViewController alloc] initWithNibName:@"SVRegistByPhoneViewController" bundle:nil];
    if (PresOrPush) {
        regi.navigationItem.hidesBackButton = YES;
    }
    
    if (IS_IPAD) {
        regi.view.bounds = CGRectMake(0, 0, 400, 480);
    }
    
//    [self presentModalViewController:regi animated:YES];
    [self.navigationController pushViewController:regi animated:YES];
    
}
- (IBAction)Logout:(UIButton *)sender{
    HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
	[self.view.window addSubview:HUD];
	
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"LOGOUT_ING", nil);
	
    //    [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
//    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kLoggedUserID];
//    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kLoggedUserKey];
    [UserInfo logOut];
    self.LogoutView.hidden = YES;
    self.LoginView.hidden = NO;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = NSLocalizedString(@"LOGOUT_SUCCESS", nil);
	sleep(1);
    
}

- (IBAction)Cancel:(id)sender{
    HUD.delegate = nil;
    [self popMyself];
}

- (void) popMyself{
    if (PresOrPush) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark -
#pragma UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField.tag == 0) //UsrName
        [PassWordTextField becomeFirstResponder];
    else 
        [textField resignFirstResponder];
    
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (textField.tag == 0) {
        //        KeychainItemWrapper * keychain = [[KeychainItemWrapper alloc] initWithIdentifier:textField.text accessGroup:nil];
        NSString * pass = [SFHFKeychainUtils getPasswordForUsername:textField.text andServiceName:kMyAppService error:nil];
        if (pass) {
            self.PassWordTextField.text = pass;
            self.RemPasswordBtn.selected = YES;
        }
        
    }
    return YES;
}
#pragma mark -
#pragma ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if ([request.username isEqualToString:@"log"]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOGIN_FAILED", nil) message:NSLocalizedString(@"CHECK_INTERNET", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
    }
    if ([request.username isEqualToString:@"yub"]) {
        self.YuBLabel.text = @"网络连接失败";
    }
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *myData = [request responseData];
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:myData options:0 error:nil];
    if ([request.username isEqualToString:@"yub"]) {
        NSArray *items = [doc nodesForXPath:@"response" error:nil];
        if (items) {
            for (DDXMLElement *obj in items) {
                NSString *amount = [[obj elementForName:@"amount"] stringValue];
                self.YuBLabel.text = amount;
            }
        }
    }
    
    if ([request.username isEqualToString:@"log" ]) {
        NSArray *items = [doc nodesForXPath:@"response" error:nil];
        if (items) {
            for (DDXMLElement *obj in items) {
                NSString *result = [[obj elementForName:@"result"] stringValue];
                //                s(@"status:%@",status);
                if ([result isEqualToString:@"101"]) {
                    
                    NSString *realUsername = [[obj elementForName:@"username"] stringValue];
                    [UserInfo setLoggedRealUserName:realUsername];
                    [UserInfo setLoggedUserName:self.UsrNameTextField.text];
                    
                    NSString * userID = [[obj elementForName:@"uid"] stringValue];
                    [UserInfo setLoggedUserID:userID];
                    NSString *isVIP = [[obj elementForName:@"vipStatus"] stringValue];
                    if ([isVIP isEqualToString:@"1"]) {
                        [UserInfo setIsVIP:YES];
                        [UserInfo setVIPExpireTime:[[[obj elementForName:@"expireTime"] stringValue] doubleValue]];
                    }
                    else{
                        [UserInfo setIsVIP:NO];
                        [UserInfo setVIPExpireTime:0.0];
                    }
//                    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:kLoggedUserID];
                    if (RemPasswordBtn.selected) {
                        //                        KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:self.UsrNameTextField.text accessGroup:nil];
                        //                        [keychain setObject:self.PassWordTextField.text forKey:kPasswordKey];
                        [SFHFKeychainUtils storeUsername:self.UsrNameTextField.text andPassword:self.PassWordTextField.text forServiceName:kMyAppService updateExisting:YES error:nil];
                    }
                    HUD = [[MBProgressHUD alloc] initWithView:self.view];
                    [self.view addSubview:HUD];
                    
                    // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
                    // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
                    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                    
                    // Set custom view mode
                    HUD.mode = MBProgressHUDModeCustomView;
                    
                    HUD.delegate = self;
                    HUD.labelText = NSLocalizedString(@"LOGIN_SUCCESS", nil);
                    
                    [HUD show:YES];
                    [HUD hide:YES afterDelay:1];
//                    self.CurrentUsrLabel.text = self.UsrNameTextField.text;
                    [self LoginViewWillAppear:self.UsrNameTextField.text];
                    self.LoginView.hidden = YES;
                    self.LogoutView.hidden = NO;
                    
                }else if([result isEqualToString:@"103"] || [result isEqualToString:@"102"] || [result isEqualToString:@"105"])
                {
                    NSString *msg = NSLocalizedString(@"WRONG_USER_INFO", nil) ;
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOGIN_FAILED", nil) message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    
                    [alert show];
                }
                else{
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOGIN_FAILED", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    
                    [alert show];
                }
            }
        }
    }
}

#pragma mark -
#pragma MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud{
    [self popMyself];
}
@end
