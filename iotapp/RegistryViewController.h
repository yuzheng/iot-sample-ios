//
//  RegistryViewController.h
//  iotapp
//
//  Created by chttl on 2016/12/20.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "OpenRESTfulClient.h"
#import "QRCodeReaderDelegate.h"

@interface RegistryViewController : UIViewController<QRCodeReaderDelegate>
{
    AppDelegate *appDeleage;
    
    OpenRESTfulClient* client;
    
    NSString *apiKey;
}

@property (weak, nonatomic) IBOutlet UIView *inputRegistryView;
@property (weak, nonatomic) IBOutlet UITextField *snTextField;
@property (weak, nonatomic) IBOutlet UITextField *digestTextField;
@property (weak, nonatomic) IBOutlet UIButton *registryButton;

- (IBAction)touchQRCode:(id)sender;
- (IBAction)touchInput:(id)sender;
- (IBAction)touchRegistry:(id)sender;


@end
