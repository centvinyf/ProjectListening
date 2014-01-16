//
//  web.m
//  JLPT3Listening
//
//  Created by zhaozilong on 12-3-31.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "web.h"


@implementation web

@synthesize webView;
//@synthesize webSiteButton;
//@synthesize indicator = _indicator;

- (id)init {
	
	self = [super init];
	if (self) {
        //		[self setHidesBottomBarWhenPushed:YES];
		
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:@"web" bundle:nil];
            
    
    if (self) {

        [self setHidesBottomBarWhenPushed:YES];
    }
    
    return self;
    
    
}

- (void)_loadInfoContent
{
    NSURLRequest *  request;
    
    if ([TestType systemLanguage] == LanguageCN) {
        //中文介绍链接
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://app.iyuba.com/ios"]];
    } else {
        //英文介绍链接
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://app.iyuba.com/ios/indexjp.jsp"]];
    }
    
    assert(request != nil);
    
    [self.webView loadRequest:request];
    
//    if (_indicator) {
//        [_indicator indicatorStopAnimating], _indicator = nil;
//    }
}

- (void)backButtonPressed:(UIButton *)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

//- (IBAction)webSiteButtonPressed:(UIButton *)sender {

//    _indicator = [[Indicator alloc] initWithBeAddedOnView:self.view];
//    [_indicator indicatorStartAnimating];
    
	//访问主页
//	assert(self.webView != nil);
//    [self _loadInfoContent];
	
//	[self.view addSubview:webView];
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//self.tabBarController.tabBar.hidden = YES;
	self.navigationController.navigationBarHidden = NO;
//    self.navigationItem.title = @"爱语吧应用";
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"MORE_APP", nil)];
    
    [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
    
    //访问主页
	assert(self.webView != nil);
    [self _loadInfoContent];
	
}

- (void)backToTop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
}

- (void)dealloc
{
    [self->webView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


@end
