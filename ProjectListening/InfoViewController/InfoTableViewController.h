//
//  InfoTableViewController.h
//  ToeicListeningFREE
//
//  Created by 赵子龙 on 13-9-22.
//
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "GADBannerView.h"

@interface InfoTableViewController : UITableViewController <ASIHTTPRequestDelegate,MBProgressHUDDelegate, GADBannerViewDelegate> {
    MBProgressHUD *HUD;
}

+ (CGFloat)heightWithText:(NSString *)text constraintWidth:(CGFloat)width font:(UIFont *)font;

@end
