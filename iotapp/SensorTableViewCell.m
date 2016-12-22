//
//  SensorTableViewCell.m
//  firstapp
//
//  Created by chttl on 2016/6/27.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "SensorTableViewCell.h"

@implementation SensorTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) initCell:(NSDictionary*) dict {
    sensor = (ISensor*)[dict objectForKey:@"sensor"];
    rawdata = (IRawdata*)[dict objectForKey:@"rawdata"];
    //NSLog(@"sensor type:%@",sensor.type);
    
    // set sensor name
    self.sensorNameLabel.text = sensor.name;
    
    // set sensor value
    NSString* value = @"";
    if([rawdata.value isKindOfClass:[NSArray class]]){
        if([(NSArray*) rawdata.value count] > 0){
            value = rawdata.value[0];
        }
    }else if([rawdata.value isKindOfClass:[NSDictionary class]]){
        //is dictionary
    }else{
        //is something else
    }
    //NSLog(@"sensor value:%@",value);
    if([sensor.type isEqualToString:@"switch"]){
        
        
        if([value isEqualToString:@"1"] || [value isEqualToString:@"T"] || [value isEqualToString:@"Y"] ){
            [self.sensorValueSwitch setOn:TRUE];
        }else{
            [self.sensorValueSwitch setOn:FALSE];
        }
        
    }else if([sensor.type isEqualToString:@"snapshot"]){
        
        
    }else{
       
       
        self.sensorValueLabel.text = value;
    }
}

- (IBAction)changeSwitch:(UISwitch*)sender {
    NSLog(@"sensor id:%@",sensor.id);
    if(sender.isOn){
        [rawdata setValue:@"1"];
    }else{
        [rawdata setValue:@"0"];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRawdata:)])
    {
        NSLog(@"call delegate");
        [self.delegate onRawdata:rawdata];
    }

}


@end
