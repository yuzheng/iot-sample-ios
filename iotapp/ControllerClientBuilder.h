//
//  ControllerClientBuilder.h
//  iotapp
//
//  Created by chttl on 2016/8/22.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"

@class ControllerClientBuilder;

@protocol ControllerClientBuilderDelegate <NSObject>

- (void)findController:(Session*) session;

@end

@interface ControllerClientBuilder : NSObject

@property (nonatomic, weak) id<ControllerClientBuilderDelegate> delegate;

- (void)setupAnnouncementSocket:(uint16_t)port;

@end
