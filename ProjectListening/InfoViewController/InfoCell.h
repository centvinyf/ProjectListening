//
//  InfoCell.h
//  ToeicListeningFREE
//
//  Created by 赵子龙 on 13-9-24.
//
//

#import <UIKit/UIKit.h>

#define cBLOGID     @"blogid"
#define cDATELINE   @"dateline"
#define cFAVTIMES   @"favtimes"
#define cIDS        @"ids"
#define cMESSAGE    @"message"
#define cNOREPLY    @"noreply"
#define cPASSWORD   @"password"
#define cREPLYNUM   @"replynum"
#define cSHARETIMES @"sharetimes"
#define cSUBJECT    @"subject"
#define cVIEWNUM    @"viewnum"

#define SUBJECT_WIDTH (IS_IPAD ? 700.f : 280.0f)

#define IOFO_FONT_SIZE (IS_IPAD ? 22.0f : 16.0f)



@interface InfoCell : UITableViewCell

- (void)setCellWithDic:(NSDictionary *)infoDic;
@end
