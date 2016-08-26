//
//  DeviceTableViewCell.m
//  firstapp
//
//  Created by chttl on 2016/6/27.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "DeviceTableViewCell.h"

@implementation DeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) initCell:(IDevice*) device {
    self.deviceNameLabel.text = device.name;
    self.deviceDescLabel.text = device.desc;
}

-(void) initSessionCell:(LocalSession*) session {
    self.deviceNameLabel.text = [NSString stringWithFormat:@"Local-%@",session.series];
    self.deviceDescLabel.text = [NSString stringWithFormat:@"%@/%@/%@/%@",session.vendor,session.model,session.series,session.name];
}

@end
