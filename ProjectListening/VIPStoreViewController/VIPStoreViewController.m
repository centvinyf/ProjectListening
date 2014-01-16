//
//  VIPStoreViewController.m
//  ToeflListening
//
//  Created by zhaozilong on 13-6-19.
//
//

#import "VIPStoreViewController.h"
#import "UserSetting.h"

@interface VIPStoreViewController ()
@property (nonatomic, retain) UIAlertView *indicator;

@end

@implementation VIPStoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:(IS_IPAD ? @"VIPStoreViewController-iPad" : @"VIPStoreViewController") bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //为内部交易加监听事件
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
        
        [self setHidesBottomBarWhenPushed:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    [self.navigationItem setTitle:@"升级VIP"];
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"UPGRADE_VIP", nil)];
    
    self.navigationController.navigationBarHidden = NO;
    
    [self.alertLabel setText:NSLocalizedString(@"ENTRY_AGAIN_REMOVE_AD", nil)];
    [self.restoreBtn setTitle:NSLocalizedString(@"RESTORE_PURCHASE", nil) forState:UIControlStateNormal];
    
    if (IS_IPAD) {
        //
    } else {
        if (IS_IPHONE_568H) {
            CGRect pFrame = self.purchaseBtn.frame;
            pFrame.origin.y += 40;
            [self.purchaseBtn setFrame:pFrame];
            
            CGRect aFrame = self.alertLabel.frame;
            aFrame.origin.y += 40;
            [self.alertLabel setFrame:aFrame];
            
        } else {
            
        }
    }
    
    if ([UserSetting isSystemOS7]) {
//        self.view.backgroundColor = [UIColor blackColor];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backToTop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)Cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
    
    [_purchaseBtn release];
    [_restoreBtn release];
    [_alertLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setPurchaseBtn:nil];
    [self setRestoreBtn:nil];
    [self setAlertLabel:nil];
    [super viewDidUnload];
}
- (IBAction)purchaseBtnPressed:(id)sender {
    
    [self buyWhichProduct:PID_VIP_MODE];
    
    [self setIndicatorShow];
}

- (IBAction)restoreBtnPressed:(id)sender {
    //恢复内购操作
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
    [self setIndicatorShow];
}

- (void)buyWhichProduct:(NSString *)PID {
    
    if ([SKPaymentQueue canMakePayments]) {
        
        //请求产品信息
        NSArray *productArray = [[NSArray alloc] initWithObjects:PID, nil];
        
        NSSet *productSet = [NSSet setWithArray:productArray];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
        request.delegate = self;
        [request start];
        [productArray release];
        
        //        NSLog(@"允许程序内付费购买");
    } else {
        
        //        NSLog(@"不允许程序内付费购买");
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STORE_ALERT_TITLE", nil) message:NSLocalizedString(@"STORE_ALERT_MSG", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"STORE_ALERT_CLOSE", nil) otherButtonTitles:nil];
        
        [alerView show];
        [alerView release];
        
    }
}

//记录交易
-(void)recordTransaction:(NSString *)productName{
    //    NSLog(@"-----记录交易--------");
}

//处理下载内容
-(void)provideContent:(NSString *)productName{
    //    NSLog(@"-----下载--------");
    
    [UserSetting setPurchaseVIPMode:YES];
    
}

- (void)transactionCompleted:(SKPaymentTransaction *)transaction {
    
    //    NSLog(@"-----completeTransaction--------");
    // Your application should implement these two methods.
    NSString *product = transaction.payment.productIdentifier;
    if ([product length] > 0) {
        
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0) {
            [self recordTransaction:bookid];
            [self provideContent:bookid];
        }
    }
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)transactionFailed:(SKPaymentTransaction *)transaction {
    //    NSLog(@"------失败--------");
    [self setIndicatorOff];
    if (transaction.error.code != SKErrorPaymentCancelled){
        
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)transactionRestored:(SKPaymentTransaction *)transaction {
    //    NSLog(@"交易恢复处理");
    
    NSString *PID = transaction.payment.productIdentifier;
    
    if ([PID length] > 0) {
        NSArray *temp = [PID componentsSeparatedByString:@"."];
        NSString *productName = [temp lastObject];
        
        if ([productName length] > 0) {
            [self provideContent:productName];
        }
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    //    NSLog(@"-----paymentQueue--------");
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self transactionCompleted:transaction];
                
                [self setIndicatorOff];
                
                //                NSLog(@"-----交易完成 --------");
                UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STORE_ALERT_CON", nil) message:NSLocalizedString(@"STORE_ALERT_CON_MSG", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"STORE_ALERT_CON_OK", nil) otherButtonTitles:nil];
                
                [alerView show];
                [alerView release];
                
                break;
            case SKPaymentTransactionStatePurchasing:
                //                NSLog(@"-----商品添加进列表 --------");
                break;
                
            case SKPaymentTransactionStateFailed:
                [self transactionFailed:transaction];
                //                NSLog(@"-----交易失败--------");
                
                [self setIndicatorOff];
                
                UIAlertView *alerView2 =  [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"STORE_ALERT_FAIL_MSG", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"STORE_ALERT_CLOSE", nil) otherButtonTitles:nil];
                
                [alerView2 show];
                [alerView2 release];
                break;
                
            case SKPaymentTransactionStateRestored:
                //                NSLog(@"-----已经购买过该商品 --------");
                [self transactionRestored:transaction];
                
                [self setIndicatorOff];
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    
    [self setIndicatorOff];
    //    NSLog(@"restoreCompletedTransactionsFailedWithError");
    
}

//- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
//    NSLog(@"removedTransactions");
//}
//
//- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
//    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
//}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSArray *myProducts = response.products;
    if ([myProducts count] >= 1) {
        //    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
        //    NSLog(@"产品付费数量: %d", [myProducts count]);
        
        SKPayment *payment = nil;
        for (SKProduct *product in myProducts) {
            //        NSLog(@"product info");
            //        NSLog(@"SKProduct 描述信息%@", [product description]);
            //        NSLog(@"产品标题 %@" , product.localizedTitle);
            //        NSLog(@"产品描述信息: %@" , product.localizedDescription);
            //        NSLog(@"价格: %@" , product.price);
            //        NSLog(@"Product id: %@" , product.productIdentifier);
            payment = [SKPayment paymentWithProduct:product];
        }
        
        //    NSLog(@"---------发送购买请求------------");
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [request autorelease];
    } else {
        [self setIndicatorOff];
        
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SORRY", nil) message:NSLocalizedString(@"FAIL_GET_INFO", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"STORE_ALERT_CON_OK", nil) otherButtonTitles:nil];
        
        [alerView show];
        [alerView release];
    }
}

#pragma mark - SKRequestDelegate

//下载失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    [self setIndicatorOff];
    
    //    NSLog(@"-------弹出错误信息----------");
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STORE_ALERT_TITLE", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"STORE_ALERT_CLOSE", nil) otherButtonTitles:nil];
    
    [alerView show];
    [alerView release];
}

- (void)requestDidFinish:(SKRequest *)request {
    //    NSLog(@"----------反馈信息结束--------------");
}

- (void)setIndicatorShow {
    
    NSString *str = NSLocalizedString(@"PLEASE_WAIT", @"请稍后...");
    _indicator = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_indicator addSubview:indicatorView];
    [indicatorView startAnimating];
    CGRect rect = indicatorView.frame;
    rect.origin.x += 125;
    rect.origin.y += 50;
    [indicatorView setFrame:rect];
    [indicatorView release];
    [_indicator show];
    [_indicator release];
    
    [self performSelector:@selector(setIndicatorOff) withObject:nil afterDelay:30];
}

- (void)setIndicatorOff {
    if (_indicator) {
        [_indicator dismissWithClickedButtonIndex:0 animated:YES];
        _indicator = nil;
    }
}

@end
