//
//  DictTableViewController.m
//  JLPT1ListeningFree
//
//  Created by iyuba on 13-7-26.
//
//

#import "DictTableViewController.h"
#import "DictInfoCell.h"
#import "UserSetting.h"

@interface DictTableViewController ()

@property int currentIndex;

@property (nonatomic, retain)NSMutableArray *dictSelectionArray;

@end

@implementation DictTableViewController

- (void)dealloc {
    
    [_dictSelectionArray release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setHidesBottomBarWhenPushed:YES];
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
        
    }
    
    return self;
}

- (void)backToTop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    self.navigationItem.title = @"强度选择";
    
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"DICT_SELECTION", nil)];
    
    _dictSelectionArray = [[NSMutableArray alloc] init];
//    [UserSetting setStudyTimeInfoArray:_dictSelectionArray];
    if ([TestType isEnglishTest]) {
        _dictSelectionArray = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"EN_CN", nil), NSLocalizedString(@"EN_JP", nil), NSLocalizedString(@"EN_EN", nil), nil];
    } else if ([TestType isJapaneseTest]) {
        _dictSelectionArray = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"JP_CN", nil), NSLocalizedString(@"JP_EN", nil), NSLocalizedString(@"JP_TCN", nil), NSLocalizedString(@"JP_KR", nil), nil];
    } else if ([TestType isChineseTest]) {
        _dictSelectionArray = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"CN_EN", nil), NSLocalizedString(@"CN_JP", nil), NSLocalizedString(@"CN_KR", nil), nil];
    } else {
        NSAssert(NO, @"没有正确的词典");
    }
    
    self.currentIndex = -1;
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (IS_IPAD ? 70 : 44);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    //    NSLog(@"%d", self.dictSelectionArray.count);
    return self.dictSelectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DictInfoCell";
    DictInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil] objectAtIndex:(IS_IPAD ? 1 : 0)];
        
    }
    
    // Configure the cell...
    NSString *DictName = [_dictSelectionArray objectAtIndex:indexPath.row];
    [cell setDictNameWithDictName:DictName];
    
    DictTypeTags dictNameType = [UserSetting dictTypeWithDictName:DictName];
    DictTypeTags dictType = [UserSetting dictType];
    if (dictNameType == dictType) {
        self.currentIndex = indexPath.row;
    }
    
    if(indexPath.row==_currentIndex){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return NSLocalizedString(@"NEXT_DAY_EFFECT", @"设定强度将在第二天生效");
//}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dictName = [_dictSelectionArray objectAtIndex:indexPath.row];
    
    DictTypeTags dictType = [UserSetting dictTypeWithDictName:dictName];
    [UserSetting setDictType:dictType];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //    [self.tableView reloadData];
    
    if(indexPath.row==_currentIndex){
        return;
    }
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:_currentIndex
                                                   inSection:0];
    DictInfoCell *newCell = (DictInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        //        newCell.textColor=[UIColor blueColor];
    }
    DictInfoCell *oldCell = (DictInfoCell *)[tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        //        oldCell.textColor=[UIColor blackColor];
    }
    _currentIndex=indexPath.row;
}

@end
