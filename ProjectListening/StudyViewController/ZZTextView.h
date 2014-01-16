//
//  ZZTextView.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-25.
//
//

#import <UIKit/UIKit.h>
#import "StudyViewController.h"

@interface ZZTextView : UITextView <UIPopoverControllerDelegate>

@property (nonatomic, assign) StudyViewController *parentVC;

@end
