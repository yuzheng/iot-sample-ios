//
//  GlobalData.m
//  iotapp
//
//  Created by chttl on 2016/12/20.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "GlobalData.h"

#define IOT_KEY @"IOT_KEY"

@implementation GlobalData


static GlobalData *sharedGlobalData = nil;

+(GlobalData*) sharedGlobalData {
    if(sharedGlobalData == nil)
    {
        sharedGlobalData = [[super allocWithZone:NULL] init];
        //initialize ubi-api
        
    }
    return sharedGlobalData;
}

+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self)
    {
        if(sharedGlobalData == nil)
        {
            sharedGlobalData = [super allocWithZone:zone];
            return sharedGlobalData;
        }
    }
    return nil;
}

-(id)copyWithZone:(NSZone *)zone{
    return self;
}

-(NSString*) fetchIoTKey {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([userDefaults stringForKey:IOT_KEY] == NULL) {
        return nil;
    }else{
        apiKey = [userDefaults stringForKey:IOT_KEY];
        return apiKey;
    }
}

@end
