//
//  ViewController.m
//  iotapp
//
//  Created by chttl on 2016/8/19.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "ViewController.h"
#import "DeviceTableViewCell.h"
#import "ControllerClient.h"
#import "ControllerClientBuilder.h"

@interface ViewController () <ControllerClientBuilderDelegate, ControllerClientDelegate>

@property (nonatomic, strong, readonly) ControllerClientBuilder *udpConnection;
@property (nonatomic, strong, readonly) ControllerClient *udpCotroller;
//@property (nonatomic, strong, readonly) ControllerClient *client;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.localDevicesTableView.dataSource = self;
    self.localDevicesTableView.delegate = self;
    
    // set projectKey, device, sensor
    projectKey = @"PKY9H2EBYMRF9RST2R"; //@"DKRHF4KM29RXM27X3M";
    
    // set my device info
    deviceId = @"693590269"; //@"799538117";
    sensorIds = @[@"sensor01"]; //@[@"led"];
    
    [self startClient];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) startClient {
    // initial the sessions of discover controllers
    sessions = [[NSMutableArray alloc] init];
    
    _udpConnection = [[ControllerClientBuilder alloc] init];
    _udpConnection.delegate = self;
    [_udpConnection setupAnnouncementSocket:10400];
}

- (Boolean) existsSession:(LocalSession*) session {
    for(LocalSession* msession in sessions){
        if([msession isEqual:session]){
            return true;
        }
    }
    return false;
}

#pragma mark -
#pragma mark ControllerClientBuilderDelegate

- (void)findController:(LocalSession*) session{
    NSLog(@"findController: %@/%@/%@/%@",session.vendor, session.model, session.series, session.name);
    //[_udpConnection closeAnnouncementSocket];
    
    if( ![self existsSession:session] ) {
        NSLog(@" Find new controller!");
        _udpCotroller = [[ControllerClient alloc] init];
        _udpCotroller.delegate = self;
        [_udpCotroller setupSocket:session.port];
        //[_udpCotroller setApiKey:projectKey];
        // just for testing
        deviceId = session.series;
        sensorIds = @[session.name];
        [_udpCotroller setApiKey:session.model];
        // just for testing
        [_udpCotroller linkController:session];
        
        [sessions addObject:session];
        
        [self.localDevicesTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}

#pragma mark -
#pragma mark ControllerClientDelegate
//連接成功
- (void) didConnectToController {
    NSLog(@"Connect to controller : success");
}
//連接失敗的代理
- (void) didDisconnectWithError:(NSError *)error {
    NSLog(@" >.< Disconnect to controller : %@", error);
}

//- (void)didReceivedWriteData:(NSString *) rDeviceId sensor:(NSString*) rSensorId value:(NSArray*) value {
- (void)didReceivedData:(IRawdata *) data {
    NSLog(@" Received Data: %@ / %@", data.deviceId, data.id);
    
}

#pragma mark -
#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sessions count];
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
    
    NSString *cellIdentifier = @"deviceCell";
    
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell initSessionCell: sessions[index]];
    cell.tag = index;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Push to TripInfoViewController;
    selectedTag = [tableView cellForRowAtIndexPath:indexPath].tag;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
    if([sessions count]>0){
        [self performSegueWithIdentifier:@"deviceSegue" sender:self];
    }
     */
}

#pragma mark -
#pragma mark action handle

- (IBAction)onSwitchChanged:(UISwitch* ) switchState {
    NSLog(@"on switch changed");
    
    NSArray* values = @[@"0"];
    if ([switchState isOn]) {
        values = @[@"1"];
    } else {
        values = @[@"0"];
    }
    [_udpCotroller writeDevice:deviceId sensor:sensorIds[0] value:values];
}

- (IBAction)onRefreshClick:(id)sender {
    NSLog(@"on refresh click");
    [_udpCotroller readDevice:deviceId sensor:sensorIds[0]];
}

#pragma mark - 
#pragma mark jsut for testing

- (IBAction)onGo:(id)sender {
    [self performSegueWithIdentifier:@"segueConfigureProject" sender:self];
}

// unwind segue 返回ViewController使用
// https://spin.atomicobject.com/2014/10/25/ios-unwind-segues/
// https://spin.atomicobject.com/2015/03/03/ios-unwind-segue-custom-animation/
- (IBAction )unwind:(UIStoryboardSegue *)segue {
    NSLog(@"unwind");
    if( [[segue identifier] isEqualToString:@"unwindConfigureProject"] ) {
        // ...
    }
}

@end