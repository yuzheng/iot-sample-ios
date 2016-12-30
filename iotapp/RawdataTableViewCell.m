
//
//  SnapshotTableViewCell.m
//  iotapp
//
//  Created by chttl on 2016/12/28.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "RawdataTableViewCell.h"

@implementation RawdataTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initCell:(IRawdata *)rawdata
{
    self.dateLabel.text = rawdata.time;
    self.snapshotLabel.text = rawdata.value[0];
    
}

@end
