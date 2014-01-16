//
//  PackInfoClass.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-15.
//
//

#import <Foundation/Foundation.h>

//cell整体的状态
typedef enum {
    PICStatusPurchase,
    PICStatusDownload,
    PICStatusStop,
    PICStatusDownloading,
    PICStatusWaiting,
    PICStatusFree,
    PICStatusMAX,
}PICStatusTags;

//下状态
//typedef enum {
//    PICDownloadStatusStop,
//    PICDownloadStatusDownloading,
//    PICDownloadStatusWaiting,
//    PICDownloadStatusPurchase,
//    PICDownloadStatusFree,
//    PICDownloadStatusMAX,
//}PICDownloadStatusTags;

@interface PackInfoClass : NSObject

@property (nonatomic, retain) NSString *packName;
@property (assign) BOOL isVip;
@property (assign) BOOL isDownload;
@property (assign) BOOL isFree;
@property (assign) CGFloat progress;
@property (assign) CGFloat lastProgress;
@property (assign) int totalRightNum;
@property (assign) int totalQuesNum;
@property (assign) int totalTitleNum;
@property (assign) PICStatusTags PICStatus;
//@property (assign) PICDownloadStatusTags PICDS;

@property (retain, nonatomic) NSMutableArray *titleNumArray;

+ (PackInfoClass *)packInfoWithPackName:(NSString *)name isVip:(BOOL)isVip isDownload:(BOOL)isDownload progress:(CGFloat)progress isFree:(BOOL)isFree;

- (void)setIyubaVipWithIsDownload:(BOOL)isDownload isFree:(BOOL)isFree isVip:(BOOL)isVip progress:(float)progress;

@property int idNum;
@property (nonatomic, retain)NSString *productID;

+ (PackInfoClass *)packInfoWithPackName:(NSString *)name isVip:(BOOL)isVip isDownload:(BOOL)isDownload progress:(CGFloat)progress idNum:(int)idNum isFree:(BOOL)isFree productID:(NSString *)productID;

@end
