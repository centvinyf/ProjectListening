//
//  RegisterViewController.m
//  CET4Lite
//
//  Created by Seven Lee on 12-4-17.
//  Copyright (c) 2012年 iyuba. All rights reserved.
//

#import "RegisterViewController.h"
#import "RegexKitLite.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "NSString+MD5.h"
#import "UserSetting.h"

@interface RegisterViewController ()

@property (nonatomic, strong)NSString * mobile;

@end

@implementation RegisterViewController
@synthesize scroll;
@synthesize Password1TextField;
@synthesize Password2TextField;
@synthesize UserNameTextField;
@synthesize EmailTextField;
@synthesize LabelAfterReg;
@synthesize RegistBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSString * nibName = (IS_IPAD ? @"RegisterViewController-iPad" : @"RegisterViewController");
    self = [super initWithNibName:nibName bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        TextFieldArray = nil;
        
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
    }
    return self;
}

- (id)initWithMobile:(NSString *)mobile{
    NSString *nibName = (IS_IPAD ? @"RegisterViewController-iPad" : @"RegisterViewController");
    
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        TextFieldArray = nil;
        self.mobile = mobile;
        
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
    }
    return self;
}

- (void)backToTop {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.title = @"用户注册";
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"USER_REGISTER", nil)];
    // Do any additional setup after loading the view from its nib.
    self.scroll.contentSize = CGSizeMake(self.scroll.frame.size.width, self.scroll.frame.size.height + 90);
//    TextFieldArray = [NSArray arrayWithObjects: self.UserNameTextField, self.Password1TextField, self.Password2TextField,self.EmailTextField, nil];
    TextFieldArray = [[NSArray alloc] initWithObjects:self.UserNameTextField, self.Password1TextField, self.Password2TextField,self.EmailTextField, nil];
    TextFieldNameArray = [NSArray arrayWithObjects:NSLocalizedString(@"USERNAME", nil), NSLocalizedString(@"PASSWORD", nil), NSLocalizedString(@"PASSWORD_CONFIRM", nil), NSLocalizedString(@"EMAIL", nil), nil];
    
    //设置界面的本地化
    [self setLocalizedLayout];
    
    if ([UserSetting isSystemOS7]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.scroll = nil;
    self.UserNameTextField = nil;
    self.Password1TextField = nil;
    self.Password2TextField = nil;
    self.EmailTextField = nil;
    self.RegistBtn = nil;
    self.LabelAfterReg = nil;
    
    [self setUsernameLabel:nil];
    [self setPasswordLabel:nil];
    [self setConfirmPasswordLabel:nil];
    [self setEmailLabel:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    self.LabelAfterReg.text = @"";
    self.scroll.hidden = NO;
    self.RegistBtn.hidden = NO;
}

- (void)setLocalizedLayout {
    [self.usernameLabel setText:NSLocalizedString(@"USERNAME", nil)];
    [self.passwordLabel setText:NSLocalizedString(@"PASSWORD", nil)];
    [self.confirmPasswordLabel setText:NSLocalizedString(@"PASSWORD_CONFIRM", nil)];
    [self.emailLabel setText:NSLocalizedString(@"EMAIL", nil)];
    [self.UserNameTextField setPlaceholder:NSLocalizedString(@"USERNAME_FORMAT", nil)];
    [self.Password1TextField setPlaceholder:NSLocalizedString(@"PASSWORD_FORMAT", nil)];
    [self.Password2TextField setPlaceholder:NSLocalizedString(@"PASSWORD_FORMAT", nil)];
    [self.EmailTextField setPlaceholder:NSLocalizedString(@"INSERT_EMAIL", nil)];
    [self.RegistBtn setTitle:NSLocalizedString(@"HAND_IN", nil) forState:UIControlStateNormal];
    [self.RegistBtn setTitle:NSLocalizedString(@"HAND_IN", nil) forState:UIControlStateHighlighted];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)dismissMyself:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)RegistGo:(UIButton *)sender{
    for (int i = 0; i < 4; i++) {//验证四个输入框是否为空
        UITextField * textField = [TextFieldArray objectAtIndex:i];
        if (textField == self.EmailTextField && self.mobile) {
            continue;
        }
        if ([textField.text isEqualToString:@""]) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@%@",[TextFieldNameArray objectAtIndex:i], NSLocalizedString(@"CANNOT_BLANK", nil)] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil] ;
            [alert show];
            return;
        }
    }
    if (self.UserNameTextField.text.length > 15 || self.UserNameTextField.text.length < 4) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"WRONG_USERNAME", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
        return;
    }

    if ([Password1TextField.text compare:Password2TextField.text] != NSOrderedSame) {
        //验证两次输入的密码是否一致
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"WRONG_PASSWORD", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
        return;
    }
    if (!self.mobile && ![EmailTextField.text isMatchedByRegex:@"^([0-9a-zA-Z]([-.\\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\\w]*[0-9a-zA-Z]\\.)+[a-zA-Z]{2,9})$"]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"WRONG_EMAIL", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    [self.view.window addSubview:HUD];
    
    HUD.dimBackground = YES;
//    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText = NSLocalizedString(@"REGISTER_ING", nil);
    [HUD show:YES];
    NSString * username = self.UserNameTextField.text;
    NSString * password = [self.Password1TextField.text MD5String];
    NSString * email = self.EmailTextField.text;
    NSString * sign = [[NSString stringWithFormat:@"11002%@%@%@iyubaV2",username,password,email] MD5String];
//    apis.iyuba.com/v2/api.iyuba?protocol=10002
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:self.UserNameTextField.text forKey:@"username"];
    [params setObject:sign forKey:@"sign"];
    [params setObject:password forKey:@"password"];
    [params setObject:@"ios" forKey:@"platform"];
    [params setObject:APP_NAME forKey:@"appName"];
    [params setObject:@"xml" forKey:@"format"];
    [params setObject:[UserSetting token] forKey:@"token"];
    
//    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceTokenString"] forKey:@"token"];
    if (self.mobile) {
        [params setObject:self.mobile forKey:@"mobile"];
    }
    if (self.EmailTextField.text.length > 0) {
        [params setObject:self.EmailTextField.text forKey:@"email"];
    }
    NSString *url = @"http://api.iyuba.com.cn/v2/api.iyuba?protocol=11002";
    
    NSEnumerator * keys = [params keyEnumerator];
    for (NSString * key in keys) {
        NSString * value = [params objectForKey:key];
//        NSLog(@"key:%@,value:%@",key,value);
        url = [url stringByAppendingFormat:@"&%@=%@",key,value];
    }
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    ASIHTTPRequest * request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    request.delegate = self;
    request.timeOutSeconds = 30;
    [request startAsynchronous];
}
#pragma mark -
#pragma UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //    
    //    if (textField.tag  < 3) //前面三个
    //        [[TextFieldArray objectAtIndex:textField.tag + 1] becomeFirstResponder];
    //    else        //Email
    [textField resignFirstResponder];
//    if (!IS_IPAD) 
        [self.scroll setContentOffset:CGPointMake(0, 0) animated:YES];
    
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    CGFloat pointY = textField.frame.origin.y > 90 ? 90 : 0;
    if (!IS_IPAD) {
        [self.scroll setContentOffset:CGPointMake(0, textField.frame.origin.y - 27) animated:YES];
    }
    
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//    [self.scroll setContentOffset:CGPointMake(0, 0) animated:YES];
    return YES;
}
#pragma mark -
#pragma ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [HUD hide:YES];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOGIN_FAILED", nil) message:NSLocalizedString(@"BAD_NETWORK", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *myData = [request responseData];
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:myData options:0 error:nil];
    //    if ([request.username isEqualToString:@"regist" ]) {
    NSArray *items = [doc nodesForXPath:@"response" error:nil];
    if (items) {
        for (DDXMLElement *obj in items) {
            NSString *status = [[obj elementForName:@"result"] stringValue];
            if ([status isEqualToString:@"111"]) {
                //注册成功
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = NSLocalizedString(@"REGISTER_SUCCESS", nil);
                
                self.LabelAfterReg.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"USER", nil), self.UserNameTextField.text, NSLocalizedString(@"REGISTER_SUCCESS", nil)];
                self.LabelAfterReg.hidden = NO;
                self.RegistBtn.hidden = YES;
                self.scroll.hidden = YES;
                [UserInfo setLoggedUserID:[[obj elementForName:@"daga"] stringValue]];
                [UserInfo setLoggedUserName:self.UserNameTextField.text];
                [UserInfo setLoggedRealUserName:self.UserNameTextField.text];
                [self performSelector:@selector(dismiss) withObject:nil afterDelay:1];
                
            }else
            {
                NSString *usernameExist = NSLocalizedString(@"USERNAME_EXIST", nil);
                NSString *emailExist = NSLocalizedString(@"EMAIL_EXIST", nil);
                NSString *usernameError = NSLocalizedString(@"WRONG_USERNAME", nil);
                NSDictionary * errDic = [NSDictionary dictionaryWithObjectsAndKeys:usernameExist,@"112",emailExist,@"113",usernameError,@"114", nil];
                
                [HUD hide:YES];
                NSString *msg = [errDic objectForKey:status] ;
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REGISTER_FAILED", nil) message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    [HUD hide:NO];
}
- (void)dismiss{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
