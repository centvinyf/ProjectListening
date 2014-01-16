//
//  DictInfoCell.h
//  JLPT1ListeningFree
//
//  Created by iyuba on 13-7-26.
//
//

#import <UIKit/UIKit.h>

@interface DictInfoCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *dictNameLabel;

- (void)setDictNameWithDictName:(NSString *)dictName;

@end
