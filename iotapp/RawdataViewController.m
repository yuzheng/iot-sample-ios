//
//  RawdataViewController.m
//  iotapp
//
//  Created by chttl on 2016/12/28.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "RawdataViewController.h"
#import "RawdataTableViewCell.h"
#import "GlobalData.h"

@interface RawdataViewController ()
@property (nonatomic, strong, readonly) OpenMqttClient *mqtt;
@end

@implementation RawdataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = self.sensor.name;
    
    self.rawdataTableView.dataSource = self;
    self.rawdataTableView.delegate = self;
    
    client = [[OpenRESTfulClient alloc] init];
    [client setupApiKey:self.apiKey];
    save = true;
    
    [self initSensorRawdata];
    
    showChartLine = FALSE;
    if([self.sensor.type isEqualToString:@"gauge"]){
        
        CGRect frame = self.rawdataTableView.frame;
        frame.size.height = frame.size.height - self.lineChartView.frame.size.height;
        [self.rawdataTableView setFrame:frame];
        
        self.lineChartView.dataSource = self;
        self.lineChartView.delegate = self;
        [self.lineChartView setFooterPadding:10.0f];
        [self.lineChartView setHeaderPadding:80.0f];
        [self.lineChartView setShowsVerticalSelection:TRUE];
        
        showChartLine = TRUE;
    }else{
        [self.lineChartView setHidden:TRUE];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    if(_mqtt == NULL){
        _mqtt = [[OpenMqttClient alloc] init];
        [_mqtt usingTLS:TRUE];
        [_mqtt setupApiKey:self.apiKey];
        _mqtt.delegate = self;
        [_mqtt doConnect];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if(_mqtt){
        [_mqtt stop];
        _mqtt = NULL;
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

- (void) initSensorRawdata
{
    
    rawdataData = [NSMutableArray new];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];
    
    NSDate *endDate = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    //comps.month = -1;
    comps.day   = -7;
    NSDate *startDate = [calendar dateByAddingComponents:comps toDate:endDate options:0];
    
    self.startDateLabel.text = [[GlobalData sharedGlobalData] utcDate:startDate];
    self.endDateLabel.text = [[GlobalData sharedGlobalData] utcDate:endDate];
    [client getRawdataWithSensor:self.sensor.id withDevice:self.device.id withStart:[[GlobalData sharedGlobalData] utcDate:startDate] withEnd:[[GlobalData sharedGlobalData] utcDate:endDate] withInterval:nil completion:^(NSArray<IRawdata *> *rawdatas, NSError *error) {
        NSLog(@"rawdatas: %lu",(unsigned long)[rawdatas count]);
        
        NSArray* reverseRawdatas = [[rawdatas reverseObjectEnumerator] allObjects];
        
        for(IRawdata *rawdata in reverseRawdatas){
            [rawdataData addObject:rawdata];
        }
        
        [self.rawdataTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        
        
        if(showChartLine) {
            [self.lineChartView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }
        
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
    NSLog(@"%lu",(long) [rawdataData count]);
    return [rawdataData count];
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
    
    NSString *cellIdentifier = @"rawdataCell";
    
    //NSLog(@"cellIdentifier:%@",cellIdentifier);
    RawdataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell initCell:rawdataData[index]];
    cell.tag = index;
    //cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -
#pragma mark OpenMqttClientDelegate
- (void)didConnected {
    NSLog(@"ViewController: mqtt is connected");
    //subscribe topic
    [_mqtt subscribeDevice:self.device.id sensor:self.sensor.id];
}

- (void)didConnectClosed {
    NSLog(@"ViewController: mqtt is connect closed");
}

- (void)onRawdata:(NSString *)topic data:(IRawdata *)data {
    NSLog(@"ViewController: onRawdata: %@: %@ %@" ,topic, data.id, [data.value componentsJoinedByString:@","]);
    IRawdata *lastRawdata = NULL;
    if([rawdataData count] > 0 ){
        lastRawdata = [rawdataData objectAtIndex:0];
    }
    if(lastRawdata == NULL || (![data.time isEqual:lastRawdata.time] && ![data.value isEqual:lastRawdata.value] )){
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:rawdataData];
        [rawdataData removeAllObjects];
        [rawdataData addObject:data];
        [rawdataData addObjectsFromArray:tempArray];
        
        [self.rawdataTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        
        if(showChartLine) {
            [self.lineChartView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }
    }
    
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView stopAnimating];
    });
     */
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

#pragma mark - JBLineChart
- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return 1; // number of lines in chart
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return [rawdataData count]; // number of values for a line
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    
    IRawdata *rawdata = [rawdataData objectAtIndex:([rawdataData count] - horizontalIndex - 1)];
    return [rawdata.value[0] floatValue];
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return false;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return [UIColor whiteColor];
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    NSLog(@"didSelectLineAtIndex: %lu",(unsigned long)horizontalIndex);
    IRawdata *rawdata = [rawdataData objectAtIndex:([rawdataData count] - horizontalIndex - 1)];
    self.chartTimeLabel.text = rawdata.time;
    self.chartValueLabel.text = rawdata.value[0];
}


@end
