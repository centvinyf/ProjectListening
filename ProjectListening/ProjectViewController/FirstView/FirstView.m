//
//  FirstView.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-20.
//
//

#import "FirstView.h"
#import "RootViewController.h"
#import "UserSetting.h"

@implementation FirstView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)awakeFromNib {
//    [_assKenBtn setSelected:YES];
//    [_assKenBtn setEnabled:NO];
    
//    [_timeOneBtn setSelected:YES];
//    [_timeOneBtn setEnabled:NO];
    
//    [UserSetting setStudyTime:1800];
//    [UserSetting setAssistantID:0];
    
    
    //设置选择界面的一些本地化本地化
    [self.timePlanLabel setText:NSLocalizedString(@"FIRST_SETTINGS", nil)];
    [self.timeDiffcultyLabel setText:NSLocalizedString(@"DIFFCULTY_SELECTION", nil)];
    [self.assPlanLabel setText:NSLocalizedString(@"FIRST_SETTINGS", nil)];
    [self.assSelectionLabel setText:NSLocalizedString(@"ASSISTANT_SELECTION", nil)];
    
    //设置助理信息
    NSString *path = [ZZAcquirePath getPlistAssistantFromBundle];
    NSMutableArray *assArray = [NSMutableArray arrayWithContentsOfFile:path];
    int count = [assArray count];
    for (int i = 0; i < count; i++) {
        NSMutableDictionary *dic = [assArray objectAtIndex:i];
        //此处本地化一下子
        NSString *info = nil;
        NSString *name = nil;
        switch ([TestType systemLanguage]) {
            case LanguageCN:
                info = [dic objectForKey:@"kAssCInfo"];
                name = [dic objectForKey:@"kAssCName"];
                break;
                
            case LanguageJP:
                info = [dic objectForKey:@"kAssJInfo"];
                name = [dic objectForKey:@"kAssJName"];
                break;
                
            case LanguageEN:
                info = [dic objectForKey:@"kAssEInfo"];
                name = [dic objectForKey:@"kAssEName"];
                break;
                
            default:
                NSAssert(NO, @"没有正确的助理信息");
                break;
        }
        
        int assID = [[dic objectForKey:@"kAssID"] integerValue];
        
        switch (assID) {
            case 0:
                [self.dayeLabel setText:info];
                [self.dayeNameLabel setText:name];
                break;
                
            case 1:
                [self.xiaotaoLabel setText:info];
                [self.xiaotaoNameLabel setText:name];
                break;
                
            default:
                break;
        }
    }
    
    //设置难度信息
    path = [ZZAcquirePath getPlistStudyTimeFromBundle];
    NSMutableArray *timeArray = [NSMutableArray arrayWithContentsOfFile:path];
    count = [timeArray count];
    for (int i = 0; i < count; i++) {
        NSMutableDictionary *dic = [timeArray objectAtIndex:i];
        //此处本地化一下子
        NSString *info = nil;
        switch ([TestType systemLanguage]) {
            case LanguageCN:
                info = [dic objectForKey:@"kStudyTimeInfoCN"];
                break;
                
            case LanguageJP:
                info = [dic objectForKey:@"kStudyTimeInfoJP"];
                break;
                
            case LanguageEN:
                info = [dic objectForKey:@"kStudyTimeInfoEN"];
                break;
                
            default:
                NSAssert(NO, @"没有正确的难度选择信息");
                break;
        }
//        int studyTime = [[dic objectForKey:@"kStudyTime"] integerValue];
//        switch (studyTime) {
//            case 1800:
//                [_easyLabel setText:info];
//                break;
//                
//            case 3600:
//                [_normalLabel setText:info];
//                break;
//                
//            case 7200:
//                [_hardLabel setText:info];
//                break;
//                
//            default:
//                break;
//        }
        
        switch (i) {
            case 0:
                [_easyLabel setText:info];
                break;
                
            case 1:
                [_normalLabel setText:info];
                break;
                
            case 2:
                [_hardLabel setText:info];
                break;
                
            default:
                break;
        }
    }
    
    //不同设备上的不同字体在这里实现
    if (IS_IPAD) {
        
    } else {
        switch ([TestType systemLanguage]) {
            case LanguageCN:
                
                break;
                
            case LanguageJP:
                [self.hardLabel setFont:[UIFont systemFontOfSize:13]];
                break;
                
            case LanguageEN:
                
                break;
                
            default:
                break;
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_assKenBtn release];
    [_assKateBtn release];
    [_timeOneBtn release];
    [_timeTwoBtn release];
    [_timeThreeBtn release];
    [_startBtn release];
    [_ENHView release];
    [_easyLabel release];
    [_normalLabel release];
    [_hardLabel release];
    [_xiaotaoLabel release];
    [_dayeLabel release];
    [_timePlanLabel release];
    [_timeDiffcultyLabel release];
    [_xiaotaoNameLabel release];
    [_dayeNameLabel release];
    [_assSelectionLabel release];
    [_assPlanLabel release];
    [super dealloc];
}
- (IBAction)KenBtnPressed:(id)sender {
//    [_assKenBtn setSelected:YES];
//    [_assKateBtn setSelected:NO];
    
    [_assKenBtn setEnabled:NO];
    [_assKateBtn setEnabled:YES];
    
    [UserSetting setAssistantID:0];
    [UserSetting removeAssistantTextureExcept:0];
    
    [self startBtnPressed:nil];
}

- (IBAction)KateBtnPressed:(id)sender {
//    [_assKenBtn setSelected:NO];
//    [_assKateBtn setSelected:YES];
    
    [_assKenBtn setEnabled:YES];
    [_assKateBtn setEnabled:NO];
    
    [UserSetting setAssistantID:1];
    [UserSetting removeAssistantTextureExcept:1];
    
    [self startBtnPressed:nil];
}

//+ (int)studyTimeByNum:(int)diffcultyNum {
//    //设置难度信息
//    NSString *path = [ZZAcquirePath getPlistStudyTimeFromBundle];
//    NSMutableArray *timeArray = [NSMutableArray arrayWithContentsOfFile:path];
//    NSMutableDictionary *dic = [timeArray objectAtIndex:diffcultyNum];
//    int studyTime = [[dic objectForKey:@"kStudyTime"] integerValue];
//    
//    return studyTime;
//}

- (IBAction)timeOneBtnPressed:(id)sender {
    
    int studyTime = [UserSetting studyTimeByNum:0];
    
    [_timeOneBtn setEnabled:NO];
    [_timeTwoBtn setEnabled:YES];
    [_timeThreeBtn setEnabled:YES];
    
    [UserSetting setStudyTime:studyTime];
    
    [self nextPage];
}

- (IBAction)timeTwoBtnPressed:(id)sender {
    
    int studyTime = [UserSetting studyTimeByNum:1];
    
    [_timeOneBtn setEnabled:YES];
    [_timeTwoBtn setEnabled:NO];
    [_timeThreeBtn setEnabled:YES];
    
    [UserSetting setStudyTime:studyTime];
    
    [self nextPage];
}

- (IBAction)timeThreeBtnPressed:(id)sender {
    
    int studyTime = [UserSetting studyTimeByNum:2];
    
    [_timeOneBtn setEnabled:YES];
    [_timeTwoBtn setEnabled:YES];
    [_timeThreeBtn setEnabled:NO];
    
    [UserSetting setStudyTime:studyTime];
    
    [self nextPage];
}

- (void)nextPage {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self cache:YES];
    [_ENHView removeFromSuperview];
//    [UIView setAnimationDelegate:self];
    // 动画完毕后调用某个方法
    //[UIView setAnimationDidStopSelector:@selector(animationFinished:)];
    [UIView commitAnimations];
}

- (IBAction)startBtnPressed:(id)sender {
    [[RootViewController sharedRootViewController] startOfEverythingNew];
}
@end
