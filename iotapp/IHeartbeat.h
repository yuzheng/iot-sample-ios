//
//  IHeartbeat.h
//  iotapp
//
//  Created by chttl on 2016/9/2.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IHeartbeat : NSObject

@property (strong, nonatomic) NSNumber* pulse;  // millisecond: 1000
@property (strong, nonatomic) NSString* from;   // ip
@property (strong, nonatomic) NSString* last;
@property (strong, nonatomic) NSString* time;
@property (strong, nonatomic) NSString* type;

@end
