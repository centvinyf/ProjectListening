//
//  AssInfoClass.m
//  ProjectListening
//
//  Created by zhaozilong on 13-4-21.
//
//

#import "AssInfoClass.h"

@implementation AssInfoClass

- (void)dealloc {
    
    self.assName = nil;
    self.assInfo = nil;
    self.assImgName = nil;
    [super dealloc];
}

+ (AssInfoClass *)assInfoWithID:(int)aID name:(NSString *)aName info:(NSString *)aInfo imgName:(NSString *)imgName {
    
    return [[[self alloc] initWithID:aID name:aName info:aInfo imgName:imgName] autorelease];
}

- (id)initWithID:(int)aID name:(NSString *)aName info:(NSString *)aInfo imgName:(NSString *)imgName {
    self = [super init];
    if (self) {
        
        self.assID = aID;
        self.assName = aName;
        self.assInfo = aInfo;
        self.assImgName = imgName;
    }
    
    return self;
}

@end
