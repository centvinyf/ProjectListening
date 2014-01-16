//
//  TextCell.m
//  ProjectListening
//
//  Created by zhaozilong on 13-3-26.
//
//

#import "TextCell.h"
#import "UserSetting.h"

@implementation TextCell

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier parentVC:(StudyViewController *)svc {
//    self = (TextCell *)[[[NSBundle mainBundle] loadNibNamed:reuseIdentifier owner:self options:nil] objectAtIndex:0];
//    if (self) {
//        _parentVC = svc;
//    }
//    return self;
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self setUserInteractionEnabled:YES];
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)dealloc {
    [_syncTV release];
    //    [_switchBtn release];
    [_favBtn release];
    [super dealloc];
}

//- (IBAction)switchBtnPressed:(id)sender {
//    [_parentVC showOrHideTextTable];
//}

- (IBAction)favBtnPressed:(id)sender {
//    [_parentVC updateFavoriteSentencesBySenIndex:_senIndex];
}

- (void)setSyncTVLayoutWithText:(NSString *)text {
    CGFloat height = [ZZPublicClass getTVHeightByStr:text constraintWidth:TEXT_WIDTH_LIMIT isBold:NO];
    CGRect frame = _syncTV.frame;
    frame.size.height = height;
    frame.origin.y = 0;
    _syncTV.frame = frame;
    
    [_syncTV setText:text];
    
//    CGSize size = [_syncTV contentSize];
//    CGRect frame = _syncTV.frame;
//    frame.size.height = size.height;
//    frame.origin.y = 0;
    
    _syncTV.frame = frame;

    [_syncTV setScrollEnabled:NO];
    [_syncTV setContentOffset:CGPointZero animated:YES];
    
    [_syncTV setUserInteractionEnabled:YES];
    
}

- (void)setSyncSingleTVLayoutWithText:(NSString *)text {
    CGRect frame = _syncTV.frame;
    frame.size.height = (IS_IPAD ? 170.0f : 82.0f);
    frame.origin.y = 2;
    _syncTV.frame = frame;
    
    [_syncTV setText:text];
//    [_syncTV setTextColor:[UIColor blackColor]];
    [_syncTV setTextColor:[UserSetting syncTextColor]];
    [_syncTV setScrollEnabled:YES];
//    [_syncTV setScrollsToTop:YES];
    [_syncTV setContentOffset:CGPointZero animated:YES];
}

- (void)addWordToFavorite:(id)sender {
    NSLog(@"%@", [_syncTV.text substringWithRange:_syncTV.selectedRange]);
    
}
@end
