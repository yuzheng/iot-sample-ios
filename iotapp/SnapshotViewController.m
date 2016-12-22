//
//  SnapshotViewController.m
//  firstapp
//
//  Created by chttl on 2016/6/26.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "SnapshotViewController.h"

#define SNAPSHOT_SENSOR @"ssss"
#define SNAPSHOT_DEVICE @"271290572"

@interface SnapshotViewController ()

@end

@implementation SnapshotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    iDeviceId = SNAPSHOT_DEVICE;
    if(self.device != nil){
        iDeviceId = self.device.id;
    }
    iSensorId = SNAPSHOT_SENSOR;
    if(self.sensor != nil){
        iSensorId = self.sensor.id;
    }
    
    NSLog(@"Snapshot device: %@ - %@",iDeviceId, iSensorId);
    
    client = [[OpenRESTfulClient alloc] init];
    [client setupApiKey:self.apiKey];
    save = true;
    
    [self initSnapshot];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) initSnapshot {
    [self getSnapshot:nil withSensor:iSensorId withDevice:iDeviceId ];
}

- (void) getSnapshot:(NSString*) snapshotId withSensor:(NSString*) sensorId withDevice:(NSString*) deviceId
{
    if(snapshotId == nil){
        /*
         [client getSnapshotBodyWithSensor:sensorId withDevice:deviceId completion:^(UIImage *image, NSError *error) {
            NSLog(@"getSnapshot");
            self.SnapshotImageView.image = image;
        }];
         */
        [client getSnapshotBodyWithSensor:sensorId withDevice:deviceId delegate:self];
    }else{
        /*
        [client getSnapshotBody:snapshotId withSensor:sensorId withDevice:deviceId completion:^(UIImage *image, NSError *error) {
            NSLog(@"getSnapshot:%@",snapshotId);
            self.SnapshotImageView.image = image;
        }];
         */
        [client getSnapshotBody:snapshotId withSensor:sensorId withDevice:deviceId delegate:self];
    }
}

- (IBAction)takePicture:(id)sender {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined) {
        //建立一個ImagePickerController
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        // 設置 delegate
        imagePicker.delegate = self;
        
        // 設定影像來源 這裡設定為相機
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        //imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        
        
        
        // 設置拍照完後 可以編輯 會多一個編輯照片的步驟
        imagePicker.allowsEditing = YES;
        
        [imagePicker view];
        [imagePicker setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        
        // 顯示相機功能
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"無法存取相機" message:@"請至 設定>隱私權 中開啟權限" preferredStyle:UIAlertControllerStyleAlert];
        
        // 確定按鈕
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)onSaveChanged:(id)sender {
    if([sender isOn]){
        NSLog(@"Switch is ON");
        save = true;
    } else{
        NSLog(@"Switch is OFF");
        save = false;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // 取得編輯後的圖片 UIImage
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    if (img == nil) {
        // 如果沒有編輯 則是取得原始拍照的照片 UIImage
        img = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    // 再來就是對圖片的處理 img 是一個 UIImage
    self.SnapshotImageView.image = img;
    
    [self uploadImage];
    //移除Picker
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) uploadImage {
    [self.activityIndicatorView startAnimating];
    
    NSString *strSave = @"true";
    if(!save){
        strSave = @"false";
    }
    
    NSString *body = [NSString stringWithFormat:@"{\"id\":\"%@\",\"value\":[\"iphone image\"],\"save\":\"%i\"}",iSensorId, save];
    IRawdata *meta = [IRawdata fromJSONString:body];
    
    [client saveSnapshot:self.SnapshotImageView.image withMeta:meta withDevice:iDeviceId delegate:self];
}

#pragma mark - delegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"didFinishDownloadingToURL %@", [location absoluteString]);
    //self.SnapshotImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self.progressView setHidden:YES];
        [self.SnapshotImageView setImage:[UIImage imageWithData:data]];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"start download...");
    
    if(totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown){
        NSLog(@"Header of Content-Length was not provided");
    }else{
        NSLog(@"%f, %f",(float)totalBytesWritten,(float)totalBytesExpectedToWrite);
        double currentProgress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%f",currentProgress);
        });

    }
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    NSLog(@"start upload...");
    NSLog(@"%f, %f",(float)totalBytesSent,(float)totalBytesExpectedToSend);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error == nil) { // Success
        NSLog(@"URL Session Task Succeeded: HTTP %ld", (long)((NSHTTPURLResponse*)[task response]).statusCode);
    } else { // Failure
        NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView stopAnimating];
    });
}

@end
