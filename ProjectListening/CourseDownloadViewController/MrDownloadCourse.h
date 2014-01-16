//
//  MrDownloadCourse.h
//  JLPT1Listening
//
//  Created by 赵子龙 on 13-12-31.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ASIHttpRequest.h"
#import "ASINetworkQueue.h"

@protocol MrDownloadDelegate <NSObject>

@required
- (void)MrDownloadDidFailWithMessage:(NSString *)msg cellRow:(int)row;
- (void)MrDownloadDidFinishWithCellRow:(int)row;
- (void)MrDownloadProgress:(CGFloat)progress cellRow:(int)row;

@end

@interface MrDownloadCourse : NSObject <ASIHTTPRequestDelegate> {
    
    //本次下载的初始进度条值
    //    float _lastProgress;
    
}

//@property float _lastProgress;

@property (nonatomic, assign) id<MrDownloadDelegate> delegate;

//+ (MrDownload *)MrDownloadWithPackName:(NSString *)packName titleNumArray:(NSMutableArray *)titleNumArray cellRow:(int)row;
//- (id)initWithPackName:(NSString *)packName titleNumArray:(NSMutableArray *)titleNumArray cellRow:(int)row;

- (id)initWithPackId:(int)packId titleId:(int)titleId cellRow:(int)row;

- (void)startDownload;

- (void)stopDownload;

- (void)setProgress:(CGFloat)progress;


@end
