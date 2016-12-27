//
//  MyDevicesViewController.h
//  iotapp
//
//  Created by chttl on 2016/12/20.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OpenRESTfulClient.h"

#import "AppDelegate.h"

@interface MyDevicesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    AppDelegate *appDeleage;
    
    NSString *apiKey;
    
    OpenRESTfulClient* client;
    NSMutableArray *devicesData;
    NSInteger selectedTag;
}

@property (weak, nonatomic) IBOutlet UITableView *devicesTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

- (IBAction)addAction:(id)sender;

@end
