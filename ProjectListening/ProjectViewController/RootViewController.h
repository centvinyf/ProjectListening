//
//  RootViewController.h
//  ProjectListening
//
//  Created by zhaozilong on 13-3-4.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssistantLayer.h"
#import "ZZAssistant.h"


@interface RootViewController : UIViewController  {
//    UINavigationController *_navController;

}

@property (assign) AMTags currAMTag;

@property (retain, nonatomic) IBOutlet UIButton *yesBtn;
@property (retain, nonatomic) IBOutlet UIButton *skipBtn;

- (IBAction)skipBtnPressed:(id)sender;
- (IBAction)yesBtnPressed:(id)sender;
//- (void)pushStudyViewControllerBySection:(NSInteger)section index:(NSInteger)row;
- (void)pushStudyViewControllerBySection:(NSInteger)section index:(NSInteger)row isContinue:(BOOL)isContinue;

- (void)setButtonStatusCurrentAMTags:(AMTags)tag;
+ (RootViewController *)sharedRootViewController;

- (void)startOfEverythingNew;

@end
