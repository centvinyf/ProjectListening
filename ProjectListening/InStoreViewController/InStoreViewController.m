//
//  InStoreViewController.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-17.
//
//

#import "InStoreViewController.h"
#import "ProductInfoClass.h"

#import "ProductCell.h"
#include <sqlite3.h>
#import "UserSetting.h"

@interface InStoreViewController () {
    sqlite3 *_database;
    BOOL _isFreeAll;
}
@property (nonatomic, retain) NSMutableArray *productInfoArray;
@property (nonatomic, retain) UIAlertView *indicator;
@end

@implementation InStoreViewController

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

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isTypeVIP:(BOOL)isVIPMode {
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//        
//        //为内部交易加监听事件
//        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//        
//        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
//        
//        [self setHidesBottomBarWhenPushed:YES];
//    }
//    return self;
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //为内部交易加监听事件
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
//        [self.productTableView setScrollEnabled:NO];
//        [self.productTableView setBackgroundColor:[UIColor clearColor]];
        
        //商品类数组
        _productInfoArray = [[NSMutableArray alloc] init];
        NSString *dataPath = [ZZAcquirePath getBundleDirectoryWithFileName:PLIST_NAME_PRODUCTS];
        NSMutableArray *productArray = [NSMutableArray arrayWithContentsOfFile:dataPath];
        int count = [productArray count];
        for (int i = 0; i < count; i++) {
            NSMutableDictionary *dic = [productArray objectAtIndex:i];
            NSString *ID = [dic objectForKey:@"ProductID"];
            NSString *CName = [dic objectForKey:@"ProductNameCN"];
            NSString *EName = [dic objectForKey:@"ProductNameEN"];
            NSString *JName = [dic objectForKey:@"ProductNameJP"];
            NSString *Info = [dic objectForKey:@"ProductInfo"];
            NSString *Img = [dic objectForKey:@"ProductImg"];
            BOOL isFreeAll = [[dic objectForKey:@"ProductIsFreeAll"] boolValue];
            
            ProductInfoClass *PIC = [ProductInfoClass productInfoWithID:ID CName:CName EName:EName JName:JName info:Info imgName:Img isFreeAll:isFreeAll];
            
            [_productInfoArray addObject:PIC];
        }
        
        _isFreeAll = NO;
        
//        //从ProductPlist中取出商品列表
//        NSString *dataPath = [ZZAcquirePath getBundleDirectoryWithFileName:PLIST_NAME_PRODUCTS];
//        NSMutableDictionary *productDic = [NSDictionary dictionaryWithContentsOfFile:dataPath];
//        NSArray *IDs = [productDic objectForKey:@"ProductID"];
//        NSArray *CNames = [productDic objectForKey:@"ProductNameCN"];
//        NSArray *ENames = [productDic objectForKey:@"ProductNameEN"];
//        NSArray *JNames = [productDic objectForKey:@"ProductNameJP"];
//        NSArray *Infos = [productDic objectForKey:@"ProductInfo"];
//        NSArray *Imgs = [productDic objectForKey:@"ProductImg"];
//        
//        int count = [IDs count];
//        for (int i = 0; i < count; i++) {
//            NSString *ID = [IDs objectAtIndex:i];
//            NSString *CName = [CNames objectAtIndex:i];
//            NSString *EName = [ENames objectAtIndex:i];
//            NSString *JName = [JNames objectAtIndex:i];
//            NSString *Info = [Infos objectAtIndex:i];
//            NSString *Img = [Imgs objectAtIndex:i];
//            
//            ProductInfoClass *PIC = [ProductInfoClass productInfoWithID:ID CName:CName EName:EName JName:JName info:Info imgName:Img];
//            
//            [_productInfoArray addObject:PIC];
//
//        }
    
        
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
        
        
        [self setHidesBottomBarWhenPushed:YES];
    }
    return self;
}

- (void)backToTop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)Cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationItem setTitle:@"升级VIP"];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
#if COCOS2D_DEBUG    
    NSLog(@"InStoreViewController dealloc");
#endif
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
    
    [_productTableView release];
    [_restoreBtn release];
    [_productInfoArray release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setProductTableView:nil];
    [self setRestoreBtn:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row % 2 == 0) {
        return 20;
    } else {
        return 93;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return ([_productInfoArray count] * 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = nil;
    
    if (indexPath.row % 2 == 0) {
        CellIdentifier = @"BlankCell";
        UITableViewCell *cell = [self.productTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [cell setAlpha:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        return cell;
  
    } else {
        CellIdentifier = @"ProductCell";
        
        ProductCell *cell = [self.productTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = (ProductCell *)[[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
//            cell.parentVC = self;
        }
        
        ProductInfoClass *PIC = [_productInfoArray objectAtIndex:indexPath.row / 2];
        
        [cell setImgViewWithImgName:PIC.productImgName];
        
        if (PIC.isFreeAllLocked) {
            [cell.discountImgView setHidden:NO];
        } else {
            [cell.discountImgView setHidden:YES];
        }
        
        return cell;
    }
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row % 2 != 0) {
        [self.productTableView deselectRowAtIndexPath:indexPath animated:YES];
        
        int num = indexPath.row / 2;
        ProductInfoClass *PIC = [_productInfoArray objectAtIndex:num];
        if (PIC.isFreeAllLocked) {
            _isFreeAll = YES;
        } else {
            _isFreeAll = NO;
        }
        
#if COCOS2D_DEBUG
        NSLog(@"内购商品的ID是:%@", PIC.productID);
#endif

        [self buyWhichProduct:PIC.productID];

        
        [self setIndicatorShow];
    }
    
}

#pragma mark - Purchase Methods
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
    
    //购买成功,标记到数据库中
    //更改PackInfo数据库中的IsVip字段
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:dbPath];
    
    NSString *update = nil;
    
    if (_isFreeAll) {//全部解锁的
        update = @"UPDATE PackInfo SET IsVip = 'true';";
    } else {
        update = [NSString stringWithFormat:@"UPDATE PackInfo SET IsVip = 'true' WHERE ProductID = '%@';", productName];
    }
    
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    
    [self closeDatabase];
    
    /*****这个地方有点问题，当恢复内购的时候就不太准确，还会推送内购信息******/
    //在plist中设置purchase num数值
    if (_isFreeAll) {
        [UserSetting setPurchaseNum:0];
    } else {
        int num = [UserSetting purchaseNum];
        num--;
        if (num <= 0) {
            [UserSetting setPurchaseNum:0];
        } else {
            [UserSetting setPurchaseNum:num];
        }
    
    }
    
    
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

#pragma mark - My Methods
- (void)openDatabaseIn:(NSString *)dbPath {
    if (sqlite3_open([dbPath UTF8String], &_database) != SQLITE_OK) {
        //        sqlite3_close(database);
        
        NSAssert(NO, @"Open database failed");
    }
}

- (void)closeDatabase {
    if (sqlite3_close(_database) != SQLITE_OK) {
        NSAssert(NO, @"Close database failed");
    }
}

@end
