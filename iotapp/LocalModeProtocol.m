
//
//  LocalModeProtocol.m
//  iotapp
//
//  Created by chttl on 2016/8/22.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "LocalModeProtocol.h"

#define MAGIC_HEAD_HI 0x0A4
#define MAGIC_HEAD_LO 0x0B2
#define COMMAND_ANNOUNCE 0x00
#define COMMAND_CONNECT_REQUEST 0x01
#define COMMAND_CHALLENGE_REQUEST 0x01
#define COMMAND_CHALLENGE_REPLY 0x081
#define COMMAND_INTRODUCE_REQUEST 0x02
#define COMMAND_INTRODUCE_REPLY 0x82
#define COMMAND_PING_REQUEST 0x03
#define COMMAND_PING_REPLY 0x083
#define COMMAND_READ_REQUEST 0x0A
#define COMMAND_READ_REPLY 0x8A
#define COMMAND_WRITE_REQUEST 0x0B
#define COMMAND_WRITE_REPLY 0x8B
#define ZERO_TAIL 0x0


@implementation LocalModeProtocol

- (Byte*) readPacketBody:(NSData*) data {
    NSData *bodyData = [data subdataWithRange:NSMakeRange(4, data.length-5)];
    
    NSUInteger bodyLen = [bodyData length];
    Byte *byteBodyData = (Byte*)malloc(bodyLen);
    memcpy(byteBodyData, [bodyData bytes], bodyLen);
    
    return byteBodyData;
}

- (NSData*) buildPacket:(NSData*) bodyData {
    NSMutableData *packageData = [[NSMutableData alloc] init];
    [packageData appendBytes:[self magicHeader] length:2];
    [packageData appendBytes:[self bodyLength:(bodyData.length)] length:2];
    [packageData appendData:bodyData];
    NSInteger checksum =[self checksum:bodyData];
    [packageData appendBytes:&checksum length:1];
    [self showByteData:packageData];
    return packageData;
}

- (NSData*) buildConnectPacket {
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    [bodyData appendBytes:[self command:COMMAND_CONNECT_REQUEST] length:1];
    
    return [self buildPacket:bodyData];
}

- (NSString*) readString:(NSData*) data {
    /*
     * String vendor = "vendor";
     * String model = "model";
     * String series = "series";
     * String name = "name";
     */
   
    NSData *bodyData = [self getBodyData:data];
    Byte* byte = [self byteOfData:bodyData];
    int pos = 0;
    for(int i=1 ;i <[data length]; i++){
        //NSLog(@"%02X ",byte[i]);
        if(byte[i] == ZERO_TAIL){
            break;
        }else{
            pos++;
        }
    }
    NSLog(@"--- pos : %d ---",pos);
    NSData *stringData = [bodyData subdataWithRange:NSMakeRange(1, pos)];
    NSLog(@"string: %@",[NSString stringWithUTF8String:[stringData bytes]]);
    
    return [NSString stringWithUTF8String:[stringData bytes]];
}

- (Session*) getSession:(NSData *) bodyData {
    Session *session = [Session new];
    //NSLog(@"bodyData length: %d", bodyData.length);
    NSData *data = [bodyData subdataWithRange:NSMakeRange(1, bodyData.length-1)];
    NSInteger epVendor = [self getZeroTailPosition:data]; //end pos of vendor
    NSData *vendorData = [data subdataWithRange:NSMakeRange(0, epVendor)];
    session.vendor = [NSString stringWithUTF8String:[vendorData bytes]];
    NSLog(@"vendor: %@",[NSString stringWithUTF8String:[vendorData bytes]]);
    data = [data subdataWithRange:NSMakeRange(epVendor+1, data.length-epVendor-1)];
    NSInteger epModel = [self getZeroTailPosition:data]; //end pos of model
    NSData *modelData = [data subdataWithRange:NSMakeRange(0, epModel)];
    session.model = [NSString stringWithUTF8String:[modelData bytes]];
    NSLog(@"model: %@",[NSString stringWithUTF8String:[modelData bytes]]);
    data = [data subdataWithRange:NSMakeRange(epModel+1, data.length-epModel-1)];
    NSInteger epSeries = [self getZeroTailPosition:data]; //end pos of model
    NSData *seriesData = [data subdataWithRange:NSMakeRange(0, epSeries)];
    session.series = [NSString stringWithUTF8String:[seriesData bytes]];
    NSLog(@"series: %@",[NSString stringWithUTF8String:[seriesData bytes]]);
    data = [data subdataWithRange:NSMakeRange(epSeries+1, data.length-epSeries-1)];
    NSInteger epName = [self getZeroTailPosition:data]; //end pos of model
    NSData *nameData = [data subdataWithRange:NSMakeRange(0, epName)];
    session.name = [NSString stringWithUTF8String:[nameData bytes]];
    NSLog(@"series: %@",[NSString stringWithUTF8String:[nameData bytes]]);
    
    
    return session;
}

- (NSInteger) getZeroTailPosition:(NSData *) data {
    NSInteger pos = 0;
    Byte* byte = [self byteOfData:data];
    for(int i=0 ;i <[data length]; i++){
        //NSLog(@"%02X ",byte[i]);
        if(byte[i] == ZERO_TAIL){
            break;
        }else{
            pos++;
        }
    }
    //NSLog(@"--- pos : %d ---",pos);
    return pos;
}

- (Byte*) magicHeader {
    Byte *bytes = (Byte*)malloc(2);
    bytes[0]=MAGIC_HEAD_HI;
    bytes[1]=MAGIC_HEAD_LO;
    return bytes;
}

- (NSInteger) getLength:(NSData *) data {
    Byte *byteData = [self byteOfData:[data subdataWithRange:NSMakeRange(2, 2)]];
    return (NSInteger)(byteData[0] << 8 | byteData[1]);
}

- (Byte*) getBody:(NSData *) data {
    // remove magic-header, length and checksum
    return [self byteOfData:[data subdataWithRange:NSMakeRange(4, data.length-5)]];
}

- (Byte *) getCommond:(NSData *) data {
    NSData *bodyData = [self getBodyData:data];
    if([bodyData length]>0){
        NSData *commandData = [bodyData subdataWithRange:NSMakeRange(0, 1)];
        Byte* byte = [self byteOfData:commandData];
        [self showByteData:commandData];
        return byte;
    }
    return nil;
}

- (NSData*) getBodyData:(NSData *) data {
    return [data subdataWithRange:NSMakeRange(4, data.length-5)];
}

- (Byte*) bodyLength:(NSInteger) len {
    Byte *bytes = (Byte*)malloc(2);
    bytes[0] = ((len >> 8) & 0x0FF);
    bytes[1] = (len & 0x0FF);
    return bytes;
}


- (Byte*) command:(NSInteger) cmd {
    Byte *bytes = (Byte*)malloc(1);
    bytes[0] = cmd;
    return bytes;
}

- (int) checksum:(NSData*) bodyData {
    int checksum = 0;
    Byte *byteBodyData = [self byteOfData:bodyData];
    
    for (int i = 0 ; i < bodyData.length ; i ++) {
        checksum = checksum + (byteBodyData[i] & 0x0FF);
    }
    return checksum & 0x0FF;
}

- (Byte*) byteOfData:(NSData*) data {
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    return byteData;
}

- (void) showByteData:(NSData*) data {
    NSMutableString *result = [NSMutableString new];
    Byte *byteData = [self byteOfData:data];
    for (int i = 0 ; i < data.length; i ++)
    {
        [result appendFormat:@"%02X ", byteData[i]];
        
    }
    NSLog(@"%@",result);
}
@end
