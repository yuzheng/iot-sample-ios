//
//  DeviceViewController.m
//  firstapp
//
//  Created by chttl on 2016/6/27.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "DeviceViewController.h"
#import "SnapshotViewController.h"
#import "RawdataViewController.h"
#import "EditSensorViewController.h"

#import "GlobalData.h"

@interface DeviceViewController ()
@property (nonatomic, strong, readonly) OpenMqttClient *mqtt;
@end

@implementation DeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = self.device.name;
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSensor)];
    
    // set datasource and delegate
    self.sensorsTableView.dataSource = self;
    self.sensorsTableView.delegate = self;
}

- (void) viewDidAppear:(BOOL)animated
{
    if(_mqtt == NULL){
        _mqtt = [[OpenMqttClient alloc] init];
        [_mqtt usingTLS:TRUE];
        [_mqtt setupApiKey:self.apiKey];
        _mqtt.delegate = self;
        [_mqtt doConnect];
        
        client = [[OpenRESTfulClient alloc] init];
        [client setupApiKey:self.apiKey];
        [self loadSensors];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if(_mqtt){
        [_mqtt stop];
        _mqtt = NULL;
    }
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([[segue identifier] isEqualToString:@"sensorSnapshotSegue"]){
        SnapshotViewController *vc = [segue destinationViewController];
        vc.device = self.device;
        vc.apiKey = self.apiKey;
        vc.sensor = [sensorsData[selectedTag] objectForKey:@"sensor"];
    }else if([[segue identifier] isEqualToString:@"sensorRawdataSegue"]){
        RawdataViewController *rc = [segue destinationViewController];
        rc.device = self.device;
        rc.apiKey = self.apiKey;
        rc.sensor = [sensorsData[selectedTag] objectForKey:@"sensor"];
    }else if([[segue identifier] isEqualToString:@"editSensorSegue"]) {
        EditSensorViewController *ec = [segue destinationViewController];
        ec.apiKey = self.apiKey;
        ec.device = self.device;
        if(selectedTag == -1){
            ec.sensor = NULL;
        }else{
            NSDictionary *dictSensor = [sensorsData objectAtIndex:selectedTag];
            ec.sensor = [dictSensor objectForKey:@"sensor"];
        }
    }
}

- (void) loadSensors {
    NSLog(@"loadSensors: %@", self.device.name);
    [self performSelectorOnMainThread:@selector(getSensorsWithDevice:) withObject:self.device.id waitUntilDone:YES];
}

- (void) getSensorsWithDevice:(NSString*) deviceId
{
    [client getSensorsWithDevice:deviceId completion:^(NSArray<ISensor *> *sensors, NSError *error) {
        //sensorsData = [NSMutableArray arrayWithArray:sensors];
        sensorsData = [NSMutableArray new];
        for(ISensor *sensor in sensors){
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:sensor forKey:@"sensor"];
            NSLog(@"getSensor : sensor id:%@",sensor.id);
            NSLog(@"getSensor : sensor name:%@",sensor.name);
            
            //MQTT Subscribe
            [_mqtt subscribeDevice:self.device.id sensor:sensor.id];
            
            [client getRawdataWithSensor:sensor.id withDevice:self.device.id completion:^(IRawdata *rawdata, NSError *error) {
                NSLog(@"getSensor : rawdata time:%@",rawdata.time);
                NSLog(@"getSensor : rawdata value:%@",[rawdata.value toJSONString]);
                [dict setObject:rawdata forKey:@"rawdata"];
                [sensorsData addObject:dict];
                NSLog(@"count:%ld",(long)[sensorsData count]);
                
                [self.sensorsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                
            }];
        }
    }];
}

- (void) addSensor
{
    selectedTag = -1;
    [self performSegueWithIdentifier:@"editSensorSegue" sender:self];
}

#pragma mark -
#pragma mark OpenMqttClientDelegate
- (void)didConnected {
    NSLog(@"ViewController: mqtt is connected");
}

- (void)didConnectClosed {
    NSLog(@"ViewController: mqtt is connect closed");
}

- (void)onRawdata:(NSString *)topic data:(IRawdata *)data {
    NSLog(@"ViewController: onRawdata: %@: %@ %@" ,topic, data.id, [data.value componentsJoinedByString:@","]);
    for(NSDictionary *dict in sensorsData){
        ISensor* sensor = (ISensor*)[dict objectForKey:@"sensor"];
        //NSLog(@"%@:%@",sensor.id,data.id);
        if([sensor.id isEqualToString:data.id]){
            [dict setValue:data forKey:@"rawdata"];
            break;
        }
    }
    [self.sensorsTableView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView stopAnimating];
    });
}

- (void)onHeartBeat:(NSString *)topic data:(IHeartbeat *)data {
    NSLog(@"ViewController: onHeartBeat: %@: %@",topic, data.type);
}

- (void) onReconfigure:(NSString *)topic data:(IProvision *)data {
    NSLog(@"ViewController: onReconfigure: %@: %@ %@ %@",topic, data.op, data.ck, data.deviceId);
}

- (void)onSetDeviceId:(NSString *)topic data:(IProvision *)data {
    NSLog(@"ViewController: onSetDeviceId: %@: %@ %@ %@",topic, data.op, data.ck, data.deviceId);
}

#pragma mark -
#pragma mark SensorCellDelegate
- (void)onRawdata:(IRawdata *)data
{
    NSLog(@"SensorCellDelegate Delegate onRawdata change value: %@", data.value);
    [client saveRawdataWithSensor:data.id withDevice:self.device.id withSingleValue:data.value completion:^(long status, NSError *error) {
        NSLog(@"status: %ld",status);
    }];
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
    return [sensorsData count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    NSString *cellIdentifier = @"sensorCell";
    ISensor* sensor = [(NSDictionary*)sensorsData[index] objectForKey:@"sensor"];
    if([sensor.type isEqualToString:@"switch"]){
        cellIdentifier = @"switchCell";
    }else if([sensor.type isEqualToString:@"snapshot"]){
        cellIdentifier = @"snapshotCell";
    }
    //NSLog(@"cellIdentifier:%@",cellIdentifier);
    SensorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell initCell:(NSDictionary*)sensorsData[index]];
    cell.tag = index;
    cell.delegate = self;
    
    if([sensor.type isEqualToString:@"snapshot"]){
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void) {
            //NSLog(@"load snapshot");
            [cell.activityIndicatorView setHidden:FALSE];
            [cell.activityIndicatorView startAnimating];
            [client getSnapshotBodyWithSensor:sensor.id withDevice:self.device.id completion:^(UIImage *image, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    SensorTableViewCell* cell = (SensorTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                    cell.sensorSnapshot.image = image;
                    cell.sensorSnapshot.hidden = FALSE;
                    [cell.activityIndicatorView stopAnimating];
                });
            }];
        });
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Push to TripInfoViewController;
    selectedTag = [tableView cellForRowAtIndexPath:indexPath].tag;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([sensorsData count]>0){
        ISensor *sensor = [sensorsData[selectedTag] objectForKey:@"sensor"];
        if([sensor.type isEqualToString:@"snapshot"]){
            [self performSegueWithIdentifier:@"sensorSnapshotSegue" sender:self];
        }else{
            [self performSegueWithIdentifier:@"sensorRawdataSegue" sender:self];
        }
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell:%@",[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier);
    UITableViewRowAction *setDataAction = [UITableViewRowAction rowActionWithStyle: UITableViewRowActionStyleNormal title:@"  Set  " handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your setDataAction here
        
        [self setSensorValue:indexPath.row];
        
        
    }];
    setDataAction.backgroundColor = [UIColor colorWithRed:39/255.0 green:209/255.0 blue:51/255.0 alpha:1.0];
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle: UITableViewRowActionStyleNormal title:@" Edit  " handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your editAction here
        
        selectedTag = indexPath.row;
        [self performSegueWithIdentifier:@"editSensorSegue" sender:self];
        
    }];
    editAction.backgroundColor = [UIColor colorWithRed:0/255.0 green:102/255.0 blue:153/255.0 alpha:1.0];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //add deleteAction code here
        
        NSDictionary *dictSensor = [sensorsData objectAtIndex:indexPath.row];
        ISensor* sensor = [dictSensor objectForKey:@"sensor"];
        [client deleteSensor:sensor.id withDevice:self.device.id completion:^(long status, NSError *error) {
            NSLog(@"status:%ld",status);
            if(status == 200){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [sensorsData removeObjectAtIndex:indexPath.row];
                    // 刪除儲存格
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                    return;
                    
                });
            }
        }];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    if([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"sensorCell"]){
        return @[deleteAction,editAction,setDataAction];
    }
    
    return @[deleteAction,editAction];
}

- (void) setSensorValue:(NSInteger) index
{
    NSDictionary *dictSensor = [sensorsData objectAtIndex:index];
    ISensor* sensor = [dictSensor objectForKey:@"sensor"];
    NSString *message = [NSString stringWithFormat:@"變更感測器『%@』數值",sensor.name];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"變更感測器數值" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
            //
        }];
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
        NSString *strVal = ((UITextField*)[alertController.textFields objectAtIndex:0]).text;
        
        if([[GlobalData sharedGlobalData] checkValue:strVal] ){
            [_mqtt saveDevice:self.device.id sensor:sensor.id value:@[strVal]];
        }
        
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"感測器數值";
    }];
    
    [alertController addAction:cancelAction];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}



@end
