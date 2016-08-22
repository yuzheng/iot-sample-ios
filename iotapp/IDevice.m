//
//  IDevice.m
//  firstapp
//
//  Created by chttl on 2016/6/23.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "IDevice.h"

@implementation IDevice

- (Class)typeInProperty:(NSString *)property {
    if ([property isEqualToString:@"attributes"]) {
        return [IAttribute class];
    }
    
    return nil;
}

@end
