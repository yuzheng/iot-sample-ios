//
//  LocalModeProtocol.h
//  iotapp
//
//  Created by chttl on 2016/8/22.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalSession.h"
#import "LocalIntroduce.h"

typedef NS_ENUM(Byte, LocalModeProtocolCommand) {
    COMMAND_ANNOUNCE = 0x00,
    COMMAND_CONNECT_REQUEST = 0x01,
    COMMAND_CHALLENGE_REQUEST = 0x01,
    COMMAND_CHALLENGE_REPLY = 0x081,
    COMMAND_INTRODUCE_REQUEST = 0x02,
    COMMAND_INTRODUCE_REPLY = 0x82,
    COMMAND_PING_REQUEST = 0x03,
    COMMAND_PING_REPLY = 0x083,
    COMMAND_READ_REQUEST = 0x0A,
    COMMAND_READ_REPLY = 0x8A,
    COMMAND_WRITE_REQUEST = 0x0B,
    COMMAND_WRITE_REPLY = 0x8B
};

@interface LocalModeProtocol : NSObject

// FIXED
- (NSData*) readPacketBody:(NSData*) data error:(NSError **) error;
- (Byte*) readCommond:(NSData *) data;

- (LocalSession*) getSession:(NSData *) bodyData;
- (NSString*) readSalt:(NSData *) bodyData;
- (LocalIntroduce*) readIntroduce:(NSData *) bodyData;


- (NSData*) buildConnectPacket;
- (NSData*) buildChallengeReplyPacket:(NSString *) salt apiKey:(NSString *) key;
- (NSData*) buildIntroduceReplyPacket;
- (NSData*) buildPingRequestPacket;
- (NSData*) buildPingReplyPacket;


- (void) showByteData:(NSData*) data;

// TO CHECK

@end
