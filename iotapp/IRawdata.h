//
//  IRawdata.h
//  firstapp
//
//  Created by chttl on 2016/6/25.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BWJSONValueObject.h"

@interface IRawdata : NSObject

@property (strong, nonatomic) NSString* id;
@property (strong, nonatomic) NSString* deviceId;
@property (strong, nonatomic) NSString* time;
@property (strong, nonatomic) NSNumber* lat;
@property (strong, nonatomic) NSNumber* lon;
@property (strong, nonatomic) id value;

@end
