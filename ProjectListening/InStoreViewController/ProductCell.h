//
//  ProductCell.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-17.
//
//

#import <UIKit/UIKit.h>
#import "InStoreViewController.h"

@interface ProductCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *productImgView;
//@property (assign, nonatomic) InStoreViewController *parentVC;
@property (retain, nonatomic) IBOutlet UIImageView *discountImgView;

- (void)setImgViewWithImgName:(NSString *)name;

@end
