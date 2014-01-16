//
//  StudyTimeCell.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-21.
//
//

#import "StudyTimeCell.h"

@implementation StudyTimeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellInfoWithSTIC:(StudyTimeInfoClass *)STIC {
    [_studyTimeImg setImage:[UIImage imageNamed:STIC.studyTimeImg]];
    [_studyTimeLabel setText:STIC.studyTimeInfo];
}

- (void)dealloc {
    [_studyTimeImg release];
    [_studyTimeLabel release];
    [super dealloc];
}
@end
