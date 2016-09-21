//
//  OpenRESTfulClient.h
//  firstapp
//
//  Created by chttl on 2016/6/23.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NSObject+BWJSONMatcher.h"
#import "BWJSONMatcher.h"
#import "IId.h"
#import "IDevice.h"
#import "ISensor.h"
#import "IRawdata.h"
#import "IProvision.h"

@interface OpenRESTfulClient : NSObject 
- (void)setupHost:(NSString*) host;
- (void)setupApiKey:(NSString*) key;

// device
- (void)getDevices:(void(^)(NSArray<IDevice *> *devices, NSError *error))completion;
- (void)saveDevice:(IDevice*) device completion:(void(^)(IDevice* device, NSError *error))completion;
- (void)modifyDevice:(IDevice*) device completion:(void(^)(IDevice* device, NSError *error))completion;
- (void)getDevice:(NSString*) deviceId completion:(void(^)(IDevice* device, NSError *error))completion;
- (void)deleteDevice:(NSString*) deviceId completion:(void(^)(long status, NSError *error))completion;

// sensor
- (void)getSensorsWithDevice:(NSString*) deviceId completion:(void(^)(NSArray<ISensor *> *sensors, NSError *error))completion;
- (void)getSensor:(NSString*) sensorId withDevice:(NSString*) deviceId completion:(void(^)(ISensor *sensor, NSError *error))completion;
- (void)saveSensor:(ISensor*) sensor withDevice:(NSString*) deviceId completion:(void(^)(ISensor *sensor, NSError *error))completion;
- (void)modifySensor:(ISensor*) sensor withDevice:(NSString*) deviceId completion:(void(^)(ISensor *sensor, NSError *error))completion;
- (void)deleteSensor:(NSString*) sensorId withDevice:(NSString*) deviceId completion:(void(^)(long status, NSError *error))completion;

// rawdata
- (void)saveRawdata:(NSArray<IRawdata*>*) rawdata withDevice:(NSString*) deviceId completion:(void(^)(long status, NSError *error))completion;
- (void)saveRawdataWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId withTime:(NSString*) time withLatitude:(NSNumber*) lat withLongitude:(NSNumber*) lon withValue:(NSArray<NSString*>*) value completion:(void(^)(long status, NSError *error))completion;
- (void)saveRawdataWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId withValue:(NSArray<NSString*>*) value completion:(void(^)(long status, NSError *error))completion;
- (void)saveRawdataWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId withSingleValue:(NSString*) value completion:(void(^)(long status, NSError *error))completion;
- (void)getRawdataWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId completion:(void(^)(IRawdata *rawdata, NSError *error))completion;
- (void)getRawdataWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId withStart:(NSString*) start withEnd:(NSString*) end withInterval:(NSNumber*) interval completion:(void(^)(NSArray<IRawdata *> *rawdatas, NSError *error))completion;
- (void)deleteRawdataWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId withStart:(NSString*) start withEnd:(NSString*) end completion:(void(^)(long status, NSError *error))completion;

// snapshot
- (void) saveSnapshot:(UIImage*) image withMeta:(IRawdata*) meta withDevice:(NSString*) deviceId delegate:(id<NSURLSessionDelegate>) delegate;
- (void)getSnapshotMetaWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId completion:(void(^)(IRawdata *rawdata, NSError *error))completion;
- (void)getSnapshotMetaWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId withStart:(NSString*) start withEnd:(NSString*) end completion:(void(^)(NSArray<IRawdata *> *rawdatas, NSError *error))completion;
- (void)getSnapshotBodyWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId completion:(void(^)(UIImage *image, NSError *error))completion;
- (void)getSnapshotBodyWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId delegate:( id<NSURLSessionDelegate>) delegate;
- (void)getSnapshotBody:(NSString*) snapshotId withSensor:(NSString*) sensorId withDevice:(NSString*) deviceId completion:(void(^)(UIImage *image, NSError *error))completion;
- (void)getSnapshotBody:(NSString*)snapshotId withSensor:(NSString*) sensorId withDevice:(NSString*) deviceId delegate:(id<NSURLSessionDelegate>) delegate;
- (void)deleteSnapshotWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId withStart:(NSString*) start withEnd:(NSString*) end completion:(void(^)(long status, NSError *error))completion;

// registry
-(void) reconfigure:(NSString*) serialId withDigest:(NSString*) digest completion:(void(^)(long status, NSError *error))completion;
-(void) setDeviceId:(NSString*) deviceId withSerialId:(NSString*) serialId withDigest:(NSString*) digest completion:(void(^)(long status, NSError *error))completion;

// heartbeat

@end
