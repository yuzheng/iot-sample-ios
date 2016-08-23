//
//  Session.h
//  iotapp
//
//  Created by chttl on 2016/8/22.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalSession : NSObject
@property (strong, nonatomic) NSString* vendor;
@property (strong, nonatomic) NSString* model;
@property (strong, nonatomic) NSString* series;
@property (strong, nonatomic) NSString* name;

@property (strong, nonatomic) NSString* host;
@property (nonatomic) uint16_t port;

@end
