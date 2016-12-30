//
//  GlobalData.h
//  iotapp
//
//  Created by chttl on 2016/12/20.
//  Copyright © 2016年 chttl. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface GlobalData : NSObject
{
    NSString *apiKey;
}

+ (GlobalData*) sharedGlobalData;

- (NSString*) fetchIoTKey;
- (BOOL) checkValue:(NSString* )value;

- (NSString*) utcDate:(NSDate*) date;
@end
