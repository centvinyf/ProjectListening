//
//  IASKAppSettingsViewController.m
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009-2010:
//  Luc Vandal, Edovia Inc., http://www.edovia.com
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//  All rights reserved.
// 
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz, 
//  as the original authors of this code. You can give credit in a blog post, a tweet or on 
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//


#import "IASKAppSettingsViewController.h"
#import "IASKSettingsReader.h"
#import "IASKSettingsStoreUserDefaults.h"
#import "IASKPSToggleSwitchSpecifierViewCell.h"
#import "IASKPSToggleSwitchTouchSpecifierViewCell.h"
#import "IASKPSSliderSpecifierViewCell.h"
#import "IASKPSTextFieldSpecifierViewCell.h"
#import "IASKPSTitleValueSpecifierViewCell.h"
#import "IASKSwitch.h"
#import "IASKSlider.h"
#import "IASKSpecifier.h"
#import "IASKSpecifierValuesViewController.h"
#import "IASKTextField.h"
#import "UserSetting.h"
#import "NSDate+ZZDate.h"
#import "AppDelegate.h"
#import "ZZPickerView.h"

#import "NewWordsViewController.h"
#import "LibTitleTableViewController.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;

static NSString *kIASKCredits = @"Powered by InAppSettingsKit"; // Leave this as-is!!!

#define kIASKSpecifierValuesViewControllerIndex       0
#define kIASKSpecifierChildViewControllerIndex        1

#define kIASKCreditsViewWidth                         285

CGRect IASKCGRectSwap(CGRect rect);

@interface IASKAppSettingsViewController ()
@property (nonatomic, retain) NSMutableArray *viewList;
@property (nonatomic, retain) NSIndexPath *currentIndexPath;
@property (nonatomic, retain) id currentFirstResponder;

@property (nonatomic, retain) NSIndexPath *pushTimeCellIndexPath;
@property (nonatomic, retain) UIPopoverController *popViewController;
@property (nonatomic, retain) UIViewController *sortViewController;

- (void)_textChanged:(id)sender;
- (void)synchronizeSettings;
- (void)reload;
@end

@implementation IASKAppSettingsViewController

@synthesize delegate = _delegate;
//@synthesize DADelegate = _DADelegate;
@synthesize viewList = _viewList;
@synthesize currentIndexPath = _currentIndexPath;
@synthesize settingsReader = _settingsReader;
@synthesize file = _file;
@synthesize currentFirstResponder = _currentFirstResponder;
@synthesize showCreditsFooter = _showCreditsFooter;
@synthesize showDoneButton = _showDoneButton;
@synthesize settingsStore = _settingsStore;
@synthesize tableView = _tableView;
@synthesize doneBtn = _doneBtn;

#pragma mark accessors
- (IASKSettingsReader*)settingsReader {
	if (!_settingsReader) {
		_settingsReader = [[IASKSettingsReader alloc] initWithFile:self.file];
	}
	return _settingsReader;
}

- (id<IASKSettingsStore>)settingsStore {
	if (!_settingsStore) {
		_settingsStore = [[IASKSettingsStoreUserDefaults alloc] init];
	}
	return _settingsStore;
}

- (NSString*)file {
	if (!_file) {
		return @"Root";
	}
	return [[_file retain] autorelease];
}

- (void)setFile:(NSString *)file {
	if (file != _file) {
		[_file release];
		_file = [file copy];
	}
	
    self.tableView.contentOffset = CGPointMake(0, 0);
	self.settingsReader = nil; // automatically initializes itself
}

- (BOOL)isPad {
	BOOL isPad = NO;
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 30200)
	isPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
#endif
	return isPad;
}

#pragma mark standard view controller methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        // If set to YES, will display credits for InAppSettingsKit creators
        _showCreditsFooter = NO;
        
        // If set to YES, will add a DONE button at the right of the navigation bar
        _showDoneButton = YES;
		
		if ([self isPad]) {
			self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
//            [self.tableView setBackgroundColor:[UIColor clearColor]];
		}

    }
    return self;
}

- (void)awakeFromNib {
	
	  [[NSBundle mainBundle] loadNibNamed:@"IASKAppSettingsView" owner:self options:nil];
	
	//[self init];
	// If set to YES, will display credits for InAppSettingsKit creators
	_showCreditsFooter = NO;
	
	// If set to YES, will add a DONE button at the right of the navigation bar
	// if loaded via NIB, it's likely we sit in a TabBar- or NavigationController
	// and thus don't need the Done button
	_showDoneButton = YES;
    

	if ([self isPad]) {
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
	}
}

- (NSMutableArray *)viewList {
    if (!_viewList) {
		_viewList = [[NSMutableArray alloc] init];
		[_viewList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"IASKSpecifierValuesView", @"ViewName",nil]];
		[_viewList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"IASKAppSettingsView", @"ViewName",nil]];
	}
	return _viewList;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.view = nil;
	self.viewList = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	
	[self.tableView reloadData];
//    self.navigationController.navigationBarHidden = YES;
//	self.navigationItem.rightBarButtonItem = nil;
    self.navigationController.delegate = self;
    if (_showDoneButton) {
//        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
//                                                                                    target:self 
//                                                                                    action:@selector(dismiss:)];
//        UIBarButtonItem * buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss:)];
//       // buttonItem.tintColor = [UIColor blackColor];
//        self.navigationItem.rightBarButtonItem = buttonItem;
//        [buttonItem release];
    }
    
//    self.title = NSLocalizedString(@"NAV_TITLE_SETTINGS", nil);
//    self.title = @"Settings";
//    self.navigationItem.title = @"设置";
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"TAB_MORE", nil)];
	
	if (self.currentIndexPath) {
		if (animated) {
			// animate deselection of previously selected row
			[self.tableView selectRowAtIndexPath:self.currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
			[self.tableView deselectRowAtIndexPath:self.currentIndexPath animated:YES];
		}
		self.currentIndexPath = nil;
	}
	
	[super viewWillAppear:animated];
    
    if ([self isPad]) {
        
        [self.tableView.backgroundView setAlpha:0];

    }
}

- (void)backButtonPressed {
    [self .navigationController popViewControllerAnimated:YES];
}

- (CGSize)contentSizeForViewInPopover {
    return [[self view] sizeThatFits:CGSizeMake(320, 2000)];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
	IASK_IF_IOS4_OR_GREATER([dc addObserver:self selector:@selector(synchronizeSettings) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];);
	IASK_IF_IOS4_OR_GREATER([dc addObserver:self selector:@selector(reload) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];);
	[dc addObserver:self selector:@selector(synchronizeSettings) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
}

- (void)viewWillDisappear:(BOOL)animated {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	if (!self.navigationController.delegate) {
		// hide the keyboard when we're popping from the navigation controller
		[self.currentFirstResponder resignFirstResponder];
	}
	
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([self isPad]) {
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if (![viewController isKindOfClass:[IASKAppSettingsViewController class]] && ![viewController isKindOfClass:[IASKSpecifierValuesViewController class]]) {
		[self dismiss:nil];
	}
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_viewList release], _viewList = nil;
    [_currentIndexPath release], _currentIndexPath = nil;
	[_file release], _file = nil;
	[_currentFirstResponder release], _currentFirstResponder = nil;
	[_settingsReader release], _settingsReader = nil;
    [_settingsStore release], _settingsStore = nil;
	
	_delegate = nil;

    [super dealloc];
}


#pragma mark -
#pragma mark Actionsheet
#define kDatePickerTag 100
- (void)showPickerInPopover:(CGRect)rect
{
    rect = CGRectMake(220, -350, 300, 500);
    
    _sortViewController = [[UIViewController alloc] init];
    UIView *theView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 500)];
    
    //选取时间的PickView
    ZZPickerView *pickerView = (ZZPickerView *)[[[NSBundle mainBundle] loadNibNamed:@"ZZPickerView" owner:nil options:nil] objectAtIndex:0];
    CGRect frame = pickerView.frame;
    frame.origin.y = 40;
    [pickerView setFrame:frame];
//    [actionSheet addSubview:pickerView];
    [pickerView setTag: kDatePickerTag];
    
    UIButton *OKBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [OKBtn setFrame:CGRectMake(50, 280, 200, 50)];
    [theView addSubview:OKBtn];
    [OKBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [OKBtn addTarget:self action:@selector(changeNotificationTime) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *pushArray = [UserSetting pushHourAndMinAndAMPM];
    int hour = [[pushArray objectAtIndex:0] intValue];
    int min = [[pushArray objectAtIndex:1] intValue];
    NSString *amOrPmStr = [pushArray objectAtIndex:2];
    int amOrPm = ([amOrPmStr isEqualToString:@"AM"] ? 0 : 1);
    [pickerView setAMPM:amOrPm hour:hour min:min];
    
    //
    [theView addSubview:pickerView];
    _sortViewController.view = theView;
    [theView release];
    
    _popViewController = [[UIPopoverController alloc] initWithContentViewController:_sortViewController];
    [_popViewController setPopoverContentSize:CGSizeMake(300, 350) animated:NO];
    [_popViewController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    _popViewController.delegate = self;
    ;
    [_sortViewController release];
    
    //
    //Gets an array af all of the subviews of our actionSheet
//    NSArray *subviews = [actionSheet subviews];
//    
//    [[subviews objectAtIndex:1] setFrame:CGRectMake(20, 266, 280, 46)];
//    [[subviews objectAtIndex:2] setFrame:CGRectMake(20, 317, 280, 46)];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [popoverController release];
}

- (void)pushTimeButtonPressed {
    //本地化一下子
    UIActionSheet *asheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"NOTIF_TIME_SELECTION", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [asheet showInView:[self.view superview]]; //note: in most cases this would be just self.view, but because I was doing this in a tabBar Application, I use the superview.
    
    CGRect rect;
    
    if ([UserSetting isSystemOS7]) {
        if (IS_IPAD) {
            rect = CGRectMake(0, 0, 768, 500);
        } else if (IS_IPHONE_568H) {
            rect = CGRectMake(0, 220, 320, 383);
        } else {
            rect = CGRectMake(0, 132, 320, 383);
        }
    } else {
        if (IS_IPAD) {
            rect = CGRectMake(0, 0, 768, 500);
        } else if (IS_IPHONE_568H) {
            rect = CGRectMake(0, 117 + 88, 320, 383);
        } else {
            rect = CGRectMake(0, 117, 320, 383);
        }
    }
    

    [asheet setFrame:rect];
    [asheet release];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    
    ZZPickerView *pickerView = (ZZPickerView *)[[[NSBundle mainBundle] loadNibNamed:@"ZZPickerView" owner:nil options:nil] objectAtIndex:0];
    CGRect frame = pickerView.frame;
    if ([UserSetting isSystemOS7]) {
        frame.origin.y = 20;
    } else {
        frame.origin.y = 40;
    }
    
    [pickerView setFrame:frame];
    [actionSheet addSubview:pickerView];
    [pickerView setTag: kDatePickerTag];
    
    NSArray *pushArray = [UserSetting pushHourAndMinAndAMPM];
    int hour = [[pushArray objectAtIndex:0] intValue];
    int min = [[pushArray objectAtIndex:1] intValue];
    NSString *amOrPmStr = [pushArray objectAtIndex:2];
    int amOrPm = ([amOrPmStr isEqualToString:@"AM"] ? 0 : 1);
    [pickerView setAMPM:amOrPm hour:hour min:min];
    
    
#if 0
    UIDatePicker *pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
    
    [pickerView setDatePickerMode:UIDatePickerModeTime];
    
    //Configure picker...
    [pickerView setDate:[UserSetting pushDate] animated:YES];
    [pickerView setTag: kDatePickerTag];
    //Add picker to action sheet
    [actionSheet addSubview:pickerView];
    
    [pickerView release];
#endif
    //Gets an array af all of the subviews of our actionSheet
    NSArray *subviews = [actionSheet subviews];
    
    if ([UserSetting isSystemOS7]) {
//        [[subviews objectAtIndex:1] setFrame:CGRectMake(20, 0, 280, 46)];//请选择助理学习
        [[subviews objectAtIndex:2] setFrame:CGRectMake(0, 250, 320, 46)];//确认
        [[subviews objectAtIndex:3] setFrame:CGRectMake(0, 296, 320, 46)];//取消
//        [[subviews objectAtIndex:4] setFrame:CGRectMake(20, 317, 280, 46)];//取消
    } else {
        [[subviews objectAtIndex:1] setFrame:CGRectMake(20, 266, 280, 46)];
        [[subviews objectAtIndex:2] setFrame:CGRectMake(20, 317, 280, 46)];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        
        //Gets our picker
        ZZPickerView *pickView = (ZZPickerView *) [actionSheet viewWithTag:kDatePickerTag];
        
        NSString *amOrPm = [pickView AMOrPM];
        NSString *hour = [pickView hour];
        NSString *min = [pickView minute];
        
        [UserSetting setPushHour:hour min:min amOrPm:amOrPm];
        
//        NSDate *selectedDate = [pickView date];
//        [NSDate getLocateDate:selectedDate];
        
//        NSLog(@"选择的日期是：%@", selectedDate);
        
//        [UserSetting setPushDate:selectedDate];
        
        [[(IASKPSToggleSwitchTouchSpecifierViewCell *)[self.tableView cellForRowAtIndexPath:self.pushTimeCellIndexPath] timeLabel] setText:[NSString stringWithFormat:@"%@:%@ %@", hour, min, amOrPm]];
        
        //重新设置本地通知
        [AppDelegate cancelLocalNotification];
        [AppDelegate createLocalNotification];
        
        //set Date formatter
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"hh:mm a"];
//        NSString *msg = [[NSString alloc] initWithFormat:@"The date that you had selected was, %@", [formatter stringFromDate:selectedDate]];
//        [formatter release];
//        [msg release];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Date" message:msg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//        [alert show];
//        [alert release];
        
    }
     
}

- (void)changeNotificationTime {
    //Gets our picker
    ZZPickerView *pickView = (ZZPickerView *) [_sortViewController.view viewWithTag:kDatePickerTag];
    
    NSString *amOrPm = [pickView AMOrPM];
    NSString *hour = [pickView hour];
    NSString *min = [pickView minute];
    
    [UserSetting setPushHour:hour min:min amOrPm:amOrPm];
    
    //        NSDate *selectedDate = [pickView date];
    //        [NSDate getLocateDate:selectedDate];
    
    //        NSLog(@"选择的日期是：%@", selectedDate);
    
    //        [UserSetting setPushDate:selectedDate];
    
    [[(IASKPSToggleSwitchTouchSpecifierViewCell *)[self.tableView cellForRowAtIndexPath:self.pushTimeCellIndexPath] timeLabel] setText:[NSString stringWithFormat:@"%@:%@ %@", hour, min, amOrPm]];
    
    //重新设置本地通知
    [AppDelegate cancelLocalNotification];
    [AppDelegate createLocalNotification];
    
//    [self popoverControllerDidDismissPopover:_popViewController];
    [_popViewController dismissPopoverAnimated:YES];

}

#pragma mark - Actions
- (IBAction)doneBtnPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)dismiss:(id)sender {
	[self.settingsStore synchronize];
	self.navigationController.delegate = nil;
	
	if (self.delegate && [self.delegate conformsToProtocol:@protocol(IASKSettingsDelegate)]) {
		[self.delegate settingsViewControllerDidEnd:self];
	}
}

- (void)touchToggleValue:(id)sender {
    IASKSwitch *toggle    = (IASKSwitch*)sender;
    IASKSpecifier *spec   = [_settingsReader specifierForKey:[toggle key]];
    
    if ([toggle isOn]) {
        if ([spec trueValue] != nil) {
            [self.settingsStore setObject:[spec trueValue] forKey:[toggle key]];
        }
        else {
            [self.settingsStore setBool:YES forKey:[toggle key]];
        }
        [AppDelegate createLocalNotification];
    } else {
        if ([spec falseValue] != nil) {
            [self.settingsStore setObject:[spec falseValue] forKey:[toggle key]];
        }
        else {
            [self.settingsStore setBool:NO forKey:[toggle key]];
        }
        [AppDelegate cancelLocalNotification];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged
                                                        object:[toggle key]
                                                      userInfo:[NSDictionary dictionaryWithObject:[self.settingsStore objectForKey:[toggle key]]
                                                                                           forKey:[toggle key]]];
}

- (void)toggledValue:(id)sender {
    IASKSwitch *toggle    = (IASKSwitch*)sender;
    IASKSpecifier *spec   = [_settingsReader specifierForKey:[toggle key]];
    
    if ([toggle isOn]) {
        if ([spec trueValue] != nil) {
            [self.settingsStore setObject:[spec trueValue] forKey:[toggle key]];
        }
        else {
            [self.settingsStore setBool:YES forKey:[toggle key]]; 
        }
    } else {
        if ([spec falseValue] != nil) {
            [self.settingsStore setObject:[spec falseValue] forKey:[toggle key]];
        }
        else {
            [self.settingsStore setBool:NO forKey:[toggle key]]; 
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged
                                                        object:[toggle key]
                                                      userInfo:[NSDictionary dictionaryWithObject:[self.settingsStore objectForKey:[toggle key]]
                                                                                           forKey:[toggle key]]];
}

- (void)sliderChangedValue:(id)sender {
    IASKSlider *slider = (IASKSlider*)sender;
    [self.settingsStore setFloat:[slider value] forKey:[slider key]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged
                                                        object:[slider key]
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:[slider value]]
                                                                                           forKey:[slider key]]];
}


#pragma mark -
#pragma mark UITableView Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.settingsReader numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.settingsReader numberOfRowsForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView1 heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
    if ([[specifier type] isEqualToString:kIASKCustomViewSpecifier]) {
		if ([self.delegate respondsToSelector:@selector(tableView:heightForSpecifier:)]) {
			return [self.delegate tableView:tableView1 heightForSpecifier:specifier];
		} else {
			return 0;
		}
	}
	return tableView1.rowHeight;
}

- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = [self.settingsReader titleForSection:section];
	if (0 == header.length) {
		return nil;
	}
	return header;
}

- (UIView *)tableView:(UITableView*)tableView1 viewForHeaderInSection:(NSInteger)section {
	NSString *key  = [self.settingsReader keyForSection:section];
	if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderForKey:)]) {
		return [self.delegate tableView:tableView1 viewForHeaderForKey:key];
	} else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView*)tableView1 heightForHeaderInSection:(NSInteger)section {
	NSString *key  = [self.settingsReader keyForSection:section];
	if ([self tableView:tableView1 viewForHeaderInSection:section] && [self.delegate respondsToSelector:@selector(tableView:heightForHeaderForKey:)]) {
		CGFloat result;
		if ((result = [self.delegate tableView:tableView1 heightForHeaderForKey:key])) {
			return result;
		}
		
	}
	NSString *title;
	if ((title = [self tableView:tableView1 titleForHeaderInSection:section])) {
		CGSize size = [title sizeWithFont:[UIFont boldSystemFontOfSize:[UIFont labelFontSize]] 
						constrainedToSize:CGSizeMake(tableView1.frame.size.width - 2*kIASKHorizontalPaddingGroupTitles, INFINITY)
							lineBreakMode:UILineBreakModeWordWrap];
		return size.height+kIASKVerticalPaddingGroupTitles;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSString *footerText = [self.settingsReader footerTextForSection:section];
	if (_showCreditsFooter && (section == [self.settingsReader numberOfSections]-1)) {
		// show credits since this is the last section
		if ((footerText == nil) || ([footerText length] == 0)) {
			// show the credits on their own
			return kIASKCredits;
		} else {
			// show the credits below the app's FooterText
			return [NSString stringWithFormat:@"%@\n\n%@", footerText, kIASKCredits];
		}
	} else {
		if ([footerText length] == 0) {
			return nil;
		}
		return [self.settingsReader footerTextForSection:section];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
    NSString *key           = [specifier key];

    if ([[specifier type] isEqualToString:kIASKCustomViewSpecifier] && [self.delegate respondsToSelector:@selector(tableView:cellForSpecifier:)]) {
        return [self.delegate tableView:tableView1 cellForSpecifier:specifier];
    }
	
	UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:[specifier type]];
//    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    if ([[specifier type] isEqualToString:kIASKPSToggleSwitchTouchSpecifier]) {
        if (!cell) {
            cell = (IASKPSToggleSwitchTouchSpecifierViewCell*) [[[NSBundle mainBundle] loadNibNamed:@"IASKPSToggleSwitchTouchSpecifierViewCell" owner:self options:nil] objectAtIndex:(IS_IPAD ? 1 : 0)];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        ((IASKPSToggleSwitchTouchSpecifierViewCell*)cell).label.text = [specifier title];
        NSArray *pushArray = [UserSetting pushHourAndMinAndAMPM];
        NSString *pushStr = [NSString stringWithFormat:@"%@:%@ %@", [pushArray objectAtIndex:0], [pushArray objectAtIndex:1], [pushArray objectAtIndex:2]];
        ((IASKPSToggleSwitchTouchSpecifierViewCell*)cell).timeLabel.text = pushStr;
        id currentValue = [self.settingsStore objectForKey:key];
		BOOL toggleState;
		if (currentValue) {
			if ([currentValue isEqual:[specifier trueValue]]) {
				toggleState = YES;
			} else if ([currentValue isEqual:[specifier falseValue]]) {
				toggleState = NO;
			} else {
				toggleState = [currentValue boolValue];
			}
		} else {
			toggleState = [specifier defaultBoolValue];
		}
		((IASKPSToggleSwitchTouchSpecifierViewCell*)cell).toggle.on = toggleState;
		
        [((IASKPSToggleSwitchTouchSpecifierViewCell*)cell).toggle addTarget:self action:@selector(touchToggleValue:) forControlEvents:UIControlEventValueChanged];
        [((IASKPSToggleSwitchTouchSpecifierViewCell*)cell).toggle setKey:key];
		[cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    } else if ([[specifier type] isEqualToString:kIASKPSToggleSwitchSpecifier]) {
        if (!cell) {
            cell = (IASKPSToggleSwitchSpecifierViewCell*) [[[NSBundle mainBundle] loadNibNamed:@"IASKPSToggleSwitchSpecifierViewCell" owner:self options:nil] objectAtIndex:0];
        }
        ((IASKPSToggleSwitchSpecifierViewCell*)cell).label.text = [specifier title];

		id currentValue = [self.settingsStore objectForKey:key];
		BOOL toggleState;
		if (currentValue) {
			if ([currentValue isEqual:[specifier trueValue]]) {
				toggleState = YES;
			} else if ([currentValue isEqual:[specifier falseValue]]) {
				toggleState = NO;
			} else {
				toggleState = [currentValue boolValue];
			}
		} else {
			toggleState = [specifier defaultBoolValue];
		}
		((IASKPSToggleSwitchSpecifierViewCell*)cell).toggle.on = toggleState;
		
        [((IASKPSToggleSwitchSpecifierViewCell*)cell).toggle addTarget:self action:@selector(toggledValue:) forControlEvents:UIControlEventValueChanged];
        [((IASKPSToggleSwitchSpecifierViewCell*)cell).toggle setKey:key];
		//[cell.backgroundView  removeFromSuperview];
		[cell setBackgroundColor:[UIColor clearColor]];
		//[cell setBackgroundColor:[UIColor whiteColor]];
		//[cell set]
        return cell;
    }
    else if ([[specifier type] isEqualToString:kIASKPSMultiValueSpecifier]) {
        if (!cell) {
            cell = [[[IASKPSTitleValueSpecifierViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[specifier type]] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
		}
        [[cell textLabel] setText:[specifier title]];
		[[cell detailTextLabel] setText:[[specifier titleForCurrentValue:[self.settingsStore objectForKey:key] != nil ? 
										 [self.settingsStore objectForKey:key] : [specifier defaultValue]] description]];
        return cell;
    }
    else if ([[specifier type] isEqualToString:kIASKPSTitleValueSpecifier]) {
        if (!cell) {
            cell = [[[IASKPSTitleValueSpecifierViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[specifier type]] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.backgroundColor = [UIColor whiteColor];
        }
		
		cell.textLabel.text = [specifier title];
		id value = [self.settingsStore objectForKey:key] ? : [specifier defaultValue];
		
		NSString *stringValue;
		if ([specifier multipleValues] || [specifier multipleTitles]) {
			stringValue = [specifier titleForCurrentValue:value];
		} else {
			stringValue = [value description];
		}

		cell.detailTextLabel.text = stringValue;
		[cell setUserInteractionEnabled:NO];
		
        return cell;
    }
    else if ([[specifier type] isEqualToString:kIASKPSVersionValueSpecifierZZL]) {
        if (!cell) {
            cell = [[[IASKPSTitleValueSpecifierViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[specifier type]] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.backgroundColor = [UIColor whiteColor];
        }
		
		cell.textLabel.text = [specifier title];
		id value = [self.settingsStore objectForKey:key] ? : [specifier defaultValue];
		
		NSString *stringValue;
		if ([specifier multipleValues] || [specifier multipleTitles]) {
			stringValue = [specifier titleForCurrentValue:value];
		} else {
			stringValue = [value description];
		}
        
		cell.detailTextLabel.text = [UserSetting applicationVersion];
		[cell setUserInteractionEnabled:NO];
		
        return cell;
    }
    else if ([[specifier type] isEqualToString:kIASKPSTextFieldSpecifier]) {
        if (!cell) {
            cell = (IASKPSTextFieldSpecifierViewCell*) [[[NSBundle mainBundle] loadNibNamed:@"IASKPSTextFieldSpecifierViewCell" 
                                                                                      owner:self 
                                                                                    options:nil] objectAtIndex:0];

            ((IASKPSTextFieldSpecifierViewCell*)cell).textField.textAlignment = UITextAlignmentLeft;
            ((IASKPSTextFieldSpecifierViewCell*)cell).textField.returnKeyType = UIReturnKeyDone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

		((IASKPSTextFieldSpecifierViewCell*)cell).label.text = [specifier title];
      
        NSString *textValue = [self.settingsStore objectForKey:key] != nil ? [self.settingsStore objectForKey:key] : [specifier defaultStringValue];
        if (textValue && ![textValue isMemberOfClass:[NSString class]]) {
            textValue = [NSString stringWithFormat:@"%@", textValue];
        }
		IASKTextField *textField = ((IASKPSTextFieldSpecifierViewCell*)cell).textField;
        textField. text = textValue;
		textField.key = key;
		textField.delegate = self;
		textField.secureTextEntry = [specifier isSecure];
		textField.keyboardType = [specifier keyboardType];
		textField.autocapitalizationType = [specifier autocapitalizationType];
        [textField addTarget:self action:@selector(_textChanged:) forControlEvents:UIControlEventEditingChanged];
        if([specifier isSecure]){
			textField.autocorrectionType = UITextAutocorrectionTypeNo;
        } else {
			textField.autocorrectionType = [specifier autoCorrectionType];
        }
        [cell setNeedsLayout];
        return cell;
    }
	else if ([[specifier type] isEqualToString:kIASKPSSliderSpecifier]) {
        if (!cell) {
            cell = (IASKPSSliderSpecifierViewCell*) [[[NSBundle mainBundle] loadNibNamed:@"IASKPSSliderSpecifierViewCell" 
																				 owner:self 
																			   options:nil] objectAtIndex:0];
		}
        
        if ([[specifier minimumValueImage] length] > 0) {
            ((IASKPSSliderSpecifierViewCell*)cell).minImage.image = [UIImage imageWithContentsOfFile:[_settingsReader pathForImageNamed:[specifier minimumValueImage]]];
        }
		
        if ([[specifier maximumValueImage] length] > 0) {
            ((IASKPSSliderSpecifierViewCell*)cell).maxImage.image = [UIImage imageWithContentsOfFile:[_settingsReader pathForImageNamed:[specifier maximumValueImage]]];
		}
        
		IASKSlider *slider = ((IASKPSSliderSpecifierViewCell*)cell).slider;
        slider.minimumValue = [specifier minimumValue];
        slider.maximumValue = [specifier maximumValue];
        slider.value =  [self.settingsStore objectForKey:key] != nil ? [[self.settingsStore objectForKey:key] floatValue] : [[specifier defaultValue] floatValue];
        [slider addTarget:self action:@selector(sliderChangedValue:) forControlEvents:UIControlEventValueChanged];
        slider.key = key;
		[cell setNeedsLayout];
        return cell;
    }
    else if ([[specifier type] isEqualToString:kIASKPSChildPaneSpecifier]) {
        if (!cell) {
            cell = [[[IASKPSTitleValueSpecifierViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[specifier type]] autorelease];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }

        [[cell textLabel] setText:[specifier title]];
		[cell setBackgroundColor:[UIColor clearColor]];
//		[cell setSelectionStyle:UITableViewCellStyleValue1];
        return cell;
    } else if ([[specifier type] isEqualToString:kIASKOpenURLSpecifier]) {
        if (!cell) {
            cell = [[[IASKPSTitleValueSpecifierViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[specifier type]] autorelease];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }

		cell.textLabel.text = [specifier title];
		cell.detailTextLabel.text = [[specifier defaultValue] description];
		[cell setBackgroundColor:[UIColor clearColor]];
		return cell;        
    } else if ([[specifier type] isEqualToString:kIASKOpenRateURLSpecifierZZL]) {
        
        if (!cell) {
            cell = [[[IASKPSTitleValueSpecifierViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[specifier type]] autorelease];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
		cell.textLabel.text = [specifier title];
		cell.detailTextLabel.text = [[specifier defaultValue] description];
		[cell setBackgroundColor:[UIColor clearColor]];
		return cell;
    } else if ([[specifier type] isEqualToString:kIASKOpenWordsFavoritesZZL]) {
        if (!cell) {
            cell = [[[IASKPSTitleValueSpecifierViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[specifier type]] autorelease];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
		cell.textLabel.text = [specifier title];
		cell.detailTextLabel.text = [[specifier defaultValue] description];
		[cell setBackgroundColor:[UIColor clearColor]];
		return cell;
    } else if ([[specifier type] isEqualToString:kIASKOpenQuestionsFavoritesZZL]) {
        if (!cell) {
            cell = [[[IASKPSTitleValueSpecifierViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[specifier type]] autorelease];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
		cell.textLabel.text = [specifier title];
		cell.detailTextLabel.text = [[specifier defaultValue] description];
		[cell setBackgroundColor:[UIColor clearColor]];
		return cell;
    } else if ([[specifier type] isEqualToString:kIASKButtonSpecifier]) {
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[specifier type]] autorelease];
			cell.backgroundColor = [UIColor whiteColor];
        }
        cell.textLabel.text = [specifier title];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
		[cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    } else if ([[specifier type] isEqualToString:kIASKMailComposeSpecifier]) {
        if (!cell) {
            cell = [[[IASKPSTitleValueSpecifierViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[specifier type]] autorelease];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			cell.backgroundColor = [UIColor whiteColor];
        }
        
		cell.textLabel.text = [specifier title];
		cell.detailTextLabel.text = [[specifier defaultValue] description];
		return cell;
	} else {
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[specifier type]] autorelease];
			cell.backgroundColor = [UIColor whiteColor];
        }
        [[cell textLabel] setText:[specifier title]];
        return cell;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
	
	if ([[specifier type] isEqualToString:kIASKPSToggleSwitchSpecifier]) {
		return nil;
	} else {
		return indexPath;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
    
    if ([[specifier type] isEqualToString:kIASKPSToggleSwitchTouchSpecifier]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (IS_IPAD) {
            [self showPickerInPopover:CGRectZero];
        } else {
            [self pushTimeButtonPressed];
        }
        
        self.pushTimeCellIndexPath = indexPath;
        
        
    } else if ([[specifier type] isEqualToString:kIASKPSToggleSwitchSpecifier]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
    }
    else if ([[specifier type] isEqualToString:kIASKPSMultiValueSpecifier]) {
        IASKSpecifierValuesViewController *targetViewController = [[self.viewList objectAtIndex:kIASKSpecifierValuesViewControllerIndex] objectForKey:@"viewController"];
        
        if (targetViewController) {
            targetViewController = nil;
        }
		
        if (targetViewController == nil) {
            // the view controller has not been created yet, create it and set it to our viewList array
            // create a new dictionary with the new view controller
            NSMutableDictionary *newItemDict = [NSMutableDictionary dictionaryWithCapacity:3];
            [newItemDict addEntriesFromDictionary: [self.viewList objectAtIndex:kIASKSpecifierValuesViewControllerIndex]];	// copy the title and explain strings
            
            targetViewController = [[IASKSpecifierValuesViewController alloc] initWithNibName:@"IASKSpecifierValuesView" bundle:nil];
            // add the new view controller to the dictionary and then to the 'viewList' array
            [newItemDict setObject:targetViewController forKey:@"viewController"];
            [self.viewList replaceObjectAtIndex:kIASKSpecifierValuesViewControllerIndex withObject:newItemDict];
            [targetViewController release];
            
            // load the view controll back in to push it
            targetViewController = [[self.viewList objectAtIndex:kIASKSpecifierValuesViewControllerIndex] objectForKey:@"viewController"];
        }
        self.currentIndexPath = indexPath;
        [targetViewController setCurrentSpecifier:specifier];
        targetViewController.settingsReader = self.settingsReader;
        targetViewController.settingsStore = self.settingsStore;
        [[self navigationController] pushViewController:targetViewController animated:YES];
    }
    else if ([[specifier type] isEqualToString:kIASKPSSliderSpecifier]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else if ([[specifier type] isEqualToString:kIASKPSTextFieldSpecifier]) {
		IASKPSTextFieldSpecifierViewCell *textFieldCell = (id)[tableView cellForRowAtIndexPath:indexPath];
		[textFieldCell.textField becomeFirstResponder];
    }
    else if ([[specifier type] isEqualToString:kIASKPSChildPaneSpecifier]) {

        
        Class vcClass = [specifier viewControllerClass];
        if (vcClass) {
            SEL initSelector = [specifier viewControllerSelector];
            if (!initSelector) {
                initSelector = @selector(init);
            }
            UIViewController * vc = [vcClass performSelector:@selector(alloc)];
            [vc performSelector:initSelector withObject:[specifier file] withObject:[specifier key]];
//            NSLog(@"%@, %@", [specifier file], [specifier key]);
			if ([vc respondsToSelector:@selector(setDelegate:)]) {
				[vc performSelector:@selector(setDelegate:) withObject:self.delegate];
			}
			if ([vc respondsToSelector:@selector(setSettingsStore:)]) {
				[vc performSelector:@selector(setSettingsStore:) withObject:self.settingsStore];
			}
			self.navigationController.delegate = nil;
            [self.navigationController pushViewController:vc animated:YES];
            [vc performSelector:@selector(release)];
            return;
        }
        
        if (nil == [specifier file]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }        
        
        IASKAppSettingsViewController *targetViewController = [[self.viewList objectAtIndex:kIASKSpecifierChildViewControllerIndex] objectForKey:@"viewController"];
		
        if (targetViewController == nil) {
            // the view controller has not been created yet, create it and set it to our viewList array
            // create a new dictionary with the new view controller
            NSMutableDictionary *newItemDict = [NSMutableDictionary dictionaryWithCapacity:3];
            [newItemDict addEntriesFromDictionary: [self.viewList objectAtIndex:kIASKSpecifierChildViewControllerIndex]];	// copy the title and explain strings
            
            targetViewController = [[[self class] alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
			targetViewController.showDoneButton = NO;
			targetViewController.settingsStore = self.settingsStore; 
			targetViewController.delegate = self.delegate;

            // add the new view controller to the dictionary and then to the 'viewList' array
            [newItemDict setObject:targetViewController forKey:@"viewController"];
            [self.viewList replaceObjectAtIndex:kIASKSpecifierChildViewControllerIndex withObject:newItemDict];
            [targetViewController release];
            
            // load the view controll back in to push it
            targetViewController = [[self.viewList objectAtIndex:kIASKSpecifierChildViewControllerIndex] objectForKey:@"viewController"];
        }
        self.currentIndexPath = indexPath;
		targetViewController.file = specifier.file;
		targetViewController.title = specifier.title;
        targetViewController.showCreditsFooter = NO;
        [[self navigationController] pushViewController:targetViewController animated:YES];
    } else if ([[specifier type] isEqualToString:kIASKOpenURLSpecifier]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:specifier.file]]; 
//		NSLog(@"%@",[NSURL URLWithString:specifier.file]);
    } else if ([[specifier type] isEqualToString:kIASKOpenWordsFavoritesZZL]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NewWordsViewController *newWord = [[[NewWordsViewController alloc] initFromSettingsWithNibName:(IS_IPAD ? @"NewWordsViewController-iPad" : @"NewWordsViewController") bundle:nil] autorelease];
        
        [[self navigationController] pushViewController:newWord animated:YES];
        
    } else if ([[specifier type] isEqualToString:kIASKOpenQuestionsFavoritesZZL]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        LibTitleTableViewController *titleVC = [[[LibTitleTableViewController alloc] initFromSettingsWithNibName:(IS_IPAD ? @"LibTitleTableViewController" : @"LibTitleTableViewController") bundle:nil] autorelease];
        
        [[self navigationController] pushViewController:titleVC animated:YES];
        
    } else if ([[specifier type] isEqualToString:kIASKButtonSpecifier]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		if ([self.delegate respondsToSelector:@selector(settingsViewController:buttonTappedForKey:)]) {
			[self.delegate settingsViewController:self buttonTappedForKey:[specifier key]];
			//SEL ACtion = @selector(settingsViewController:buttonTappedForKey:);
//			[self.delegate]
			
		} else {
			// legacy code, provided for backward compatibility
			// the delegate mechanism above is much cleaner and doesn't leak
			Class buttonClass = [specifier buttonClass];
			SEL buttonAction = [specifier buttonAction];
			if ([buttonClass respondsToSelector:buttonAction]) {
				[buttonClass performSelector:buttonAction withObject:self withObject:[specifier key]];
				//NSLog(@"InAppSettingsKit Warning: Using IASKButtonSpecifier without implementing the delegate method is deprecated");
			}
		}
    } else if ([[specifier type] isEqualToString:kIASKMailComposeSpecifier]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            mailViewController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
			mailViewController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
			
            if ([specifier localizedObjectForKey:kIASKMailComposeSubject]) {
                [mailViewController setSubject:[specifier localizedObjectForKey:kIASKMailComposeSubject]];
            }
            if ([[specifier specifierDict] objectForKey:kIASKMailComposeToRecipents]) {
                [mailViewController setToRecipients:[[specifier specifierDict] objectForKey:kIASKMailComposeToRecipents]];
            }
            if ([[specifier specifierDict] objectForKey:kIASKMailComposeCcRecipents]) {
                [mailViewController setCcRecipients:[[specifier specifierDict] objectForKey:kIASKMailComposeCcRecipents]];
            }
            if ([[specifier specifierDict] objectForKey:kIASKMailComposeBccRecipents]) {
                [mailViewController setBccRecipients:[[specifier specifierDict] objectForKey:kIASKMailComposeBccRecipents]];
            }
            if ([specifier localizedObjectForKey:kIASKMailComposeBody]) {
                BOOL isHTML = NO;
                if ([[specifier specifierDict] objectForKey:kIASKMailComposeBodyIsHTML]) {
                    isHTML = [[[specifier specifierDict] objectForKey:kIASKMailComposeBodyIsHTML] boolValue];
                }
                
                if ([self.delegate respondsToSelector:@selector(mailComposeBody)]) {
                    [mailViewController setMessageBody:[self.delegate mailComposeBody] isHTML:isHTML];
                }
                else {
                    [mailViewController setMessageBody:[specifier localizedObjectForKey:kIASKMailComposeBody] isHTML:isHTML];
                }
            }

            UIViewController<MFMailComposeViewControllerDelegate> *vc = nil;
            
            if ([self.delegate respondsToSelector:@selector(viewControllerForMailComposeView)]) {
                vc = [self.delegate viewControllerForMailComposeView];
            }
            
            if (vc == nil) {
                vc = self;
            }
            
            mailViewController.mailComposeDelegate = vc;
            [vc presentModalViewController:mailViewController animated:YES];
            [mailViewController release];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Mail not configured", @"InAppSettingsKit")
                                  message:NSLocalizedString(@"This device is not configured for sending Email. Please configure the Mail settings in the Settings app.", @"InAppSettingsKit")
                                  delegate: nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"InAppSettingsKit")
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }

	} else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int num = [indexPath row];
    UIColor *color = nil;
    if (num % 2 == 1) {
        color = [UIColor colorWithRed:(CGFloat)232 / 255 green:(CGFloat)239 / 255 blue:(CGFloat)234 / 255 alpha:1.0];
    } else {
        color = [UIColor colorWithRed:(CGFloat)242 / 255 green:(CGFloat)250 / 255 blue:(CGFloat)245 / 255 alpha:1.0];
    }
    [cell setBackgroundColor:color];
    
}


#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate Function

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    // Forward the mail compose delegate
    if ([self.delegate respondsToSelector:@selector(mailComposeController: didFinishWithResult: error:)]) {
         [self.delegate mailComposeController:controller didFinishWithResult:result error:error];
     }
    
    // NOTE: No error handling is done here
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate Functions

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	self.currentFirstResponder = textField;
	return YES;
}

- (void)_textChanged:(id)sender {
    IASKTextField *text = (IASKTextField*)sender;
    [_settingsStore setObject:[text text] forKey:[text key]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged
                                                        object:[text key]
                                                      userInfo:[NSDictionary dictionaryWithObject:[text text]
                                                                                           forKey:[text key]]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	self.currentFirstResponder = nil;
	return YES;
}


#pragma mark Notifications

- (void)synchronizeSettings {
    [_settingsStore synchronize];
}

- (void)reload {
	// wait 0.5 sec until UI is available after applicationWillEnterForeground
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
}

#pragma mark CGRect Utility function
CGRect IASKCGRectSwap(CGRect rect) {
	CGRect newRect;
	newRect.origin.x = rect.origin.y;
	newRect.origin.y = rect.origin.x;
	newRect.size.width = rect.size.height;
	newRect.size.height = rect.size.width;
	return newRect;
}
@end
