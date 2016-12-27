//
//  EditDeviceViewController.h
//  iotapp
//
//  Created by chttl on 2016/12/23.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "IDevice.h"
#import "AttributeTableViewCell.h"

@interface EditDeviceViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, AttributeCellDelegate>
{
    MKPointAnnotation* ann;
    NSMutableArray *attributesData;
    
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) NSString* apiKey;
@property (nonatomic, strong) IDevice* device;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descTextField;
@property (weak, nonatomic) IBOutlet UITableView *attributesTableView;
@property (weak, nonatomic) IBOutlet MKMapView *locationMapView;

- (IBAction)touchAdd:(id)sender;
- (IBAction)touchLocate:(id)sender;

@end
