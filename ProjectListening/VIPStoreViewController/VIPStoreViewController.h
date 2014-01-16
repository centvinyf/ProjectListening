//
//  VIPStoreViewController.h
//  ToeflListening
//
//  Created by zhaozilong on 13-6-19.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface VIPStoreViewController : UIViewController<SKPaymentTransactionObserver, SKProductsRequestDelegate, SKRequestDelegate>
@property (retain, nonatomic) IBOutlet UIButton *purchaseBtn;
@property (retain, nonatomic) IBOutlet UIButton *restoreBtn;
- (IBAction)purchaseBtnPressed:(id)sender;
- (IBAction)restoreBtnPressed:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *alertLabel;

@end
