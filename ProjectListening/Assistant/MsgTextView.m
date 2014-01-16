//
//  MsgTextView.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-28.
//
//

#import "MsgTextView.h"

@implementation MsgTextView

- (BOOL)canBecomeFirstResponder {
    return NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setEditable:NO];
        int fontSize;
        if (IS_IPAD) {
            fontSize = 22.0f;
        } else {
            fontSize = 14.0f;
        }
        [self setFont:[UIFont boldSystemFontOfSize:fontSize]];
//        [self setTextColor:[UIColor whiteColor]];
        [self setBackgroundColor:[UIColor clearColor]];
//        [self setBackgroundColor:[UIColor whiteColor]];
        
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
