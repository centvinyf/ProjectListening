//
//  AboutIyubaViewController.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-20.
//
//

#import "AboutIyubaViewController.h"

@interface AboutIyubaViewController ()

@end

@implementation AboutIyubaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
//    nibNameOrNil = nil;
//    if (IS_IPAD) {
//        nibNameOrNil = @"AboutIyubaViewController";
//    } else if (IS_IPHONE_568H) {
//        nibNameOrNil = @"AboutIyubaViewController_568h";
//    } else {
//        nibNameOrNil = @"AboutIyubaViewController";
//    }
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self setHidesBottomBarWhenPushed:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"ABOUT_IYUBA", nil)];
    
    [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
    
//    NSString *imgName = nil;
//    if (IS_IPAD) {
//        imgName = @"aboutIyuba~ipad.png";
//    } else if (IS_IPHONE_568H) {
//        imgName = @"aboutIyuba-568h@2x.png";
//    } else {
//        imgName = @"aboutIyuba.png";
//    }
//    [self.imgView setImage:[UIImage imageNamed:imgName]];
}

- (void)backToTop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_imgView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setImgView:nil];
    [super viewDidUnload];
}
@end
