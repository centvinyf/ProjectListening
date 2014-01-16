//
//  PackageClass.h
//  JLPT1Listening
//
//  Created by 赵子龙 on 13-12-31.
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

@interface PackageClass : NSObject


@property (assign)int titleId;
@property (assign)int price;

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

@property (assign) NSTimeInterval lastPlayTime;
@property (assign) int lastPageNum;

@property (retain, nonatomic) NSMutableArray *titleNumArray;

+ (PackageClass *)packInfoWithPackName:(NSString *)name isVip:(BOOL)isVip isDownload:(BOOL)isDownload progress:(CGFloat)progress isFree:(BOOL)isFree;

- (void)setIyubaVipWithIsDownload:(BOOL)isDownload isFree:(BOOL)isFree isVip:(BOOL)isVip progress:(float)progress;

@property int idNum;
@property (nonatomic, retain)NSString *productID;

+ (PackageClass *)packInfoWithPackName:(NSString *)name isVip:(BOOL)isVip isDownload:(BOOL)isDownload progress:(CGFloat)progress idNum:(int)idNum isFree:(BOOL)isFree productID:(NSString *)productID;

@end
