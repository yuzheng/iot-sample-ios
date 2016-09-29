//
//  OpenMqttClient.m
//  iotapp
//
//  Created by chttl on 2016/9/2.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "OpenMqttClient.h"
#import "MQTTClient.h"

#import "NSObject+BWJSONMatcher.h"
#import "BWJSONMatcher.h"

@interface OpenMqttClient() <MQTTSessionDelegate>
{
    NSString *mqtt_host;
    uint16_t mqtt_port;
    
    NSString *apiKey;
    
    BOOL connected;
    
    BOOL isTLS;
}
@property (nonatomic, strong, readonly) MQTTSession *session;
@end


@implementation OpenMqttClient

- (id)init {
    self = [super init];
    
    if(self){
        mqtt_host = @"iot.cht.com.tw";
        mqtt_port = 1883;  //8883
        isTLS = FALSE;
        apiKey = @"";
        
        connected = FALSE;
    }
    
    return self;
}

- (void)setupHost:(NSString*) host withPort:(uint16_t)port {
    mqtt_host = host;
    mqtt_port = port;
}

- (void)setupApiKey:(NSString*) key {
    apiKey = key;
}

- (void)usingTLS:(BOOL) tls {
    isTLS = tls;
    if(isTLS){
        mqtt_port = 8883;
    }
}

- (void) doConnect {
    MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
    transport.host = mqtt_host;
    transport.port = mqtt_port;
    transport.tls = isTLS;
    
    _session = [[MQTTSession alloc] init];
    _session.transport = transport;
    
    if( apiKey.length > 0) {
        _session.userName = apiKey;
        _session.password = apiKey;
    }
    _session.delegate = self;
    
    [_session connectAndWaitTimeout:0];  //this is part of the synchronous API
    //[_session connectToHost:mqtt_host port:mqtt_port usingSSL:true];
}

- (void) stop {
    if(connected) {
        [_session close];
    }
}

#pragma mark -
#pragma mark IoT MQTT Support Methods
- (void) subscribeDevice:(NSString*) deviceId sensor:(NSString*) sensorId {
    
    NSString *topic = [self getRawdataTopic:deviceId sensor:sensorId];
    NSLog(@"subscribeDevice: %@",topic);
    
    [self subscribeTopic:topic];
}

- (void) unsubscribeDevice:(NSString*) deviceId sensor:(NSString*) sensorId {
    NSString *topic = [self getRawdataTopic:deviceId sensor:sensorId];
    NSLog(@"unsubscribeDevice: %@",topic);
    
    [self unsubscribeTopic:topic];
}

- (void) subscribeDevice:(NSString*) deviceId sensor:(NSString*) sensorId type:(NSString *)type {
    NSString *topic = [self getRawdataTopic:deviceId sensor:sensorId];
    
    if([type isEqualToString:@"csv"]) {
        topic = [self getCsvRawdataTopic:deviceId sensor:sensorId];
    }
    NSLog(@"subscribeDevice: %@",topic);
    
    [self subscribeTopic:topic];
}

- (void) unsubscribeDevice:(NSString*) deviceId sensor:(NSString*) sensorId type:(NSString *)type {
    NSString *topic = [self getRawdataTopic:deviceId sensor:sensorId];
    
    if([type isEqualToString:@"csv"]) {
        topic = [self getCsvRawdataTopic:deviceId sensor:sensorId];
    }
    NSLog(@"unsubscribeDevice: %@",topic);
    
    [self unsubscribeTopic:topic];
}

- (void) saveDevice:(NSString*) deviceId sensor:(NSString*) sensorId value:(NSArray*) value {
    NSString *topic = [self getSavingRawdataTopic:deviceId];
    NSLog(@"saveDevice: %@", topic);
    
    IRawdata *rawdata = [[IRawdata alloc] init];
    [rawdata setId:sensorId];
    [rawdata setValue:value];
    
    [self publishTopic:topic data:[@[rawdata] toJSONData]];
}

- (void) registry:(NSString*) serialId {
    NSString *topic = [self getRegistryTopic:serialId];
    NSLog(@"registry: %@", topic);
    
    [self subscribeTopic:topic];
}

- (void) unregistry:(NSString*) serialId {
    NSString *topic = [self getRegistryTopic:serialId];
    NSLog(@"unregistry: %@", topic);
    
    [self unsubscribeTopic:topic];
}

- (void) subscribeHeartBeat:(NSString*) deviceId {
    NSString *topic = [self getHeartBeatTopic:deviceId];
    NSLog(@"subscribe heartbeat: %@", topic);
    
    [self subscribeTopic:topic];
}
- (void) unsubscribeHeartBeat:(NSString*) deviceId {
    NSString *topic = [self getHeartBeatTopic:deviceId];
    NSLog(@"unsubscribe heartbeat: %@", topic);
    
    [self unsubscribeTopic:topic];
}
- (void) saveHeartBeat:(NSString*) deviceId pulse:(NSNumber*) pulse {
    NSString *topic = [self getHeartBeatTopic:deviceId];
    NSLog(@"save heartbeat: %@", topic);
    
    NSDictionary *heartBeat = @{@"pulse" : pulse};
    
    [self publishTopic:topic data:[heartBeat toJSONData]];
}

#pragma mark -
#pragma mark IoT Topics
- (NSString*) getCsvRawdataTopic:(NSString*) deviceId sensor:(NSString*) sensorId {
    return [NSString stringWithFormat:@"/v1/device/%@/sensor/%@/csv", deviceId, sensorId];
}

- (NSString*) getRawdataTopic:(NSString*) deviceId sensor:(NSString*) sensorId {
    return [NSString stringWithFormat:@"/v1/device/%@/sensor/%@/rawdata", deviceId, sensorId];
}

- (NSString*) getSavingRawdataTopic:(NSString*) deviceId {
    return [NSString stringWithFormat:@"/v1/device/%@/rawdata", deviceId];
}

- (NSString*) getRegistryTopic:(NSString*) serialId {
    return [NSString stringWithFormat:@"/v1/registry/%@", serialId];
}

- (NSString*) getHeartBeatTopic:(NSString*) deviceId {
    return [NSString stringWithFormat:@"/v1/device/%@/heartbeat", deviceId];
}

#pragma mark -
#pragma mark MQTTSession actions
- (void) publishTopic:(NSString*) topic data:(NSData*) data {
    NSLog(@"publish data: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [_session publishData:data onTopic:topic retain:FALSE qos:MQTTQosLevelAtLeastOnce];
}

- (void) subscribeTopic:(NSString*) topic {
    [_session subscribeToTopic:topic atLevel:MQTTQosLevelAtMostOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
        if (error) {
            NSLog(@"Subscription failed %@", error.localizedDescription);
        } else {
            NSLog(@"Subscription sucessfull! Granted Qos: %@", gQoss);
        }
    }];
}

- (void) unsubscribeTopic:(NSString*) topic {
    [_session unsubscribeTopic:topic unsubscribeHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Subscription failed %@", error.localizedDescription);
        } else {
            NSLog(@"Unsubscription sucessfull! ");
        }
    }];
}

#pragma mark -
#pragma mark MQTTSessionDelegate
- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid {
    NSLog(@"Get Message on Topic: %@", topic);
    NSLog(@"Data is :%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    // handle message: rawdata, csv, heartbeat, registry(Reconfigure, setDeviceId)
    if([self isTopic:topic startsWith:@"/v1/device/"]) {
        //NSLog(@"Topic prefix match device");
        if([self isTopic:topic endsWith:@"/rawdata"]) {
            //NSLog(@"Topic suffix match rawdata");
            IRawdata* rawdata = [IRawdata fromJSONData:data];
            if (self.delegate && [self.delegate respondsToSelector:@selector(onRawdata:data:)])
            {
                [self.delegate onRawdata:topic data:rawdata];
            }
        } else if([self isTopic:topic endsWith:@"/csv"]) {
            //NSLog(@"Topic suffix match csv");
            //回傳格式為：日期, 設備編號, 感測器識別代碼, 感測器數值
            NSString *csvString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSArray *csvData = [csvString componentsSeparatedByString:@","];
            
            if([csvData count] >= 4) {
                IRawdata* rawdata = [[IRawdata alloc] init];
                [rawdata setTime:csvData[0]];
                [rawdata setDeviceId:csvData[1]];
                [rawdata setId:csvData[2]];
                
                NSMutableArray *value = [[NSMutableArray alloc] init];
                for(int i = 3; i<[csvData count]; i++){
                    [value addObject:csvData[i]];
                }
                [rawdata setValue:value];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(onRawdata:data:)])
                {
                    [self.delegate onRawdata:topic data:rawdata];
                }
            }else{
                NSLog(@"csv format is error!");
            }
            
        } else if([self isTopic:topic endsWith:@"/heartbeat"]) {
            //NSLog(@"Topic suffix match heartbeat");
            IHeartbeat* heartbeat = [IHeartbeat fromJSONData:data];
            if (self.delegate && [self.delegate respondsToSelector:@selector(onHeartBeat:data:)])
            {
                [self.delegate onHeartBeat:topic data:heartbeat];
            }
        } else {
            NSLog(@"not found mqtt format!");
        }
    } else if([self isTopic:topic startsWith:@"/v1/registry/"]) {
        //NSLog(@"Topic prefix match registry");
        IProvision* provision = [IProvision fromJSONData:data];
        if([provision.op isEqualToString:@"Reconfigure"]){
            if (self.delegate && [self.delegate respondsToSelector:@selector(onReconfigure:data:)])
            {
                [self.delegate onReconfigure:topic data:provision];
            }
        } else if([provision.op isEqualToString:@"Reconfigure"]){
            if (self.delegate && [self.delegate respondsToSelector:@selector(onSetDeviceId:data:)])
            {
                [self.delegate onSetDeviceId:topic data:provision];
            }
        } else {
            NSLog(@"not found registry mqtt format!");
        }
        
        
    } else {
        NSLog(@"not found mqtt format!");
    }
    
}

- (void) connected:(MQTTSession *)session {
    NSLog(@"MQTT connected!");
    connected = TRUE;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnected)])
    {
        [self.delegate didConnected];
    }
}

- (void) connectionClosed:(MQTTSession *)session {
    NSLog(@"MQTT connect closed!");
    connected = FALSE;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectClosed)])
    {
        [self.delegate didConnectClosed];
    }
}

#pragma mark - 
#pragma mark startWith, endWith
- (BOOL) isTopic:(NSString*) topic startsWith:(NSString*) prefix {
    NSRange range = [topic rangeOfString:prefix options:(NSAnchoredSearch | NSCaseInsensitiveSearch)];
    if(range.length > 0) {
        if(range.location == 0) {
            return TRUE;
        }
    }
    return FALSE;
}

- (BOOL) isTopic:(NSString*) topic endsWith:(NSString*) suffix {
    NSRange range = [topic rangeOfString:suffix options:(NSBackwardsSearch | NSCaseInsensitiveSearch)];
    if(range.length > 0) {
        //NSLog(@"suffix range: %d, %d (%d)", range.location, range.length, topic.length);
        if((range.location + range.length )== topic.length) {
            return TRUE;
        }
    }
    return FALSE;
}

@end