//
//  Tickets.m
//  ToeflListeningPro
//
//  Created by zhaozilong on 13-6-25.
//
//

#import "Tickets.h"

@implementation Tickets

+ (NSString *)toeicTicket {
    NSString *ticketNum = [[NSUserDefaults standardUserDefaults] objectForKey:kToeicTicket];
    return ticketNum;
}

+ (void)setToeicTicket:(NSString *)ticketNum {
    [[NSUserDefaults standardUserDefaults] setObject:ticketNum forKey:kToeicTicket];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)clearTicketInfomation {
    if ([TestType isToeic]) {
        [Tickets setToeicTicket:nil];
    }
}

@end
