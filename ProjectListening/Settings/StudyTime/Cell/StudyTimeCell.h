//
//  StudyTimeCell.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-21.
//
//

#import <UIKit/UIKit.h>
#import "StudyTimeInfoClass.h"

@interface StudyTimeCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *studyTimeImg;
@property (retain, nonatomic) IBOutlet UILabel *studyTimeLabel;
//@property (retain, nonatomic) IBOutlet UIImageView *selectedImg;

- (void)setCellInfoWithSTIC:(StudyTimeInfoClass *)STIC;

@end
