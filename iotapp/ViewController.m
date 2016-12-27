//
//  ViewController.m
//  iotapp
//
//  Created by chttl on 2016/8/19.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "ViewController.h"
#import "SWRevealViewController.h"

#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"

#define IOT_KEY @"IOT_KEY"
#define URL_IOT_HELP @"https://iot.cht.com.tw/iot/doc/api"

@interface ViewController ()

@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //projectKey = @"PKXT2XGTMRFK3T9YXT";
    
    [self customSetup];
    
    [self initialState];
}

- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
}

- (void)initialState {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([userDefaults stringForKey:IOT_KEY] == NULL) {
        NSString *plistPickPath = [[NSBundle mainBundle] pathForResource:@"iot" ofType:@"plist"];
        NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPickPath];
        
        // read plist
        apiKey = [plistDictionary objectForKey:IOT_KEY];
        // set apiKey to userDefault
        [userDefaults setObject:apiKey forKey:IOT_KEY];
        [userDefaults synchronize];
        NSLog(@"iot.plist apiKey:%@",apiKey);
        
    }else{
        apiKey = [userDefaults stringForKey:IOT_KEY];
    }
    
    if(apiKey.length == 0){
        self.initialView.hidden = FALSE;
        
    }else{
        self.initialView.hidden = TRUE;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchHelpOfKey:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_IOT_HELP]];
}

- (IBAction)touchScanCode:(id)sender {
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        static QRCodeReaderViewController *vc = nil;
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            vc                   = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        });
        vc.delegate = self;
        
        [vc setCompletionWithBlock:^(NSString *resultAsString) {
            NSLog(@"Completion with result: %@", resultAsString);
        }];
        
        [self presentViewController:vc animated:YES completion:NULL];
    } else {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"QR Code Error"
                                                                       message:@"目前裝置不支援讀取 QR Code"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action= [UIAlertAction actionWithTitle:@"確定"
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * action) {
                                                          
                                                      }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)touchMyDevices:(id)sender {
    
}

- (IBAction)touchRegistryDevice:(id)sender {
    
}

//
#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [reader stopScanning];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"QR Code掃描結果"
                                                                       message:result
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action= [UIAlertAction actionWithTitle:@"確定"
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * action) {
                                                          NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                                          [userDefaults setObject:result forKey:IOT_KEY];
                                                          [userDefaults synchronize];
                                                          
                                                          [self initialState];
                                                      }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];

        
        
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
