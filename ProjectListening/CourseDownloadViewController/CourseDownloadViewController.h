//
//  CourseDownloadViewController.h
//  JLPT1Listening
//
//  Created by 赵子龙 on 13-12-31.
//
//

#import <UIKit/UIKit.h>

#import "PackageClass.h"
#include <sqlite3.h>

#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "MrDownloadCourse.h"

@interface CourseDownloadViewController : UITableViewController <MrDownloadDelegate, ASIHTTPRequestDelegate, MBProgressHUDDelegate, UIAlertViewDelegate> {
    MBProgressHUD *HUD;
}

//- (void)pushPurchaseViewController;
- (void)downloadOrStopDownloadByRow:(int)index;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil packageID:(NSString *)packageId desc:(NSString *)desc;

//- (void)downBtnPressed:(id)sender;

- (void)purchaseSingleCourseWithPICIndex:(int)index;


@end
