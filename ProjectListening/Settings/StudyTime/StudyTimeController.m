//
//  StudyTimeController.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-21.
//
//

#import "StudyTimeController.h"
#import "UserSetting.h"
#import "StudyTimeInfoClass.h"
#import "StudyTimeCell.h"

@interface StudyTimeController ()

@property int currentIndex;

@property (nonatomic, retain)NSMutableArray *studyTimeArray;

@end

@implementation StudyTimeController

- (void)dealloc {
    
    [_studyTimeArray release];
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

    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"DIFFCULTY_SELECTION", nil)];
    
    _studyTimeArray = [[NSMutableArray alloc] init];
    [UserSetting setStudyTimeInfoArray:_studyTimeArray];
    
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
    return (IS_IPAD ? 200 : 120);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
//    NSLog(@"%d", self.studyTimeArray.count);
    return self.studyTimeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StudyTimeCell";
    StudyTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil] objectAtIndex:(IS_IPAD ? 1 : 0)];
        
    }
    StudyTimeInfoClass *STIC = [_studyTimeArray objectAtIndex:indexPath.row];
    
    int studyTime = STIC.studyTime;
    int userStudyTime = [UserSetting studyTime];
    if (studyTime == userStudyTime) {
        self.currentIndex = indexPath.row;
    }
    
    if(indexPath.row==_currentIndex){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell...
    [cell setCellInfoWithSTIC:STIC];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"NEXT_DAY_EFFECT", @"设定强度将在第二天生效");
}

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
//    return @"设定强度将在第二天生效";
//}

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
    StudyTimeInfoClass *STIC = [_studyTimeArray objectAtIndex:indexPath.row];
    
    [UserSetting setStudyTime:STIC.studyTime];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    [self.tableView reloadData];
    
    if(indexPath.row==_currentIndex){
        return;
    }
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:_currentIndex
                                                   inSection:0];
    StudyTimeCell *newCell = (StudyTimeCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
//        newCell.textColor=[UIColor blueColor];
    }
    StudyTimeCell *oldCell = (StudyTimeCell *)[tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
//        oldCell.textColor=[UIColor blackColor];
    }
    _currentIndex=indexPath.row;
}



@end
