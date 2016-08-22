//
//  IMessage.h
//  firstapp
//
//  Created by chttl on 2016/7/27.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMessage : NSObject

@property (strong, nonatomic) NSNumber* from;
@property (strong, nonatomic) NSString* topic;
@property (strong, nonatomic) NSString* payload;

@end
