//
//  IDevice.h
//  firstapp
//
//  Created by chttl on 2016/6/23.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWJSONValueObject.h"
#import "IAttribute.h"

@interface IDevice : NSObject <BWJSONHasArrayProperties>

@property (strong, nonatomic) NSString* id;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* desc;
@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) NSString* uri;
@property (strong, nonatomic) NSNumber* lat;
@property (strong, nonatomic) NSNumber* lon;
@property (strong, nonatomic) IAttribute* attributes;


@end
