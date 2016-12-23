//
//  OpenRESTfulClient.m
//  firstapp
//
//  Created by chttl on 2016/6/23.
//  Copyright © 2016年 chttl. All rights reserved.
//
//  references:
//  http://jsonmodel.com/docs/Classes/JSONModel.html
//  https://github.com/BurrowsWang/BWJSONMatcher

//#define IOT_URL @"https://iot.cht.com.tw/iot"
//#define API_KEY @"0H4X3ZSPWG0SS9XW"

#import "OpenRESTfulClient.h"
@interface OpenRESTfulClient()
{
    NSString *iot_host;
    NSString *apiKey;
}
@end

@implementation OpenRESTfulClient


- (OpenRESTfulClient *)init
{
    self = [super init];
    
    if(self){
        iot_host = @"https://iot.cht.com.tw/iot";
        apiKey = @"";
    }
    
    return self;
}

- (void)setupHost:(NSString*) host {
    iot_host = host;
}

- (void)setupApiKey:(NSString*) key {
    apiKey = key;
}

#pragma mark - device
- (void)getDevices:(void(^)(NSArray<IDevice*> *devices, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device"];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"GET" data:jsonData];
    
    [self taskDataRequest:request completion:^(NSData *jsonData, NSError *error) {
        NSArray *devices = [BWJSONMatcher matchJSONData:jsonData withClass:[IDevice class]];
        if(completion){
            completion(devices, error);
        }
    }];
}

- (void)saveDevice:(IDevice*) device completion:(void(^)(IDevice* device, NSError *error))completion
{
    NSData *jsonData = [device toJSONData];
    //NSLog(@"jsonData:%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    NSString *uri = [NSString stringWithFormat:@"/v1/device"];
    
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"POST" data:jsonData];
    
    [self taskRequest:request completion:^(NSString *jsonString, NSError *error) {
        IId *iId = [IId fromJSONString:jsonString];
        device.id = iId.id;
        if(completion){
            completion(device, error);
        }
    }];
}

- (void)modifyDevice:(IDevice*) device completion:(void(^)(IDevice* device, NSError *error))completion
{
    NSData *jsonData = [device toJSONData];
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@",device.id];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"PUT" data:jsonData];
    
    [self taskRequest:request completion:^(NSString *jsonString, NSError *error) {
        //IId *iId = [IId fromJSONString:jsonString];
        if(completion){
            completion(device, error);
        }
    }];
}

- (void)getDevice:(NSString*) deviceId completion:(void(^)(IDevice* device, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@",deviceId];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"GET" data:jsonData];
    
    [self taskRequest:request completion:^(NSString *jsonString, NSError *error) {
        IDevice* device = [IDevice fromJSONString:jsonString];
        if(completion){
            completion(device, error);
        }
    }];
}

- (void)deleteDevice:(NSString*) deviceId completion:(void(^)(long status, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@",deviceId];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"DELETE" data:jsonData];
    
    [self taskStatusRequest:request completion:^(long status, NSError *error) {
        if(completion){
            completion(status, error);
        }
    }];
}

#pragma mark - sensor
- (void)getSensorsWithDevice:(NSString*) deviceId completion:(void(^)(NSArray<ISensor *> *sensors, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor",deviceId];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"GET" data:jsonData];
    
    [self taskDataRequest:request completion:^(NSData *jsonData, NSError *error) {
        NSLog(@"data:%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        NSArray *sensors = [BWJSONMatcher matchJSONData:jsonData withClass:[ISensor class]];
        if(completion){
            completion(sensors, error);
        }
    }];
}

- (void)getSensor:(NSString*) sensorId withDevice:(NSString*) deviceId completion:(void(^)(ISensor *sensor, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor/%@",deviceId,sensorId];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"GET" data:jsonData];
    
    [self taskRequest:request completion:^(NSString *jsonString, NSError *error) {
        ISensor* sensor = [ISensor fromJSONString:jsonString];
        if(completion){
            completion(sensor, error);
        }
    }];
}

- (void)saveSensor:(ISensor*) sensor withDevice:(NSString*) deviceId completion:(void(^)(ISensor *sensor, NSError *error))completion
{
    NSData *jsonData = [sensor toJSONData];
    //NSLog(@"jsonData:%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor/",deviceId];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"POST" data:jsonData];
    
    [self taskStatusRequest:request completion:^(long status, NSError *error) {
        if(completion){
            completion(sensor, error);  // 主要判斷是否有error
        }
    }];
}

- (void)modifySensor:(ISensor*) sensor withDevice:(NSString*) deviceId completion:(void(^)(ISensor *sensor, NSError *error))completion
{
    NSData *jsonData = [sensor toJSONData];
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor/%@",deviceId,sensor.id];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"PUT" data:jsonData];
    
    [self taskRequest:request completion:^(NSString *jsonString, NSError *error) {
        if(completion){
            completion(sensor, error);  // 主要判斷是否有error
        }
    }];
}

- (void)deleteSensor:(NSString*) sensorId withDevice:(NSString*) deviceId completion:(void(^)(long status, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor/%@",deviceId, sensorId];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"DELETE" data:jsonData];
    
    [self taskStatusRequest:request completion:^(long status, NSError *error) {
        if(completion){
            completion(status, error);
        }
    }];
}

#pragma mark - rawdata
- (void)saveRawdata:(NSArray<IRawdata*>*) rawdata withDevice:(NSString*) deviceId completion:(void(^)(long status, NSError *error))completion
{
    NSData *jsonData = [rawdata toJSONData];
    //NSLog(@"jsonData:%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/rawdata",deviceId];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"POST" data:jsonData];
    
    [self taskStatusRequest:request completion:^(long status, NSError *error) {
        if(completion){
            completion(status, error);  // 主要判斷是否有error
        }
    }];
}

- (void)saveRawdataWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId withTime:(NSString*) time withLatitude:(NSNumber*) lat withLongitude:(NSNumber*) lon withValue:(NSArray<NSString*>*) value completion:(void(^)(long status, NSError *error))completion
{
    NSMutableDictionary *rawdata = [NSMutableDictionary new];
    [rawdata setObject:sensorId forKey:@"id"];
    if(time != nil ) [rawdata setObject:time forKey:@"time"];
    if(lat != nil) [rawdata setObject:lat forKey:@"lat"];
    if(lon != nil) [rawdata setObject:lon forKey:@"lon"];
    [rawdata setObject:value forKey:@"value"];
   
    NSArray *data = [NSArray arrayWithObject:rawdata];
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&err];
    
    //NSLog(@"jsonData:%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/rawdata",deviceId];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"POST" data:jsonData];
    
    [self taskStatusRequest:request completion:^(long status, NSError *error) {
        if(completion){
            completion(status, error);  // 主要判斷是否有error
        }
    }];
}

- (void)saveRawdataWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId withValue:(NSArray<NSString*>*) value completion:(void(^)(long status, NSError *error))completion
{
    [self saveRawdataWithSensor:sensorId withDevice:deviceId withTime:nil withLatitude:nil withLongitude:nil withValue:value completion:completion];
}

- (void)saveRawdataWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId withSingleValue:(NSString*) value completion:(void(^)(long status, NSError *error))completion
{
    [self saveRawdataWithSensor:sensorId withDevice:deviceId withTime:nil withLatitude:nil withLongitude:nil withValue:[NSArray arrayWithObject:value] completion:completion];
}

- (void)getRawdataWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId completion:(void(^)(IRawdata *rawdata, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor/%@/rawdata",deviceId,sensorId];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"GET" data:jsonData];
    
    [self taskRequest:request completion:^(NSString *jsonString, NSError *error) {
        IRawdata* rawdata = [IRawdata fromJSONString:jsonString];
        if(completion){
            completion(rawdata, error);
        }
    }];
}

- (void)getRawdataWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId withStart:(NSString*) start withEnd:(NSString*) end withInterval:(NSNumber*) interval completion:(void(^)(NSArray<IRawdata *> *rawdatas, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor/%@/rawdata",deviceId,sensorId];
    
    NSString *param = @"";
    if(start != nil){
        param = [self generateQueryParam:param withKey:@"start" withValue:start];
    }
    if(end != nil){
        param = [self generateQueryParam:param withKey:@"end" withValue:end];
    }
    if(interval != nil){
        param = [self generateQueryParam:param withKey:@"interval" withValue:[interval stringValue]];
    }
    if([param length] != 0){
        param = [NSString stringWithFormat:@"?%@",param];
    }
    NSURLRequest *request = [self iotRestfulRequest:[NSString stringWithFormat:@"%@%@",uri,param] method:@"GET" data:jsonData];
    
    [self taskDataRequest:request completion:^(NSData *jsonData, NSError *error) {
        NSArray* rawdatas = [BWJSONMatcher matchJSONData:jsonData withClass:[IRawdata class]];
        
        if(completion){
            completion(rawdatas, error);
        }
    }];
}

- (void)deleteRawdataWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId withStart:(NSString*) start withEnd:(NSString*) end completion:(void(^)(long status, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor/%@/rawdata",deviceId,sensorId];
    
    NSString *param = @"";
    if(start != nil){
        param = [self generateQueryParam:param withKey:@"start" withValue:start];
    }
    if(end != nil){
        param = [self generateQueryParam:param withKey:@"end" withValue:end];
    }
    if([param length] != 0){
        param = [NSString stringWithFormat:@"?%@",param];
    }
    NSURLRequest *request = [self iotRestfulRequest:[NSString stringWithFormat:@"%@%@",uri,param] method:@"DELETE" data:jsonData];
    
    [self taskStatusRequest:request completion:^(long status, NSError *error) {
        if(completion){
            completion(status, error);
        }
    }];
}

#pragma mark - snapshot
-( NSData*) generateSnapshotData:(UIImage*) image withMeta:(IRawdata*) meta withBoundary:(NSString*) boundary
{
    NSMutableData *body = [NSMutableData data];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    if (imageData) {
        /* meta */
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"meta\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/json; charset=UTF-8\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Transfer-Encoding: 8bit\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [meta toJSONString]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        /* image */
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", @"image"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return body;
}

- (void) saveSnapshot:(UIImage*) image withMeta:(IRawdata*) meta withDevice:(NSString*) deviceId delegate:(nullable id<NSURLSessionDelegate>) delegate
{
    // Build the request body
    NSString *boundary = [self generateBoundaryString];
    NSData *body = [self generateSnapshotData:image withMeta:meta withBoundary:boundary];
    
    // Data uploading task. We could use NSURLSessionUploadTask instead of NSURLSessionDataTask if we needed to support uploads in the background
    NSURL *url = [NSURL URLWithString:[iot_host stringByAppendingString:[NSString stringWithFormat:@"/v1/device/%@/snapshot",deviceId]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    
    [self taskUploadDataRequest:request withBoundary:boundary delegate:delegate];
    
}

- (void)getSnapshotMetaWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId completion:(void(^)(IRawdata *rawdata, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor/%@/snapshot/meta",deviceId,sensorId];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"GET" data:jsonData];
    
    [self taskRequest:request completion:^(NSString *jsonString, NSError *error) {
        IRawdata* rawdata = [IRawdata fromJSONString:jsonString];
        if(completion){
            completion(rawdata, error);
        }
    }];
}

- (void)getSnapshotMetaWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId withStart:(NSString*) start withEnd:(NSString*) end completion:(void(^)(NSArray<IRawdata *> *rawdatas, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor/%@/snapshot/meta",deviceId,sensorId];
    
    NSString *param = @"";
    if(start != nil){
        param = [self generateQueryParam:param withKey:@"start" withValue:start];
    }
    if(end != nil){
        param = [self generateQueryParam:param withKey:@"end" withValue:end];
    }
    if([param length] != 0){
        param = [NSString stringWithFormat:@"?%@",param];
    }
    NSURLRequest *request = [self iotRestfulRequest:[NSString stringWithFormat:@"%@%@",uri,param] method:@"GET" data:jsonData];
    
    [self taskDataRequest:request completion:^(NSData *jsonData, NSError *error) {
        NSArray* rawdatas = [BWJSONMatcher matchJSONData:jsonData withClass:[IRawdata class]];
        
        if(completion){
            completion(rawdatas, error);
        }
    }];
}

- (void)getSnapshotBodyWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId completion:(void(^)(UIImage *image, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor/%@/snapshot",deviceId,sensorId];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"GET" data:jsonData];
    
    [self taskDataRequest:request completion:^(NSData *data, NSError *error) {
        //NSLog(@"snapshot body: %ld",[data length]);
        UIImage *image = [UIImage imageWithData:data];
        //NSLog(@"snapshot uiimage: %f x %f",image.size.width,image.size.height);
        if(completion){
            completion(image, error);
        }
    }];
}

- (void)getSnapshotBodyWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId delegate:(nullable id<NSURLSessionDelegate>) delegate
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor/%@/snapshot",deviceId,sensorId];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"GET" data:jsonData acceptEncoding:@""];
    
    [self taskDownloadDataRequest:request delegate:delegate];

}

- (void)getSnapshotBody:(NSString*)snapshotId withSensor:(NSString*) sensorId withDevice:(NSString*) deviceId completion:(void(^)(UIImage *image, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor/%@/snapshot/%@",deviceId,sensorId,snapshotId];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"GET" data:jsonData acceptEncoding:@""];
    
    [self taskDataRequest:request completion:^(NSData *data, NSError *error) {
        //NSLog(@"snapshot body: %ld",[data length]);
        UIImage *image = [UIImage imageWithData:data];
        //NSLog(@"snapshot uiimage: %f x %f",image.size.width,image.size.height);
        if(completion){
            completion(image, error);
        }
    }];
}

- (void)getSnapshotBody:(NSString*)snapshotId withSensor:(NSString*) sensorId withDevice:(NSString*) deviceId delegate:(nullable id<NSURLSessionDelegate>) delegate
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor/%@/snapshot/%@",deviceId,sensorId,snapshotId];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"GET" data:jsonData];
    
    [self taskDownloadDataRequest:request delegate:delegate];
}


- (void)deleteSnapshotWithSensor:(NSString*) sensorId withDevice:(NSString*) deviceId withStart:(NSString*) start withEnd:(NSString*) end completion:(void(^)(long status, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/device/%@/sensor/%@/snapshot/meta",deviceId,sensorId];
    
    NSString *param = @"";
    if(start != nil){
        param = [self generateQueryParam:param withKey:@"start" withValue:start];
    }
    if(end != nil){
        param = [self generateQueryParam:param withKey:@"end" withValue:end];
    }
    if([param length] != 0){
        param = [NSString stringWithFormat:@"?%@",param];
    }
    NSURLRequest *request = [self iotRestfulRequest:[NSString stringWithFormat:@"%@%@",uri,param] method:@"DELETE" data:jsonData];
    
    [self taskStatusRequest:request completion:^(long status, NSError *error) {
        if(completion){
            completion(status, error);
        }
    }];
}

#pragma mark - registry
-(void) reconfigure:(NSString*) serialId withDigest:(NSString*) digest completion:(void(^)(long status, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/registry/%@",serialId];
    IProvision *provision = [IProvision new];
    provision.op = @"Reconfigure";
    provision.digest = digest;
    jsonData = [provision toJSONData];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"POST" data:jsonData];
    
    [self taskStatusRequest:request completion:^(long status, NSError *error) {
        if(completion){
            completion(status, error);  // 主要判斷是否有error
        }
    }];
}

-(void) reconfigureData:(NSString*) serialId withDigest:(NSString*) digest completion:(void(^)(long status, NSData* data, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/registry/%@",serialId];
    IProvision *provision = [IProvision new];
    provision.op = @"Reconfigure";
    provision.digest = digest;
    jsonData = [provision toJSONData];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"POST" data:jsonData];
    
    [self taskStatusDataRequest:request completion:^(long status, NSData* data, NSError *error) {
        if(completion){
            completion(status, data, error);  // 主要判斷是否有error
        }
    }];
}

-(void) setDeviceId:(NSString*) deviceId withSerialId:(NSString*) serialId withDigest:(NSString*) digest completion:(void(^)(long status, NSError *error))completion
{
    NSData *jsonData = nil;
    NSString *uri = [NSString stringWithFormat:@"/v1/registry/%@",serialId];
    IProvision *provision = [IProvision new];
    provision.op = @"SetDeviceId";
    provision.digest = digest;
    provision.deviceId = deviceId;
    jsonData = [provision toJSONData];
    NSURLRequest *request = [self iotRestfulRequest:uri method:@"POST" data:jsonData];
    
    [self taskStatusRequest:request completion:^(long status, NSError *error) {
        if(completion){
            completion(status, error);  // 主要判斷是否有error
        }
    }];
}

#pragma mark - Shared functions
- (void)taskStatusRequest:(NSURLRequest*)request completion:(void(^)(long status, NSError *error))completion
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
    {
        
        if (error == nil){
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
            if(completion){
                completion((long)[httpResponse statusCode], error);
            }
        }else{
            if(error.code == 404){
                NSLog(@"404");
            }else{
                NSLog(@"connect error:%@",error);
            }
            if(completion){
                completion(error.code, error);
            }
        }
    }];
    
    [task resume];
}

- (void)taskStatusDataRequest:(NSURLRequest*)request completion:(void(^)(long status, NSData *jsonData, NSError *error))completion
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
                                  {
                                      
                                      if (error == nil){
                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                          NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                                          if(completion){
                                              completion((long)[httpResponse statusCode], data, error);
                                          }
                                      }else{
                                          if(error.code == 404){
                                              NSLog(@"404");
                                          }else{
                                              NSLog(@"connect error:%@",error);
                                          }
                                          if(completion){
                                              completion(error.code, data, error);
                                          }
                                      }
                                  }];
    
    [task resume];
}

- (void)taskDataRequest:(NSURLRequest*)request completion:(void(^)(NSData *jsonData, NSError *error))completion
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
                                  {
                                      if (error == nil){
                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                          NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                                          if((long)[httpResponse statusCode] == 200){
                                              if(completion){
                                                  completion(data, error);
                                              }
                                          }
                                      }else{
                                          if(error.code == 404){
                                              NSLog(@"404");
                                          }else{
                                              NSLog(@"connect error:%@",error);
                                          }
                                          if(completion){
                                              completion(nil, error);
                                          }
                                      }
                                  }];
    
    [task resume];
}

- (void)taskDownloadDataRequest:(NSURLRequest*)request delegate:(nullable id<NSURLSessionDelegate>) delegate
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //NSURLSession *session = [NSURLSession sharedSession];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:delegate delegateQueue:nil];
    //NSURLSessionDataTask* task = [session dataTaskWithRequest:request];
    NSURLSessionDownloadTask* task = [session downloadTaskWithRequest:request];
    
    [task resume];
}

/*
- (void)taskDownloadDataRequest:(NSURLRequest*)request completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler
{
    NSURLSession *session = [NSURLSession sharedSession];
    [session downloadTaskWithRequest:request completionHandler:completionHandler];
}
*/
- (void)taskUploadDataRequest:(NSURLRequest*)request withBoundary:(NSString*) boundary delegate:(nullable id<NSURLSessionDelegate>) delegate
{
    // Setup the session
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"CK" : apiKey,
                                                   @"Content-Type"  : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
                                                   };
    
    // Create the session
    // We can use the delegate to track upload progress
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:delegate delegateQueue:nil];
    
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request];
    /*
     [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
     dispatch_async(dispatch_get_main_queue(), ^{
     //NSError *err;
     //NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
     if (error == nil) {
     // Success
     NSLog(@"URL Session Task Succeeded: HTTP %ld", (long)((NSHTTPURLResponse*)response).statusCode);
     
     //successBlock(resultDict);
     }
     else {
     // Failure
     NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
     
     //failBlock(error);
     }
     });
     }];
     */
    [uploadTask resume];
}


- (void)taskRequest:(NSURLRequest*)request completion:(void(^)(NSString *jsonString, NSError *error))completion
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
    {
        NSLog(@"data:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (error == nil){
            NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if(completion){
                completion(jsonString, error);
            }
        }else{
            if(error.code == 404){
                NSLog(@"404");
            }else{
                NSLog(@"connect error:%@",error);
            }
            if(completion){
                completion(nil, error);
            }
        }
    }];
    [task resume];
}

- (NSMutableURLRequest*)iotRestfulRequest:(NSString*) uri method:(NSString*) method data:(NSData*) jsonData
{
    NSMutableURLRequest *request  = [[NSMutableURLRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",iot_host,uri];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //NSLog(@"urlString:%@",urlString);
    [request setURL:[NSURL URLWithString:urlString]];
    // 設置HTTP方法
    [request setHTTPMethod:method];  //GET, POST, PUT
    
    if(jsonData != nil){
        [request setHTTPBody:jsonData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    [request setValue:apiKey forHTTPHeaderField:@"CK"];
    
    return request;
}

- (NSMutableURLRequest*)iotRestfulRequest:(NSString*) uri method:(NSString*) method data:(NSData*) jsonData acceptEncoding:(NSString*) encoding
{
    NSMutableURLRequest *request  = [[NSMutableURLRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",iot_host,uri];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //NSLog(@"urlString:%@",urlString);
    [request setURL:[NSURL URLWithString:urlString]];
    [request addValue:encoding forHTTPHeaderField:@"Accept-Encoding"];
    // 設置HTTP方法
    [request setHTTPMethod:method];  //GET, POST, PUT
    
    if(jsonData != nil){
        [request setHTTPBody:jsonData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    [request setValue:apiKey forHTTPHeaderField:@"CK"];
    
    return request;
}

-(NSString*) generateQueryParam:(NSString*) param withKey:(NSString*) key withValue:(NSString*) value
{
    if([param length] != 0){
        param = [param stringByAppendingString:@"&"];
    }
    param = [param stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,value]];
    
    return param;
}

- (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}
@end
