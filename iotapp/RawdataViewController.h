//
//  RawdataViewController.h
//  iotapp
//
//  Created by chttl on 2016/12/28.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenRESTfulClient.h"
#import "OpenMqttClient.h"
#import "IDevice.h"
#import "ISensor.h"

#import "JBChartView.h"
#import "JBLineChartView.h"

@interface RawdataViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, OpenMqttClientDelegate, JBLineChartViewDelegate, JBLineChartViewDataSource >
{
    OpenRESTfulClient* client;
    
    NSMutableArray* rawdataData;
    
    BOOL save;
    BOOL showChartLine;
}
@property (nonatomic, strong) NSString* apiKey;
@property (nonatomic, strong) IDevice* device;
@property (nonatomic, strong) ISensor* sensor;

@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;

@property (weak, nonatomic) IBOutlet UITableView *rawdataTableView;

@property (weak, nonatomic) IBOutlet JBLineChartView *lineChartView;
@property (weak, nonatomic) IBOutlet UILabel *chartTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *chartValueLabel;


@end
