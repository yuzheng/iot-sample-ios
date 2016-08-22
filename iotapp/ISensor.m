//
//  ISensor.m
//  firstapp
//
//  Created by chttl on 2016/6/24.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "ISensor.h"

@implementation ISensor

- (Class)typeInProperty:(NSString *)property {
    if ([property isEqualToString:@"attributes"]) {
        return [IAttribute class];
    }
    
    return nil;
}

@end
