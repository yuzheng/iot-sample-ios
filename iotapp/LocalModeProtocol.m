
//
//  LocalModeProtocol.m
//  iotapp
//
//  Created by chttl on 2016/8/22.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
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

#define PACKET_MINIMUM_SIZE 6
#define PACKET_MAGIC_HEADER_SIZE 2
#define PACKET_LENGTH_SIZE 2

@implementation LocalModeProtocol

- (NSError*) buildErrorWithDomain:(NSString*) domain code:(NSInteger) code message:(NSString*) message {
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:message forKey:NSLocalizedDescriptionKey];
    
    // populate the error object with the details
    return [NSError errorWithDomain:domain code:code userInfo:details];
}

- (Boolean) checkPacket:(NSData*) data  error:(NSError **) error{
    
    return true;
}

- (NSData*) readPacketBody:(NSData*) data  error:(NSError **) error{
    // check packet size
    if( data.length < PACKET_MINIMUM_SIZE ) {
        *error = [self buildErrorWithDomain:@"packet" code:401 message:@"Packet size error!"];
        return nil;
    }else{
        // check Magic Header
        NSData *headerData = [data subdataWithRange:NSMakeRange(0, PACKET_MAGIC_HEADER_SIZE)];
        Byte* headerByte = [self byteOfData:headerData];
        if(headerByte[0] != MAGIC_HEAD_HI || headerByte[1] != MAGIC_HEAD_LO) {
            *error = [self buildErrorWithDomain:@"packet" code:402 message:@"Magic Header is illegal!"];
            return nil;
        }else{
            NSData *lengthData = [data subdataWithRange:NSMakeRange(2, PACKET_LENGTH_SIZE)];
            NSInteger length = [self getLength:lengthData];
            
            NSData *bodyData = [data subdataWithRange:NSMakeRange(4, length)];
            
            NSInteger checksum = [self checksum:bodyData];
            
            //NSLog(@"checksum: %ld",(long)checksum);
            
            // check body size
            if( (PACKET_MAGIC_HEADER_SIZE+PACKET_LENGTH_SIZE+length+1) != data.length ){
                *error = [self buildErrorWithDomain:@"packet" code:403 message:@"Packet body size error!"];
                return nil;
            }else{
                NSData *checksumData = [data subdataWithRange:NSMakeRange(4+length, 1)];
                if(![checksumData isEqualToData:[[NSData alloc] initWithBytes:&checksum length:1]]){
                    *error = [self buildErrorWithDomain:@"packet" code:404 message:@"Checksum is wrong!"];
                    return nil;
                }
                
                return bodyData;
            }
        }
    }
}

- (Byte *) readCommond:(NSData *) bodyData {
    if([bodyData length]>0){
        NSData *commandData = [bodyData subdataWithRange:NSMakeRange(0, 1)];
        Byte* byte = [self byteOfData:commandData];
        //[self showByteData:commandData];
        return byte;
    }
    return nil;
}

- (LocalIntroduce*) readIntroduce:(NSData *) bodyData {
    LocalIntroduce* introduce = [LocalIntroduce new];
    NSData *data = [bodyData subdataWithRange:NSMakeRange(1, bodyData.length-1)];
    NSInteger epCipher = [self getZeroTailPosition:data]; //end pos of vendor
    NSLog(@"epCipher: %ld",(long)epCipher);
    if(epCipher > 0) {
        NSData *cipherData = [data subdataWithRange:NSMakeRange(0, epCipher)];
        introduce.cipher = [self getStringFromData:cipherData];
        //introduce.cipher = [NSString stringWithUTF8String:[cipherData bytes]];
    }else{
        introduce.cipher = @"";
    }
    
    data = [data subdataWithRange:NSMakeRange(epCipher+1, data.length-epCipher-1)];
    NSInteger epExtra = [self getZeroTailPosition:data]; //end pos of model
    if(epExtra > 0){
        NSData *extraData = [data subdataWithRange:NSMakeRange(0, epExtra)];
        introduce.extra = [self getStringFromData:extraData];
        //introduce.extra = [NSString stringWithUTF8String:[extraData bytes]];
    }else{
        introduce.extra = @"";
    }
    return introduce;
}

- (NSString*) readSalt:(NSData *) bodyData {
    NSData *data = [bodyData subdataWithRange:NSMakeRange(1, bodyData.length-1)];
    NSInteger epSalt = [self getZeroTailPosition:data]; //end pos of vendor
    NSData *saltData = [data subdataWithRange:NSMakeRange(0, epSalt)];
    //return [NSString stringWithUTF8String:[saltData bytes]];
    return [self getStringFromData:saltData];
}

- (LocalSession*) getSession:(NSData *) bodyData {
    LocalSession *session = [LocalSession new];
    //NSLog(@"bodyData length: %d", bodyData.length);
    NSData *data = [bodyData subdataWithRange:NSMakeRange(1, bodyData.length-1)];
    NSInteger epVendor = [self getZeroTailPosition:data]; //end pos of vendor
    NSData *vendorData = [data subdataWithRange:NSMakeRange(0, epVendor)];
    session.vendor = [self getStringFromData:vendorData];
    //session.vendor = [NSString stringWithUTF8String:[vendorData bytes]];
    //NSLog(@"vendor: %@",[NSString stringWithUTF8String:[vendorData bytes]]);
    
    data = [data subdataWithRange:NSMakeRange(epVendor+1, data.length-epVendor-1)];
    NSInteger epModel = [self getZeroTailPosition:data]; //end pos of model
    NSData *modelData = [data subdataWithRange:NSMakeRange(0, epModel)];
    session.model = [self getStringFromData:modelData];
    //session.model = [NSString stringWithUTF8String:[modelData bytes]];
    //NSLog(@"model: %@",[NSString stringWithUTF8String:[modelData bytes]]);
    
    data = [data subdataWithRange:NSMakeRange(epModel+1, data.length-epModel-1)];
    NSInteger epSeries = [self getZeroTailPosition:data]; //end pos of model
    NSData *seriesData = [data subdataWithRange:NSMakeRange(0, epSeries)];
    session.series = [self getStringFromData:seriesData];
    //session.series = [NSString stringWithUTF8String:[seriesData bytes]];
    //NSLog(@"series: %@",[NSString stringWithUTF8String:[seriesData bytes]]);
    
    data = [data subdataWithRange:NSMakeRange(epSeries+1, data.length-epSeries-1)];
    NSInteger epName = [self getZeroTailPosition:data]; //end pos of model
    NSData *nameData = [data subdataWithRange:NSMakeRange(0, epName)];
    session.name = [self getStringFromData:nameData];
    //session.name = [NSString stringWithUTF8String:[nameData bytes]];
    //NSLog(@"series: %@",session.name);
    
    return session;
}

- (NSString*) getStringFromData:(NSData*) data{
    return [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
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

#pragma mark -
#pragma mark build packet

- (NSData*) buildPacket:(NSData*) bodyData {
    NSMutableData *packageData = [[NSMutableData alloc] init];
    [packageData appendBytes:[self magicHeader] length:2];
    [packageData appendBytes:[self bodyLength:(bodyData.length)] length:2];
    [packageData appendData:bodyData];
    NSInteger checksum =[self checksum:bodyData];
    [packageData appendBytes:&checksum length:1];
    //[self showByteData:packageData];
    return packageData;
}

- (NSData*) buildConnectPacket {
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    [bodyData appendBytes:[self command:COMMAND_CONNECT_REQUEST] length:1];
    
    return [self buildPacket:bodyData];
}

- (NSData*) buildChallengeReplyPacket:(NSString *) salt apiKey:(NSString *) key {
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    
    NSString *sign = [NSString stringWithFormat:@"%@%@", salt, key];
    const char *cStr = [sign UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), digest);
    
    NSData *hashData = [[NSData alloc] initWithBytes:digest length: sizeof digest];
    [self showByteData:hashData];
    
    [bodyData appendBytes:[self command:COMMAND_CHALLENGE_REPLY] length:1];
    [bodyData appendData:hashData];
    [bodyData appendBytes:[self command:ZERO_TAIL] length:1];
    
    return [self buildPacket:bodyData];
}

- (NSData*) buildIntroduceReplyPacket {
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    [bodyData appendBytes:[self command:COMMAND_INTRODUCE_REPLY] length:1];
    
    return [self buildPacket:bodyData];
}

- (NSData*) buildPingRequestPacket {
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    [bodyData appendBytes:[self command:COMMAND_PING_REQUEST] length:1];
    
    return [self buildPacket:bodyData];
}

- (NSData*) buildPingReplyPacket {
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    [bodyData appendBytes:[self command:COMMAND_PING_REPLY] length:1];
    
    return [self buildPacket:bodyData];
}

- (NSData*) buildReadRequestPacket:(NSString *) deviceId sensor:(NSString *) sensorId {
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    [bodyData appendBytes:[self command:COMMAND_READ_REQUEST] length:1];
    
    [bodyData appendData:[deviceId dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendBytes:[self command:ZERO_TAIL] length:1];
    
    [bodyData appendData:[sensorId dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendBytes:[self command:ZERO_TAIL] length:1];
    
    return [self buildPacket:bodyData];
}

- (NSData*) buildReadReplyPacket {
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    [bodyData appendBytes:[self command:COMMAND_READ_REPLY] length:1];
    
    return [self buildPacket:bodyData];
}

- (NSData*) buildWriteRequestPacket:(NSString *) deviceId sensor:(NSString *) sensorId value:(NSArray*) values {
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    [bodyData appendBytes:[self command:COMMAND_WRITE_REQUEST] length:1];
    
    [bodyData appendData:[deviceId dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendBytes:[self command:ZERO_TAIL] length:1];
    
    [bodyData appendData:[sensorId dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendBytes:[self command:ZERO_TAIL] length:1];
    
    NSInteger count = [values count] & 0x0FF;
    [bodyData appendBytes:&count length:1];
    
    for(NSString *value in values){
        [bodyData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendBytes:[self command:ZERO_TAIL] length:1];
    }
    
    return [self buildPacket:bodyData];
}

- (NSData*) buildWriteReplyPacket {
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    [bodyData appendBytes:[self command:COMMAND_WRITE_REPLY] length:1];
    
    return [self buildPacket:bodyData];
}


#pragma mark -
#pragma mark common

- (Byte*) magicHeader {
    Byte *bytes = (Byte*)malloc(2);
    bytes[0]=MAGIC_HEAD_HI;
    bytes[1]=MAGIC_HEAD_LO;
    return bytes;
}

- (NSInteger) getLength:(NSData *) data {
    Byte *byteData = [self byteOfData:data];
    return (NSInteger)(byteData[0] << 8 | byteData[1]);
}

- (Byte*) getBody:(NSData *) data {
    // remove magic-header, length and checksum
    return [self byteOfData:[data subdataWithRange:NSMakeRange(4, data.length-5)]];
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
