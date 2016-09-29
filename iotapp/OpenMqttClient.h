//
//  OpenMqttClient.h
//  iotapp
//
//  Created by chttl on 2016/9/2.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRawdata.h"
#import "IHeartbeat.h"
#import "IProvision.h"


@class OpenMqttClient;
@protocol OpenMqttClientDelegate <NSObject>
//@required
@optional 
//連接成功
- (void)didConnected;
//連接失敗的代理
- (void)didConnectClosed;

- (void)onRawdata:(NSString*) topic data:(IRawdata *) data;
- (void)onHeartBeat:(NSString*) topic data:(IHeartbeat *) data;
- (void)onReconfigure:(NSString*) topic data:(IProvision *) data;
- (void)onSetDeviceId:(NSString*) topic data:(IProvision *) data;

@end

@interface OpenMqttClient : NSObject 

@property (nonatomic, weak) id<OpenMqttClientDelegate> delegate;
- (void)setupHost:(NSString*) host withPort:(uint16_t)port;
- (void)setupApiKey:(NSString*) key;
- (void)usingTLS:(BOOL) tls;

- (void) doConnect;
- (void) subscribeDevice:(NSString*) deviceId sensor:(NSString*) sensorId;
- (void) unsubscribeDevice:(NSString*) deviceId sensor:(NSString*) sensorId;
// subscribe support type(csv)
- (void) subscribeDevice:(NSString*) deviceId sensor:(NSString*) sensorId type:(NSString*) type;
- (void) unsubscribeDevice:(NSString*) deviceId sensor:(NSString*) sensorId type:(NSString*) type;
// save Rawdata
- (void) saveDevice:(NSString*) deviceId sensor:(NSString*) sensorId value:(NSArray*) value;
// registry
- (void) registry:(NSString*) serialId;
- (void) unregistry:(NSString*) serialId;
// heartbeat
- (void) subscribeHeartBeat:(NSString*) deviceId;
- (void) unsubscribeHeartBeat:(NSString*) deviceId;
- (void) saveHeartBeat:(NSString*) deviceId pulse:(NSNumber*) pulse;

- (void) stop;

@end
