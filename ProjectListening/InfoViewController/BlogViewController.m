//
//  BlogViewController.m
//  ToeicListeningFREE
//
//  Created by 赵子龙 on 13-9-24.
//
//

#import "BlogViewController.h"

@interface BlogViewController ()<UIWebViewDelegate>
@property (retain, nonatomic) IBOutlet UIWebView *blogWebView;



@end

@implementation BlogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
        
        UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BLOG_TOP", @"回到博文") style:UIBarButtonItemStyleBordered target:self action:@selector(goBackToBlog)];
        btnItem.tintColor = [TestType colorWithTestType];
        self.navigationItem.rightBarButtonItem = btnItem;
    }
    return self;
}

- (void)backToTop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.blogWebView loadHTMLString:self.blogContent baseURL:nil];
    self.blogWebView.delegate = self;
    
    self.navigationItem.title = self.blogTitle;
    
//    [self.backBtn setEnabled:NO];

    
//    [self.blogWebView setScalesPageToFit:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_blogWebView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBlogWebView:nil];
    [super viewDidUnload];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] description] isEqualToString:@"about:blank"]) {
//        [self.backBtn setEnabled:NO];
    }
    else {
//        [self.backBtn setEnabled:YES];
   
    }
    return YES;
}
- (void)goBackToBlog {
    
    [self.blogWebView loadHTMLString:self.blogContent baseURL:nil];
    
}
@end
