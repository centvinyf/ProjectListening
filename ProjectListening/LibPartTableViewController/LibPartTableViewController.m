//
//  LibPartTableViewController.m
//  ToeflListening
//
//  Created by zhaozilong on 13-6-1.
//
//

#import "LibPartTableViewController.h"
#import "LibTitleTableViewController.h"
#import "PartInfoClass.h"
#import "PartCell.h"
#include <sqlite3.h>

@interface LibPartTableViewController () {
    sqlite3 *_database;
}
@property (nonatomic, retain) NSString *packName;
@property (nonatomic, retain) NSMutableArray *PICArray;
@end

@implementation LibPartTableViewController

- (void)dealloc {
    
    [_PICArray release];
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil packName:(NSString *)packName {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.packName = packName;
        
        //初始化信息
        [self initalizePartInfo];
        
        //设置navbar上的按钮Back按钮
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
    }
    
    return self;
}

- (void)backToTop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initalizePartInfo {
    _PICArray = [[NSMutableArray alloc] init];
    
    if ([TestType isJLPT]) {
        NSString *name = self.packName;
        name = [name stringByReplacingOccurrencesOfString:@"年" withString:@""];
        name = [name stringByReplacingOccurrencesOfString:@"7月" withString:@""];
        name = [name stringByReplacingOccurrencesOfString:@"12月" withString:@""];
        int nameNum = [name intValue];
        if (nameNum <= 2009) {
            [self setJLPT2009PartInfoClasses];
        } else {
            [self setPartInfoClasses];
        }
    } else {
        [self setPartInfoClasses];
    }
    
//    _isUpdated = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *navTitle = [NSString stringWithFormat:@"%@%@", self.packName, NSLocalizedString(@"TEST_SET", nil)];
    
    [ZZPublicClass setTitleOnTargetNav:self title:navTitle];

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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return (IS_IPAD ? 70 : 55);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.PICArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PartCell";
    PartCell *cell = (PartCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil] objectAtIndex:(IS_IPAD ? 1 : 0)];
    }
    
    // Configure the cell...
    PartInfoClass *PIC = [self.PICArray objectAtIndex:indexPath.row];
    
    // Configure the cell...
    [cell setLabelInfoWithQuesNum:PIC.quesNumOfPart rightNum:PIC.rightNumOfPart partType:PIC.partType];
    
    return cell;
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
    
    PartInfoClass *PIC = [self.PICArray objectAtIndex:indexPath.row];
    LibTitleTableViewController *detailViewController = [[LibTitleTableViewController alloc] initWithNibName:@"LibTitleTableViewController" bundle:nil packName:PIC.packName partType:PIC.partType];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)setJLPT2009PartInfoClasses {
    //清空之前的数组
    [_PICArray removeAllObjects];
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:dbPath];
    
    //开始查询
    NSString *sel = [NSString stringWithFormat:@"SELECT COUNT(TitleNum), PartType, SUM(RightNum), SUM(QuesNum) FROM TitleInfo WHERE PackName = '%@' GROUP BY PartType = 304 ORDER BY PartType", self.packName];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询PartInfoClass失败");
    }
    
    int countTitleNum = 0, countRightNum = 0, countQuesNum = 0;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        int titleNum = sqlite3_column_int(stmt, 0);
        PartTypeTags partType = sqlite3_column_int(stmt, 1);
        int rightNum = sqlite3_column_int(stmt, 2);
        int quesNum = sqlite3_column_int(stmt, 3);
        
        PartInfoClass *PIC = [PartInfoClass partInfoWithPackName:self.packName partType:partType titleNum:titleNum rightNum:rightNum quesNum:quesNum];
        [self.PICArray addObject:PIC];
        
        countTitleNum += titleNum;
        countRightNum += rightNum;
        countQuesNum += quesNum;
    }
    sqlite3_finalize(stmt);
    
    //关闭数据库
    [self closeDatabase];
    
    //全部分类的数组
    PartInfoClass *PIC = [PartInfoClass partInfoWithPackName:self.packName partType:PartTypeMAX titleNum:countTitleNum rightNum:countRightNum quesNum:countQuesNum];
    [self.PICArray insertObject:PIC atIndex:0];
}


- (void)setPartInfoClasses {
    //清空之前的数组
    [_PICArray removeAllObjects];
    
    //打开数据库
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:dbPath];
    
    //开始查询
    NSString *sel = [NSString stringWithFormat:@"SELECT COUNT(TitleNum), PartType, SUM(RightNum), SUM(QuesNum) FROM TitleInfo WHERE PackName = '%@' GROUP BY PartType ORDER BY PartType", self.packName];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询PartInfoClass失败");
    }
    
    int countTitleNum = 0, countRightNum = 0, countQuesNum = 0;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        int titleNum = sqlite3_column_int(stmt, 0);
        PartTypeTags partType = sqlite3_column_int(stmt, 1);
        int rightNum = sqlite3_column_int(stmt, 2);
        int quesNum = sqlite3_column_int(stmt, 3);
        
        PartInfoClass *PIC = [PartInfoClass partInfoWithPackName:self.packName partType:partType titleNum:titleNum rightNum:rightNum quesNum:quesNum];
        [self.PICArray addObject:PIC];
        
        countTitleNum += titleNum;
        countRightNum += rightNum;
        countQuesNum += quesNum;
    }
    sqlite3_finalize(stmt);
    
    //关闭数据库
    [self closeDatabase];
    
    //全部分类的数组
    PartInfoClass *PIC = [PartInfoClass partInfoWithPackName:self.packName partType:PartTypeMAX titleNum:countTitleNum rightNum:countRightNum quesNum:countQuesNum];
    [self.PICArray insertObject:PIC atIndex:0];
}


@end
