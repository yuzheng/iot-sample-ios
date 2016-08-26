//
//  DeviceTableViewCell.h
//  firstapp
//
//  Created by chttl on 2016/6/27.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDevice.h"
#import "LocalSession.h"

@interface DeviceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceDescLabel;

-(void) initCell:(IDevice*) device;
-(void) initSessionCell:(LocalSession*) session;

@end
