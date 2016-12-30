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

@end
