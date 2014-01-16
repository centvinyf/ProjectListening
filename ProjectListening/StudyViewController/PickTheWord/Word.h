//
//  Word.h
//  CET4Lite
//
//  Created by Seven Lee on 12-3-19.
//  Copyright (c) 2012年 iyuba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "ASIHTTPRequest.h"

#define kXMLResultPath  @"result"
#define kXMLDataPath    @"data"
#define kXMLDefPath     @"def"
#define kXMLPronPath    @"pron"
#define kXMLAudioPath   @"audio"
#define kXMLWordPath    @"key"
#define kXMLSentencePath @"data/sent"
#define kXMLOrigPath    @"orig"
#define kXMLTransPath   @"trans"

@class Word;
@protocol WordDelegate <NSObject>

- (void)WordFindInternetExpSucceed:(Word*)thisWord ;
- (void)WordFindInternetExpFailed:(Word *)thisWord witError:(NSError *)err;

@end
@interface Word : NSObject{
    NSString * Name;                //单词，如boy，girl
    NSString * Definition;          //释义
    NSString * Pronunciation;       //发音
    NSString * Audio;
    id<WordDelegate> delegate;
    NSMutableData * WordData;
    NSMutableArray * _SentencesArray;
}
@property (nonatomic, strong) NSString * Name;
@property (nonatomic, strong) NSString * Pronunciation;
@property (nonatomic, strong) NSString * Definition;
@property (nonatomic, strong) NSString * Audio;
@property (nonatomic, strong) id<WordDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableArray * SentencesArray;

- (id) initWithWord:(NSString *)word Pron:(NSString *)pron Def:(NSString *)def Audio:(NSString *)audio;
- (NSError *) FindWordOnInternet:(NSString *)word;
//+ (NSString *)replaceUnicode:(NSString *)unicodeStr;

+ (Word *)wordWithWord:(NSString *)word Pron:(NSString *)pron Def:(NSString *)def Audio:(NSString *)audio;

- (void)cancel;
@end
