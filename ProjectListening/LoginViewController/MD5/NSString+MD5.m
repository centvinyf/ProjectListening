//
//  NSString+MD5.m
//  CET6Free
//
//  Created by Lee Seven on 13-3-7.
//  Copyright (c) 2013年 iyuba. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)
- (NSString *)MD5String{
    const char *cStr = [self UTF8String];
    unsigned char digest[32];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD2_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD2_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    //NSLog(@"md5:%@",output);
    return  output;
}
@end
