
//
//  MyDevicesViewController.m
//  iotapp
//
//  Created by chttl on 2016/12/20.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "MyDevicesViewController.h"
#import "DeviceViewController.h"
#import "DeviceTableViewCell.h"
#import "SWRevealViewController.h"

#define IOT_KEY @"IOT_KEY"

@interface MyDevicesViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;

@end

@implementation MyDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDeleage = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // set datasource and delegate
    self.devicesTableView.dataSource = self;
    self.devicesTableView.delegate = self;

    
    [self customSetup];
    
    if([self checkIoTKey]){
        client = [[OpenRESTfulClient alloc] init];
        [client setupApiKey:apiKey];
        [self loadDevices];
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
    
    if([[segue identifier] isEqualToString:@"deviceSegue"]){
        DeviceViewController *vc = [segue destinationViewController];
        vc.apiKey = apiKey;
        vc.device = devicesData[selectedTag];
    }
}

- (void) loadDevices {
    [self performSelectorOnMainThread:@selector(getDevices) withObject:nil waitUntilDone:YES];
}

- (void) getDevices
{
    [client getDevices:^(NSArray<IDevice *> *devices, NSError *error) {
        devicesData = [NSMutableArray arrayWithArray:devices];
        /*
         for(IDevice *device in devices){
         NSLog(@"getDevice : device id:%@",device.id);
         NSLog(@"getDevice : device name:%@",device.name);
         }
         */
        [self.devicesTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView stopAnimating];
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"%ld",(long)[devicesData count]);
    return [devicesData count];
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
    [cell initCell:(IDevice*) devicesData[index]];
    cell.tag = index;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Push to TripInfoViewController;
    selectedTag = [tableView cellForRowAtIndexPath:indexPath].tag;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([devicesData count]>0){
        [self performSegueWithIdentifier:@"deviceSegue" sender:self];
    }
}

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
