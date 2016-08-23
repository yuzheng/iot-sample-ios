//
//  ControllerClient.h
//  iotapp
//
//  Created by chttl on 2016/8/22.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalSession.h"

@class ControllerClient;

@protocol ControllerClientDelegate <NSObject>


//連接成功
- (void)didConnectToController;
//連接失敗的代理
- (void)didDisconnectWithError:(NSError *)error;
//讀取Socket
- (void)didReceivedData:(NSData *)data;

@end

@interface ControllerClient : NSObject
{
    LocalSession* session;
    
    BOOL authenticated;
    
    NSTimeInterval keepalive;
    
    NSTimer *timer;
}

@property (nonatomic, weak) id<ControllerClientDelegate> delegate;

- (void)setupSocket:(uint16_t) port;
- (void)setKeepalive:(double) time;
- (void)linkController:(LocalSession *) linksession;
- (void) doKeepalive:(NSTimer *)timer;
@end
