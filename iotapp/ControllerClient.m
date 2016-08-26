//
//  ControllerClient.m
//  iotapp
//
//  Created by chttl on 2016/8/22.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "ControllerClient.h"
#import "GCDAsyncUdpSocket.h"
#import "LocalModeProtocol.h"

#define MAXIMUN_COUNT_RESEND 3

@interface ControllerClient() <GCDAsyncUdpSocketDelegate>
{
    LocalModeProtocol *protocol;
    NSString *apiKey;
}
@property (nonatomic, strong, readonly) dispatch_queue_t udpSocketQueue;
@property (nonatomic, strong, readonly) dispatch_queue_t waitingForAckQueue;
@property (nonatomic, strong, readonly) GCDAsyncUdpSocket *udpSocket;
//@property (nonatomic, strong, readonly) NSTimer *timer;

@end

@implementation ControllerClient

- (instancetype)init
{
    if (self = [super init]) {
        
        apiKey = @"DKRHF4KM29RXM27X3M";
        authenticated = false;
        keepalive = 10.0; //second
        timeout = 2.0; //second
        
        protocol = [LocalModeProtocol new];
        
        countResend = 0;
        _waitingForAckQueue = dispatch_queue_create("com.cht.iot.client.queue", DISPATCH_QUEUE_SERIAL);
        
        _udpSocketQueue = dispatch_queue_create("com.cht.iot.controller.queue", DISPATCH_QUEUE_SERIAL);
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_udpSocketQueue];
        
        // avoid receiving two times
        [_udpSocket setIPv4Enabled:YES];
        [_udpSocket setIPv6Enabled:NO];
    }
    return self;
}

- (void)dealloc
{
    if(timerAlive != nil){
        [timerAlive invalidate];
        timerAlive = nil;
    }
    
    if(timerAck != nil){
        [timerAck invalidate];
        timerAck = nil;
    }
    
    _udpSocket.delegate = nil;
    _udpSocket = nil;
}
- (void)setupSocket:(uint16_t)port
{
    NSLog(@"ControllerClient port:%d",port);
    NSError *error = nil;
    if (![_udpSocket bindToPort:port error:&error]) {
        NSLog(@"Error binding: %@", error);
        return;
    }
    
    if (![_udpSocket beginReceiving:&error]) {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
    NSLog(@"setupUdpSocket Ready");
}

- (void)setApiKey:(NSString*)key {
    apiKey = key;
}

- (void)setKeepalive:(double)time {
    keepalive = time;
}

- (void)setTimeout:(double) time {
    timeout = time;
}

- (void)linkController:(LocalSession *) linksession
{
    session = linksession;
    NSLog(@"linkController:%@ : %hu",session.host, session.port);
    NSData *connectData = [protocol buildConnectPacket];
    //[_udpSocket sendData:connectData toHost:session.host port:session.port withTimeout:-1 tag:clock()];
    [self sendData:connectData toHost:session.host port:session.port needAck:true];
    
}

- (void)sendData:(NSData *)data toHost:(NSString *)host port:(int)port needAck:(BOOL) ack
{
    long tag = clock();
    if(ack){
        [self doWaitingForAck:data];
    }
    [self sendData:data toHost:host port:port tag:tag];
}

- (void)sendData:(NSData *)data toHost:(NSString *)host port:(int)port
{
    long tag = clock();
    [self sendData:data toHost:host port:port tag:tag];
}

- (void)sendData:(NSData *)data toHost:(NSString *)host port:(int)port tag:(long)tag
{
    [_udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:tag];
}

- (void) startKeepalive {  //ping
    if(timerAlive != nil){
        [timerAlive invalidate];
        timerAlive = nil;
    }
    // create new timer with async ping call:
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //run function methodRunAfterBackground
        timerAlive = [NSTimer scheduledTimerWithTimeInterval:keepalive target:self selector:@selector(doPing:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timerAlive forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void) doWaitingForAck:(NSData*) data {
    NSLog(@"show doWaitingForAck: %ld",(long)countResend);
    dispatch_async(_waitingForAckQueue, ^{
        if(countResend < MAXIMUN_COUNT_RESEND){
            timerAck =[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(doResend:) userInfo:data repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:timerAck forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        }else{
            NSLog(@"Need close this socket");
        }
    });
}

- (void) resetAck {
    countResend = 0;
    [self doCloseAckTimer];
}

- (void) doCloseAckTimer {
    if(timerAck != nil) {
        NSLog(@"timerAck: need to close!");
        [timerAck invalidate];
        timerAck = nil;
    }
}

- (void) doResend:(NSTimer *)timer {
    NSLog(@"Ack timeout: doResend:");
    NSData *resendData =[timer userInfo];
    [self doCloseAckTimer];
    if(resendData != nil) {
        countResend ++;
        [protocol showByteData:resendData];
        [self sendData:resendData toHost:session.host port:session.port needAck:true];
    }
}

- (void) doPing:(NSTimer *)timer {
    if(authenticated){
        NSLog(@"doKeepalive");
        NSData *pingData = [protocol buildPingRequestPacket];
        [self sendData:pingData toHost:session.host port:session.port];
    }
}

- (void)readDevice:(NSString*) deviceId sensor:(NSString*) sensorId
{
    NSData *readData = [protocol buildReadRequestPacket:deviceId sensor:sensorId];
    [self sendData:readData toHost:session.host port:session.port];
}
- (void)writeDevice:(NSString*) deviceId sensor:(NSString*) sensorId value:(NSArray*) values
{
    NSData *writeData = [protocol buildWriteRequestPacket:deviceId sensor:sensorId value:values];
    [self sendData:writeData toHost:session.host port:session.port];
}

#pragma mark - GCDAsyncUdpSocketDelegate

/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the connection is successful.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSLog(@"didConnectToAddress");
}

/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the connection fails.
 * This may happen, for example, if a domain name is given for the host and the domain name is unable to be resolved.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    NSLog(@"didNotConnect: %@", error);
}

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    // You could add checks here
    NSLog(@"didSendDataWithTag[%ld]", tag);
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    // You could add checks here
    NSLog(@"didNotSendDataWithTag[%ld]: %@", tag, error);
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    // 獲取設備端socket的host與port
    //NSString *controllerHost = nil;
    //uint16_t controllerPort = session.port;
    //[GCDAsyncUdpSocket getHost:&controllerHost port:&controllerPort fromAddress:address];
    
    //NSLog(@"didReceiveData: %ld",(unsigned long)data.length);
    
    NSError *error = nil;
    NSData *bodyData = [protocol readPacketBody:data error:&error];
    
    if(error != nil){
        NSLog(@"Error of readPacketBody: %@",error);
    }else{
        //[protocol showByteData:[data mutableCopy]];
        
        Byte* command = [protocol readCommond:bodyData];
        //NSLog(@"%lu", sizeof(command)); // 1 Byte > 4 size
        if(command[0] == COMMAND_CHALLENGE_REQUEST) {
            NSLog(@"COMMAND_CHALLENGE_REQUEST");
            
            [self resetAck];
            
            NSString *salt = [protocol readSalt:bodyData];
            //NSLog(@"salt: %@", salt);
            
            NSData *challengeData = [protocol buildChallengeReplyPacket:salt apiKey:apiKey];
            
            [self sendData:challengeData toHost:session.host port:session.port needAck:true];
            //[_udpSocket sendData:challengeData toHost:session.host port:session.port withTimeout:-1 tag:clock()];
            
        } else if(command[0] == COMMAND_INTRODUCE_REQUEST) {
            NSLog(@"COMMAND_INTRODUCE_REQUEST");
            
            [self resetAck];
            
            LocalIntroduce* introduce = [protocol readIntroduce:bodyData];
            NSLog(@"introduce: %@/%@", introduce.cipher, introduce.extra);
            
            @synchronized (session) {
                authenticated = true;
            }
            
            [self startKeepalive];
            
            NSData *replyData = [protocol buildIntroduceReplyPacket];
            
            [self sendData:replyData toHost:session.host port:session.port];
            //[_udpSocket sendData:replyData toHost:session.host port:session.port withTimeout:-1 tag:clock()];
            
        } else if(command[0] == COMMAND_PING_REPLY) {
            NSLog(@"COMMAND_PING_REPLY");
            
            [self doCloseAckTimer];
            
        } else if(command[0] == COMMAND_READ_REPLY) {
            NSLog(@"COMMAND_READ_REPLY");
            
        } else if(command[0] == COMMAND_WRITE_REQUEST) {
            NSLog(@"COMMAND_WRITE_REQUEST");
            
            
            
        } else if(command[0] == COMMAND_WRITE_REPLY) {
            NSLog(@"COMMAND_WRITE_REPLY");
            
        }
    }
}

/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"Socket DidClose: %@", error);
}

@end
