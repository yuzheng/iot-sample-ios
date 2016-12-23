//
//  DeviceViewController.m
//  firstapp
//
//  Created by chttl on 2016/6/27.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "DeviceViewController.h"

#import "SnapshotViewController.h"

@interface DeviceViewController ()
@property (nonatomic, strong, readonly) OpenMqttClient *mqttClient;
@end

@implementation DeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = self.device.name;
    
    // set datasource and delegate
    self.sensorsTableView.dataSource = self;
    self.sensorsTableView.delegate = self;
    
    mqtt = [[OpenMqttClient alloc] init];
    [mqtt usingTLS:TRUE];
    [mqtt setupApiKey:self.apiKey];
    mqtt.delegate = self;
    [mqtt doConnect];
    
    client = [[OpenRESTfulClient alloc] init];
    [client setupApiKey:self.apiKey];
    [self loadSensors];
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
            [mqtt subscribeDevice:self.device.id sensor:sensor.id];
            
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
        }
    }
}


@end
