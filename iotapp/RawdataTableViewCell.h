//
//  SnapshotTableViewCell.h
//  iotapp
//
//  Created by chttl on 2016/12/28.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRawdata.h"


@interface RawdataTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *snapshotLabel;

-(void) initCell:(IRawdata*) rawdata;

@end
