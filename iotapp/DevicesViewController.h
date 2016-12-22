//
//  DevicesViewController.h
//  iotapp
//
//  Created by chttl on 2016/12/16.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalSession.h"
#import "GCDAsyncUdpSocket.h"

@interface DevicesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray<LocalSession*> *sessions;
    
    NSString *projectKey;
    NSString *deviceId;
    NSArray *sensorIds;
    
    NSInteger selectedTag;
    
}
@property (weak, nonatomic) IBOutlet UITableView *localDevicesTableView;

@property (weak, nonatomic) IBOutlet UIView *deviceView;
@property (weak, nonatomic) IBOutlet UISwitch *sensorSwitch;
- (IBAction)onSwitchChanged:(id)sender;
- (IBAction)onRefreshClick:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *btnGo;
- (IBAction)onGo:(id)sender;

@end
