//
//  ControllerClient.h
//  iotapp
//
//  Created by chttl on 2016/8/22.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalSession.h"
#import "IRawdata.h"

@class ControllerClient;

@protocol ControllerClientDelegate <NSObject>


//連接成功
- (void)didConnectToController;
//連接失敗的代理
- (void)didDisconnectWithError:(NSError *)error;
//讀取Socket
//- (void)didReceivedData:(NSData *)data;
//- (void)didReceivedWriteData:(NSString *) deviceId sensor:(NSString*) sensorId value:(NSArray*) value;
- (void)didReceivedData:(IRawdata *) data;

@end

@interface ControllerClient : NSObject
{
    LocalSession* session;
    
    BOOL authenticated;
    
    NSTimeInterval keepalive;
    NSTimeInterval timeout;
    
    NSTimer *timerAlive;
    
    // Ack handle
    NSTimer *timerAck; //
    NSInteger countResend;
}

@property (nonatomic, weak) id<ControllerClientDelegate> delegate;

- (void)setupSocket:(uint16_t) port;
- (void)setApiKey:(NSString*) key;
- (void)setKeepalive:(double) time;
- (void)setTimeout:(double) time;
- (void)readDevice:(NSString*) deviceId sensor:(NSString*) sensorId;
- (void)writeDevice:(NSString*) deviceId sensor:(NSString*) sensorId value:(NSArray*) values;
- (void)linkController:(LocalSession *) linksession;


@end
