//
//  ZZAssistant.h
//  ProjectListening
//
//  Created by zhaozilong on 13-3-12.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    AMTagsNeedPurchase = 0,     //0 ****需要内购$$$$
    AMTagsLongTimeNoSee = 1,    //1 ****很久不见
    AMTagsNeedRate = 2,         //2 需要评价$$$$
    AMTagsNoWordToSay = 3,      //3 词穷
    AMTagsSayings = 7,          //7 ****名人名言$$$$
    AMTagsJokes = 8,            //8 ****笑话$$$$
    AMTagsSkillToefl = 9,       //9 ****考试技巧$$$$
    AMTagsSkillToeic = 10,      
    AMTagsSkillJLPT = 11,
    AMTagsSkillHSK = 12,
    AMTagsSkillTEM4 = 13,
    AMTagsSayingsJP = 71,
    AMTagsSayingsCN = 72,
    AMTagsJokesJP = 81,
    AMTagsJokesCN = 82,
    AMTagsRecentScore0 = 400,   //400 刚用3天不到,显示鼓励的话语
    AMTagsRecentScore1,         //401 ****成绩优秀，非常稳定,保持住$$$$
    AMTagsRecentScore2,         //402 成绩良，非常稳定，再加油一定能更优秀
    AMTagsRecentScore3,         //403 成绩及格，非常稳定，但是还需要加油
    AMTagsRecentScore4,         //404 成绩在及格边缘徘徊，非常稳定，不能安于现状，需要努力了
    AMTagsRecentScore5,         //405 ****成绩很差$$$$
    AMTagsRecentScore6,         //406 你到底在没在学习啊？
    AMTagsRecentScore7,         //407 成绩优秀，再稳定些就更好了
    AMTagsRecentScore8,         //408 成绩有时很好，但是有时也在及格边缘，要注意了
    AMTagsRecentScore9,         //409 成绩已经出现不及格了，要加油了哦
    AMTagsRecentScore10,        //410 再加把劲，你会做的很好，成绩48-72徘徊
    AMTagsRecentScore11,        //411 Invaild
    AMTagsRecentScore12,        //412 Invaild
    AMTagsRecentScore13,        //413 成绩优秀，但是有时也很一般,比较波动
    AMTagsRecentScore14,        //414 成绩有时很好，但是有时也在及格边缘，要注意了
    AMTagsRecentScore15,        //415 成绩已经出现不及格了，要加 油了哦
    AMTagsRecentScore16,        //416 再加把劲，你会做的很好，成绩48-72徘徊
    AMTagsRecentScore17,        //417 Invaild
    AMTagsRecentScore18,        //418 Invaild
    AMTagsRecentScore19,        //419 你还是有实力能学的很好的，只要你愿意，波动太大
    AMTagsRecentScore20,        //420 只要努力，你可以的，波动很大
    AMTagsRecentScore21,        //421 波动太大，成绩还不好
    AMTagsRecentScore22,        //422 Invaild
    AMTagsRecentScore23,        //423 Invaild
    AMTagsHealthyTip = 500,//500 刚用3天不到,显示提倡早休息
    AMTagsRecentSleepTime1,     //501 ****最近睡觉比较晚$$$$
    AMTagsRecentSleepTime2,     //Invaild 502 ****不知道睡的早晚,告诫早休息
    AMTagsPsychologyTip = 600,//600 刚用3天不到,显示提倡早睡早起
    AMTagsRecentWakeTime1,      //601 ****最近起的比较早
    AMTagsRecentWakeTime2,      //Invaild 602 不知道起的早晚，健康提示
    AMTagsTodayScore0 = 1000,   //1000 ****今天成绩90-100&&&&
    AMTagsTodayScore1,          //1001 今天成绩80-90
    AMTagsTodayScore2,          //1002 今天成绩70-80
    AMTagsTodayScore3,          //1003 今天成绩60-70
    AMTagsTodayScore4,          //1004 ****今天成绩50-60
    AMTagsTodayScore5,          //1005 ****今天成绩40-50
    AMTagsTodayScore6,          //1006 ****今天成绩40以下$$$$
    AMTagsTodayScore7,          //1007 今天成绩等于0分的时候代表今天没有学习，不需要提示成绩差，有可能还没开始学习
    
} AMTags;

@interface ZZAssistant : NSObject

- (AMTags)getAssistantStatus;
- (NSString *)getAssistantMessageWithTag:(AMTags)tag;

+ (int)getRandomNumBelow:(int)low;

@end
