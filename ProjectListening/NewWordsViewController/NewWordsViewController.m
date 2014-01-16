//
//  NewWordsViewController.m
//  CET4Lite
//
//  Created by Seven Lee on 12-2-24.
//  Copyright (c) 2012年 iyuba. All rights reserved.
//

#import "NewWordsViewController.h"
#import "UserWordCell.h"
#include <sqlite3.h>
#import "Word.h"
#import "Reachability.h"
#import "LoginViewController.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "SevenNavigationBar.h"
#import "UserInfo.h"
#import "UserSetting.h"

#import "LibTitleTableViewController.h"

@interface NewWordsViewController ()
{
    sqlite3 *_database;
}

@end
//static NSMutableArray * jjjjjjArray;
AVPlayer * player;
@implementation NewWordsViewController
@synthesize jjjjjjArray;
@synthesize tabelView;
@synthesize ToDeleteArray;

- (void)viewWillAppear:(BOOL)animated{
    [self readFromDatabase];
    [self.tabelView reloadData];
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

- (void)readFromDatabase {
    
    self.jjjjjjArray = [[NSMutableArray alloc] init];
    
    //把收藏状态存到数据库中
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:path];
    
    NSString *sql = @"SELECT Word, def, pron, audio FROM FavoriteWord ORDER BY id DESC";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询Words失败");
    }
    
    Word *thisword = nil;
    NSString * name = @"";
    NSString * defi = NSLocalizedString(@"CAN_NOT_FIND_WORD_SHORT", @"词义未找到");
    NSString * pron = @"";
    NSString * audio = @"";
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
        defi = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
        pron = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
        audio = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
        
        thisword = [[Word alloc] initWithWord:name Pron:pron Def:defi Audio:audio];
        [self.jjjjjjArray addObject:thisword];
    }
    sqlite3_finalize(stmt);
    //关闭数据库
    [self closeDatabase];

}

- (id)initFromSettingsWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [ZZPublicClass setBackButtonOnTargetNav:self action:@selector(backToTop)];
    }
    
    return self;
}

- (void)backToTop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //设置navbar上的按钮去往生词本按钮
        
        UIBarButtonItem *NewWordItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"FAV_TEST", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(presentLibTitleTableViewController)];
        NewWordItem.tintColor = [TestType colorWithTestType];
        self.navigationItem.leftBarButtonItem = NewWordItem;
    }
    
    return self;
}

- (void)presentLibTitleTableViewController {
    
    LibTitleTableViewController *LTTVC = [[LibTitleTableViewController alloc] initWithNibName:@"LibTitleTableViewController" bundle:nil];
    
    [UIView  beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];
    [self.navigationController pushViewController:LTTVC animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationItem.title = @"生词本";
    [ZZPublicClass setTitleOnTargetNav:self title:NSLocalizedString(@"WORDS_NOTEBOOK", nil)];
//    UIBarButtonItem * editButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleBordered target:self action:@selector(BeginEditing)];
//    self.navigationItem.rightBarButtonItem = editButton;
    UISegmentedControl *segmentedControl = nil;
    //只有中文系统下，英语考试，字典为英中词典的情况下才可以使用同步按钮
    if ([TestType systemLanguage] == LanguageCN && [TestType isEnglishTest] && [UserSetting dictType] == DictTypeEN_CN) {
        segmentedControl=[[UISegmentedControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 30.0f) ];
        [segmentedControl insertSegmentWithTitle:NSLocalizedString(@"SYNC", nil) atIndex:0 animated:YES];
        [segmentedControl insertSegmentWithTitle:NSLocalizedString(@"EDIT", nil) atIndex:1 animated:YES];
        [segmentedControl addTarget:self action:@selector(doSeg:) forControlEvents:UIControlEventValueChanged];
    } else {
        segmentedControl=[[UISegmentedControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 30.0f) ];
        [segmentedControl insertSegmentWithTitle:NSLocalizedString(@"EDIT", nil) atIndex:0 animated:YES];
        [segmentedControl addTarget:self action:@selector(doSegNoSync:) forControlEvents:UIControlEventValueChanged];
    }
    
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = YES;
    segmentedControl.tintColor = [TestType colorWithTestType];
    segmentedControl.multipleTouchEnabled=NO;
    
    UIBarButtonItem *segButton = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    self.navigationItem.rightBarButtonItem = segButton;
    self.ToDeleteArray = NULL;
    HUD = nil;
    [self readFromDatabase];
    self.navigationController.navigationBarHidden = NO;

}

- (void)doSegNoSync:(UISegmentedControl *)sender {
    [self BeginEditingNoSync:sender];
}

- (void)doSeg:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        if (![UserInfo userLoggedIn]) {
            LoginViewController *myLog = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            [myLog setHidesBottomBarWhenPushed:YES];
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:myLog];
            
            CGRect rect = (IS_IPAD ? CGRectMake(0, 0, 768, 44) : CGRectMake(0, 0, 320, 44));
            SevenNavigationBar * navBar = [[SevenNavigationBar alloc] initWithFrame:rect];
            UIBarButtonItem * back = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIBarButtonItemStylePlain target:myLog action:@selector(Cancel:)];
            UINavigationItem * item = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"USER_LOGIN", nil)];
            navBar.tintColor = [TestType colorWithTestType];
            
            item.leftBarButtonItem = back;
            NSArray * array = [NSArray arrayWithObject:item];
            [navBar setItems:array];
            [nav.navigationBar addSubview:navBar];
//            [myLog.view addSubview:navBar];
            myLog.PresOrPush = YES;
            
            [self presentModalViewController:nav animated:YES];
        } else {
            HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
            [self.view.window addSubview:HUD];
            
            HUD.dimBackground = YES;
            
            // Regiser for HUD callbacks so we can remove it from the window at the right time
            HUD.delegate = nil;
            
            // Show the HUD while the provided method executes in a new thread
            [HUD showWhileExecuting:@selector(SynchoWithCloud) onTarget:self withObject:nil animated:YES];
        }
            
    } else {
        [self BeginEditing:sender];
    }
}

- (void)SynchoWithCloud{
    
    BOOL succeed = YES;
    //过程分三步
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText = @"SYNC_ING";
    float progress = 0.0f;
    HUD.progress = progress;
    
    //第一步，将之前记录的要删除的词读出来，上传至服务器，将其删除delete
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *realPath = [documentPath stringByAppendingPathComponent:@"Deletlog"];
    self.ToDeleteArray = [NSArray arrayWithContentsOfFile:realPath];
    if (self.ToDeleteArray) {
        NSInteger count = [self.ToDeleteArray count];
        for (int i = 0; i < count; i++) {
            NSString * url = [NSString stringWithFormat:@"http://word.iyuba.com/words/updateWord.jsp?userId=%@&mod=delete&groupName=Iyuba&word=%@",[UserInfo loggedUserID],[ToDeleteArray objectAtIndex:i]];
            NSString * response = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
            if (response) {
                DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:response options:0 error:nil];
                NSArray *items = [doc nodesForXPath:@"response" error:nil];
                if (items) {
                    for (DDXMLElement *obj in items) {
//                        NSInteger res = [[[obj elementForName:@"result"] stringValue] integerValue];
//                        NSString * w = [[obj elementForName:@"word"] stringValue];
                    }
                }
            }
            else {
                succeed = NO;
            }
        }
    }
    if (succeed) {
        NSFileManager * fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:realPath error:nil];
        //第一步完成，更新进度显示
        progress = 0.1;
        HUD.progress = progress;
        
        //第二步，将用户数据库中现有的单词上传到服务器，insert，每成功插入一个单词，就从本地数据库中将其删除
        NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
        [self openDatabaseIn:path];
        
        NSString * sql = [NSString stringWithFormat:@"SELECT Word FROM FavoriteWord"];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, nil) != SQLITE_OK) {
            sqlite3_close(_database);
            NSAssert(NO, @"查询Words失败");
        }
        
        NSMutableArray * wordArray = [[NSMutableArray alloc] init];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSString *word = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
            [wordArray addObject:word];
        }
        sqlite3_finalize(stmt);
        
        NSInteger count = [wordArray count];
        float progressStep = 0.5/count;
        for (int i = 0; i < count; i++) {
            NSString * url = [NSString stringWithFormat:@"http://word.iyuba.com/words/updateWord.jsp?userId=%@&mod=insert&groupName=Iyuba&word=%@",[UserInfo loggedUserID],[wordArray objectAtIndex:i]];
            NSString * response = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
            if (response) {
                DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:response options:0 error:nil];
                NSArray *items = [doc nodesForXPath:@"response" error:nil];
                if (items) {
                    for (DDXMLElement *obj in items) {
                        NSInteger res = [[[obj elementForName:@"result"] stringValue] integerValue];
                        NSString * w = [[obj elementForName:@"word"] stringValue];
                        if (res == 1) {
                            NSString * delet = [NSString stringWithFormat:@"DELETE FROM FavoriteWord WHERE Word = \"%@\"",w];
                            char *errorMsg = NULL;
                            if (sqlite3_exec (_database, [delet UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                                sqlite3_close(_database);
                                NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
                            }
                        }
                    }
                }
            }
            else {
                
            }
            progress += progressStep;
            HUD.progress = progress;
        }
        
        //第三步，从服务器获取所有单词，插入数据库
        NSString *url = [NSString stringWithFormat:@"http://word.iyuba.com/words/wordListService.jsp?u=%@&pageNumber=%d&pageCounts=%ld",[UserInfo loggedUserID],1,NSIntegerMax];
        NSString * response = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
        if (response) {
            DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:response options:0 error:nil];
            DDXMLElement * element = [doc rootElement];
            NSInteger number = [[[element elementForName:@"counts"] stringValue] integerValue];
            progressStep = 0.4/number;
            NSArray *items = [doc nodesForXPath:@"response/row" error:nil];
            if (items) {
                for (DDXMLElement *obj in items) {

                    
                    NSString *key = [[obj elementForName:@"Word"] stringValue];
                    NSString *audio = [[obj elementForName:@"Audio"] stringValue];
                    NSString *pron = [[obj elementForName:@"Pron"] stringValue];
                    NSString *def = [[obj elementForName:@"Def"] stringValue];
                    
                    NSString* date;
                    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
                    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
                    date = [formatter stringFromDate:[NSDate date]];
                    NSString * sql = [NSString stringWithFormat:@"INSERT INTO FavoriteWord (Word,audio,pron,def,CreateDate) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",key,audio,pron,def,date];
                    char *errorMsg = NULL;
                    if (sqlite3_exec (_database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                        sqlite3_close(_database);
                        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
                    }
                    progress += progressStep;
                    HUD.progress = progress;
                    
                }
            }
            
        }
        else {
            succeed = NO;
        }
    }
    
    //可以关闭数据库
    [self closeDatabase];
    
    HUD.progress = 1.0;
    if (succeed) {
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = NSLocalizedString(@"SYNC_DONE", nil);
    }
    else {
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-X.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = NSLocalizedString(@"SYNC_FAILED", nil);
    }
    sleep(1);
    [self readFromDatabase];
    [self.tabelView reloadData];
}

- (void)BeginEditing:(UISegmentedControl *)seg{
    [self.tabelView setEditing:!self.tabelView.editing animated:YES];
    if (self.tabelView.editing) 
        [seg setTitle:NSLocalizedString(@"DONE", nil) forSegmentAtIndex:1];
    else 
        [seg setTitle:NSLocalizedString(@"EDIT", nil) forSegmentAtIndex:1];
    
}

- (void)BeginEditingNoSync:(UISegmentedControl *)seg{
    [self.tabelView setEditing:!self.tabelView.editing animated:YES];
    if (self.tabelView.editing)
        [seg setTitle:NSLocalizedString(@"DONE", nil) forSegmentAtIndex:0];
    else
        [seg setTitle:NSLocalizedString(@"EDIT", nil) forSegmentAtIndex:0];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) PlayWordSound:(UIButton *)button{
    NSString * pro = [[jjjjjjArray objectAtIndex:button.tag] Audio];
    if ([pro isEqualToString:@""]) {
        return;
    }
    else {
        NetworkStatus ns = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
        if (ns == NotReachable ) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PROUNCE_FAILED", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
            [alert show];
        }
        else {
//            wordPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:pro]];
//            [wordPlayer play];
            player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:pro]];
            [player play];
        }
    }
}
#pragma mark -
#pragma mark UITableViewDatasource
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserWordCell * cell = (UserWordCell *)[tableView dequeueReusableCellWithIdentifier:kUsrWordCellReuseID];
    if (!cell) {
        cell = [[UserWordCell alloc] init];
        cell = (UserWordCell *)[[[NSBundle mainBundle] loadNibNamed:@"UserWordCellView" 
                                                              owner:self 
                                                            options:nil] objectAtIndex:(IS_IPAD ? 1 : 0)];
        
        if (![TestType isEnglishTest]) {
            cell.PlaySoundButton.hidden = YES;
        }
    }
    Word * word = [jjjjjjArray objectAtIndex:indexPath.row];
    cell.WordLabel.text = word.Name;
    cell.DefLabel.text = word.Definition;
    cell.pronLabel.text = [NSString stringWithFormat:@"[%@]", word.Pronunciation];
    cell.PlaySoundButton.tag = indexPath.row;
    [cell.PlaySoundButton addTarget:self action:@selector(PlayWordSound:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.jjjjjjArray count];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * Thisword = [[jjjjjjArray objectAtIndex:indexPath.row] Name];
    
    //删数据
    NSString *dbPath = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:dbPath];
    NSString * sql = [NSString stringWithFormat:@"DELETE FROM FavoriteWord WHERE Word = \"%@\"",Thisword];
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    [self closeDatabase];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *realPath = [documentPath stringByAppendingPathComponent:@"Deletlog"];
    NSFileManager * fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:realPath]) {
        self.ToDeleteArray = [NSMutableArray arrayWithContentsOfFile:realPath];
    }
    else {
        self.ToDeleteArray = [[NSMutableArray alloc] init];
        [fm createFileAtPath:realPath contents:NULL attributes:nil];
    }
    [self.ToDeleteArray addObject:Thisword];
    if ([self.ToDeleteArray writeToFile:realPath atomically:YES]) {
        
    }
    [self.jjjjjjArray removeObjectAtIndex:indexPath.row];
    [self.tabelView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
#pragma mark UITabelViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return (IS_IPAD ? 130 : 110);
    
    //SELECT ec.Word, ee.English FROM EN_CN AS ec, EN_EN AS ee WHERE (ec.Word = "a" AND ee.English = "a") OR ee.English = "a"
}
@end
