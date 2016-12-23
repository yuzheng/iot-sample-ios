//
//  RegistryViewController.m
//  iotapp
//
//  Created by chttl on 2016/12/20.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "RegistryViewController.h"
#import "ViewController.h"

#import "SWRevealViewController.h"

#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"

#define IOT_KEY @"IOT_KEY"

@interface RegistryViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@end

@implementation RegistryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDeleage = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [self customSetup];
    
    if([self checkIoTKey]){
        client = [[OpenRESTfulClient alloc] init];
        [client setupApiKey:apiKey];
    }
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) checkIoTKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([userDefaults stringForKey:IOT_KEY] == NULL) {
        //Error
        [self showAlertTitle:@"Error" message:@"您尚未設定IoT Key!" handler:^(UIAlertAction * action) {
            [appDeleage backHome];
        }];
        return false;
    }else{
        apiKey = [userDefaults stringForKey:IOT_KEY];
    }
    
    if(apiKey.length == 0){
        //Error
        [self showAlertTitle:@"Error" message:@"您尚未設定IoT Key!" handler:^(UIAlertAction * action) {
            [appDeleage backHome];
        }];
        return false;
    }
    
    return true;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)touchQRCode:(id)sender {
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

- (IBAction)touchInput:(id)sender {
    [self.inputRegistryView setHidden:FALSE];
}

- (IBAction)touchRegistry:(id)sender {
    
    NSString* sn = self.snTextField.text;
    NSString* digest = self.digestTextField.text;
    
    if(sn.length > 0 && digest.length > 0) {
        // call RESTful registry api
        [client reconfigureData:sn withDigest:digest completion:^(long status, NSData* data, NSError *error) {
            NSLog(@"status %ld", status);
            NSLog(@"data:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            if(status == 200){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [appDeleage showDevices];
                });
            }
        }];
        
    }else{
        [self showAlertTitle:@"Error" message:@"產品序號(SN)與驗證簽章(Digest)為必填欄位！" handler:nil];
    }
}

- (void) handleRegistryQRCode:(NSString*) code {
    if(code != NULL && code.length > 0){
        NSArray* arrayOfStrings = [code componentsSeparatedByString:@";"];
        if([arrayOfStrings count]!=2){
            //error
            [self showAlertTitle:@"Error" message:@"QR Code內容不符合IoT設備納管格式！" handler:nil];
        }else{
            for(NSString* str in arrayOfStrings) {
                NSArray* dataOfStrings = [str componentsSeparatedByString:@":"];
                if([dataOfStrings count]==2){
                    if([dataOfStrings[0] isEqualToString:@"sn"]){
                        self.snTextField.text = dataOfStrings[1];
                    }else if([dataOfStrings[0] isEqualToString:@"digest"]){
                        self.digestTextField.text = dataOfStrings[1];
                    }
                }else{
                    [self showAlertTitle:@"Error" message:@"QR Code內容不符合IoT設備納管格式！" handler:nil];
                    break;
                }
            }
        }
        
        [self.inputRegistryView setHidden:FALSE];
    }
}

#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [reader stopScanning];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self handleRegistryQRCode:result];
        
        /*
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"QR Code掃描結果"
                                                                       message:result
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action= [UIAlertAction actionWithTitle:@"確定"
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * action) {
                                                          
                                                          [self handleRegistryQRCode:result];
                                                          
                                                      }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        */
        
        
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark

- (void) showAlertTitle:(NSString* ) title message:(NSString*) message handler:(void (^ __nullable)(UIAlertAction *action))handler
{
    dispatch_queue_t q = dispatch_get_main_queue();
    dispatch_async(q, ^{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action= [UIAlertAction actionWithTitle:@"確定"
                                                        style:UIAlertActionStyleDestructive
                                                      handler:handler];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    });
}


@end
