//
//  CourseListController.h
//  ToeicListeningFREE
//
//  Created by 赵子龙 on 13-12-29.
//
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"

@interface CourseListController : UITableViewController <ASIHTTPRequestDelegate,MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@end
