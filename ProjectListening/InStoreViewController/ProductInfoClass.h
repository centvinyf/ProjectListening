//
//  ProductInfoClass.h
//  ProjectListening
//
//  Created by zhaozilong on 13-4-17.
//
//

#import <Foundation/Foundation.h>

@interface ProductInfoClass : NSObject

@property (retain, nonatomic) NSString *productID;
@property (retain, nonatomic) NSString *productCName;
@property (retain, nonatomic) NSString *productEName;
@property (retain, nonatomic) NSString *productJName;
@property (retain, nonatomic) NSString *productInfo;
@property (retain, nonatomic) NSString *productImgName;
@property (assign) BOOL isFreeAllLocked;

+ (ProductInfoClass *)productInfoWithID:(NSString *)productID CName:(NSString *)CName EName:(NSString *)EName JName:(NSString *)JName info:(NSString *)productInfo imgName:(NSString *)imgName isFreeAll:(BOOL)isFreeAll;

@end
