//
//  testViewController.m
//  JLPT1Listening
//
//  Created by Sylar on 14-1-16.
//
//

#import "testViewController.h"

@interface testViewController ()

@end

@implementation testViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_button release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setButton:nil];
    [super viewDidUnload];
}
- (IBAction)buttonPressed:(UIButton *)sender {
    
}
@end
