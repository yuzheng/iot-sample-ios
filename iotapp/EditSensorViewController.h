//
//  EditSensorViewController.h
//  iotapp
//
//  Created by chttl on 2016/12/27.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IDevice.h"
#import "ISensor.h"
#import "AttributeTableViewCell.h"

@interface EditSensorViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AttributeCellDelegate>
{
    NSMutableArray *attributesData;
}
@property (nonatomic, strong) NSString* apiKey;
@property (nonatomic, strong) IDevice* device;
@property (nonatomic, strong) ISensor* sensor;

@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descTextField;
@property (weak, nonatomic) IBOutlet UIButton *typeButton;

@property (weak, nonatomic) IBOutlet UITableView *attributesTableView;

- (IBAction)touchType:(id)sender;
- (IBAction)touchAdd:(id)sender;

@end
