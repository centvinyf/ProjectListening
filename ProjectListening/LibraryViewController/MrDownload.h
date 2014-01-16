//
//  MrDownload.h
//  ToeicListening
//
//  Created by zhaozilong on 12-8-5.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
#import "ASIHttpRequest.h"
#import "ASINetworkQueue.h"


@protocol MrDownloadDelegate <NSObject>

@required
- (void)MrDownloadDidFailWithMessage:(NSString *)msg cellRow:(int)row;
- (void)MrDownloadDidFinishWithCellRow:(int)row;
- (void)MrDownloadProgress:(CGFloat)progress cellRow:(int)row;

@end

@interface MrDownload : NSObject <ASIHTTPRequestDelegate> {

    //本次下载的初始进度条值
//    float _lastProgress;
    
}

//@property float _lastProgress;

@property (nonatomic, assign) id<MrDownloadDelegate> delegate;

//+ (MrDownload *)MrDownloadWithPackName:(NSString *)packName titleNumArray:(NSMutableArray *)titleNumArray cellRow:(int)row;
- (id)initWithPackName:(NSString *)packName titleNumArray:(NSMutableArray *)titleNumArray cellRow:(int)row;

- (void)startDownload;

- (void)stopDownload;

- (void)setProgress:(CGFloat)progress;

@end
