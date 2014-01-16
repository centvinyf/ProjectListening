//
//  StudyViewController.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-25.
//
//

#import "StudyViewController.h"
#include <sqlite3.h>
#import "TextCell.h"
#import "TextAndQuesClass.h"
#import "ZZGrabWordLabel.h"
#import "NSDate+ZZDate.h"
#import "SectionView.h"
#import "ExplainTableView.h"
#import "UserSetting.h"
#import "TitleInfoClass.h"

#import "QuesCell.h"
#import "JLPTImageCell.h"
#import "ToeicCell.h"
#import "HSKCell.h"

#define TAG_TEXT_TABLE      11
#define TAG_QUES_TABLE      12
#define TAG_EXPLAIN_TABLE   13

#define IPHONE_TITLE_YES_EXPLAIN_WIDTH (IS_IPAD ? 400.0f : 140.0f)
#define IPHONE_TITLE_NO_EXPLAIN_WIDTH (IS_IPAD ? 400.0f : 180.0f)

//#define IPHONE_GRAYLINE_CHANGE_HEIGHT 90

#define IPHONE_TEXTTABLE_CHANGE_HEIGHT 260.0
#define IPHONE_QUESTABLE_CHANGE_HEIGHT 101.0

#define IPHONE5_TEXTTABLE_CHANGE_HEIGHT 348.0
#define IPHONE5_QUESTABLE_CHANGE_HEIGHT 101.0

#define IPAD_TEXTTABLE_CHANGE_HEIGHT 660.0
#define IPAD_QUESTABLE_CHANGE_HEIGHT 200.0

#define IPHONE_AD_BANNER_HEIGHT 48.0
#define IPAD_AD_BANNER_HEIGHT 90.0

#define IOS7_SATUTS_HEIGHT 20.0f

//UPDATE TitleInfo SET Vip = "false", EnText = "false", CnText = "false", JpText = "true", EnExplain = "false", CnExplain = "true", JpExplain = "false", Favorite = "false" WHERE TitleNum > 20000000

//Insert Into PackInfo Values("2010年7月", "true", "true", 0.0, 11, "true", "");Insert Into PackInfo Values("2010年12月", "true", "true", 0.0, 12, "true", "");Insert Into PackInfo Values("2011年7月", "true", "true", 0.0, 13, "true", "");

//UPDATE PackInfo SET IsVip = "true", IsDownload = "true", IsFree = "true" WHERE PackName = "2010年7月" OR PackName = "2010年12月" OR PackName = "2011年7月"

//UPDATE Text SET PartType = 303 WHERE PartType = 302 AND (TitleNum = 20100741 OR TitleNum = 20100741 OR TitleNum = 20100741 OR TitleNum = 20100741 OR TitleNum = 20100741 OR TitleNum = 20100741 OR TitleNum = 20100741 OR TitleNum = 20100741 OR)


#define SCORE_TIME_PERCENT 40
#define SCORE_RIGHT_PERCENT 60

typedef enum {
    ExplainStyleShow,
    ExplainStyleHide,
} ExplainStyleTags;

@interface StudyViewController () {
    NSMutableArray *_articleIndexArray;
    NSMutableArray *_quesNumArray;
    NSMutableArray *_rightNumArray;
    
    NSMutableArray *_TAQArray;
    
    int _syncNum;
    
    TextShowStyleTags _textShowStyle;
    ExplainStyleTags _explainShowStyle;
    
    NSDate *_inDate;//计划入口进入时的时间
    NSDate *_thisTitleInDate;//每一道题进入的时间
    
    
    
    int _currQuesPlayIndex;
    
    sqlite3 *_database;
    
    BOOL _isZZAudioPlaying;
    
}

@property (nonatomic, retain) UIColor *syncTextColor;
@property (assign) int userFontSizeReal;
//@property (assign) int userFontSizeFake;
@property (nonatomic, retain) ExplainTableView *ExTableView;

@property (nonatomic, retain) GADBannerView *adView;
@property BOOL isPurchaseVIPMode;

@end

@implementation StudyViewController

- (void)dealloc {
#if COCOS2D_DEBUG    
    NSLog(@"StudyViewController dealloc");
#endif
    
    self.syncTextColor = nil;
    
    //    [_audioPlayer unload];
    if (_quesAudioPlayer) {
        [_quesAudioPlayer stop];
        [_quesAudioPlayer setDelegate:nil];
        [_quesAudioPlayer release], _quesAudioPlayer = nil;
    }
    [_audioPlayer release];
    [_questionTable release];
    [_textTable release];
    [_TAQArray release];
    [_articleIndexArray release];
    [_quesNumArray release];
    if (_enterType == EnterTypePlan) {
        [_rightNumArray release];
    }
//    [_grayLineView release];
    
    [_inDate release];
    [_thisTitleInDate release];
    
    [self.navBar release];
    [_titleLabel release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil articles:(NSMutableArray *)articles currIndex:(int)currIndex totalTime:(int)totalTime ymd:(int)ymd enterTypeTags:(EnterTypeTags)enterType {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //从哪个入口进来的
        _enterType = enterType;
        
        if (_enterType == EnterTypePlan) {
            //安排任务的ymd
            _YMD = ymd;
            
            //所有文章总时间
            _totalTime = totalTime;
        }
       
        //当前原文显示的方式
        _textShowStyle = [UserSetting textShowStyle];
        
        //设置同步文字颜色
        self.syncTextColor = [UserSetting syncTextColor];
        
        //设置字体大小
        self.userFontSizeReal = [UserSetting textFontSizeReal];
//        self.userFontSizeFake = [UserSetting textFontSizeFake];
        
        //正在同步的句子号
        _syncNum = 0;
        
        //当前播放的问题音频名称
        _currQuesPlayIndex = -1;
        
        //第一文章，当前文章，最后一文章的序列号
        _firstIndex = 1;
        _currentIndex = currIndex;
        _lastIndex = [articles count];
        
        //进来的时间
        _inDate = [[NSDate getLocateDate:[NSDate date]] retain];
        _thisTitleInDate = [[NSDate getLocateDate:[NSDate date]] retain];
        
        _articleIndexArray = [[NSMutableArray alloc] init];
        _quesNumArray = [[NSMutableArray alloc] init];
        
        if (_enterType == EnterTypePlan) {
            _rightNumArray = [[NSMutableArray alloc] init];
        }
        
        for (TitleInfoClass *TIC in articles) {
            [_articleIndexArray addObject:[NSNumber numberWithInt:TIC.titleNum]];
            [_quesNumArray addObject:[NSNumber numberWithInt:TIC.quesNum]];
            
            if (_enterType == EnterTypePlan) {
                [_rightNumArray addObject:[NSNumber numberWithInt:TIC.rightNum]];
            }
        }

        
        
        
        _TAQArray = [[NSMutableArray alloc] init];
        [self setTAQs];
        [self setTAQsWithMoreInfo];
        
        //设置收藏句子数组
        /*
         [self initializeCurrSentenceFavArray];
         */
        
    }
    return self;
}

- (void)backToTop {
    switch (_enterType) {
        case EnterTypePlan:
            [self updatePlanScoreToDatabase];
            break;
            
        case EnterTypeLibrary:
        case EnterTypeFavorite:
//            [self.navigationController setNavigationBarHidden:NO animated:YES];
            break;
            
        default:
            NSAssert(NO, @"Enter Type Error");
            break;
    }
    
    //更新titleInfo表的handle字段
    TextAndQuesClass *TAQ = [self getCurrTAQ];
    [self updateDetailScoreToDatabaseByTAQ:TAQ];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    switch (_enterType) {
        case EnterTypePlan:
            break;
            
        case EnterTypeLibrary:
        case EnterTypeFavorite:
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            break;
            
        default:
            NSAssert(NO, @"Enter Type Error");
            break;
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    
    //设置屏幕常亮Off
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if (_WordView) {
        [_WordView hide:nil];
        _WordView = nil;
        [WordExplainView RemoveView];
    }
    
    //系统字典出现的时候先停止播放
    if (_isZZAudioPlaying) {
        
    } else {
        _isZZAudioPlaying = [_audioPlayer isZZAudioPlaying];
    }
    //退出的时候或则系统字典出现的时候均停止播放音频s
    [_audioPlayer setZZAudioPlayerPause];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    //设置屏幕常亮OffOrOn
    [[UIApplication sharedApplication] setIdleTimerDisabled:[UserSetting screenKeepLightStatus]];
    
    switch (_enterType) {
        case EnterTypeFavorite:
        case EnterTypeLibrary:
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            break;
            
        default:
            break;
    }
    
    //系统字典消失的时候，是否继续播放音频
    [self ZZAudioContinuePlayOrNot];
}

- (void)viewDidAppear:(BOOL)animated {
    [self checkQuestionScrollEnabled];
}

- (void)showAlertView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注意!" message:@"本篇听力已被您删除, 在重新下载之前将不能播放, 请到题库中重新下载." delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    if ([UserSetting isSystemOS7]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        //NavBar
        CGRect frame = self.navBar.frame;
        frame.origin.y += IOS7_SATUTS_HEIGHT;
        [self.navBar setFrame:frame];
        
        //Title Label
        frame = self.titleLabel.frame;
        frame.origin.y += IOS7_SATUTS_HEIGHT;
        [self.titleLabel setFrame:frame];
        
        //tableText
        frame = self.textTable.frame;
        frame.origin.y += IOS7_SATUTS_HEIGHT;
        [self.textTable setFrame:frame];
        
        //questionTable
        frame = self.questionTable.frame;
        frame.size.height -= IOS7_SATUTS_HEIGHT;
        frame.origin.y += IOS7_SATUTS_HEIGHT;
        [self.questionTable setFrame:frame];
    
    }
    
    //测试是不是VIP会员
    self.isPurchaseVIPMode = [UserSetting isPurchasedVIPMode];
    
    if ([UserSetting isSwipeGestureEnabled]) {
        //加入手势
        
        //向左
        UISwipeGestureRecognizer *oneFingerSwipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeLeft:)] autorelease];
        [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [[self view] addGestureRecognizer:oneFingerSwipeLeft];
        //向右
        UISwipeGestureRecognizer *oneFingerSwipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeRight:)] autorelease];
        [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [[self view] addGestureRecognizer:oneFingerSwipeRight];
    }
    
    
    //设置播放器委托,并初始化一些设置
    _audioPlayer.delegate = self;
    TextAndQuesClass *TAQ = [self getCurrTAQ];
    NSMutableArray *times = [TAQ timingArray];
    [_audioPlayer initializeAudioPlayer];
//    [_audioPlayer playSoundByAudioName:TAQ.soundName timeArray:times lastTimePoint:0];
    [_audioPlayer playSoundWithAudioName:TAQ.soundName packName:TAQ.packName isFree:TAQ.isFree timeArray:times lastTimePoint:0];
    [_audioPlayer fireSliderTimer:YES];
    
    if (!TAQ.isVip) {
        [self showAlertView];
    }
    //显示上一题下一题箭头
    if (_currentIndex == _lastIndex) {
        [_audioPlayer.nextQuesBtn setEnabled:NO];
    }
    if (_currentIndex == _firstIndex) {
        [_audioPlayer.prevQuesBtn setEnabled:NO];
    }
    
    //设置title的宽度，看是否有解析
    CGFloat labelWidth;
    if ([self isHasExplain:TAQ]) {
        labelWidth = IPHONE_TITLE_YES_EXPLAIN_WIDTH;
    } else {
        labelWidth = IPHONE_TITLE_NO_EXPLAIN_WIDTH;
    }
    CGRect frame = self.titleLabel.frame;
    frame.size.width = labelWidth;
    [self.titleLabel setFrame:frame];
    [self setNavBarTitleNameBy:TAQ];
    //设置title的名称
    [self setSevenNavBarBy:TAQ];
    
    //设置文章收藏标识
    TAQ.isFavorite = [self getCurrIsFavoriteByTitleNum:TAQ.titleNum partType:TAQ.partType];
    [self setFavTitleStatusIsFavBy:TAQ];
    
    
    //添加自定义menu
    /******************本地化的时候加入AddToItem按钮**************************/
//    UIMenuItem *addToItem = [[UIMenuItem alloc]initWithTitle:@"★" action:@selector(addWordToFavorite:)];
    UIMenuItem *systemDefineItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"DEFINE", nil)
                                                        action:@selector(sysDefine:)];
    NSString *dicName = [UserSetting dictTypeName];
    UIMenuItem *defineItem = [[UIMenuItem alloc] initWithTitle:dicName
                                                        action:@selector(myDefine:)];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:[NSArray arrayWithObjects:systemDefineItem, defineItem, /*addToItem, */nil]];
//    [addToItem release];
    [defineItem release];
    [systemDefineItem release];
    
    //加广告条
    if (!self.isPurchaseVIPMode) {
        //没有内购需要广告条
        [self addAdMob];
    }
    
    [self setTextShowStyle];
    
}

- (CGFloat)questionChangeHeight {
    CGFloat QCH = 0.0f;
    if (IS_IPAD) {
        QCH = IPAD_QUESTABLE_CHANGE_HEIGHT;
    } else if (IS_IPHONE_568H) {
        QCH = IPHONE5_QUESTABLE_CHANGE_HEIGHT;
    } else {
        QCH = IPHONE_QUESTABLE_CHANGE_HEIGHT;
    }
    
    return QCH;
}

- (CGFloat)textChangeHeight {
    CGFloat TCH = 0.0f;
    if (IS_IPAD) {
        TCH = IPAD_TEXTTABLE_CHANGE_HEIGHT;
    } else if (IS_IPHONE_568H) {
        TCH = IPHONE5_TEXTTABLE_CHANGE_HEIGHT;
    } else {
        TCH = IPHONE_TEXTTABLE_CHANGE_HEIGHT;
    }
    return TCH;
}

- (CGFloat)adBannerHeight {
    CGFloat ADBH = 0.0f;
    if (IS_IPAD) {
        ADBH = IPAD_AD_BANNER_HEIGHT;
    } else {
        ADBH = IPHONE_AD_BANNER_HEIGHT;
    }
    
    return ADBH;
}

- (void)addAdMob {
    
    if (IS_IPAD) {
        _adView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    } else {
        _adView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    }
    
//    NSLog(@"广告条的高度是%f", _adView.frame.size.height);
    
    _adView.rootViewController = self;
    _adView.adUnitID = ADMOB_ID;
    CGRect rect = _adView.frame;
    CGFloat height = 0;
    CGFloat adHeight = 0;
    if (IS_IPAD) {
        height = 100;
        adHeight = 145;
    } else if (IS_IPHONE_568H) {
        height = -35;
        adHeight = -10;
    } else {
        height = 53;  
        adHeight = 78;
    }
    CGPoint point = CGPointMake(self.view.center.x, self.view.frame.size.height - rect.size.height / 2 - height);
    _adView.center = point;
//    _adView.delegate = self;
    [self.view insertSubview:_adView belowSubview:self.audioPlayer];
//    [self.view addSubview:_adView];
    [_adView loadRequest:[GADRequest request]];
    
    //判断网络状态
	NetworkStatus NetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    //没有网的情况
	if (NetStatus == NotReachable) {
        //没有网络的时候显示自己的广告条
//        UIButton *adBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [adBtn setImage:[UIImage imageNamed:@"adIyuba.png"] forState:UIControlStateNormal];
//        [adBtn addTarget:self action:@selector(ZZAudioPushToVIPPage) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"adIyuba.png"]];
        CGRect frame = imgView.frame;
        frame.origin = CGPointMake(self.view.frame.origin.x, self.view.frame.size.height - rect.size.height / 2 - adHeight);
        [imgView setFrame:frame];
        [self.view insertSubview:imgView belowSubview:_adView];
        
    }
}

- (void)checkQuestionScrollEnabled {
    BOOL isScroll = YES;
#if COCOS2D_DEBUG
    NSLog(@"内容的高度是：%f\n问题框的高度是：%f", _questionTable.contentSize.height, _questionTable.frame.size.height);
#endif
    if (_questionTable.contentSize.height <= _questionTable.frame.size.height) {
        isScroll = NO;
    } else {
        isScroll = YES;
    }
    
    [_questionTable setScrollEnabled:isScroll];
    
}

- (void)oneFingerSwipeLeft:(UISwipeGestureRecognizer *)recognizer {
    
    [self hideWordExplainView];
    [self ZZAudioNextTitleBtnPressed];
    
//    CGPoint point = [recognizer locationInView:[self view]];
//    NSLog(@"Swipe Left - start location: %f,%f", point.x, point.y);
}

- (void)oneFingerSwipeRight:(UISwipeGestureRecognizer *)recognizer {
    [self hideWordExplainView];
    [self ZZAudioPrevTitleBtnPressed];
    
//    CGPoint point = [recognizer locationInView:[self view]];
//    NSLog(@"Swipe Right - start location: %f,%f", point.x, point.y);
    
    
}



- (void)setSevenNavBarBy:(TextAndQuesClass *)TAQ {
    //设置navbar上的按钮Back按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(backToTop) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"backBtn.png"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"backBtn_hl.png"] forState:UIControlStateHighlighted];
    [backBtn setFrame:CGRectMake(0, 0, 32, 30)];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navBar.navItem.leftBarButtonItem = backItem;
//        self.navigationItem.leftBarButtonItem = backItem;
    [backItem release];
    
    //设置navbar上的按钮
    UIButton *favBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [favBtn addTarget:self action:@selector(updateTitleFavoriteStatus) forControlEvents:UIControlEventTouchUpInside];
    [favBtn setImage:[UIImage imageNamed:@"favNO.png"] forState:UIControlStateNormal];
    [favBtn setFrame:CGRectMake(0, 0, 32, 30)];
    
    UIButton *textStyleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [textStyleBtn setImage:[UIImage imageNamed:@"textAll.png"] forState:UIControlStateNormal];
    [textStyleBtn addTarget:self action:@selector(showOrHideTextTable) forControlEvents:UIControlEventTouchUpInside];
    [textStyleBtn setFrame:CGRectMake(0, 0, 32, 30)];
    
    UIBarButtonItem *favItem = [[UIBarButtonItem alloc] initWithCustomView:favBtn];
    UIBarButtonItem *showOrHideItem = [[UIBarButtonItem alloc] initWithCustomView:textStyleBtn];
    
    NSArray *btnItemArray = nil;
    if ([self isHasExplain:TAQ]) {
        //解析按钮
        UIButton *explainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [explainBtn addTarget:self action:@selector(showOrHideExplain) forControlEvents:UIControlEventTouchUpInside];
        [explainBtn setImage:[UIImage imageNamed:@"explainBtn.png"] forState:UIControlStateNormal];
        [explainBtn setImage:[UIImage imageNamed:@"explainBtn_hl.png"] forState:UIControlStateHighlighted];
        [explainBtn setFrame:CGRectMake(0, 0, 32, 30)];
        UIBarButtonItem *explainItem = [[UIBarButtonItem alloc] initWithCustomView:explainBtn];
        
        btnItemArray = [NSArray arrayWithObjects:showOrHideItem, explainItem, favItem, nil];
        [explainItem release];
    } else {
        btnItemArray = [NSArray arrayWithObjects:showOrHideItem, favItem, nil];
    }
    
    [favItem release];
    [showOrHideItem release];
    [self.navBar.navItem setRightBarButtonItems:btnItemArray animated:YES];
}

- (void)setNavBarTitleNameBy:(TextAndQuesClass *)TAQ {
    CGFloat labelWidth;
    if ([self isHasExplain:TAQ]) {
        labelWidth = IPHONE_TITLE_YES_EXPLAIN_WIDTH;
    } else {
        labelWidth = IPHONE_TITLE_NO_EXPLAIN_WIDTH;
    }
    //设置title NavBar
    CGSize size = [TAQ.titleName sizeWithFont:[UIFont boldSystemFontOfSize:17.0f]];
    CGFloat fontSize = floorf(17 * labelWidth / size.width);
    
    if (fontSize > 17.0f) {
        fontSize = 17.0f;
    }
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    [_titleLabel setText:TAQ.titleName];
}

- (BOOL)isHasExplain:(TextAndQuesClass *)TAQ {
    
    if ([TestType isToeic]) {
        return YES;
    }
    switch ([TestType systemLanguage]) {
        case LanguageCN:
            if (TAQ.isCNExplain) return YES;
            break;
            
        case LanguageEN:
            if (TAQ.isENExplain) return YES;
            break;
            
        case LanguageJP:
            if (TAQ.isJPExplain) return YES;
            break;
            
        default:
            break;
    }
//    if (TAQ.isENExplain || TAQ.isJPExplain || TAQ.isCNExplain/* || YES*/) {
//        return YES;
//    }
    return NO;
}

- (void)viewDidUnload {
    [self setQuestionTable:nil];
    [self setTextTable:nil];
    
    [self setAudioPlayer:nil];
    [self setNavBar:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - My Public method
- (void)playQuesAudioByQuesIndex:(int)quesIndex msgIsFromZZAudioPlayer:(BOOL)isFromZZAP {
    
    if (_quesAudioPlayer) {
        [_quesAudioPlayer stop];
        [_quesAudioPlayer setDelegate:nil];
        [_quesAudioPlayer release], _quesAudioPlayer = nil;
    }
    
    if (_currQuesPlayIndex != quesIndex) {
        //把原文播放的音频停止
        [_audioPlayer setZZAudioPlayerPause];
        
        //把之前的停止
        QuesCell *cell = (QuesCell *)[_questionTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currQuesPlayIndex - 1 inSection:0]];
        [cell isQuesAudioPlaying:NO];
        
        //点击的不是之前的cell，播放点击的quesAudio，同时把之前的cell上的按钮状态更改成停止
        _currQuesPlayIndex = quesIndex;
        
        TextAndQuesClass *TAQ = [self getCurrTAQ];
        NSString *audioName = [TAQ.quesSoundNameArray objectAtIndex:quesIndex - 1];
        audioName = [audioName stringByAppendingFormat:TEMP_AUDIO_SUFFIX];
        
        //加载音频
        NSString *audioPath = nil;
        if (TAQ.isFree) {
            audioPath = [ZZAcquirePath getBundleDirectoryWithFileName:audioName];
        } else {
            audioPath = [ZZAcquirePath getAudioDocDirectoryWithFileName:[NSString stringWithFormat:@"%@/%@", TAQ.packName, audioName]];
        }
        NSURL *audioDir = [NSURL fileURLWithPath:audioPath];
        _quesAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioDir error:NULL];
        [_quesAudioPlayer setDelegate:self];
        [_quesAudioPlayer prepareToPlay];
        [_quesAudioPlayer play];
        
    } else {
        if (isFromZZAP) {
            //把之前的停止
            QuesCell *cell = (QuesCell *)[_questionTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currQuesPlayIndex - 1 inSection:0]];
            [cell isQuesAudioPlaying:NO];
        }
        _currQuesPlayIndex = -1;
    }
}

- (void)updateUserSelectArrayByQuesIndex:(int)quesIndex ansBtnIndex:(int)selectIndex {
    NSMutableArray *selArray = [[[self getCurrTAQ] selectArray] objectAtIndex:quesIndex - 1];
    [selArray replaceObjectAtIndex:selectIndex withObject:[NSNumber numberWithBool:YES]];
}

- (void)setTextShowStyle {
    
    NSArray *barBtns = [self.navBar.navItem rightBarButtonItems];
    UIBarButtonItem *barBtn = [barBtns objectAtIndex:0];
    UIButton *styleBtn = (UIButton *)[barBtn customView];
    NSString *pngName = nil;
    
    if (_textShowStyle == TextShowStyleNone) {
        pngName = @"textPart.png";
        
        //textTable & quesTable change
        CGRect tFrame = _textTable.frame;
        CGPoint tPoint = tFrame.origin;
        
        CGRect qFrame = _questionTable.frame;
        CGPoint qPoint = qFrame.origin;
        CGSize qSize = qFrame.size;
        
        tPoint.y -= [self questionChangeHeight];
        qSize.height += [self questionChangeHeight];
        qPoint.y -= [self questionChangeHeight];
        
        if (!self.isPurchaseVIPMode) {
            qSize.height -= [self adBannerHeight];
        }
        
        tFrame.origin = tPoint;
        
        qFrame.origin = qPoint;
        qFrame.size = qSize;
        
        [_textTable setFrame:tFrame];
        [_textTable setAlpha:0.0f];
        [_questionTable setFrame:qFrame];
        
        
    } else if (_textShowStyle == TextShowStyleAll) {
        pngName = @"textNone.png";
        
        [self.textTable setScrollEnabled:YES];
        //原文表格的变化
        CGRect tFrame = _textTable.frame;
        CGSize tSize = tFrame.size;
        
        tSize.height += [self textChangeHeight];
        
        if (!self.isPurchaseVIPMode) {
            tSize.height -= [self adBannerHeight];
            CGRect qFrame = _questionTable.frame;
            CGSize qSize = qFrame.size;
            qSize.height -= [self adBannerHeight];
            qFrame.size = qSize;
            
            [_questionTable setFrame:qFrame];
            
        }
        
        tFrame.size = tSize;
        [_textTable setFrame:tFrame];
        
        
    } else {
        pngName = @"textAll.png";
        
        if (!self.isPurchaseVIPMode) {
            CGRect qFrame = _questionTable.frame;
            CGSize qSize = qFrame.size;
            qSize.height -= [self adBannerHeight];
            qFrame.size = qSize;
            
            [_questionTable setFrame:qFrame];
        }
        
    }
    
    [styleBtn setImage:[UIImage imageNamed:pngName] forState:UIControlStateNormal];
}

- (void)showOrHideTextTable {
    
    [self hideExplainTableView];
    
    //隐藏取词框
    [self hideWordExplainView];
    
    int sentenceNum = [[[_TAQArray objectAtIndex:_currentIndex - 1] senArray] count];
    NSMutableArray *editRows = [[NSMutableArray alloc] init];
    for (int i = 0; i < sentenceNum - 1; i++) {
        [editRows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    NSArray *barBtns = [self.navBar.navItem rightBarButtonItems];
    UIBarButtonItem *barBtn = [barBtns objectAtIndex:0];
    UIButton *styleBtn = (UIButton *)[barBtn customView];
    NSString *pngName = nil;
    
    TextCell *cell = nil;
    
    if (_textShowStyle == TextShowStyleAll) {
        _textShowStyle = TextShowStyleNone;
        pngName = @"textPart.png";
        
        _textTable.scrollEnabled = NO;
        
        [_textTable beginUpdates];
        [_textTable deleteRowsAtIndexPaths:editRows withRowAnimation:UITableViewRowAnimationBottom];
        [_textTable endUpdates];
        
        //设置动画效果
        [UIView beginAnimations:@"TextShowNone" context:nil];
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        //textTable & quesTable change
        CGRect tFrame = _textTable.frame;
        CGPoint tPoint = tFrame.origin;
        CGSize tSize = tFrame.size;
        
        CGRect qFrame = _questionTable.frame;
        CGPoint qPoint = qFrame.origin;
        CGSize qSize = qFrame.size;
        
        tSize.height -= [self textChangeHeight];
        tPoint.y -= [self questionChangeHeight];
        qSize.height += [self questionChangeHeight];
        qPoint.y -= [self questionChangeHeight];
        
        if (!self.isPurchaseVIPMode) {
            tSize.height += [self adBannerHeight];
        }
                
        tFrame.origin = tPoint;
        tFrame.size = tSize;
        
        qFrame.origin = qPoint;
        qFrame.size = qSize;
        
        [_textTable setFrame:tFrame];
        [_textTable setAlpha:0.0f];
//        [_textTable setHidden:YES];
        
        [_questionTable setFrame:qFrame];
        
        [UIView commitAnimations];
        
        //设置正在同步的内容
        cell = (TextCell *)[_textTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        NSString *sentence = [[[self getCurrTAQ] senArray] objectAtIndex:_syncNum];
        [cell setSyncSingleTVLayoutWithText:sentence];
        
    } else if (_textShowStyle == TextShowStylePart) {
        _textShowStyle = TextShowStyleAll;
        pngName = @"textNone.png";
        
        _textTable.scrollEnabled = YES;
        
        [_textTable beginUpdates];
        [_textTable insertRowsAtIndexPaths:editRows withRowAnimation:UITableViewRowAnimationBottom];
        [_textTable endUpdates];
        [_textTable reloadData];
        
        //设置动画效果
        [UIView beginAnimations:@"TextShowAll" context:nil];
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        //原文表格的变化
        CGRect frame = _textTable.frame;
        CGSize size = frame.size;
        size.height += [self textChangeHeight];
        
        if (!self.isPurchaseVIPMode) {
            size.height -= [self adBannerHeight];
        }
        
        frame.size = size;
        [_textTable setFrame:frame];
        
        [UIView commitAnimations];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_syncNum inSection:0];
        cell = (TextCell *)[_textTable cellForRowAtIndexPath:indexPath];
        [cell.syncTV setTextColor:_syncTextColor];
        [_textTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    } else {
        _textShowStyle = TextShowStylePart;
        pngName = @"textAll.png";
        //设置动画效果
        [UIView beginAnimations:@"TextShowPart" context:nil];
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        CGRect tFrame = _textTable.frame;
        CGPoint tPoint = tFrame.origin;
        
        CGRect qFrame = _questionTable.frame;
        CGSize qSize = qFrame.size;
        CGPoint qPoint = qFrame.origin;
        
        tPoint.y += [self questionChangeHeight];
        qSize.height -= [self questionChangeHeight];
        qPoint.y += [self questionChangeHeight];

        
        tFrame.origin = tPoint;
        
        qFrame.origin = qPoint;
        qFrame.size = qSize;
        
        [_questionTable setFrame:qFrame];
        [_textTable setFrame:tFrame];
        
        [_textTable setAlpha:1.0f];
//        [_textTable setHidden:NO];
        
        [UIView commitAnimations];
        
        //设置正在同步的内容
        cell = (TextCell *)[_textTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        NSString *sentence = [[[self getCurrTAQ] senArray] objectAtIndex:_syncNum];
        [cell setSyncSingleTVLayoutWithText:sentence];
    }
    
    [editRows release];
    
    [styleBtn setImage:[UIImage imageNamed:pngName] forState:UIControlStateNormal];
    
    //最后要判断question是否可以滚动
    [self checkQuestionScrollEnabled];
}

- (NSString *)getExplain {
    NSString *path = [ZZAcquirePath getDBTextAnswerExplainFromBundle];
    [self openDatabaseIn:path];
    
    TextAndQuesClass *TAQ = [self getCurrTAQ];
    NSString *sql = [NSString stringWithFormat:@"SELECT Explain FROM Explain WHERE TestType = %d AND PartType = %d AND TitleNum = %d;", TEST_TYPE, TAQ.partType, TAQ.titleNum];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询收藏信息失败");
    }
    
    NSString *explain = @"抱歉，老师暂时没为此题作解析。";
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        char *cExplain = (char *)sqlite3_column_text(stmt, 0);
        if (cExplain != NULL) {
            explain = [NSString stringWithUTF8String:cExplain];
        }
    }
    sqlite3_finalize(stmt);

    [self closeDatabase];
    
    return explain;
}

- (void)showOrHideExplain {
    
    if (![UserSetting isPurchasedVIPMode]) {
        //推出内购界面
        [ZZPublicClass pushToPurchasePage:self];
        return;
    }
    
    //隐藏单词view
    [self hideWordExplainView];
    
    NSString *explain = [self getExplain];
    
    CGFloat changeHeight;
    changeHeight =  [self textChangeHeight] + [self questionChangeHeight];
    
    if (self.ExTableView) {
        //设置动画效果
        [UIView beginAnimations:@"ExplainShow" context:nil];
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        CGRect frame = self.ExTableView.frame;
        
        switch (_explainShowStyle) {
            case ExplainStyleHide:
                _explainShowStyle = ExplainStyleShow;
                [self.ExTableView setExplainAndRefresh:explain];
                [self.ExTableView setContentOffset:CGPointZero animated:YES];
                frame.origin.y += (44 + changeHeight);
                
                if ([UserSetting isSystemOS7]) {
                    frame.origin.y += IOS7_SATUTS_HEIGHT;
                }
                break;
                
            case ExplainStyleShow:
                _explainShowStyle = ExplainStyleHide;
                
                frame.origin.y -= (44 + changeHeight);
                
                if ([UserSetting isSystemOS7]) {
                    frame.origin.y -= IOS7_SATUTS_HEIGHT;
                }
                break;
                
            default:
                break;
        }
        [self.ExTableView setFrame:frame];
        [UIView commitAnimations];

    } else {
        
        CGRect explainRect = (IS_IPAD ? CGRectMake(0, 44 - changeHeight, 768, changeHeight) : CGRectMake(0, 44 - changeHeight, 320, changeHeight));
        if ([UserSetting isSystemOS7]) {
            explainRect.origin.y += IOS7_SATUTS_HEIGHT;
        }
        _explainShowStyle = ExplainStyleShow;
        _ExTableView = [[ExplainTableView alloc] initWithFrame:explainRect];
        _ExTableView.parentVC = self;
        _ExTableView.tag = TAG_EXPLAIN_TABLE;
        [self.view insertSubview:self.ExTableView aboveSubview:self.textTable];
        
        [_ExTableView setExplainAndRefresh:explain];
        
        //设置动画效果
        [UIView beginAnimations:@"ExplainShow" context:nil];
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        CGRect frame = self.ExTableView.frame;
        frame.origin.y += changeHeight;
        [self.ExTableView setFrame:frame];
        [UIView commitAnimations];
    }
}

- (void)hideExplainTableView {
    if (self.ExTableView && _explainShowStyle == ExplainStyleShow) {
        _explainShowStyle = ExplainStyleHide;
        [self.ExTableView setExplainAndRefresh:[self getExplain]];
        
        //设置动画效果
        [UIView beginAnimations:@"ExplainShow" context:nil];
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        CGRect frame = self.ExTableView.frame;
        
        frame.origin.y -= (44 + [self questionChangeHeight] + [self textChangeHeight]);
        
        if ([UserSetting isSystemOS7]) {
            frame.origin.y -= IOS7_SATUTS_HEIGHT;
        }
        
        [self.ExTableView setFrame:frame];
        [UIView commitAnimations];
    }
    
}

- (void)hideWordExplainView {
    if (_WordView) {
        [_WordView hide:nil];
    }
}

#pragma mark - My Private method
- (void)setFavTitleStatusIsFavBy:(TextAndQuesClass *)TAQ {
    NSArray *barBtns = [self.navBar.navItem rightBarButtonItems];
    UIBarButtonItem *barBtn = nil;
    if ([self isHasExplain:TAQ]) {
        barBtn = [barBtns objectAtIndex:2];
    } else {
        barBtn = [barBtns objectAtIndex:1];
    }
    
    UIButton *favBtn = (UIButton *)[barBtn customView];
    NSString *pngName = nil;
    //改变按钮的状态
    if (TAQ.isFavorite) {
        //换图标到非收藏状态
        pngName = @"favYES.png";
        
    } else {
        //换图标到收藏状态
        pngName = @"favNO.png";
        
    }
    [favBtn setImage:[UIImage imageNamed:pngName] forState:UIControlStateNormal];
}

- (void)updateDetailScoreToDatabaseByTAQ:(TextAndQuesClass *)TAQ {
    //把一篇文章的handle值， 正确的题目， 学习的时间记录到数据库中
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:path];
    
    int lastStudyTime = 0;//取得上次的做题时间
    int lastRightNum = 0;//取得上次的题目正确数目
    int soundTime = 0;
    NSString *getInfo = [NSString stringWithFormat:@"SELECT StudyTime, RightNum, SoundTime FROM TitleInfo WHERE TestType = %d AND PartType = %d AND TitleNum = %d;", TEST_TYPE, TAQ.partType, TAQ.titleNum];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [getInfo UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询收藏信息失败");
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        lastStudyTime = sqlite3_column_int(stmt, 0);
        lastRightNum = sqlite3_column_int(stmt, 1);
        soundTime = sqlite3_column_int(stmt, 2);
    }
    sqlite3_finalize(stmt);
    
    //计算题目的正确率，占60%，都选择正确满分，其他选错情况0分
    int rightNum = 0;
    int quesNum = 0;
    BOOL isRight = NO;
    BOOL isStudy = NO;//判断是否做了本篇的问题
    quesNum = TAQ.quesNum;
    int countAllSel= [[TAQ selectArray] count];
    for (int i = 0; i < countAllSel; i++) {//选出本篇文章的所有用户选择数组和答案数组
        NSMutableArray *perSelArray = [TAQ.selectArray objectAtIndex:i];
        NSMutableArray *perAnsArray = [TAQ.answerArray objectAtIndex:i];
        int countPerSel = [perSelArray count];//选择项数量
        int countPerAnswer = [perAnsArray count];//正确答案的个数
        int countWrongNum = 0;
        for (int c = 0; c < countPerSel; c++) {//选择其中一道题的用户选择数组
            BOOL isSel = [[perSelArray objectAtIndex:c] boolValue];
            if (isSel) {//如果选择这道题的某一个选项
                isStudy = YES;//作答了本篇文章
                int count = [perAnsArray count];
                for (int i = 0; i < count; i++) {//循环每一道答案
                    int answer = [[perAnsArray objectAtIndex:i] intValue];
                    if (answer == c + 1) {//出现选择正确的题目
                        countPerAnswer--;
                        break;
                    } else if (i == count - 1) {
                        countWrongNum++;
                    }
                }
            }
            
            if (c == countPerSel - 1 && countPerAnswer == 0) {
                isRight = YES;
                break;
            } else if (countWrongNum > 0){
                isRight = NO;
                break;
            }
        }
        
        if (isRight) {
            rightNum++;//正确题目的数量
        }
        
        isRight = NO;
    }
    
    float score_right = 0.0f;
    if (!isStudy) {
        rightNum = lastRightNum;
    }    
    score_right = (rightNum * SCORE_RIGHT_PERCENT) / quesNum;
    
    //计算学习时间，占40%
    NSTimeInterval studyTime = [NSDate passedSecondFormDate:_thisTitleInDate];
    int totalStudyTime = (int)studyTime + lastStudyTime;
    if (soundTime == 0) {//确保数据库不会错误的把soundTime填错
        soundTime = 1;
    }
    float score_time = (totalStudyTime * SCORE_TIME_PERCENT) / soundTime;
    if (totalStudyTime >= soundTime) {
        score_time = SCORE_TIME_PERCENT;
    }
    
    //把本篇文章的分数记录下来
    int handle = (int)(score_right + score_time);
    if (handle < 7) {//handle小于7分的话，设置为7，保证在7天之后才有可能再次出现
        handle = 7;
    }
    
    //将成绩存入数据库
    NSString *update = [NSString stringWithFormat:@"UPDATE TitleInfo SET StudyTime = %d, Handle = %d, RightNum = %d WHERE TestType = %d AND PartType = %d AND TitleNum = %d;", totalStudyTime, handle, rightNum, TEST_TYPE, TAQ.partType, TAQ.titleNum];
    
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    
    //关闭数据库
    [self closeDatabase];
    
    //刷新进入的时间
    [_thisTitleInDate release];
    _thisTitleInDate = [[NSDate getLocateDate:[NSDate date]] retain];

}

- (void)updatePlanScoreToDatabase {
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:path];
    
    
    int lastStudyTime = 0;//取得上次的做题时间
//    int lastRightScore = 0;//取得上次的题目正确率
    NSString *getScore = [NSString stringWithFormat:@"SELECT StudyTime, RightScore FROM Progress WHERE YMD = %d;", _YMD];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [getScore UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询收藏信息失败");
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        lastStudyTime = sqlite3_column_int(stmt, 0);
//        lastRightScore = sqlite3_column_int(stmt, 1);
    }
    sqlite3_finalize(stmt);
    
    //计算题目的正确率，占60%，都选择正确满分，其他选错情况0分
    int rightNum = 0;
    int quesNum = 0;
    BOOL isRight = NO;
    for (int a = 0; a <_lastIndex; a++) {//选出文章
        BOOL isStudy = NO;//判断是否做了本篇的问题
        int perRightNum = 0;
        TextAndQuesClass *TAQ = [_TAQArray objectAtIndex:a];
        quesNum += TAQ.quesNum;
        int countAllSel= [[TAQ selectArray] count];
        for (int b = 0; b < countAllSel; b++) {//选出本篇文章的所有用户选择数组和答案数组
            NSMutableArray *perSelArray = [TAQ.selectArray objectAtIndex:b];
            NSMutableArray *perAnsArray = [TAQ.answerArray objectAtIndex:b];
            int countPerSel = [perSelArray count];//选择项数量
            int countPerAnswer = [perAnsArray count];//正确答案的个数
            int countWrongNum = 0;
            for (int c = 0; c < countPerSel; c++) {//选择其中一道题的用户选择数组
                BOOL isSel = [[perSelArray objectAtIndex:c] boolValue];
                if (isSel) {//如果选择这道题的某一个选项
                    isStudy = YES;//作答了本篇文章
                    int count = [perAnsArray count];
                    for (int i = 0; i < count; i++) {//循环每一道答案
                        int answer = [[perAnsArray objectAtIndex:i] intValue];
                        if (answer == c + 1) {//出现选择正确的题目
                            countPerAnswer--;
                            break;
                        } else if (i == count - 1) {
                            countWrongNum++;
                        }
                    }
                }
                
                if (c == countPerSel - 1 && countPerAnswer == 0) {
                    isRight = YES;
                    break;
                } else if (countWrongNum > 0){
                    isRight = NO;
                    break;
                }
            }
            
            if (isRight) {
                rightNum++;//全部正确题目的数量
                perRightNum++;//当前文章的正确题目的数量
            }
            
            isRight = NO;
        }
        
        if (isStudy) {
            //把本篇文章的分数记录下来
            [_rightNumArray replaceObjectAtIndex:a withObject:[NSNumber numberWithInt:perRightNum]];
        }        

    }
    
    int totalRightNum = 0;
    NSString *rightNumStr = [NSString string];
    for (NSNumber *r in _rightNumArray) {
        int rightNum = [r intValue];
        totalRightNum += rightNum;
        rightNumStr = [rightNumStr stringByAppendingFormat:@"%d%@", rightNum, SEPARATE_SYMBOL];
    }
    
    if (quesNum == 0) {//确保不会有没有问题的文章
        quesNum = 1;
    }
    float score_right = (totalRightNum * SCORE_RIGHT_PERCENT) / quesNum;
    
//    float score_right = (rightNum * SCORE_RIGHT_PERCENT) / quesNum;
//    if (score_right < lastRightScore) {
//        score_right = lastRightScore;
//    }
//    NSLog(@"rightNum is %d, quesNum is %d, score is %f", rightNum, quesNum, score_right);
    
    
    //计算学习时间，占40%
    NSTimeInterval studyTime = [NSDate passedSecondFormDate:_inDate];
    int totalStudyTime = (int)studyTime + lastStudyTime;
    float score_time = (totalStudyTime * SCORE_TIME_PERCENT) / _totalTime;
    if (totalStudyTime >= _totalTime) {
        score_time = SCORE_TIME_PERCENT;
    }
    
    
    //总成绩
    int finalScore = (int)(score_right + score_time);
    
    //将成绩存入数据库
    NSString *update = [NSString stringWithFormat:@"UPDATE Progress SET StudyTime = %d, Score = %d, RightScore = %d, RightNum = '%@', LastIndex = %d WHERE YMD = %d;", totalStudyTime, finalScore, (int)score_right, rightNumStr, _currentIndex, _YMD ];
    
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    
    //关闭数据库
    [self closeDatabase];
    
}

- (void)changeFromPrevTAQ:(TextAndQuesClass *)prevTAQ toCurrTAQ:(TextAndQuesClass *)currTAQ {
    
    //设置解析的内容
    if (self.ExTableView && _explainShowStyle == ExplainStyleShow) {
        [self.ExTableView setExplainAndRefresh:[self getExplain]];
        [self.ExTableView setContentOffset:CGPointZero animated:YES];
    }
    
    //问题cell的更新
    int quesMin = prevTAQ.quesNum - currTAQ.quesNum;
    NSMutableArray *editRows = [[NSMutableArray alloc] init];
    for (int i = 0; i < abs(quesMin); i++) {
        [editRows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [_questionTable beginUpdates];
    if (quesMin > 0) {
        [_questionTable deleteRowsAtIndexPaths:editRows withRowAnimation:UITableViewRowAnimationBottom];
    } else if (quesMin < 0) {
        [_questionTable insertRowsAtIndexPaths:editRows withRowAnimation:UITableViewRowAnimationBottom];
    }

    [_questionTable endUpdates];
    [_questionTable reloadData];
    [_questionTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    if (_textShowStyle == TextShowStyleAll) {
        //原文cell的更新
        int textMin = [prevTAQ.senArray count] - [currTAQ.senArray count];

        [editRows removeAllObjects];
        for (int i = 0; i < abs(textMin); i++) {
            [editRows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [_textTable beginUpdates];
        if (textMin > 0) {
            [_textTable deleteRowsAtIndexPaths:editRows withRowAnimation:UITableViewRowAnimationBottom];
        } else if (textMin < 0) {
            [_textTable insertRowsAtIndexPaths:editRows withRowAnimation:UITableViewRowAnimationBottom];
        }

        [_textTable endUpdates];
        [_textTable reloadData];
        [_textTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    } else {
        [_textTable reloadData];
    }
    
    //释放
    [editRows release];
    
    //更新收藏状态
    currTAQ.isFavorite = [self getCurrIsFavoriteByTitleNum:currTAQ.titleNum partType:currTAQ.partType];
    [self setFavTitleStatusIsFavBy:currTAQ];
    
    //如果问题有播放的存在，则停止
    [self playQuesAudioByQuesIndex:_currQuesPlayIndex msgIsFromZZAudioPlayer:YES];
    
    //更改播放的音频
//    [_audioPlayer playSoundByAudioName:currTAQ.soundName timeArray:currTAQ.timingArray lastTimePoint:0.0f];
    [_audioPlayer playSoundWithAudioName:currTAQ.soundName packName:currTAQ.packName isFree:currTAQ.isFree timeArray:currTAQ.timingArray lastTimePoint:0.0f];
    
    //问题是否可以滚动
    [self checkQuestionScrollEnabled];
    _syncNum = 0;
    
    if (!currTAQ.isVip) {
        [self showAlertView];
    }
    
    //更新titleInfo表的handle字段
    [self updateDetailScoreToDatabaseByTAQ:prevTAQ];
    
    //设置NavBarTitleName
    [self setNavBarTitleNameBy:currTAQ];
    
}


//更新收藏文章状态
- (void)updateTitleFavoriteStatus {
    TextAndQuesClass *TAQ = [self getCurrTAQ];
    
    NSArray *barBtns = [self.navBar.navItem rightBarButtonItems];
    UIBarButtonItem *barBtn = nil;
    if ([self isHasExplain:TAQ]) {
        barBtn = [barBtns objectAtIndex:2];
    } else {
        barBtn = [barBtns objectAtIndex:1];
    }
    
    UIButton *favBtn = (UIButton *)[barBtn customView];
    NSString *pngName = nil;
    //改变按钮的状态
    if (TAQ.isFavorite) {
        TAQ.isFavorite = NO;
        //换图标到非收藏状态
        pngName = @"favNO.png";
        
    } else {
        TAQ.isFavorite = YES;
        //换图标到收藏状态
        pngName = @"favYES.png";
        
    }
    [favBtn setImage:[UIImage imageNamed:pngName] forState:UIControlStateNormal];
    
    //把收藏状态存到数据库中
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:path];
    
    
    NSString *trueOrFalse = (TAQ.isFavorite == YES ? @"true" : @"false");
    
    //set Favorite
    NSString *setFav = [NSString stringWithFormat:@"UPDATE TitleInfo SET Favorite = '%@' WHERE TestType = %d AND PartType = %d AND TitleNum = %d", trueOrFalse, TEST_TYPE, TAQ.partType, TAQ.titleNum];
    
    char *errorMsg = NULL;
    if (sqlite3_exec (_database, [setFav UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, [NSString stringWithUTF8String:errorMsg]);
    }
    
    //关闭数据库
    [self closeDatabase];
    
}

//获取当前收藏文章状态
- (BOOL)getCurrIsFavoriteByTitleNum:(int)titleNum partType:(PartTypeTags)partType {
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:path];
    
    //get Text
    NSString *getFav = [NSString stringWithFormat:@"SELECT Favorite FROM TitleInfo WHERE TestType = %d AND PartType = %d AND TitleNum = %d", TEST_TYPE, partType, titleNum];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [getFav UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询句子信息失败");
    }
    BOOL returnFavorite = NO;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        Byte* isFav = (Byte*)sqlite3_column_blob(stmt, 0);
        NSString *isF = [NSString stringWithFormat:@"%s", isFav];
        if ([isF isEqualToString:@"true"]) {
            returnFavorite = YES;
        } else {
            returnFavorite = NO;
        }
        
    }
    sqlite3_finalize(stmt);
    
    //关闭数据库
    [self closeDatabase];
    
    return returnFavorite;
}

//判断cell是否在屏幕可视范围之内
- (BOOL)cellIsInScreen:(TextCell *)cell {
    
//    CGRect cellRect = [self.view convertRect:cell.frame fromView:_textTable];
    CGRect cellRect = [_textTable convertRect:cell.frame toView:self.view];
    
    int heightOfView = 360;
    CGRect viewRect;
    if (IS_IPAD) {
        heightOfView = (self.isPurchaseVIPMode ? 860 : 860 - IPAD_AD_BANNER_HEIGHT);
        viewRect = CGRectMake(0, 44, 768, heightOfView);
    } else {
        if (IS_IPHONE_568H) {
            heightOfView = (self.isPurchaseVIPMode ? 448 : 448 - IPHONE_AD_BANNER_HEIGHT);
        } else {
            heightOfView = (self.isPurchaseVIPMode ? 360 : 360 - IPHONE_AD_BANNER_HEIGHT);
        }
        viewRect = CGRectMake(0, 44, 320, heightOfView);
    }
    

    cellRect.origin.y = (int)cellRect.origin.y % heightOfView;
    
    return CGRectContainsRect(viewRect, cellRect);
}

- (NSString *)getQuesTextByRow:(NSInteger)row {
    TextAndQuesClass *TAQ = [self getCurrTAQ];
    NSString *quesText = [[TAQ quesTextArray] objectAtIndex:row];
    if ([TestType isHSK]) {
        quesText = [NSString stringWithFormat:@"%d.%@", (TAQ.titleNum % 100) + row, quesText];
    } else {
        quesText = [NSString stringWithFormat:@"%d.%@", row + 1, quesText];
    }
    
    return quesText;
}

- (NSString *)getAnswerTextByRow:(NSInteger)row {
    TextAndQuesClass *TAQ = [self getCurrTAQ];
    NSMutableArray *textArray = [[TAQ ansTextArray] objectAtIndex:row];
    int count = [textArray count];
    NSString *ansText = [NSString string];
    if ([TestType isHSK]) {
        ansText = [NSString stringWithFormat:@"%d.\n", (TAQ.titleNum % 100) + row];
    }
    
    for (int i = 0; i < count; i++) {
        if ([TestType isJLPT] || [TestType isHSK]) {
            ansText = [ansText stringByAppendingFormat:@"%@\n", [textArray objectAtIndex:i]];
        } else {
            ansText = [ansText stringByAppendingFormat:@"%c) %@\n", 'A' + i, [textArray objectAtIndex:i]];
        }
    }
//    quesText = [quesText stringByAppendingFormat:@"\n%@", ansText];
    
    return ansText;
}

- (CGFloat)getBtnHeightByBtnNum:(int)num {
    int rows = (int)ceilf(num / 4.0);
    
    CGFloat margin = ((IS_IPAD ? 768 : 320) - 4 * CELL_ANSBTN_WIDTH) / 5;
    return (CGFloat)(rows * (margin + CELL_ANSBTN_HEIGHT));
}

- (TextAndQuesClass *)getCurrTAQ {
    return [_TAQArray objectAtIndex:_currentIndex - 1];
}

- (void)setTAQs {
    
    //    NSMutableArray *textAndQuesArray = _TAQArray;//[[NSMutableArray alloc] init];
    
    
    NSString *path = [ZZAcquirePath getDBTextAnswerExplainFromBundle];
    [self openDatabaseIn:path];
    
    int count = [_articleIndexArray count];
    for (int i = 0; i < count; i++) {
        int num = [[_articleIndexArray objectAtIndex:i] intValue];
        int quesNum = [[_quesNumArray objectAtIndex:i] intValue];
        
        TextAndQuesClass *TAQ = [TextAndQuesClass textAndQuesClassWithTestType:TEST_TYPE titleNum:num quesNum:quesNum];
        
        /*******get Text************/
        NSString *getText = [NSString stringWithFormat:@"SELECT Sentence, Timing, Sound, PartType, TitleName FROM Text WHERE TestType = %d AND TitleNum = %d ORDER BY SenIndex;", TEST_TYPE, num];
        
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(_database, [getText UTF8String], -1, &stmt, nil) != SQLITE_OK) {
            sqlite3_close(_database);
            NSAssert(NO, @"查询句子信息失败");
        }
        
        NSString *sentence = nil;
        NSString *timing = nil;
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            sentence = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
            timing = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
            
            TAQ.soundName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
            TAQ.soundName = [TAQ.soundName stringByAppendingString:TEMP_AUDIO_SUFFIX];
            TAQ.partType = sqlite3_column_int(stmt, 3);
            TAQ.partTypeTag = sqlite3_column_int(stmt, 3);
            TAQ.titleName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)];
            
            [TAQ.senArray addObject:sentence];
            [TAQ.timingArray addObject:timing];
            
        }
        sqlite3_finalize(stmt);
        
        
        /*******取得问题信息*************/
        sqlite3_stmt *stmtAnswer;
        //get Answer
        NSString *getAnswer = [NSString stringWithFormat:@"SELECT QuesText, QuesImage, AnswerNum, Sound, IsSingle, AnswerText, Answer, QuesIndex FROM Answer WHERE TestType = %d AND TitleNum = %d AND QuesIndex > 0 AND QuesIndex <= %d ORDER BY QuesIndex;", TEST_TYPE, num, quesNum];
        if (sqlite3_prepare_v2(_database, [getAnswer UTF8String], -1, &stmtAnswer, nil) != SQLITE_OK) {
            sqlite3_close(_database);
            NSAssert(NO, @"查询句子信息失败");
        }
        
        NSString *quesText = @"";
        NSArray *quesImgNameArray = nil;
        int answerNum;
        NSString *quesSoundName = @"";
        //        BOOL isSingle = YES;
        NSMutableArray *ansTextArray = [NSMutableArray array];
        NSMutableArray *answerArray = nil;
        NSMutableArray *selectArray = nil;
        
        char *imgName = NULL;
        char *ansText = NULL;
        char *qSoundName = NULL;
        while (sqlite3_step(stmtAnswer) == SQLITE_ROW) {
            
            char *cQuesText = (char *)sqlite3_column_text(stmtAnswer, 0);
            if (cQuesText != NULL) {
//                int quesIndex = sqlite3_column_int(stmtAnswer, 7);
//                NSString *qt = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmtAnswer, 0)];
//                quesText = [NSString stringWithFormat:@"%d.%@", quesIndex, qt];
                quesText = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmtAnswer, 0)];
            }
            
            imgName = (char *)sqlite3_column_text(stmtAnswer, 1);
            if (imgName != NULL) {
                quesImgNameArray = [[NSString stringWithUTF8String:imgName] componentsSeparatedByString:SEPARATE_SYMBOL];
            }
            
            answerNum = sqlite3_column_int(stmtAnswer, 2);
            
            qSoundName = (char *)sqlite3_column_text(stmtAnswer, 3);
            if (qSoundName != NULL) {
                quesSoundName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmtAnswer, 3)];
            }
//            isSingle = (sqlite3_column_int(stmtAnswer, 4) == 1 ? YES : NO);
            
            ansText = (char *)sqlite3_column_text(stmtAnswer, 5);
            if (ansText != NULL) {
                ansTextArray = (NSMutableArray *)[[NSString stringWithUTF8String:ansText] componentsSeparatedByString:SEPARATE_SYMBOL];
            }
            
            answerArray = (NSMutableArray *)[[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmtAnswer, 6)] componentsSeparatedByString:SEPARATE_SYMBOL];
            
            //初始化用户的选择数组
            selectArray = [NSMutableArray arrayWithCapacity:answerNum];
            for (int i = 0; i < answerNum; i++) {
                [selectArray addObject:[NSNumber numberWithBool:NO]];
            }
            
            [TAQ.quesTextArray addObject:quesText];
//            [TAQ.quesImgNameArray addObject:quesImgNameArray];
            TAQ.quesImgNameArray = quesImgNameArray;
            [TAQ.quesSoundNameArray addObject:quesSoundName];
            [TAQ.ansNumArray addObject:[NSNumber numberWithInt:answerNum]];
            //            [TAQ.ansIsSingleArray addObject:[NSNumber numberWithBool:isSingle]];
            [TAQ.ansTextArray addObject:ansTextArray];
            [TAQ.answerArray addObject:answerArray];
            [TAQ.selectArray addObject:selectArray];
            
        }
        sqlite3_finalize(stmtAnswer);
        
        [_TAQArray addObject:TAQ];
    }
    
    //关闭数据库
    [self closeDatabase];
    
    //    return textAndQuesArray;
}

- (void)setTAQsWithMoreInfo {
    
    NSString *path = [ZZAcquirePath getDBZZAIdbFromDocuments];
    [self openDatabaseIn:path];
    
    int count = [_TAQArray count];
    for (int i = 0; i < count; i++) {
        
        TextAndQuesClass *TAQ = [_TAQArray objectAtIndex:i];
        
        /*******TitleInfo*************/
        NSString *getTitleInfo = [NSString stringWithFormat:@"SELECT PackName, Vip, EnText, CnText, JpText, EnExplain, CnExplain, JpExplain FROM TitleInfo WHERE TitleNum = %d", TAQ.titleNum];
        sqlite3_stmt *stmtTitleInfo;
        if (sqlite3_prepare_v2(_database, [getTitleInfo UTF8String], -1, &stmtTitleInfo, nil) != SQLITE_OK) {
            sqlite3_close(_database);
            NSAssert(NO, @"查询TitleInfo信息失败");
        }
        
        while (sqlite3_step(stmtTitleInfo) == SQLITE_ROW) {
            NSString *packName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmtTitleInfo, 0)];
            NSString *isVipStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmtTitleInfo, 1)];
            BOOL isVip = ([isVipStr isEqualToString:@"true"] ? YES : NO);
            
            NSString *isEnTextStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmtTitleInfo, 2)];
            BOOL isEnText = ([isEnTextStr isEqualToString:@"true"] ? YES : NO);
            
            NSString *isCnTextStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmtTitleInfo, 3)];
            BOOL isCnText = ([isCnTextStr isEqualToString:@"true"] ? YES : NO);
            
            NSString *isJpTextStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmtTitleInfo, 4)];
            BOOL isJpText = ([isJpTextStr isEqualToString:@"true"] ? YES : NO);
            
            NSString *isEnExplainStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmtTitleInfo, 5)];
            BOOL isEnExplain = ([isEnExplainStr isEqualToString:@"true"] ? YES : NO);
            
            NSString *isCnExplainStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmtTitleInfo, 6)];
            BOOL isCnExplain = ([isCnExplainStr isEqualToString:@"true"] ? YES : NO);
            
            NSString *isJpExplainStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmtTitleInfo, 7)];
            BOOL isJpExplain = ([isJpExplainStr isEqualToString:@"true"] ? YES : NO);
            
            TAQ.packName = packName;
            TAQ.isVip = isVip;
            TAQ.isENText = isEnText;
            TAQ.isENExplain = isEnExplain;
            TAQ.isCNText = isCnText;
            TAQ.isCNExplain = isCnExplain;
            TAQ.isJPText = isJpText;
            TAQ.isJPExplain = isJpExplain;
            
        }
        sqlite3_finalize(stmtTitleInfo);
        
        
        /*******PackName*************/
        sqlite3_stmt *stmtPackInfo;
        //get Answer
        NSString *getPackInfo = [NSString stringWithFormat:@"SELECT IsFree FROM PackInfo WHERE PackName = '%@'", TAQ.packName];
        if (sqlite3_prepare_v2(_database, [getPackInfo UTF8String], -1, &stmtPackInfo, nil) != SQLITE_OK) {
            sqlite3_close(_database);
            NSAssert(NO, @"查询PackInfo信息失败");
        }
        
        while (sqlite3_step(stmtPackInfo) == SQLITE_ROW) {
            NSString *isFreeStr = [NSString stringWithFormat:@"%s", (Byte *)sqlite3_column_blob(stmtPackInfo, 0)];
            BOOL isFree = ([isFreeStr isEqualToString:@"true"] ? YES : NO);
            TAQ.isFree = isFree;
            
        }
        sqlite3_finalize(stmtPackInfo);
    }
    
    [self closeDatabase];
}

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

#pragma mark - Table view delegate
/*
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIImageView *imgView = nil;
    if (tableView.tag == TAG_TEXT_TABLE && _textShowStyle != TextShowStyleAll) {
        
        static NSString *TextSectionIdentifier = @"TextSectionFooter";
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        
//        UIImageView *imgView = nil;
        if (version >= 6.0)
        {
            // iPhone 3.0 code here
            imgView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:TextSectionIdentifier];
            if (!imgView) {
                imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grayLine.png"]] autorelease];
            }
        } else {
            imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grayLine.png"]] autorelease];
        }

    }
    
    return imgView;
    
}
 */

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    SectionView *TQEView = nil;
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];

    if (tableView.tag == TAG_TEXT_TABLE) {
        static NSString *TextSectionIdentifier = @"TextSectionHeader";
    
        if (version >= 6.0) {
            TQEView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:TextSectionIdentifier];
            if (!TQEView) {
                TQEView = [[[SectionView alloc] initWithSectionNameTag:SectionNameText] autorelease];
            }
        } else {
            TQEView = [[[SectionView alloc] initWithSectionNameTag:SectionNameText] autorelease];
        }
        
        
    } else {
        static NSString *QuestionSectionIdentifier = @"QuestionSectionHeader";
        if (version >= 6.0) {
            TQEView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:QuestionSectionIdentifier];
            if (!TQEView) {
                TQEView = [[[SectionView alloc] initWithSectionNameTag:SectionNameQuestion] autorelease];
            }
        } else {
            TQEView = [[[SectionView alloc] initWithSectionNameTag:SectionNameQuestion] autorelease];
        }
        
    }

    
    return TQEView;
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView.tag == TAG_TEXT_TABLE) {
        
        if (_textShowStyle == TextShowStyleAll) {
            return [[[self getCurrTAQ] timingArray] count];
        } else {
            return 1;
        }
        
    } else {
        return [[self getCurrTAQ] quesNum];
        
    }
}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return (IS_IPAD ? 22 : 13);
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int row = indexPath.row;
    TextAndQuesClass *TAQ = [self getCurrTAQ];
    
    CGFloat height = 200;
    if (tableView.tag == TAG_TEXT_TABLE) {
        
        height = [self questionChangeHeight];
        
        if (_textShowStyle == TextShowStyleAll) {
            NSString *sentence = [[TAQ senArray] objectAtIndex:row];
            height = [ZZPublicClass getTVHeightByStr:sentence constraintWidth:TEXT_WIDTH_LIMIT isBold:NO];
            
            return height;
        }
        
    } else {
        
        int ansNum = [[[TAQ ansNumArray] objectAtIndex:row] intValue];
        CGFloat btnHeight = [self getBtnHeightByBtnNum:ansNum];
        
        if ([TestType isJLPT]) {
            NSString *answerText = [self getAnswerTextByRow:row];
            switch (TAQ.partTypeTag) {
                case PartType301:
                case PartType302:
                case PartType303:
                    height = JLPT_IMG_HEIGHT;
                    break;
                case PartType304:
                case PartType305:
                case PartType306:
                case PartType307:
                case PartType308:
                case PartType309:
                case PartType310:
                    height = [ZZPublicClass getTVHeightByStr:answerText constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
                    break;
                    
                default:
                    NSAssert(NO, @"JLPT PartType error");
                    break;
            }
        } else if ([TestType isToeic]) {
            switch (TAQ.partTypeTag) {
                case PartType401:
                    height = TOEIC_IMG_HEIGHT;
                    break;
                case PartType402:
                    height = [ZZPublicClass getTVHeightByStr:[self getAnswerTextByRow:row] constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
                    break;
                case PartType403:
                case PartType404:
                    height = [ZZPublicClass getTVHeightByStr:[self getQuesTextByRow:row] constraintWidth:QUES_WIDTH_LIMIT isBold:YES] + [ZZPublicClass getTVHeightByStr:[self getAnswerTextByRow:row] constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
                    break;
                    
                default:
                    NSAssert(NO, @"Toeic PartType error");
                    break;
            }
        } else if ([TestType isHSK]) {
            switch (TAQ.partTypeTag) {
                case PartType6011:
                case PartType6012:
                case PartType6013:
                case PartType6021:
                case PartType6022:
                case PartType6031:
                    height = HSK_IMG_HEIGHT;
                    break;
                    
                case PartType6032:
                case PartType6041:
                    height = [ZZPublicClass getTVHeightByStr:[self getQuesTextByRow:row] constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
                    break;
                case PartType6014:
                case PartType6023:
                case PartType6024:
                case PartType6033:
                case PartType6034:
                case PartType6042:
                case PartType6043:
                case PartType6051:
                case PartType6052:
                case PartType6061:
                case PartType6062:
                case PartType6063:
                    height = [ZZPublicClass getTVHeightByStr:[self getAnswerTextByRow:row] constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
                    break;
                    
                default:
                    NSAssert(NO, @"HSK PartType error");
                    break;
            }
        } else {
            NSString *quesText = [self getQuesTextByRow:row];
            NSString *answerText = [self getAnswerTextByRow:row];
            
            height = [ZZPublicClass getTVHeightByStr:quesText constraintWidth:QUES_WIDTH_LIMIT isBold:YES] + [ZZPublicClass getTVHeightByStr:answerText constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
        }
        
        return height + CELL_CONTENT_MARGIN + btnHeight;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == TAG_TEXT_TABLE) {
        
    } else {
        int num = [indexPath row];
        UIColor *color = nil;
        if (num % 2 == 0) {
            color = [UIColor colorWithRed:(CGFloat)232 / 255 green:(CGFloat)238 / 255 blue:(CGFloat)234 / 255 alpha:1.0];
        } else {
            color = [UIColor colorWithRed:(CGFloat)241 / 255 green:(CGFloat)250 / 255 blue:(CGFloat)245 / 255 alpha:1.0];
        }
        [cell setBackgroundColor:color];
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    
    if (tableView.tag == TAG_TEXT_TABLE) {
        
        static NSString *TextCellIdentifier = @"TextCell";
        TextCell *cell = [tableView dequeueReusableCellWithIdentifier:TextCellIdentifier];
        
        if (!cell) {
            cell = (TextCell *)[[[NSBundle mainBundle] loadNibNamed:TextCellIdentifier owner:self options:nil] objectAtIndex:(IS_IPAD ? 1 : 0)];
            cell.parentVC = self;
            cell.syncTV.parentVC = self;
            
            //设置字体
            //改字体改字体
//            [cell.syncTV setFont:[UIFont systemFontOfSize:self.userFontSizeReal]];
            cell.syncTV.font = [UIFont fontWithName:FONT_NAME size:self.userFontSizeReal];
            

        }
        
        cell.senIndex = row;
        
        NSString *sentence = [[[self getCurrTAQ] senArray] objectAtIndex:row];
        if (_textShowStyle == TextShowStyleAll) {
            
            [cell setSyncTVLayoutWithText:sentence];
            
            if (_syncNum == row) {
                [cell.syncTV setTextColor:_syncTextColor];
            } else {
                [cell.syncTV setTextColor:[UIColor blackColor]];
            }
        } else {
            
            [cell setSyncSingleTVLayoutWithText:sentence];
        }
        
        /*
        //收藏句子功能暂时屏蔽
        BOOL isFav = [[currTAQ.favSenArray objectAtIndex:row] boolValue];
        if (isFav) {
            //更改收藏句子按钮的状态
            [self setFavSenBtnStatus:YES inCell:cell];
        } else {
            //更改收藏句子按钮的状态
            [self setFavSenBtnStatus:NO inCell:cell];
        }
        */
        
        return cell;
    } else {
        
        TextAndQuesClass *currTAQ = [self getCurrTAQ];
        
        if ([TestType isJLPT]) {
            JLPTImageCell *cell = [self JLPTCellForRow:row tableView:tableView TAQ:currTAQ];
            return cell;
        } else if ([TestType isToeic]) {
            if (currTAQ.partType == PartType401 || currTAQ.partType == PartType402) {
                ToeicCell *cell = [self ToeicCellForRow:row tableView:tableView TAQ:currTAQ];
                return cell;
            } else {
                QuesCell *cell = [self NormalCellForRow:row tableView:tableView TAQ:currTAQ];
                return cell;
            }     
            
        } else if ([TestType isHSK]) {
            HSKCell *cell = [self HSKCellForRow:row tableView:tableView TAQ:currTAQ];
            return cell;
            
        } else {
            QuesCell *cell = [self NormalCellForRow:row tableView:tableView TAQ:currTAQ];
            return cell;
//            NSAssert(NO, @"没有正确的Cell可以加载");
//            return nil;
        }
        
    }
}

- (HSKCell *)HSKCellForRow:(int)row tableView:(UITableView *)tableView TAQ:(TextAndQuesClass *)TAQ {
    NSMutableArray *currAnswerArray = [[TAQ answerArray] objectAtIndex:row];
    NSMutableArray *currSelectArray = [[TAQ selectArray] objectAtIndex:row];
    int ansNum = [[[TAQ ansNumArray] objectAtIndex:row] intValue];//选项的数量也就是按钮的数量
    
    //不同选择用到的cell Indetifirt不同
    NSString *QuesCellIdentifier = [NSString stringWithFormat:@"HSKCellAnswerTypeIs%d", TAQ.partType];
    HSKCell *cell = (HSKCell *)[tableView dequeueReusableCellWithIdentifier:QuesCellIdentifier];
    
    if (!cell) {
        int nibIndex = 0;
        switch (TAQ.partTypeTag) {
            case PartType6011:
            case PartType6012:
            case PartType6013:
            case PartType6021:
            case PartType6022:
            case PartType6031:
                nibIndex = (IS_IPAD ? 2 : 0);
                break;
                
            case PartType6032:
            case PartType6041:
            case PartType6014:
            case PartType6023:
            case PartType6024:
            case PartType6033:
            case PartType6034:
            case PartType6042:
            case PartType6043:
            case PartType6051:
            case PartType6052:
            case PartType6061:
            case PartType6062:
            case PartType6063:
                nibIndex = (IS_IPAD ? 3 : 1);
                break;
                
            default:
                NSAssert(NO, @"HSK PartType error");
                break;
        }
        cell = (HSKCell *)[[[NSBundle mainBundle] loadNibNamed:@"HSKCell" owner:nil options:nil] objectAtIndex:nibIndex];
        
        cell.parentVC = self;
        cell.answerTV.parentVC = self;
        
        //改字体改字体
        //        [cell.ansTextView setFont:[UIFont systemFontOfSize:self.userFontSizeReal]];
        cell.answerTV.font = [UIFont fontWithName:FONT_NAME size:self.userFontSizeReal];
        
        //画imgview的边际
        [cell setImageBorderByHSKTag:TAQ.partTypeTag];
        
        //针对不同的题型设置cell的button, 需要取得按钮的数量
        switch (TAQ.partTypeTag) {
            case PartType6011:
            case PartType6021:
            case PartType6032:
            case PartType6041:
                [cell addRightOrWrongBtnToCell];
                break;
                
            default:
                [cell addAnswerBtnToCell:ansNum];
                break;
        }
        
    }
    
    //设置题号
    [cell setQuesIndex:row + 1];
    
    //选择题的话是quesText字段
    NSString *QAText = nil;
    CGFloat QAHeight = 0.0f;
    switch (TAQ.partTypeTag) {
        case PartType6032:
        case PartType6041:
            QAText = [self getQuesTextByRow:row];
            break;
            
        default:
            QAText = [self getAnswerTextByRow:row];
            break;
    }
    
    QAHeight = [ZZPublicClass getTVHeightByStr:QAText constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
    [cell setQuestionWithHSKTypeTag:TAQ.partType imageName:[TAQ.quesImgNameArray objectAtIndex:0] packName:TAQ.packName textHeight:QAHeight ansText:QAText];
    
    //设置按钮的位置,传入用户的选项和答案
    [cell setAnswerBtnLayoutByNum:ansNum answers:currAnswerArray selects:currSelectArray];
    
    return cell;
}

//Toeic的Cell
- (ToeicCell *)ToeicCellForRow:(int)row tableView:(UITableView *)tableView TAQ:(TextAndQuesClass *)TAQ {
    NSMutableArray *currAnswerArray = [[TAQ answerArray] objectAtIndex:row];
    NSMutableArray *currSelectArray = [[TAQ selectArray] objectAtIndex:row];
    int ansNum = [[[TAQ ansNumArray] objectAtIndex:row] intValue];//选项的数量也就是按钮的数量
    
    //不同选择用到的cell Indetifirt不同
    NSString *QuesCellIdentifier = [NSString stringWithFormat:@"ToeicCellAnswerTypeIs%d", TAQ.partType];
    ToeicCell *cell = (ToeicCell *)[tableView dequeueReusableCellWithIdentifier:QuesCellIdentifier];
    
    //取得文本str
    //    NSString *quesText = [self getQuesTextByRow:row];
    //    NSString *answerText = [self getAnswerTextByRow:row];
    
    if (!cell) {
        int nibIndex = 0;
        switch (TAQ.partTypeTag) {
            case PartType401:
                nibIndex = (IS_IPAD ? 2 : 0);
                break;
            case PartType402:
                nibIndex = (IS_IPAD ? 3 : 1);
                break;
            default:
                NSAssert(NO, @"Toeic没有正确的PartType");
                break;
        }
        cell = (ToeicCell *)[[[NSBundle mainBundle] loadNibNamed:@"ToeicCell" owner:nil options:nil] objectAtIndex:nibIndex];
        
        cell.parentVC = self;
        cell.ansTextView.parentVC = self;
        
        //改字体改字体
        //        [cell.ansTextView setFont:[UIFont systemFontOfSize:self.userFontSizeReal]];
        cell.ansTextView.font = [UIFont fontWithName:FONT_NAME size:self.userFontSizeReal];
        
        //画imgview的边际
        [cell setImageBorderByToeicTag:TAQ.partTypeTag];
        
        //针对不同的题型设置cell的button, 需要取得按钮的数量
        [cell addAnswerBtnToCell:ansNum];
        
    }
    
    //设置题号
    [cell setQuesIndex:row + 1];
    
    NSString *answerText = [self getAnswerTextByRow:row];
    CGFloat aHeight = [ZZPublicClass getTVHeightByStr:answerText constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
//    [cell setImageWithJLPTTypeTag:TAQ.partTypeTag imageArray:TAQ.quesImgNameArray packName:TAQ.packName textHeight:aHeight ansText:answerText];
    [cell setQuestionWithToeicTypeTag:TAQ.partType imageArray:TAQ.quesImgNameArray packName:TAQ.packName textHeight:aHeight ansText:answerText];
    
    //设置按钮的位置,传入用户的选项和答案
    [cell setAnswerBtnLayoutByNum:ansNum answers:currAnswerArray selects:currSelectArray];
    
    return cell;
}



//JLPT的cell
- (JLPTImageCell *)JLPTCellForRow:(int)row tableView:(UITableView *)tableView TAQ:(TextAndQuesClass *)TAQ {
    NSMutableArray *currAnswerArray = [[TAQ answerArray] objectAtIndex:row];
    NSMutableArray *currSelectArray = [[TAQ selectArray] objectAtIndex:row];
    int ansNum = [[[TAQ ansNumArray] objectAtIndex:row] intValue];//选项的数量也就是按钮的数量
    
    //不同选择用到的cell Indetifirt不同
    NSString *QuesCellIdentifier = [NSString stringWithFormat:@"JLPTCellAnswerTypeIs%d", TAQ.partType];
    JLPTImageCell *cell = (JLPTImageCell *)[tableView dequeueReusableCellWithIdentifier:QuesCellIdentifier];
    
    //取得文本str
//    NSString *quesText = [self getQuesTextByRow:row];
//    NSString *answerText = [self getAnswerTextByRow:row];
    
    if (!cell) {
        int nibIndex = 0;
        switch (TAQ.partTypeTag) {
            case PartType301:
                nibIndex = (IS_IPAD ? 4 : 0);
                break;
            case PartType302:
                nibIndex = (IS_IPAD ? 5 : 1);
                break;
            case PartType303:
                nibIndex = (IS_IPAD ? 6 : 2);
                break;
            case PartType304:
            case PartType305:
            case PartType306:
            case PartType307:
            case PartType308:
            case PartType309:
            case PartType310:
                nibIndex = (IS_IPAD ? 7 : 3);
                break;
                
            default:
                break;
        }
        cell = (JLPTImageCell *)[[[NSBundle mainBundle] loadNibNamed:@"JLPTCell" owner:nil options:nil] objectAtIndex:nibIndex];
        
        cell.parentVC = self;
        cell.ansTextView.parentVC = self;
        
        //改字体改字体
//        [cell.ansTextView setFont:[UIFont systemFontOfSize:self.userFontSizeReal]];
        cell.ansTextView.font = [UIFont fontWithName:FONT_NAME size:self.userFontSizeReal];
        
        //画imgview的边际
        [cell setImageBorderByJLPTTag:TAQ.partTypeTag];
        
        //针对不同的题型设置cell的button, 需要取得按钮的数量
        [cell addAnswerBtnToCell:ansNum];
        
    }
    
    //设置题号
    [cell setQuesIndex:row + 1];
    
    NSString *answerText = [self getAnswerTextByRow:row];
    CGFloat aHeight = [ZZPublicClass getTVHeightByStr:answerText constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
    [cell setImageWithJLPTTypeTag:TAQ.partTypeTag imageArray:TAQ.quesImgNameArray packName:TAQ.packName textHeight:aHeight ansText:answerText];
    
    //设置按钮的位置,传入用户的选项和答案
    [cell setAnswerBtnLayoutByNum:ansNum answers:currAnswerArray selects:currSelectArray];
    
    return cell;
}

//托福的Cell
- (QuesCell *)NormalCellForRow:(int)row tableView:(UITableView *)tableView TAQ:(TextAndQuesClass *)TAQ  {
    
    NSMutableArray *currAnswerArray = [[TAQ answerArray] objectAtIndex:row];
    NSMutableArray *currSelectArray = [[TAQ selectArray] objectAtIndex:row];
    
    //不同选择用到的cell Indetifirt不同
    int ansNum = [[[TAQ ansNumArray] objectAtIndex:row] intValue];//选项的数量也就是按钮的数量
    
    NSString *QuesCellIdentifier = [NSString stringWithFormat:@"QuesCellAnswerNumIs%d", ansNum];
    QuesCell *cell = (QuesCell *)[tableView dequeueReusableCellWithIdentifier:QuesCellIdentifier];
    
    //取得文本str
    NSString *quesText = [self getQuesTextByRow:row];
    NSString *answerText = [self getAnswerTextByRow:row];
    
    if (!cell) {
        cell = (QuesCell *)[[[NSBundle mainBundle] loadNibNamed:@"QuesCell" owner:nil options:nil] objectAtIndex:(IS_IPAD ? 1 : 0)];
        
        cell.parentVC = self;
        cell.quesTV.parentVC = self;
        cell.boldQuesTV.parentVC = self;
        
        //设置字体
        cell.quesTV.font = [UIFont fontWithName:FONT_NAME size:self.userFontSizeReal];
        cell.boldQuesTV.font = [UIFont fontWithName:FONT_NAME_BOLD size:self.userFontSizeReal];
        
        //针对不同的题型设置cell的button, 需要取得按钮的数量
        [cell addAnswerBtnToCell:ansNum];
        [cell addQuesPlayBtnToCell];
    }
    //设置questionPlayButton的状态
    if (_currQuesPlayIndex == row + 1) {
        [cell isQuesAudioPlaying:YES];
    } else {
        [cell isQuesAudioPlaying:NO];
    }
    
    //设置问题和选项文本
    //        [cell setQuesTVBy:quesText quesIndex:row + 1];
    [cell setQuesTVBy:quesText answer:answerText quesIndex:row + 1];
    
    //设置题号
    [cell setQuesIndex:row + 1];
    
    //设置按钮的位置,传入用户的选项和答案
    CGFloat qHeight = [ZZPublicClass getTVHeightByStr:quesText constraintWidth:QUES_WIDTH_LIMIT isBold:YES];
    CGFloat aHeight = [ZZPublicClass getTVHeightByStr:answerText constraintWidth:QUES_WIDTH_LIMIT isBold:NO];
    [cell setAnswerBtnLayoutByNum:ansNum height:qHeight + aHeight answers:currAnswerArray selects:currSelectArray];
    
    return cell;
}

#pragma mark - audioPlayerDelegate
- (void)setQuesAudioStop {
    QuesCell *cell = (QuesCell *)[_questionTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currQuesPlayIndex - 1 inSection:0]];
    [cell isQuesAudioPlaying:NO];
    _currQuesPlayIndex = -1;
}


- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    [self setQuesAudioStop];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self setQuesAudioStop];
    
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    
}

#pragma mark - ZZAudioPlayer delegate
- (void)ZZAudioTimePointChangedByNum:(int)senNum {
    
    //当前正在同步的句子号
    _syncNum = senNum;
    
    TextAndQuesClass *TAQ = [self getCurrTAQ];
    NSString *sentence = [[TAQ senArray] objectAtIndex:senNum];
    NSIndexPath *indexPath = nil;
    TextCell *cell = nil;
    
    if (_textShowStyle == TextShowStyleAll) {
        indexPath = [NSIndexPath indexPathForRow:senNum inSection:0];
        cell = (TextCell *)[_textTable cellForRowAtIndexPath:indexPath];
        if ([[[cell syncTV] text] isEqualToString:sentence]) {
            //判断是否在可视区域
            if (![self cellIsInScreen:cell]) {
                if ([UserSetting textKeepSync]) {
                    [UIView beginAnimations:@"ScrollAnim" context:nil];
//                    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
                    [UIView setAnimationDuration:0.5f];
                    [_textTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                    [UIView commitAnimations];
                }
            
            }
        } else {
            //根据假设数组计算应该滚动到的区域
            if ([UserSetting textKeepSync]) {
//                [UIView beginAnimations:@"HideMyView" context:nil];
////                [UIView setAnimationCurve:UIViewAnimationCurveLinear];
//                [UIView setAnimationDuration:1.0f];
                [_textTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//                [UIView commitAnimations];
                
            }
        
        }
        
        //高亮显示同步原文
        int count = [[TAQ senArray] count];
        for (int i = 0; i < count; i++) {
            TextCell *tCell = (TextCell *)[_textTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            if (![tCell.syncTV.text isEqual:[NSNull null]]) {
                [tCell.syncTV setTextColor:[UIColor blackColor]];
            }
        }
        [cell.syncTV setTextColor:_syncTextColor];
    } else if (_textShowStyle == TextShowStylePart){
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        cell = (TextCell *)[_textTable cellForRowAtIndexPath:indexPath];
        [cell setSyncSingleTVLayoutWithText:sentence];
        /*
         //收藏句子功能暂时屏蔽
        BOOL isFav = [[TAQ.favSenArray objectAtIndex:senNum] boolValue];
        [self setFavSenBtnStatus:isFav inCell:cell];
         */
    } else {
        
    }
    
}

- (void)ZZAudioNextTitleBtnPressed {
    if (_currentIndex < _lastIndex) {
        [_audioPlayer.prevQuesBtn setEnabled:YES];
        
        TextAndQuesClass *prevTAQ = [self getCurrTAQ];
        
        _currentIndex++;
        TextAndQuesClass *currTAQ = [self getCurrTAQ];
        
        [self changeFromPrevTAQ:prevTAQ toCurrTAQ:currTAQ];
        
    }
    if (_currentIndex >= _lastIndex) {
        [_audioPlayer.nextQuesBtn setEnabled:NO];
    }
    
}

- (void)ZZAudioPrevTitleBtnPressed {
    if (_currentIndex > 1) {
        [_audioPlayer.nextQuesBtn setEnabled:YES];
        
        TextAndQuesClass *prevTAQ = [self getCurrTAQ];
        
        _currentIndex--;
        TextAndQuesClass *currTAQ = [self getCurrTAQ];
        
        [self changeFromPrevTAQ:prevTAQ toCurrTAQ:currTAQ];
    }
    
    if (_currentIndex <= 1) {
        [_audioPlayer.prevQuesBtn setEnabled:NO];
    }
}

- (void)ZZAudioIsPlayingNow {
    
    if (_currQuesPlayIndex != -1) {
        //当前有问题音频在播放,停止问题音频的播放
        [self playQuesAudioByQuesIndex:_currQuesPlayIndex msgIsFromZZAudioPlayer:YES];
    }
}

- (void)ZZAudioPushToVIPPage {
    [ZZPublicClass pushToPurchasePage:self];
}

#pragma mark - Pick the word
- (NSString *)getWordTranslateBy:(NSString *)EnStr {
    NSString *path = [ZZAcquirePath getDBWORDSFromBundle];
    [self openDatabaseIn:path];
    
    NSString *getWord = [NSString stringWithFormat:@"SELECT id, audio, pron, def FROM EN_CN WHERE Word = '%@';", EnStr];
    
    NSString *define = @"很抱歉, 没有找到(> <)!";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [getWord UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询单词意思失败1");
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        define = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
    }
    sqlite3_finalize(stmt);
    
    //关闭数据库
    [self closeDatabase];
    
    return define;
}


- (void)catchAWordToShow:(NSString *)word {
    
    //先停止播放
    if (_isZZAudioPlaying) {
        
    } else {
        _isZZAudioPlaying = [_audioPlayer isZZAudioPlaying];
    }
    [_audioPlayer setZZAudioPlayerPause];
    
//    NSString * name = word;
    //本地化一下子
    NSString * defi = NSLocalizedString(@"CAN_NOT_FIND_WORD_SHORT", @"词义未找到");
    NSString * pron = @"";
    NSString * audio = @"";
//    Word * thisword = [[Word alloc] initWithWord:word Pron:pron Def:defi Audio:audio];
    Word *thisword = [Word wordWithWord:word Pron:pron Def:defi Audio:audio];
    
    if ([TestType isJapaneseTest]) {
        [self catchAJapaneseWordToShow:thisword];
    } else if ([TestType isEnglishTest]) {
        [self catchAEnglishWordToShow:thisword];
    } else if ([TestType isChineseTest]) {
        [self catchAChineseWordToShow:thisword];
    } else {
        NSAssert(NO, @"不能找到正确的辞典");
    }
    
}

- (void)catchAChineseWordToShow:(Word *)thisword {
    //查询数据库中的单词
    NSString *path = [ZZAcquirePath getDBWORDSFromBundle];
    [self openDatabaseIn:path];
    
    NSString *tableName = nil;
    NSString *language = nil;
    //本地化一下子
    switch ([UserSetting dictType]) {
        case DictTypeCN_EN:
            tableName = @"CN_EN";
            language = @"English";
            break;
        case DictTypeCN_JP:
            tableName = @"CN_JP";
            language = @"Japanese";
            break;
        case DictTypeCN_KR:
            tableName = @"CN_KR";
            language = @"Korean";
            break;
            
        default:
            NSAssert(NO, @"没有正确的字典");
            break;
    }
    
    NSString * sql = [NSString stringWithFormat:@"SELECT Chinese, %@, PinYin FROM %@ WHERE Chinese = \"%@\";", language, tableName, thisword.Name];
    
    
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询单词意思失败2");
    }
    
    //判断单词是否存在
    BOOL isExist = NO;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        isExist = YES;
        char *cChinese = (char *)sqlite3_column_text(stmt, 0);
        char *cForeign = (char *)sqlite3_column_text(stmt, 1);
        char *cPinYin = (char *)sqlite3_column_text(stmt, 2);
        
        if (cChinese != NULL) {
            thisword.Name = [NSString stringWithUTF8String:cChinese];
        }
        
        if (cPinYin != NULL) {
            thisword.Pronunciation = [NSString stringWithUTF8String:cPinYin];
        }
        
        if (cForeign != NULL) {
            thisword.Definition = [NSString stringWithUTF8String:cForeign];
        }
        
        if (_WordView) {
            _WordView = [WordExplainView ViewWithState:SVWordViewStateNoProunce errMSG:nil word:thisword];
            _WordView.studyVC = self;
            [_WordView show];
        }
        else {
            
            _WordView = [WordExplainView ViewWithState:SVWordViewStateNoProunce errMSG:nil word:thisword];
            _WordView.studyVC = self;
            UIWindow * window = [[UIApplication sharedApplication] keyWindow];
            if (!window)
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            [[[window subviews] objectAtIndex:0] addSubview:_WordView];
            
            [_WordView show];
        }
        
        break;
    }
    sqlite3_finalize(stmt);
    
    //不存在的弹出查找失败框
    if (!isExist) {
        NSError * err = [NSError errorWithDomain:NSLocalizedString(@"CAN_NOT_FIND_WORD", nil) code:0 userInfo:nil];
        [self WordFindInternetExpFailed:thisword witError:err];
    }
    
    //关闭数据库
    [self closeDatabase];
}

- (void)catchAJapaneseWordToShow:(Word *)thisword {
    //查询数据库中的单词
    NSString *path = [ZZAcquirePath getDBWORDSFromBundle];
    [self openDatabaseIn:path];
    
    NSString * sql = [NSString stringWithFormat:@"SELECT Kanji, Hiragana, En, Gb, ExGbGb, ExEnEn, ExGbJp, ExEnJp, Kr, Zh, ExZhZh, ExZhJp FROM JLPTN1 WHERE Kanji = \"%@\" OR Hiragana = \"%@\";", thisword.Name, thisword.Name];
    
    
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询单词意思失败3");
    }
    
    //判断单词是否存在
    BOOL isExist = NO;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        isExist = YES;
        char *cKanji = (char *)sqlite3_column_text(stmt, 0);
        char *cHiragana = (char *)sqlite3_column_text(stmt, 1);
        char *cEn = (char *)sqlite3_column_text(stmt, 2);
        char *cGb = (char *)sqlite3_column_text(stmt, 3);
        char *cExGbGb = (char *)sqlite3_column_text(stmt, 4);
        char *cExEnEn = (char *)sqlite3_column_text(stmt, 5);
        char *cExGbJp = (char *)sqlite3_column_text(stmt, 6);
        char *cExEnJp = (char *)sqlite3_column_text(stmt, 7);
        char *cKr = (char *)sqlite3_column_text(stmt, 8);
        char *cZh = (char *)sqlite3_column_text(stmt, 9);
        char *cExZhZh = (char *)sqlite3_column_text(stmt, 10);
        char *cExZhJp = (char *)sqlite3_column_text(stmt, 11);
        
        if (cKanji != NULL) {
            thisword.Name = [NSString stringWithUTF8String:cKanji];
        }
        
        if (cHiragana != NULL) {
            thisword.Pronunciation = [NSString stringWithUTF8String:cHiragana];
        }
        
        //本地化一下子
        switch ([UserSetting dictType]) {
            case DictTypeJP_CN:
                if (cGb != NULL) {
                    thisword.Definition = [NSString stringWithUTF8String:cGb];
                }
                
                if (cExGbJp != NULL) {
                    thisword.Definition = [thisword.Definition stringByAppendingFormat:@"\n%@", [NSString stringWithUTF8String:cExGbJp]];
                    
                }
                
                if (cExGbGb != NULL) {
                    thisword.Definition = [thisword.Definition stringByAppendingFormat:@"\n%@", [NSString stringWithUTF8String:cExGbGb]];
                }
                break;
            case DictTypeJP_EN:
                if (cEn != NULL) {
                    thisword.Definition = [NSString stringWithUTF8String:cEn];
                }
                
                if (cExEnJp != NULL) {
                    thisword.Definition = [thisword.Definition stringByAppendingFormat:@"\n%@", [NSString stringWithUTF8String:cExEnJp]];
                }
                
                if (cExEnEn != NULL) {
                    thisword.Definition = [thisword.Definition stringByAppendingFormat:@"\n%@", [NSString stringWithUTF8String:cExEnEn]];
                    
                }
                
                
                break;
            case DictTypeJP_KR:
                if (cKr != NULL) {
                    thisword.Definition = [NSString stringWithUTF8String:cKr];
                }
                break;
            case DictTypeJP_TCN:
                if (cZh != NULL) {
                    thisword.Definition = [NSString stringWithUTF8String:cZh];
                }
                
                if (cExZhJp != NULL) {
                    thisword.Definition = [thisword.Definition stringByAppendingFormat:@"\n%@", [NSString stringWithUTF8String:cExZhJp]];
                }
                
                if (cExZhZh != NULL) {
                    thisword.Definition = [thisword.Definition stringByAppendingFormat:@"\n%@", [NSString stringWithUTF8String:cExZhZh]];
                    
                }
                break;
                
            default:
                NSAssert(NO, @"没有正确的字典");
                break;
        }
        
        
        if (_WordView) {
            _WordView = [WordExplainView ViewWithState:SVWordViewStateNoProunce errMSG:nil word:thisword];
            _WordView.studyVC = self;
            [_WordView show];
        }
        else {
            
            _WordView = [WordExplainView ViewWithState:SVWordViewStateNoProunce errMSG:nil word:thisword];
            _WordView.studyVC = self;
            UIWindow * window = [[UIApplication sharedApplication] keyWindow];
            if (!window)
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            [[[window subviews] objectAtIndex:0] addSubview:_WordView];
            
            [_WordView show];
        }
        
        break;
    }
    sqlite3_finalize(stmt);
    
    //不存在的弹出查找失败框
    if (!isExist) {
        NSError * err = [NSError errorWithDomain:NSLocalizedString(@"CAN_NOT_FIND_WORD", nil) code:0 userInfo:nil];
        [self WordFindInternetExpFailed:thisword witError:err];
    }
    
    //关闭数据库
    [self closeDatabase];
}

- (void)catchAEnglishWordToShow:(Word *)thisword {
    //查询数据库中的单词
    NSString *path = [ZZAcquirePath getDBWORDSFromBundle];
    [self openDatabaseIn:path];
    
    NSString *tableName = nil;
//    NSString *sql = nil;
    //本地化一下子
    switch ([UserSetting dictType]) {
        case DictTypeEN_EN:
            tableName = @"EN_EN";
//            sql = [NSString stringWithFormat:@"SELECT Word, audio, pron, def FROM EN_CN WHERE Word = \"%@\";", thisword.Name];
            break;
        case DictTypeEN_CN:
            tableName = @"EN_CN";
//            sql = [NSString stringWithFormat:@"SELECT Word, audio, pron, def FROM EN_CN WHERE Word = \"%@\";", thisword.Name];
            break;
        case DictTypeEN_JP:
            tableName = @"EN_JP";
//            sql = [NSString stringWithFormat:@"SELECT Word, audio, pron, def FROM EN_JP WHERE Word = \"%@\";", thisword.Name];
            break;
            
        default:
            NSAssert(NO, @"没有正确的字典");
            break;
    }

    NSString * sql = [NSString stringWithFormat:@"SELECT Word, audio, pron, def FROM %@ WHERE Word = \"%@\";", tableName, thisword.Name];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询单词意思失败4");
    }
    
    //判断单词是否存在
    BOOL isExist = NO;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        isExist = YES;
        
        char *cWord = (char *)sqlite3_column_text(stmt, 0);
        char *cAudio = (char *)sqlite3_column_text(stmt, 1);
        char *cPron = (char *)sqlite3_column_text(stmt, 2);
        char *cDef = (char *)sqlite3_column_text(stmt, 3);
        
        if (cWord != NULL) {
            thisword.Name = [NSString stringWithUTF8String:cWord];
        }
        
        if (cAudio != NULL) {
            thisword.Audio = [NSString stringWithUTF8String:cAudio];
        }
        
        if (cPron != NULL) {
            NSString * pron = [NSString stringWithUTF8String:cPron];
            thisword.Pronunciation = [pron stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        if (cDef != NULL) {
            thisword.Definition = [NSString stringWithUTF8String:cDef];
        }
        
        if (_WordView) {
            _WordView = [WordExplainView ViewWithState:SVWordViewStateDis errMSG:nil word:thisword];
            _WordView.studyVC = self;
            //            [self.superview addSubview:WordView];
            [_WordView show];
        }
        else {
            
            _WordView = [WordExplainView ViewWithState:SVWordViewStateDis errMSG:nil word:thisword];
            _WordView.studyVC = self;
            UIWindow * window = [[UIApplication sharedApplication] keyWindow];
            if (!window)
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            [[[window subviews] objectAtIndex:0] addSubview:_WordView];
            
            //            [self.audioPlayer addSubview:_WordView];
            
            [_WordView show];
        }
        
        break;
        
    }
    sqlite3_finalize(stmt);
    
    //不存在的话联网查询
    if (!isExist && [UserSetting dictType] == DictTypeEN_CN) {
        //        thisword = [[Word alloc] initWithWord:word Pron:pron Def:defi Audio:audio];
//        thisword = [Word wordWithWord:thisword.Name Pron:thisword.Pronunciation Def:thisword.Definition Audio:thisword.Audio];
        thisword.delegate = self;
        
        if (_WordView) {
            _WordView = [WordExplainView ViewWithState:SVWordViewStateWaiting errMSG:nil word:thisword];
            _WordView.studyVC = self;
            //            [self.superview addSubview:WordView];
            [_WordView show];
        }
        else {
            _WordView = [WordExplainView ViewWithState:SVWordViewStateWaiting errMSG:nil word:thisword];
            _WordView.studyVC = self;
            //            [self.superview addSubview:WordView];
            UIWindow * window = [[UIApplication sharedApplication] keyWindow];
            //        [[UIApplication sharedApplication].keyWindow addSubview:view];
            if (!window)
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            [[[window subviews] objectAtIndex:0] addSubview:_WordView];
            [_WordView show];
        }
        
        [thisword FindWordOnInternet:thisword.Name];
    } else if (!isExist && [UserSetting dictType] != DictTypeEN_CN) {
        NSError * err = [NSError errorWithDomain:NSLocalizedString(@"CAN_NOT_FIND_WORD", nil) code:0 userInfo:nil];
        [self WordFindInternetExpFailed:thisword witError:err];
    }
    
    //关闭数据库
    [self closeDatabase];
}
#pragma mark - ScrollView Delegate 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == TAG_TEXT_TABLE || scrollView.tag == TAG_QUES_TABLE) {
        [self hideWordExplainView];
    }
}

- (void)ZZAudioContinuePlayOrNot {
    if (_isZZAudioPlaying) {
        [_audioPlayer playBtnPressed:nil];
        _isZZAudioPlaying = NO;
    }
}

#pragma mark - WordDelegate
- (void)WordFindInternetExpSucceed:(Word*)thisWord {
    if (_WordView) {
        _WordView = [WordExplainView ViewWithState:SVWordViewStateDis errMSG:nil word:thisWord];
        _WordView.studyVC = self;
//            [self.superview addSubview:WordView];
        [_WordView show];
    }
    else {
        _WordView = [WordExplainView ViewWithState:SVWordViewStateDis errMSG:nil word:thisWord];
        _WordView.studyVC = self;
//            [self.superview addSubview:WordView];
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
//        [[UIApplication sharedApplication].keyWindow addSubview:view];
        if (!window)
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [[[window subviews] objectAtIndex:0] addSubview:_WordView];
        [_WordView show];
    }
}
- (void)WordFindInternetExpFailed:(Word *)thisWord witError:(NSError *)err{
    if (_WordView) {
        _WordView = [WordExplainView ViewWithState:SVWordViewStateDisFail errMSG:err.domain word:thisWord];
        _WordView.studyVC = self;
//            [self.superview addSubview:WordView];
        [_WordView show];
    }
    else {
        _WordView = [WordExplainView ViewWithState:SVWordViewStateDisFail errMSG:err.domain word:thisWord];
        _WordView.studyVC = self;
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        if (!window)
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [[[window subviews] objectAtIndex:0] addSubview:_WordView];
        [_WordView show];
    }
}

@end
