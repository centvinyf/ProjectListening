//
//  LibraryTableViewController.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-15.
//
//

#import <UIKit/UIKit.h>
#import "PackInfoClass.h"
#include <sqlite3.h>

#import "MrDownload.h"

@interface LibraryTableViewController : UITableViewController <MrDownloadDelegate>
- (void)pushPurchaseViewController;
- (void)downloadOrStopDownloadByRow:(int)index;

@end
