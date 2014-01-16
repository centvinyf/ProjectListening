//
//  InStoreViewController.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-17.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface InStoreViewController : UIViewController <SKPaymentTransactionObserver, SKProductsRequestDelegate, SKRequestDelegate>
@property (retain, nonatomic) IBOutlet UITableView *productTableView;
@property (retain, nonatomic) IBOutlet UIButton *restoreBtn;
- (IBAction)restoreBtnPressed:(id)sender;

@end
