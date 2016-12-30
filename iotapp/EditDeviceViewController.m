//
//  EditDeviceViewController.m
//  iotapp
//
//  Created by chttl on 2016/12/23.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "EditDeviceViewController.h"
#import "AttributeTableViewCell.h"
#import "OpenRESTfulClient.h"
#import "GlobalData.h"

@interface EditDeviceViewController ()

@end

@implementation EditDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    attributesData = [NSMutableArray new];
    
    if(self.device != NULL){
        [self initDevice];
        
    }else{
        self.navigationItem.title = @"新增設備";
        self.idLabel.text = [NSString stringWithFormat:@"設備編號：*********"];
    }
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveDevice)];
    
    self.nameTextField.delegate = self;
    self.descTextField.delegate = self;
    //tableview
    self.attributesTableView.dataSource = self;
    self.attributesTableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initDevice
{
    self.navigationItem.title = self.device.name;
    self.idLabel.text = [NSString stringWithFormat:@"設備編號：%@",self.device.id];
    self.nameTextField.text = self.device.name;
    self.descTextField.text = self.device.desc;
    
    NSLog(@"%@,%@",self.device.lat,self.device.lon);
    if(self.device.lat != NULL && self.device.lon != NULL){
        NSLog(@"setDeviceLocation");
        
        [self setDeviceLat:[self.device.lat floatValue] lon:[self.device.lon floatValue]];
    }
    
    if([self.device.attributes count] > 0){
        for(IAttribute* attribute in self.device.attributes){
            NSLog(@"%@ : %@",attribute.key, attribute.value);
            [attributesData addObject:attribute];
        }
    }else{
        // empty attribute
    }
}

- (void) saveDevice
{
    [self.view endEditing:YES];
    NSLog(@"saveDevice");
    if(self.device == NULL) self.device = [IDevice new];
    
    self.device.name = self.nameTextField.text;
    self.device.desc = self.descTextField.text;
    
    self.device.type = @"general"; //Default value
    //attributes
    self.device.attributes = attributesData;
    
    if( [[GlobalData sharedGlobalData] checkValue:self.device.name] ) {
    
        OpenRESTfulClient* client = [[OpenRESTfulClient alloc] init];
        [client setupApiKey:self.apiKey];
        
        if( self.device.id != NULL ){
            [client modifyDevice:self.device completion:^(IDevice *device, NSError *error) {
                NSLog(@"modify finish");
                if(error) {
                    [self showAlertTitle:@"更新失敗" message:@"設備更新失敗" handler:nil];
                }else{
                    [self showAlertTitle:@"更新成功" message:@"設備更新成功" handler:nil];
                }
            }];
        }else{
            [client saveDevice:self.device completion:^(IDevice *device, NSError *error) {
                NSLog(@"save finish");
                if(error) {
                    [self showAlertTitle:@"新增失敗" message:@"設備新增失敗" handler:nil];
                }else{
                    [self showAlertTitle:@"新增成功" message:@"設備新增成功" handler:^(UIAlertAction * action) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
            }];
        }

    }else{
        NSLog(@">< %@",self.device.name);
        [self showAlertTitle:@"缺少設備欄位資料" message:@"必須填寫設備名稱欄位資料！" handler:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// touch outside textfiled to hide keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - locate
- (void) setDeviceLat:(float)lat lon:(float)lon
{
    if(ann != NULL) {
        [self.locationMapView removeAnnotation:ann];
        ann = NULL;
    }
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
    [self.locationMapView setCenterCoordinate:coordinate];
    ann = [MKPointAnnotation new];
    ann.coordinate = coordinate;
    ann.title = self.device.name;
    ann.subtitle = self.device.desc;
    //[self.locationMapView addAnnotation:ann ];
    [self.locationMapView showAnnotations:@[ann] animated:YES];
}

- (IBAction)touchLocate:(id)sender {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"設定位置"
                                                                   message:@"請選擇底下任一方式設定位址"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* gps= [UIAlertAction actionWithTitle:@"GPS定位"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [self gpsLocation];
                                                    }];
    UIAlertAction* custom= [UIAlertAction actionWithTitle:@"手動定位"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                      [self manualLocation];
                                                  }];
    [alert addAction:gps];
    [alert addAction:custom];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void) manualLocation
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"位置設定" message:@"請輸入經緯度座標" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
            //
        }];
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
        NSString *strLat = ((UITextField*)[alertController.textFields objectAtIndex:0]).text;
        NSString *strLon = ((UITextField*)[alertController.textFields objectAtIndex:1]).text;
        if([[GlobalData sharedGlobalData] checkValue:strLat] && [[GlobalData sharedGlobalData] checkValue:strLon]){
            self.device.lat = [NSNumber numberWithFloat:[strLat floatValue]];
            self.device.lon = [NSNumber numberWithFloat:[strLon floatValue]];
            [self setDeviceLat:[strLat floatValue] lon:[strLon floatValue]];
        }
        
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        if(self.device.lat != NULL){
            textField.text = [self.device.lat stringValue];
        }
        textField.placeholder = @"緯度(Lat)";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        if(self.device.lon != NULL){
            textField.text = [self.device.lon stringValue];
        }
        textField.placeholder = @"經度(Lon)";
    }];
    [alertController addAction:cancelAction];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) gpsLocation
{
    NSLog(@"gpsLocation");
    
    locationManager = [CLLocationManager new];
    if( [CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ){
        NSLog(@"locationServicesEnabled!");

        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [locationManager startUpdatingLocation];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self showAlertTitle:@"定位失敗" message:@"GPS定位服務尚未開啟，請至iPhone設定中開啟定位服務" handler:nil];
    } else {
        [locationManager requestWhenInUseAuthorization];
        NSLog(@"locationServicesEnabled not!");
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"didUpdateLocations");
    CLLocation* location = [locations lastObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    self.device.lat = [NSNumber numberWithDouble:coordinate.latitude];
    self.device.lon = [NSNumber numberWithDouble:coordinate.longitude];
    [self setDeviceLat:coordinate.latitude lon:coordinate.longitude];
    
    [locationManager stopUpdatingLocation];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"%ld",(long)[sensorsData count]);
    return [attributesData count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    NSString *cellIdentifier = @"attributeCell";
    
    //NSLog(@"cellIdentifier:%@",cellIdentifier);
    AttributeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell initCell:attributesData[index]];
    cell.tag = index;
    cell.delegate = self;
    
    return cell;
}

#pragma mark - Attributes
- (IBAction)touchAdd:(id)sender {
    [attributesData addObject:[IAttribute new]];
    [self.attributesTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void) onModifyAttribute:(IAttribute*) attribute index:(NSInteger) index
{
    [attributesData replaceObjectAtIndex:index withObject:attribute];
}

- (void) onDeleteAttribute:(NSInteger) index
{
    NSLog(@"onDeleteAttribute: %ld",index);
    
    IAttribute* delAttribute = [attributesData objectAtIndex:index];
    
    NSString *message = [NSString stringWithFormat:@"確定刪除此筆 %@:%@ 屬性資料？",delAttribute.key,delAttribute.value];
    if( delAttribute.key == NULL ) {
        message = @"確定刪除此筆屬性資料?";
    } else {
        if(delAttribute.value == NULL) {
            message = [NSString stringWithFormat:@"確定刪除此筆 %@: 屬性資料？",delAttribute.key];
        }
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"刪除確認"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* action= [UIAlertAction actionWithTitle:@"確定"
                                                    style:UIAlertActionStyleDestructive
                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                      [attributesData removeObject:delAttribute];
                                                      [self.attributesTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                                                      return;
                            }];
    UIAlertAction* cancel= [UIAlertAction actionWithTitle:@"取消"
                                                    style:UIAlertActionStyleCancel
                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                      //
                                                  }];
    [alert addAction:action];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
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
