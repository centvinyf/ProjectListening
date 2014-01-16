//
//  Tickets.h
//  ToeflListeningPro
//
//  Created by zhaozilong on 13-6-25.
//
//

#import <Foundation/Foundation.h>
#define kToeicTicket @"kToeicTicket"

@interface Tickets : NSObject

//Toeic报名优惠券
+ (NSString *)toeicTicket;
+ (void)setToeicTicket:(NSString *)ticketNum;

+ (void)clearTicketInfomation;

@end
