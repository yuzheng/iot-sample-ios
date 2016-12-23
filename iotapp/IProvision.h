//
//  IProvision.h
//  firstapp
//
//  Created by chttl on 2016/6/24.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IProvision : NSObject

//SetDeviceId, Reconfigure
@property (strong, nonatomic) NSString* op;
@property (strong, nonatomic) NSString* ck;
@property (strong, nonatomic) NSString* digest;
@property (strong, nonatomic) NSString* deviceId;
@property (strong, nonatomic) NSString* authority;

@end
