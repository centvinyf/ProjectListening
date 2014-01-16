//
//  userAdvise.h
//  JLPT3Listening
//
//  Created by zhaozilong on 12-3-17.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "/usr/include/libxml2"
#import "RegexKitLite.h"
#import "DDXML.h"
#import "DDXMLElement.h"
#import "DDXMLElementAdditions.h"
#import "Reachability.h"
//#import "Indicator.h"
//#import "Database.h"
//#import "KeychainItemWrapper.h"


@interface userAdvise : UIViewController <UITextViewDelegate> {
	
	IBOutlet UITextField *email;
	IBOutlet UITextView *advise;
	
	UIBarButtonItem *submit;
	
	NSMutableData *mp3Data;
    
//    NSURLConnection *iconnection;

}

- (void) stopDownload;

@end
