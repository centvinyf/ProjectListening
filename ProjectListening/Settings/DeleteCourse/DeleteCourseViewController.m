//
//  DeleteCourseViewController.m
//  JLPT1Listening
//
//  Created by 爱语吧 on 14-1-6.
//
//

#import "DeleteCourseViewController.h"
#include <sqlite3.h>

#define kPackName @"kPackName"
#define kPackId @"kPackId"
#define kTitleId @"kTitleId"

@interface DeleteCourseViewController () {
    sqlite3 *_database;
}

@property (nonatomic, retain)NSMutableArray *deleteArray;
@property (nonatomic, retain)NSMutableArray *fileSizeArray;

@end

@implementation DeleteCourseViewController

- (void)dealloc {
#if COCOS2D_DEBUG
    NSLog(@"DeleteCourseViewController dealloc");
#endif
    [_deleteArray release];
    [_fileSizeArray release];
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
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"DELETE_COURSE", nil)];
    
    [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
    
    [ZZPublicClass setRightButtonOnTargetNav:self action:@selector(BeginEditing:) title:NSLocalizedString(@"EDIT", nil)];
    
    _deleteArray = [[NSMutableArray alloc] init];
    _fileSizeArray = [[NSMutableArray alloc] init];
    
    NSString *dbPath = [ZZAcquirePath getDBClassFromDocuments];
    [self openDatabaseIn:dbPath];
    
    NSString *sql = @"SELECT PackName, PackId, TitleId FROM PackInfo WHERE IsDownload = 'true';";
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询DeleteCourse信息失败");
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSString *packName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
        NSNumber *packId = [NSNumber numberWithInt:sqlite3_column_int(stmt, 1)];
        NSNumber *titleId = [NSNumber numberWithInt:sqlite3_column_int(stmt, 2)];
        
        NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:packName, kPackName, packId, kPackId, titleId, kTitleId, nil];
        [_deleteArray addObject:infoDic];
        
        //        NSString * path = [ZZAcquirePath getDocDirectoryWithFileName:[NSString stringWithFormat:@"audio/%@", packName]];
        NSString * path = [ZZAcquirePath getCourseDocDirectoryWithPackId:[packId integerValue] titleId:[titleId integerValue]];
        
        float fileSize = [self folderSize:path];
        
        [_fileSizeArray addObject:[NSNumber numberWithFloat:fileSize]];
    }
    
    sqlite3_finalize(stmt);
    
    [self closeDatabase];
    
    [self.tableView reloadData];
}

- (void)backToTop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)BeginEditing:(UIBarButtonItem *)item {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (self.tableView.editing)
        [item setTitle:NSLocalizedString(@"DONE", nil)];
    else
        [item setTitle:NSLocalizedString(@"EDIT", nil)];
}

#pragma mark - Table view data source
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return NSLocalizedString(@"RESTART_DOWLOAD", @"程序重启后可在题库界面重新下载");
//}

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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int row = indexPath.row;
    
    NSDictionary *infoDic = [_deleteArray objectAtIndex:row];
    NSInteger titleId = [[infoDic objectForKey:kTitleId] integerValue];
    NSInteger packId = [[infoDic objectForKey:kPackId] integerValue];
    
    //删文件音频
    //    NSString *audioPath = [ZZAcquirePath getDocDirectoryWithFileName:[NSString stringWithFormat:@"audio/%@", packName]];
    NSString *audioPath = [ZZAcquirePath getCourseDocDirectoryWithPackId:packId titleId:titleId];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:audioPath error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        [fileManager removeItemAtPath:[audioPath stringByAppendingPathComponent:filename] error:NULL];
    }
    
    
    //修改PackInfo数据库标志IsDownload, Progress字段
    //修改TitleInfo表中 IsVip字段为false
    NSString *dbPath = [ZZAcquirePath getDBClassFromDocuments];
    
    [self openDatabaseIn:dbPath];
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE PackInfo SET IsDownload = 'false', Progress = 0.0, LastPlayTime = '0', LastPageNum = 0 WHERE PackId = %d AND TitleId = %d;", packId, titleId];
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    
    
    //删除Text表格内容
    sql = [NSString stringWithFormat:@"DELETE FROM Text WHERE PackId = %d AND TitleId = %d;", packId, titleId];
    errorMsg = NULL;
    if (sqlite3_exec (_database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    
    
    [self closeDatabase];
    
    [_deleteArray removeObjectAtIndex:row];
    [_fileSizeArray removeObjectAtIndex:row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return (IS_IPAD ? 70 : 44);
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
////#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_deleteArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DeleteCourseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UILabel *label = [[UILabel alloc] initWithFrame:(IS_IPAD ? CGRectMake(0, 0, 768, 70) : CGRectMake(0, 0, 320, 44))];
        [cell addSubview:label];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.tag = 100;
        [label release];
    }
    
    int i = indexPath.row;
    NSDictionary *infoDic = [_deleteArray objectAtIndex:i];
    NSString *packName = [infoDic objectForKey:kPackName];
    float fileSize = [[_fileSizeArray objectAtIndex:i] floatValue];
    UILabel *infoLabel = (UILabel *)[cell viewWithTag:100];
    [infoLabel setText:[NSString stringWithFormat:@"%@%@:%.2fMB", packName, NSLocalizedString(@"COURSE_NEED_MEMORY", nil), fileSize]];
    
    // Configure the cell...
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
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

- (float)folderSize:(NSString *)folderPath {
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        //        NSDictionary *fileDictionary = [[NSFileManager defaultManager] fileAttributesAtPath:[folderPath stringByAppendingPathComponent:fileName] traverseLink:YES];
        fileName;
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }
    float mb = fileSize / 1024.0 / 1024.0;
    return mb;
}

@end
