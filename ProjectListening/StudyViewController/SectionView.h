//
//  SectionView.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-18.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    SectionNameText,
    SectionNameQuestion,
    SectionNameExplain,
} SectionNameTags;

@interface SectionView : UIView

- (id)initWithSectionNameTag:(SectionNameTags)tag;

@end
