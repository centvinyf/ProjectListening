//
//  SectionView.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-18.
//
//

#import "SectionView.h"

@implementation SectionView

- (id)initWithSectionNameTag:(SectionNameTags)tag
{
    self = [super init];
    if (self) {
        // Initialization code
        CGRect frame;
        if (IS_IPAD) {
            frame = CGRectMake(0, 0, 768, 22);
        } else {
            frame = CGRectMake(0, 0, 320, 13);
        }
        
        [self setFrame:frame];
        
        NSString *name = @"";
        switch (tag) {
            case SectionNameText:
                name = @"textTitle.png";
                break;
                
            case SectionNameQuestion:
                name = @"questionTitle.png";
                break;
                
            case SectionNameExplain:
                name = @"explainTitle.png";
                break;
                
            default:
                break;
        }
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
        [imgView setFrame:frame];
        
        [self addSubview:imgView];
        [imgView release];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
