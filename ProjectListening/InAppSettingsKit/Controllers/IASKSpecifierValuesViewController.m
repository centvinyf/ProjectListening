//
//  IASKSpecifierValuesViewController.m
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009:
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

#import "IASKSpecifierValuesViewController.h"
#import "IASKSpecifier.h"
#import "IASKSettingsReader.h"
#import "IASKSettingsStoreUserDefaults.h"
#import "ZZPublicClass.h"

#define kCellValue      @"kCellValue"

@interface IASKSpecifierValuesViewController()
- (void)userDefaultsDidChange;
@end

@implementation IASKSpecifierValuesViewController

@synthesize tableView=_tableView;
@synthesize currentSpecifier=_currentSpecifier;
@synthesize checkedItem=_checkedItem;
@synthesize settingsReader = _settingsReader;
@synthesize settingsStore = _settingsStore;

- (void) updateCheckedItem {
    NSInteger index;
	
	// Find the currently checked item
    if([self.settingsStore objectForKey:[_currentSpecifier key]]) {
      index = [[_currentSpecifier multipleValues] indexOfObject:[self.settingsStore objectForKey:[_currentSpecifier key]]];
    } else {
      index = [[_currentSpecifier multipleValues] indexOfObject:[_currentSpecifier defaultValue]];
    }
	[self setCheckedItem:[NSIndexPath indexPathForRow:index inSection:0]];
}

- (id<IASKSettingsStore>)settingsStore {
    if(_settingsStore == nil) {
        _settingsStore = [[IASKSettingsStoreUserDefaults alloc] init];
    }
    return _settingsStore;
}

- (void)viewDidLoad {
    
    [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
    
    if (IS_IPAD) {
        [_tableView.backgroundView setAlpha:0];
    }
    
    [super viewDidLoad];
    
    
}

- (void)backToTop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (_currentSpecifier) {
        [self setTitle:[_currentSpecifier title]];
        [self updateCheckedItem];
    }
    
    if (_tableView) {
        [_tableView reloadData];

		// Make sure the currently checked item is visible
        [_tableView scrollToRowAtIndexPath:[self checkedItem] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
	[super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
	[_tableView flashScrollIndicators];
	[super viewDidAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userDefaultsDidChange)
												 name:NSUserDefaultsDidChangeNotification
											   object:[NSUserDefaults standardUserDefaults]];
}

- (void)viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
	[super viewDidDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.tableView = nil;
}


- (void)dealloc {
    [_currentSpecifier release], _currentSpecifier = nil;
	[_checkedItem release], _checkedItem = nil;
	[_settingsReader release], _settingsReader = nil;
    [_settingsStore release], _settingsStore = nil;
	[_tableView release], _tableView = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_currentSpecifier multipleValuesCount];
}

- (void)selectCell:(UITableViewCell *)cell isChangeColor:(BOOL)isChange {
	[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    if (isChange) {
        [[cell textLabel] setTextColor:kIASKgrayBlueColor];
    }
}

- (void)deselectCell:(UITableViewCell *)cell isChangeColor:(BOOL)isChange {
	[cell setAccessoryType:UITableViewCellAccessoryNone];
    if (isChange) {
        [[cell textLabel] setTextColor:[UIColor darkTextColor]];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [_currentSpecifier footerText];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //背景设置透明
    [tableView.backgroundView setAlpha:0];
    
    UITableViewCell *cell   = [tableView dequeueReusableCellWithIdentifier:kCellValue];
    
    NSArray *titles         = [_currentSpecifier multipleTitles];
    NSArray *values         = [_currentSpecifier multipleValues];
	
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellValue] autorelease];
		cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	
	if ([indexPath isEqual:[self checkedItem]]) {
		[self selectCell:cell isChangeColor:YES];
    } else {
        [self deselectCell:cell isChangeColor:YES];
    }
	
	@try {
        if ([[_currentSpecifier key] isEqualToString:@"mulValueColor"]) {
            UIColor *color = [UIColor colorWithRed:0.827f green:0.051f blue:0.270f alpha:1];
            switch ([[values objectAtIndex:indexPath.row] intValue]) {
                case 2:
                    //橘黄
                    color = [UIColor colorWithRed:1.0f green:0.259f blue:0.0f alpha:1];
                    break;
                    
                case 3:
                    //紫色
                    color = [UIColor colorWithRed:0.557f green:0.047f blue:0.576f alpha:1];
                    break;
                    
                case 4:
                    //绿色
                    color = [UIColor colorWithRed:0.212f green:0.533f blue:0.0f alpha:1];
                    break;
                    
                case 5:
                    //蓝色
                    color = [UIColor colorWithRed:0.055f green:0.008f blue:0.529f alpha:1];
                    break;
                    
                default:
                    break;
            }
            cell.textLabel.textColor = color;
            cell.textLabel.highlightedTextColor = color;

        } else if ([[_currentSpecifier key] isEqualToString:@"mulValueFont"]){
            [cell.textLabel setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:[[values objectAtIndex:indexPath.row] intValue]]];
        }
        
        [[cell textLabel] setText:[self.settingsReader titleForStringId:[titles objectAtIndex:indexPath.row]]];
		
	}
	@catch (NSException * e) {}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (indexPath == [self checkedItem]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    NSArray *values         = [_currentSpecifier multipleValues];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if ([[_currentSpecifier key] isEqualToString:@"mulValueColor"]) {
        [self deselectCell:[tableView cellForRowAtIndexPath:[self checkedItem]] isChangeColor:NO];
        [self selectCell:cell isChangeColor:NO];
    } else {
        [self deselectCell:[tableView cellForRowAtIndexPath:[self checkedItem]] isChangeColor:YES];
        [self selectCell:cell isChangeColor:YES];
        
    }
    [self setCheckedItem:indexPath];
    
	
    [self.settingsStore setObject:[values objectAtIndex:indexPath.row] forKey:[_currentSpecifier key]];
	[self.settingsStore synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged
                                                        object:[_currentSpecifier key]
                                                      userInfo:[NSDictionary dictionaryWithObject:[values objectAtIndex:indexPath.row]
                                                                                           forKey:[_currentSpecifier key]]];

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
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

#pragma mark Notifications

- (void)userDefaultsDidChange {
	NSIndexPath *oldCheckedItem = self.checkedItem;
	if(_currentSpecifier) {
		[self updateCheckedItem];
	}
	
	// only reload the table if it had changed; prevents animation cancellation
	if (self.checkedItem != oldCheckedItem) {
		[_tableView reloadData];
	}
}

@end
