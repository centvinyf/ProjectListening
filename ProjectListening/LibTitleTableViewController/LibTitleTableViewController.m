//
//  LibTitleTableViewController.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-15.
//
//

#import "LibTitleTableViewController.h"

#include <sqlite3.h>
#import "TitleInfoClass.h"
#import "TitleCell.h"
#import "StudyViewController.h"


@interface LibTitleTableViewController () {
    
    sqlite3 *_database;
    
    BOOL _isUpdated;
    
    BOOL _isComeFromFavorite;
}
@property (nonatomic, retain) NSString *packName;
@property (assign) PartTypeTags partType;
@property (nonatomic, retain) NSMutableArray *titleInfoArray;
//@property (nonatomic, retain) NSMutableArray *titleNumAndQuesNumArray;

@end

@implementation LibTitleTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)dealloc {
    
//    if (self.packName) {
//        [self.packName release], self.packName = nil;
//    }
    
    [_titleInfoArray release];
//    [_titleNumAndQuesNumArray release];
    [super dealloc];
}

- (id)initFromSettingsWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.packName = nil;
        
        //是从收藏入口进来的
        _isComeFromFavorite = YES;
        
        //初始化信息
        [self initalizeTitleInfo];
        
        [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"FAV_TEST", nil)];
        
        [ZZPublicClass setRightButtonOnTargetNav:self action:@selector(BeginEditing:) title:NSLocalizedString(@"EDIT", nil)];
        
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
    }
    return self;
}

//从收藏功能入口进来的
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.packName = nil;
        
        //是从收藏入口进来的
        _isComeFromFavorite = YES;
        
        //初始化信息
        [self initalizeTitleInfo];
        
        //设置navbar上的按钮去往生词本按钮
        UIBarButtonItem *NewWordItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"WORDS_NOTEBOOK", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(presentNewWordViewController)];
        self.navigationItem.leftBarButtonItem = NewWordItem;
        NewWordItem.tintColor = [TestType colorWithTestType];
        [NewWordItem release];
        
        [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"FAV_TEST", nil)];
        
        [ZZPublicClass setRightButtonOnTargetNav:self action:@selector(BeginEditing:) title:NSLocalizedString(@"EDIT", nil)];
    }
    return self;
}

- (void)presentNewWordViewController {
    [UIView  beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0.375];
    [self.navigationController popViewControllerAnimated:NO];
    [UIView commitAnimations];
}

//从library Part入口进来的
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil packName:(NSString *)packName partType:(PartTypeTags)partType {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.packName = packName;
        self.partType = partType;
        
        _isComeFromFavorite = NO;
        
        //初始化信息
        [self initalizeTitleInfo];
        
        //设置navbar上的按钮Back按钮
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
        
//        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", self.packName, [TestType partNameWithPartType:self.partType]];
        NSString *title = [NSString stringWithFormat:@"%@ %@", self.packName, [TestType partNameWithPartType:self.partType]];
        [ZZPublicClass setTitleOnTargetNav:self title:title];
    }
    return self;
}

//从library入口进来的
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil packName:(NSString *)packName {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.packName = packName;
        self.partType = PartTypeMAX;
        
        _isComeFromFavorite = NO;
        
        //初始化信息
        [self initalizeTitleInfo];
        
        //设置navbar上的按钮Back按钮
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
        
//        self.navigationItem.title = [NSString stringWithFormat:@"%@试题", self.packName];
        NSString *title = [NSString stringWithFormat:@"%@%@", self.packName, NSLocalizedString(@"TEST_SET", nil)];
        [ZZPublicClass setTitleOnTargetNav:self title:title];
    }
    return self;
}

- (void)initalizeTitleInfo {
    _titleInfoArray = [[NSMutableArray alloc] init];
//    _titleNumAndQuesNumArray = [[NSMutableArray alloc] init];
    [self setTitleInfoClasses];
    _isUpdated = YES;
}

- (void)backToTop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    if (_isUpdated) {
        _isUpdated = NO;
    } else {
        [self setTitleInfoClasses];
        [self.tableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)BeginEditing:(UIBarButtonItem *)item {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (self.tableView.editing)
        [item setTitle:NSLocalizedString(@"DONE", nil)];
    else
        [item setTitle:NSLocalizedString(@"EDIT", nil)];
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return (IS_IPAD ? 70 : 55);
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_titleInfoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TitleCell";
    TitleCell *cell = (TitleCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (TitleCell *)[[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:(IS_IPAD ? 1 : 0)];
    }
    
    TitleInfoClass *TIC = [_titleInfoArray objectAtIndex:indexPath.row];
    
    // Configure the cell...
    [cell setLabelInfoTitleName:TIC.titleName quesNum:TIC.quesNum rightNum:TIC.rightNum soundTime:TIC.soundTime];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_isComeFromFavorite) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!_isComeFromFavorite) {
        return;
    }
    
    int row = indexPath.row;
    
//    NSString *packName = [_deleteArray objectAtIndex:row];
    TitleInfoClass *TIC = [_titleInfoArray objectAtIndex:row];
    int titleNum = TIC.titleNum;
    
    //修改PackInfo数据库标志IsDownload, Progress字段
    //修改TitleInfo IsVip字段为false
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    
    [self openDatabaseIn:dbPath];
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE TitleInfo SET Favorite = 'false' WHERE TitleNum = %d;", titleNum];
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    
    [self closeDatabase];
    
    [self.titleInfoArray removeObjectAtIndex:row];
//    [self.titleNumAndQuesNumArray removeObjectAtIndex:row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     StudyViewController *detailViewController = [[StudyViewController alloc] initWithNibName:(IS_IPAD ? @"StudyViewController-iPad" : @"StudyViewController") bundle:nil articles:_titleInfoArray currIndex:indexPath.row + 1 totalTime:0 ymd:0 enterTypeTags:EnterTypeLibrary];
     // ...
     // Pass the selected object to the new view controller.
    [detailViewController setHidesBottomBarWhenPushed:YES];
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
    
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
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


- (void)setTitleInfoClasses {
    //清空之前的数组
    [_titleInfoArray removeAllObjects];
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:dbPath];
    
    //开始查询
    NSString *sel = nil;
    NSString *partSel = @"SELECT TitleNum, QuesNum, SoundTime, TitleName, RightNum FROM TitleInfo ";
    if (_isComeFromFavorite) {
        sel = [NSString stringWithFormat:@"%@WHERE Favorite = 'true' ORDER BY TitleNum", partSel];
    } else {
        if (self.partType == PartTypeMAX) {
            sel = [NSString stringWithFormat:@"%@WHERE PackName = '%@' ORDER BY TitleNum", partSel, _packName];
        } else {
            //判断JLPT是否是有图题的301，302，303
            //去掉了下句查询语句的ORDER BY TitleNum
            if ([TestType isJLPT] && (self.partType == PartType301 || self.partType == PartType302 || self.partType == PartType303)) {
                sel = [NSString stringWithFormat:@"%@WHERE PackName = '%@' AND (PartType = 301 OR PartType = 302 OR PartType = 303) ORDER BY TitleNum", partSel, _packName];
            } else {
                sel = [NSString stringWithFormat:@"%@WHERE PackName = '%@' AND PartType = %d ORDER BY TitleNum", partSel, _packName, self.partType];
            }
        
        }
        
    }
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询TitleInfo失败");
    }
    
    int titleNum = 0;
    int quesNum = 0;
    int soundTime = 0;
    NSString *titleName = nil;
    int rightNum = 0;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        titleNum = sqlite3_column_int(stmt, 0);
        quesNum = sqlite3_column_int(stmt, 1);
        soundTime = sqlite3_column_int(stmt, 2);
        titleName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
        rightNum = sqlite3_column_int(stmt, 4);
        
        TitleInfoClass *TIC = [TitleInfoClass titleInfoWithTitleName:titleName titleNum:titleNum quesNum:quesNum soundTime:soundTime rightNum:rightNum];
        
        [_titleInfoArray addObject:TIC];
    }
    sqlite3_finalize(stmt);
    
    //关闭数据库
    [self closeDatabase];
    
}

@end
