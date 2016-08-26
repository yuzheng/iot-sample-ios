//
//  ControllerClientBuilder.m
//  iotapp
//
//  Created by chttl on 2016/8/22.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "ControllerClientBuilder.h"
#import "GCDAsyncUdpSocket.h"
#import "LocalModeProtocol.h"

@interface ControllerClientBuilder() <GCDAsyncUdpSocketDelegate>
{
    LocalModeProtocol *protocol;
}
@property (nonatomic, strong, readonly) dispatch_queue_t udpSocketQueue;
@property (nonatomic, strong, readonly) GCDAsyncUdpSocket *udpSocket;

@end

@implementation ControllerClientBuilder

- (instancetype)init
{
    if (self = [super init]) {
        protocol = [LocalModeProtocol new];
        _udpSocketQueue = dispatch_queue_create("com.cht.iot.local.queue", DISPATCH_QUEUE_SERIAL);
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_udpSocketQueue];
        // avoid receiving two times
        [_udpSocket setIPv4Enabled:YES];
        [_udpSocket setIPv6Enabled:NO];
    }
    return self;
}

- (void)dealloc
{
    _udpSocket.delegate = nil;
    _udpSocket = nil;
}

- (void)setupAnnouncementSocket:(uint16_t)port;
{
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

- (void)closeAnnouncementSocket{
    [_udpSocket close];
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
    NSString *controllerHost = nil;
    uint16_t controllerPort = 10600;
    [GCDAsyncUdpSocket getHost:&controllerHost port:&controllerPort fromAddress:address];
    
    //NSLog(@"didReceiveData: %ld",(unsigned long)data.length);
    
    NSError *error = nil;
    NSData *bodyData = [protocol readPacketBody:data error:&error];
    
    if(error != nil){
        NSLog(@"Error of readPacketBody: %@",error);
    }else{
    
    //NSData *bodyData = [protocol getBodyData:[data mutableCopy]];
        //[protocol showByteData:[data mutableCopy]];
        
        Byte* command = [protocol readCommond:bodyData];
        //NSLog(@"%lu", sizeof(command)); // 1 Byte > 4 size
        if(command[0] == COMMAND_ANNOUNCE){
            
            LocalSession *session = [protocol getSession:[bodyData mutableCopy]];
            session.host = controllerHost;
            session.port = 10600;
            
            //NSLog(@"find :%@/%@/%@/%@",session.vendor, session.model, session.series, session.name);
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(findController:)])
            {
                [self.delegate findController:session];
            }
        }else{
            NSLog(@"Receive the incorrect packet from %@ %i",controllerHost,controllerPort);
        }
    }
}

/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"Annoument Socket DidClose: %@", error);
}

@end