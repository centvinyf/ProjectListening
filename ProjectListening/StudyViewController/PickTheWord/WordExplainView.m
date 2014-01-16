//
//  WordExplainView.m
//  CET4Lite
//
//  Created by Seven Lee on 12-3-16.
//  Copyright (c) 2012年 iyuba. All rights reserved.
//

#import "WordExplainView.h"
#import "AppDelegate.h"
#include <sqlite3.h>


static WordExplainView * view;
//static NSTimer * displayTimer;
static AVPlayer * SoundPlayer;

@interface WordExplainView () {
    sqlite3 *_database;
    
    BOOL _isFavWord;
}

@end

@implementation WordExplainView
@synthesize wordLabel;
@synthesize defLabel;
@synthesize myWord;
//@synthesize delegate;
@synthesize WaitingLabel;
@synthesize activeView;
@synthesize WrongLabel;
@synthesize AddWordButton;
@synthesize ProunceButton;

+ (id) ViewWithState:(SVWordViewState)state errMSG:(NSString *)err word:(Word *)word{
    if (view) {
        [view updateState:state errMSG:err];
        if (word) {
            [view displayThisWord:word];
        }
    }
    else {
        view = [[WordExplainView alloc] initWithState:state errMSG:err word:word];
        [view updateState:state errMSG:err];
    }
    return view;
}
- (id) initWithState:(SVWordViewState)state errMSG:(NSString *)err word:(Word *)word{
    CGRect frame;
    
    NSString * nibName;
    if (IS_IPAD) {
        frame = CGRectMake(0, 1024, 768, 200);
        nibName = @"WordExplainView_iPad";
    }
    else {
        frame = IS_IPHONE_568H ? CGRectMake(0, 568, 320, 85) : CGRectMake(0, 480, 320, 85);
        nibName = @"WordExplainView";
    }
    self = [super initWithFrame:frame];
    if (self) {
        NSArray * nibs = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        [self addSubview:[nibs objectAtIndex:0]];
        [self updateState:state errMSG:err];
        [self displayThisWord:word];

    }
   
    return self;
}
- (void) displayThisWord:(Word*)word{
    if (self.myWord) {
        [self.myWord cancel];
    }
    
    self.myWord = word;
    self.wordLabel.text = [NSString stringWithFormat:@"%@  [%@]",word.Name,word.Pronunciation];
    self.defLabel.text = word.Definition;
    
    _isFavWord = [self isWordFavorite];
    
    if (_isFavWord) {
        //已经收藏过的单词
        [AddWordButton setImage:[UIImage imageNamed:@"wordFavYES.png"] forState:UIControlStateNormal];
    } else {
        //还没有收藏的单词
        [AddWordButton setImage:[UIImage imageNamed:@"wordFav.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)AddToWords:(id)sender{
//    [delegate WordExplainView:self addWord:myWord];
//    if  (displayTimer)
//    {
//        [displayTimer invalidate];
//        displayTimer = nil;
//    }
//    displayTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hide:) userInfo:nil repeats:NO];
    
    if (_isFavWord) {
        _isFavWord = NO;
        [AddWordButton setImage:[UIImage imageNamed:@"wordFav.png"] forState:UIControlStateNormal];
        [self deleteFromFavorite];
    } else {
        _isFavWord = YES;
        [AddWordButton setImage:[UIImage imageNamed:@"wordFavYES.png"] forState:UIControlStateNormal];
        [self addToFavorite];
    }

}
- (IBAction)PlayPronciation:(id)sender{
//    [delegate WordExplainView:self playWordSound:myWord];
//    if  (displayTimer)
//    {
//        [displayTimer invalidate];
//        displayTimer = nil;
//    }
//    displayTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hide:) userInfo:nil repeats:NO];
    NetworkStatus ns = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (ns == NotReachable ) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"发音失败" message:@"当前未联网" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [alert show];
    }
    else {
        SoundPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:myWord.Audio]];
        [SoundPlayer play];
    }
}

- (IBAction)closeBtnPressed:(id)sender {
    [self hide:nil];
}

//更新显示状态，state = 1为显示词义状态，state = 2 为等待状态， state = 3 为失败状态
- (void)updateState:(SVWordViewState)state errMSG:(NSString *)err{
    ShowState = state;
    switch (state) {
        case SVWordViewStateDis:
            self.WaitingLabel.hidden = YES;
            self.activeView.hidden = YES;
            self.WrongLabel.hidden = YES;
            [self.activeView stopAnimating];
            self.defLabel.hidden = NO;
            self.ProunceButton.hidden = NO;
            self.AddWordButton.hidden = NO;
            break;
        case SVWordViewStateWaiting:
            self.WaitingLabel.hidden = NO;
            self.activeView.hidden = NO;
            self.WrongLabel.hidden = YES;
            [self.activeView startAnimating];
            self.defLabel.hidden = YES;
            self.ProunceButton.hidden = YES;
            self.AddWordButton.hidden = YES;
            break;
        case SVWordViewStateDisFail:
            self.WrongLabel.text = err;
            self.WrongLabel.hidden = NO;
            self.WaitingLabel.hidden = YES;
            self.activeView.hidden = YES;
            [self.activeView startAnimating];
            self.defLabel.hidden = YES;
            self.ProunceButton.hidden = YES;
            self.AddWordButton.hidden = YES;
            break;
            
        case SVWordViewStateNoProunce:
            [self moveWordLabelToOneSide];
            self.WaitingLabel.hidden = YES;
            self.activeView.hidden = YES;
            self.WrongLabel.hidden = YES;
            [self.activeView stopAnimating];
            self.defLabel.hidden = NO;
            self.ProunceButton.hidden = YES;
            self.AddWordButton.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)moveWordLabelToOneSide {
    if (IS_IPAD) {
        return;
    } else {
        CGRect frame = self.wordLabel.frame;
        frame.origin.x = 5;
        self.wordLabel.frame = frame;
    }
    
}

- (void) show{
    CGFloat windowHeight = IS_IPAD ? 1024.0f : IS_IPHONE_568H ? 568.0f : 480.0f;
//    CGFloat windowHeight = 360;
    
    CGFloat pointX = 0.0f;
    CGFloat pointY = windowHeight - view.frame.size.height;

    
//    if  (displayTimer)
//    {
//        [displayTimer invalidate];
//        displayTimer = nil;
//    }
    if (ShowState != SVWordViewStateWaiting) {
//        displayTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hide:) userInfo:nil repeats:NO];
    }

    if (!self || self.frame.origin.y == pointY) {
        
        return;
    }
    [UIView beginAnimations:@"ShowMyView" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.5];
    self.frame = CGRectMake(pointX, windowHeight - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
}
- (void) hide:(NSTimer *)timer {

    CGFloat windowHeight = IS_IPAD ? 1024.0f : IS_IPHONE_568H ? 568.0f : 480.0f;
    CGFloat pointX = 0.0f;
    if (self.frame.origin.y != windowHeight) {//不在底部，则将其放在底部。
        [UIView beginAnimations:@"HideMyView" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.5];
        self.frame = CGRectMake(pointX, windowHeight , self.frame.size.width, self.frame.size.height);
        [UIView commitAnimations];
        
        //判断是否继续播放音频
        [_studyVC ZZAudioContinuePlayOrNot];
        return;
    }
}

+ (void) RemoveView {
    if (view) {
        [view removeFromSuperview];
        view = nil;
    }
}

#pragma mark - Database Methods
- (void)openDatabaseIn:(NSString *)dbPath {
    if (sqlite3_open([dbPath UTF8String], &_database) != SQLITE_OK) {
        NSAssert(NO, @"Open database failed");
    }
}

- (void)closeDatabase {
    if (sqlite3_close(_database) != SQLITE_OK) {
        NSAssert(NO, @"Close database failed");
    }
}

- (BOOL)isWordFavorite {
    BOOL isFavorite = NO;
    
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:path];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT Word FROM FavoriteWord WHERE Word = \"%@\";", myWord.Name];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询FavoriteWord信息失败");
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        isFavorite = YES;
    }
    
    sqlite3_finalize(stmt);
    
    [self closeDatabase];
    
    return isFavorite;
}

- (void)addToFavorite {
    NSString* date;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    date = [formatter stringFromDate:[NSDate date]];
    
    //把收藏状态存到数据库中
    //    sqlite3 *database;
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:path];
    
    NSString *updateFav = [NSString stringWithFormat:@"INSERT INTO FavoriteWord (Word,audio,pron,def,CreateDate) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",myWord.Name,myWord.Audio,myWord.Pronunciation,myWord.Definition,date];
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [updateFav UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        //        sqlite3_close(database);
        //        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"加入失败" message:@"单词已存在" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    //关闭数据库
    [self closeDatabase];
}

- (void)deleteFromFavorite {
    //把收藏状态存到数据库中
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:path];
    
    NSString *updateFav = [NSString stringWithFormat:@"DELETE FROM FavoriteWord WHERE Word = \"%@\";",myWord.Name];
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [updateFav UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        //        sqlite3_close(database);
        //        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"删除失败" message:@"单词不存在" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    //关闭数据库
    [self closeDatabase];
}


@end
