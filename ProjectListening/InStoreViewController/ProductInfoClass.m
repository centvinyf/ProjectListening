//
//  ProductInfoClass.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-17.
//
//

#import "ProductInfoClass.h"

@implementation ProductInfoClass

+ (ProductInfoClass *)productInfoWithID:(NSString *)productID CName:(NSString *)CName EName:(NSString *)EName JName:(NSString *)JName info:(NSString *)productInfo imgName:(NSString *)imgName isFreeAll:(BOOL)isFreeAll {
    
    return [[[self alloc] initWithID:productID CName:CName EName:EName JName:JName info:productInfo imgName:imgName isFreeAll:isFreeAll] autorelease];
}

- (id)initWithID:(NSString *)productID CName:(NSString *)CName EName:(NSString *)EName JName:(NSString *)JName info:(NSString *)productInfo imgName:(NSString *)imgName isFreeAll:(BOOL)isFreeAll {
    
    self = [super init];
    if (self) {
        
        self.productID = productID;
        self.productInfo = productInfo;
        self.productCName = CName;
        self.productEName = EName;
        self.productJName = JName;
        self.productImgName = imgName;
        self.isFreeAllLocked = isFreeAll;
    }
    
    return self;
}
@end
