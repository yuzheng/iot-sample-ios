//
//  ViewController.h
//  iotapp
//
//  Created by chttl on 2016/8/19.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QRCodeReaderDelegate.h"

@interface ViewController : UIViewController<QRCodeReaderDelegate>
{
    NSString *apiKey;
}
@property (weak, nonatomic) IBOutlet UIView *initialView;
- (IBAction)touchHelpOfKey:(id)sender;
- (IBAction)touchScanCode:(id)sender;
- (IBAction)touchMyDevices:(id)sender;
- (IBAction)touchRegistryDevice:(id)sender;

@end
