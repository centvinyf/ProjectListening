//
//  SVRegistByPhoneViewController.h
//  iyuba
//
//  Created by Lee Seven on 13-8-30.
//  Copyright (c) 2013年 Lee Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    SignUpStatusInput,
    SignUpStatusSentAndWait,
    SignUpStatusCanBeResent,
    SignUpStatusSending,
    SignUpStatusFailed,
    SignUpStatusChecking
}SignUpStatus;
@interface SVRegistByPhoneViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *getCodeButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UITextField *userPhoneText;
@property (strong, nonatomic) IBOutlet UITextField *codeText;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)registWithEmail:(id)sender;
- (IBAction)getCodeAction:(UIButton *)sender;
- (IBAction)nextAction:(UIButton *)sender;
@end
