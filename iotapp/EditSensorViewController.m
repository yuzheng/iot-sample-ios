//
//  EditSensorViewController.m
//  iotapp
//
//  Created by chttl on 2016/12/27.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "EditSensorViewController.h"
#import "AttributeTableViewCell.h"
#import "OpenRESTfulClient.h"
#import "GlobalData.h"

@interface EditSensorViewController ()

@end

@implementation EditSensorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    attributesData = [NSMutableArray new];
    
    if(self.sensor != NULL){
        self.navigationItem.title = @"感測器資訊";
        [self initSensor];
    }else{
        self.navigationItem.title = @"新增感測器";
    }
    
    self.idTextField.delegate = self;
    self.nameTextField.delegate = self;
    self.descTextField.delegate = self;
    
    self.attributesTableView.dataSource = self;
    self.attributesTableView.delegate = self;
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSensor)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initSensor
{
    [self.idTextField setEnabled:FALSE];
    self.idTextField.text = self.sensor.id;
    self.nameTextField.text = self.sensor.name;
    self.descTextField.text = self.sensor.desc;
    
    [self.typeButton setTitle:self.sensor.type forState:UIControlStateNormal];
    
    if([self.sensor.attributes count] > 0){
        for(IAttribute* attribute in self.sensor.attributes){
            NSLog(@"%@ : %@",attribute.key, attribute.value);
            [attributesData addObject:attribute];
        }
    }else{
        // empty attribute
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

- (void) saveSensor
{
    BOOL isNew = false;
    if(self.sensor == NULL){
        isNew = true;
        self.sensor = [ISensor new];
        self.sensor.id = self.idTextField.text;
    }
    
    self.sensor.name = self.nameTextField.text;
    self.sensor.desc = self.descTextField.text;
    
    self.sensor.type = self.typeButton.titleLabel.text;
    
    //attributes
    self.sensor.attributes = attributesData;
    
    if( [[GlobalData sharedGlobalData] checkValue:self.sensor.name] ) {
        
        OpenRESTfulClient* client = [[OpenRESTfulClient alloc] init];
        [client setupApiKey:self.apiKey];
        
        if( !isNew ){
            [client modifySensor:self.sensor withDevice:self.device.id completion:^(ISensor *sensor, NSError *error) {
                NSLog(@"modify finish");
                if(error) {
                    [self showAlertTitle:@"更新失敗" message:@"感測器更新失敗" handler:nil];
                }else{
                    [self showAlertTitle:@"更新成功" message:@"感測器更新成功" handler:nil];
                }
            }];
        }else{
            //check id format
            NSString *sensorIdRegex = @"[A-Z0-9a-z_]*";
            NSPredicate *sensorIdTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", sensorIdRegex];
            
            if([sensorIdTest evaluateWithObject:self.sensor.id]){
                [client saveSensor:self.sensor withDevice:self.device.id completion:^(ISensor *sensor, NSError *error) {
                    NSLog(@"save finish");
                    if(error) {
                        [self showAlertTitle:@"新增失敗" message:@"感測器新增失敗" handler:nil];
                    }else{
                        [self showAlertTitle:@"新增成功" message:@"感測器新增成功" handler:^(UIAlertAction * action) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    }
                }];
            }else{
                [self showAlertTitle:@"感測器識別編號格式錯誤" message:@"感測器識別編號只接受a-zA-Z0-9與2底線符號_！" handler:nil];
            }
        }
        
    }else{
        NSLog(@">< %@",self.sensor.name);
        [self showAlertTitle:@"缺少設備欄位資料" message:@"必須填寫設備名稱欄位資料！" handler:nil];
    }
}

- (IBAction)touchType:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"感測器類別"
                                                                   message:@"請選擇底下任一感測器類別"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* gaugeAction= [UIAlertAction actionWithTitle:@"gauge"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   [self setSensorType:@"gauge"];
                                               }];
    UIAlertAction* counterAction= [UIAlertAction actionWithTitle:@"counter"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                     [self setSensorType:@"counter"];
                                                 }];
    UIAlertAction* switchAction= [UIAlertAction actionWithTitle:@"switch"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self setSensorType:@"switch"];
                                                   }];
    UIAlertAction* snapshotAction= [UIAlertAction actionWithTitle:@"snapshot"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [self setSensorType:@"snapshot"];
                                                        }];
    UIAlertAction* textAction= [UIAlertAction actionWithTitle:@"text"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [self setSensorType:@"text"];
                                                          }];

    [alert addAction:gaugeAction];
    [alert addAction:counterAction];
    [alert addAction:switchAction];
    [alert addAction:snapshotAction];
    [alert addAction:textAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) setSensorType:(NSString *) type
{
    self.sensor.type = type;
    [self.typeButton setTitle:type forState:UIControlStateNormal];
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

// touch outside textfiled to hide keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
@end
