//
//  SensorTableViewCell.h
//  firstapp
//
//  Created by chttl on 2016/6/27.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISensor.h"
#import "IRawdata.h"

@protocol SensorCellDelegate <NSObject>
//@required
@optional
- (void)onRawdata:(IRawdata *) data;

@end

@interface SensorTableViewCell : UITableViewCell
{
    ISensor* sensor;
    IRawdata* rawdata;

}
@property (nonatomic, weak) id<SensorCellDelegate> delegate;

-(void) initCell:(NSDictionary*) dict;

@property (weak, nonatomic) IBOutlet UILabel *sensorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorValueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sensorSnapshot;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) IBOutlet UISwitch *sensorValueSwitch;
- (IBAction)changeSwitch:(id)sender;

@end
