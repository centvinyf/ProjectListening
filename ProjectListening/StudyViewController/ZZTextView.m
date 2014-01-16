//
//  ZZTextView.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-25.
//
//

#import "ZZTextView.h"
#import "NSString+ZZString.h"

@implementation ZZTextView

- (void)dealloc {
#if COCOS2D_DEBUG
    NSLog(@"ZZTextView dealloc");
#endif
    [super dealloc];
}

- (void)awakeFromNib {
    [self setEditable:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setScrollEnabled:NO];
    
    if (IOS_NEWER_OR_EQUAL_TO_7) {
        self.textContainerInset = UIEdgeInsetsZero;
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(myDefine:)) {
        return YES;
    } else if (action == @selector(copy:)) {
        return YES;
    } else if (action == @selector(sysDefine:)) {
        return YES;
    }
    
    return NO;
}

//- (BOOL)canBecomeFirstResponder {
//    return YES;
//}
//
//- (BOOL)canResignFirstResponder {
//    return YES;
//}

- (void)myDefine:(id)sender {
    
    [_parentVC catchAWordToShow:[NSString getSelectedWordInRange:[self selectedRange] withText:[self text]]];
    
//    [self resignFirstResponder];
    
}

- (void)sysDefine:(id)sender {
    if (IS_IPAD) {
        [self popDefine:sender];
        return;
    }
    UIReferenceLibraryViewController *dict = [[UIReferenceLibraryViewController alloc] initWithTerm:[NSString getSelectedWordInRange:[self selectedRange] withText:[self text]]];

    [_parentVC.navigationController presentModalViewController:dict animated:YES];
    [dict release];
}

- (void)popDefine:(id)sender {
    UIReferenceLibraryViewController *dict = [[UIReferenceLibraryViewController alloc] initWithTerm:[NSString getSelectedWordInRange:[self selectedRange] withText:[self text]]];
    UIPopoverController *popViewController = [[UIPopoverController alloc] initWithContentViewController:dict];
    [popViewController setPopoverContentSize:CGSizeMake(300, 350) animated:NO];
//    [popViewController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [popViewController presentPopoverFromRect:CGRectMake(230, 900, 300, 200) inView:_parentVC.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    popViewController.delegate = self;
    
    [dict release];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [popoverController release];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
