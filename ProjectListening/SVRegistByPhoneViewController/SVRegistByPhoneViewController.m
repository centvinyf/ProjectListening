//
//  SVRegistByPhoneViewController.m
//  iyuba
//
//  Created by Lee Seven on 13-8-30.
//  Copyright (c) 2013年 Lee Seven. All rights reserved.
//

#import "SVRegistByPhoneViewController.h"
#import "RegexKitLite.h"
#import "RegisterViewController.h"
#import "CJSONDeserializer.h"
#import "ASIHTTPRequest.h"
#import "UserSetting.h"

#define kUserInfoPhone @"userphone"
#define kUserInfoIdentifier @"identifier"

static NSInteger countdown;
@interface SVRegistByPhoneViewController ()
@property (nonatomic, assign)SignUpStatus status;
@property (nonatomic, strong)NSTimer * countDownTimer;
@property (nonatomic, strong)ASIHTTPRequest * getCodeRequest;
@property (nonatomic, strong)ASIHTTPRequest * checkCodeRequest;
@property (nonatomic,strong) NSString * errMessage;
@property (nonatomic, strong)NSDictionary * userInfo;
@end

@implementation SVRegistByPhoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    if (IS_IPAD) {
        nibNameOrNil = @"SVRegistByPhoneViewController-iPad";
    } else {
        nibNameOrNil = @"SVRegistByPhoneViewController";
    }
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"PHONE_REGISTER", @"手机号注册");
        
        self.status = SignUpStatusInput;
        
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self updateUI];

    [self.userPhoneText addTarget:self action:@selector(userPhoneTextChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.codeText addTarget:self action:@selector(codeTextChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.userPhoneText becomeFirstResponder];
    
    if ([UserSetting isSystemOS7]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)backToTop {
    if (self.getCodeRequest) {
        [self.getCodeRequest cancel];
    }
    if (self.checkCodeRequest) {
        [self.checkCodeRequest cancel];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {

    [self setGetCodeButton:nil];
    [self setNextButton:nil];
    [self setUserPhoneText:nil];
    [self setCodeText:nil];
    [self setStatusLabel:nil];
    [self setGetCodeRequest:nil];
    [self setCheckCodeRequest:nil];
    [super viewDidUnload];
}
- (void)updateUI{
    switch (self.status) {
        case SignUpStatusInput:
            self.getCodeButton.enabled = NO;
            self.nextButton.enabled = NO;
            self.statusLabel.text = NSLocalizedString(@"请输入您的手机号获取验证码", @"请输入您的手机号获取验证码");;
            self.statusLabel.textColor = [UIColor darkGrayColor];
            break;
        case SignUpStatusSentAndWait:
            self.getCodeButton.enabled = NO;
//            self.nextButton.enabled = NO;
            self.statusLabel.text = [NSString stringWithFormat:@"%@(%d%@)", NSLocalizedString(@"CODE_DELIVERY_PHONE", @"验证码已发送至您的手机"), countdown, NSLocalizedString(@"SENCONDS_REGET", @"秒后重新获取")];
            self.statusLabel.textColor = [UIColor darkGrayColor];
            break;
        case SignUpStatusCanBeResent:
            self.getCodeButton.enabled = YES;
//            self.nextButton.enabled = NO;
            self.statusLabel.text = NSLocalizedString(@"CODE_DELIVERY_PHONE", @"验证码已发送至您的手机");
            self.statusLabel.textColor = [UIColor darkGrayColor];
            break;
        case SignUpStatusSending:
            self.getCodeButton.enabled = NO;
            self.nextButton.enabled = NO;
            self.statusLabel.text = NSLocalizedString(@"GET_CODE_ING", @"正在获取验证码，请稍候");
            self.statusLabel.textColor = [UIColor darkGrayColor];
            break;
        case SignUpStatusFailed:
            self.getCodeButton.enabled = YES;
//            self.nextButton.enabled = NO;
            self.statusLabel.text = self.errMessage;
            self.statusLabel.textColor = [UIColor redColor];
            break;
        case SignUpStatusChecking:
//            self.getCodeButton.enabled = YES;
//            self.nextButton.enabled = NO;
            self.statusLabel.text = NSLocalizedString(@"CHECKING_PLEASE_WAIT", @"正在验证，请稍候");
            self.statusLabel.textColor = [UIColor darkGrayColor];
            break;
        default:
            break;
    }
}
- (void)countDown{
    if (countdown == 0) {
        if (self.countDownTimer) {
            [self.countDownTimer invalidate];
            self.countDownTimer = nil;
        }
        self.status = SignUpStatusCanBeResent;
        
    }
    else
        countdown--;
    [self updateUI];
    
}
- (void)startCountingDown{
    countdown = 60;
    if (self.countDownTimer) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
    
    [self countDown];
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
}
- (void)userPhoneTextChanged:(UITextField *)textField{

    if ([textField.text isMatchedByRegex:@"^1[3-8]\\d{9}$"]) {
        NSLog(@"matched:%@",textField.text);
        self.getCodeButton.enabled = YES;
    }
    else{
        self.getCodeButton.enabled = NO;
    }
    
}
- (void)codeTextChanged:(UITextField *)textField{
    if (textField.text.length > 0) {
        self.nextButton.enabled = YES;
    }
    else{
        self.nextButton.enabled = NO;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.userPhoneText) {
        
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.userPhoneText) {
       
    }
    
    return YES;
}
- (IBAction)registWithEmail:(id)sender {
    RegisterViewController * regi = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    
    [self.navigationController pushViewController:regi animated:YES];
}

- (IBAction)getCodeAction:(UIButton *)sender {
    NSString * url = [NSString stringWithFormat:@"http://api.iyuba.com.cn/sendMessage.jsp?userphone=%@",self.userPhoneText.text];//加入appid
    self.status = SignUpStatusSending;
    [self updateUI];
    if (self.getCodeRequest) {
        [self.getCodeRequest clearDelegatesAndCancel];
        self.getCodeRequest.delegate = nil;
        [self.getCodeRequest setCompletionBlock:nil];
        [self.getCodeRequest setFailedBlock:nil];
        self.getCodeRequest = nil;
    }
    
    self.getCodeRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    self.getCodeRequest.timeOutSeconds = 30;
    __weak SVRegistByPhoneViewController * weakSelf = self;
    [self.getCodeRequest setCompletionBlock:^{
        NSLog(@"response: %@",weakSelf.getCodeRequest.responseString);
        CJSONDeserializer * jsonD = [CJSONDeserializer deserializer];
        NSError * err = nil;
        NSDictionary * result = [jsonD deserializeAsDictionary:weakSelf.getCodeRequest.responseData error:&err];
        if (err) {
            weakSelf.status = SignUpStatusFailed;
            weakSelf.errMessage = NSLocalizedString(@"FAILED_SERVER_BAD", @"服务器异常，请重试");
            [weakSelf updateUI];
        }
        else{
            NSInteger resultCode = [[result objectForKey:@"result"] integerValue];
            NSInteger res_code = [[result objectForKey:@"res_code"] integerValue];
            if (resultCode == 1 && res_code == 0) {
                weakSelf.userInfo = nil;
                weakSelf.userInfo = [result copy];
                weakSelf.status = SignUpStatusSentAndWait;
                [weakSelf startCountingDown];
            }
            else if (resultCode == 0){
                weakSelf.status = SignUpStatusFailed;
                weakSelf.errMessage = NSLocalizedString(@"FAILED_PHONE_NUM_WRONG", @"获取失败，手机号格式错误");
                [weakSelf updateUI];
            }
            else if (resultCode == -1){
                weakSelf.status = SignUpStatusFailed;
                weakSelf.errMessage = NSLocalizedString(@"FAILED_PHONE_REGISTERED", @"获取失败，该手机号已被注册");
                [weakSelf updateUI];
            }
            else{
                weakSelf.status = SignUpStatusFailed;
                weakSelf.errMessage = NSLocalizedString(@"FAILED_SEND_MSG", @"短信发送失败，请重试");
                [weakSelf updateUI];
            }
        }
    }];
    [self.getCodeRequest setFailedBlock:^{
        NSLog(@"%@",weakSelf.getCodeRequest.error);
        weakSelf.status = SignUpStatusFailed;
        weakSelf.errMessage = NSLocalizedString(@"FAILED_CONNECT_INTERNET", @"网络连接失败，请重试");
        [weakSelf updateUI];
    }];
    [self.getCodeRequest startAsynchronous];
}

- (IBAction)nextAction:(UIButton *)sender {
    self.status = SignUpStatusChecking;
    [self updateUI];
    NSString * url = [NSString stringWithFormat:@"http://api.iyuba.com.cn/checkCode.jsp?userphone=%@&identifier=%@&rand_code=%@",[self.userInfo objectForKey:kUserInfoPhone],[self.userInfo objectForKey:kUserInfoIdentifier],self.codeText.text];
    if (self.checkCodeRequest) {
        [self.checkCodeRequest clearDelegatesAndCancel];
        [self.checkCodeRequest setDelegate:nil];
        [self.checkCodeRequest setCompletionBlock:nil];
        [self.checkCodeRequest setFailedBlock:nil];
        self.checkCodeRequest = nil;
    }
    self.checkCodeRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    self.checkCodeRequest.timeOutSeconds = 30;

    __weak SVRegistByPhoneViewController * weakSelf = self;
    [self.checkCodeRequest setCompletionBlock:^{
        NSLog(@"response: %@",weakSelf.getCodeRequest.responseString);
        CJSONDeserializer * jsonD = [CJSONDeserializer deserializer];
        NSError * err = nil;
        NSDictionary * result = [jsonD deserializeAsDictionary:weakSelf.checkCodeRequest.responseData error:&err];
        if (err) {
            weakSelf.status = SignUpStatusFailed;
            weakSelf.errMessage = NSLocalizedString(@"FAILED_SERVER_BAD", @"服务器异常，请重试");
            [weakSelf updateUI];
        }
        else{
            NSInteger resultCode = [[result objectForKey:@"result"] integerValue];
            if (resultCode == 1) {
                //success
                RegisterViewController * regi = [[RegisterViewController alloc] initWithMobile:[weakSelf.userInfo objectForKey:kUserInfoPhone]];
                [weakSelf.navigationController pushViewController:regi animated:YES];
            }
            else{
                //failed
                weakSelf.status = SignUpStatusFailed;
                weakSelf.nextButton.enabled = YES;
                weakSelf.errMessage = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(@"FAILED_CHECKING", @"验证失败"), [result objectForKey:@"message"]];
                [weakSelf updateUI];
            }
        }
    }];
    [self.checkCodeRequest setFailedBlock:^{
        NSLog(@"%@",weakSelf.checkCodeRequest.error);
        weakSelf.status = SignUpStatusFailed;
        weakSelf.errMessage = NSLocalizedString(@"FAILED_CONNECT_INTERNET", @"网络连接失败，请重试");
        [weakSelf updateUI];
    }];
    [self.checkCodeRequest startAsynchronous];
}
@end
