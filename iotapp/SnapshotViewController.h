//
//  SnapshotViewController.h
//  firstapp
//
//  Created by chttl on 2016/6/26.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "OpenRESTfulClient.h"

@interface SnapshotViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate>
{
    OpenRESTfulClient* client;
    
    NSString* iDeviceId;
    NSString* iSensorId;
    
    BOOL save;
}

@property (nonatomic, strong) NSString* apiKey;
@property (nonatomic, strong) IDevice* device;
@property (nonatomic, strong) ISensor* sensor;

@property (weak, nonatomic) IBOutlet UIImageView *SnapshotImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UISwitch *saveSwitch;

- (IBAction)takePicture:(id)sender;
- (IBAction)onSaveChanged:(id)sender;

@end
