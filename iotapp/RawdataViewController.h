//
//  RawdataViewController.h
//  iotapp
//
//  Created by chttl on 2016/12/28.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenRESTfulClient.h"
#import "IDevice.h"
#import "ISensor.h"

@interface RawdataViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    OpenRESTfulClient* client;
    
    NSMutableArray* rawdataData;
    
    BOOL save;
}
@property (nonatomic, strong) NSString* apiKey;
@property (nonatomic, strong) IDevice* device;
@property (nonatomic, strong) ISensor* sensor;

@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;

@property (weak, nonatomic) IBOutlet UITableView *rawdataTableView;

@end
