//
//  IRawdata.m
//  firstapp
//
//  Created by chttl on 2016/6/25.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "IRawdata.h"

@implementation IRawdata

- (Class)typeInProperty:(NSString *)property {
    if ([property isEqualToString:@"value"]) {
        return [NSString class];
    }
    
    return nil;
}

@end
