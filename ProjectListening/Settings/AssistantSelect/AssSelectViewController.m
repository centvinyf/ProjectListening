//
//  AssSelectViewController.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-20.
//
//

#import "AssSelectViewController.h"
#import "AssInfoClass.h"
#import "AssistantCell.h"
#import "UserSetting.h"
#import "AppDelegate.h"

@interface AssSelectViewController ()
@property int currentIndex;

@property (nonatomic, retain) NSMutableArray *assInfoArray;

@end

@implementation AssSelectViewController

- (void)dealloc {
    [_assInfoArray release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        _assInfoArray = [[NSMutableArray alloc] init];
        
        [UserSetting setAssInfoArray:_assInfoArray];
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
    
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"ASSISTANT_SELECTION", @"选择助理")];
    
    
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
    return (IS_IPAD ? 250 : 110);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.assInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AssistantCell";
    AssistantCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil] objectAtIndex:(IS_IPAD ? 1 : 0)];
    }
    AssInfoClass *AIC = [self.assInfoArray objectAtIndex:indexPath.row];
    
    int assID = AIC.assID;
    int userAssID = [UserSetting assistantID];
    if (assID == userAssID) {
        self.currentIndex = indexPath.row;
    }
    
    if(indexPath.row==_currentIndex){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell...
    [cell setCellWithAIC:AIC];
    
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
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AssInfoClass *AIC = [_assInfoArray objectAtIndex:indexPath.row];
    [UserSetting setAssistantID:AIC.assID];
    [UserSetting removeAssistantTextureExcept:AIC.assID];
    
    //重新设置推送的话语
    [AppDelegate cancelLocalNotification];
    [AppDelegate createLocalNotification];
    
    
    if(indexPath.row==_currentIndex){
        return;
    }
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:_currentIndex
                                                   inSection:0];
    AssistantCell *newCell = (AssistantCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        //        newCell.textColor=[UIColor blueColor];
    }
    AssistantCell *oldCell = (AssistantCell *)[tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        //        oldCell.textColor=[UIColor blackColor];
    }
    _currentIndex=indexPath.row;
    
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"设定重启后生效, 双击home键, 长按图标点击-键关闭退出程序";
//}

@end
