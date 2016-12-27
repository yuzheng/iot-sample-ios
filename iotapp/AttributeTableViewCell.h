//
//  AttributeTableViewCell.h
//  iotapp
//
//  Created by chttl on 2016/12/27.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAttribute.h"

@protocol AttributeCellDelegate <NSObject>
//@required
@optional
- (void) onDeleteAttribute:(NSInteger) index;
- (void) onModifyAttribute:(IAttribute*) attribute index:(NSInteger) index ;

@end

@interface AttributeTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) id<AttributeCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
- (IBAction)touchRemove:(id)sender;

-(void) initCell:(IAttribute*) attribute;

@end
