//
//  DeviceViewController.h
//  firstapp
//
//  Created by chttl on 2016/6/27.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SensorTableViewCell.h"
#import "OpenRESTfulClient.h"
#import "OpenMqttClient.h"

@interface DeviceViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,OpenMqttClientDelegate, SensorCellDelegate>
{
    
    OpenRESTfulClient* client;
    OpenMqttClient* mqtt;
    NSMutableArray *sensorsData;
    
    NSInteger selectedTag;
}

@property (nonatomic, strong) NSString* apiKey;
@property (nonatomic, strong) IDevice* device;

@property (weak, nonatomic) IBOutlet UITableView *sensorsTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end
