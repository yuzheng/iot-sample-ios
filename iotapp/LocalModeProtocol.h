//
//  LocalModeProtocol.h
//  iotapp
//
//  Created by chttl on 2016/8/22.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"

@interface LocalModeProtocol : NSObject

- (Byte*) readPacketBody:(NSData*) data;
- (NSData*) buildConnectPacket;

- (Byte*) getCommond:(NSData *) data;
- (NSString*) readString:(NSData*) data;

- (Session*) getSession:(NSData *) bodyData;

- (NSData*) getBodyData:(NSData *) data;
- (void) showByteData:(NSData*) data;
@end
