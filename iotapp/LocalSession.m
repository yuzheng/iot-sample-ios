//
//  Session.m
//  iotapp
//
//  Created by chttl on 2016/8/22.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "LocalSession.h"

@implementation LocalSession

- (BOOL)isEqual:(LocalSession*)other {
    if([other.vendor isEqualToString:self.vendor] &&
       [other.model isEqualToString:self.model] &&
       [other.series isEqualToString:self.series] &&
       [other.name isEqualToString:self.name]) {
        return true;
    }
    return false;
}

@end
