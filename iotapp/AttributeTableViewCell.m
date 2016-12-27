//
//  AttributeTableViewCell.m
//  iotapp
//
//  Created by chttl on 2016/12/27.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "AttributeTableViewCell.h"

@implementation AttributeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) initCell:(IAttribute*) attribute
{
    self.keyTextField.delegate = self;
    self.valueTextField.delegate = self;
    self.keyTextField.text = attribute.key;
    self.valueTextField.text = attribute.value;
}

- (IBAction)touchRemove:(id)sender {
    NSLog(@"call delegate %ld",self.tag);
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDeleteAttribute:)])
    {
        [self.delegate onDeleteAttribute:self.tag];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"textFieldShouldEndEditing: %@",textField.text);
    if (self.delegate && [self.delegate respondsToSelector:@selector(onModifyAttribute:index:)])
    {
        IAttribute *attribute = [IAttribute new];
        attribute.key = self.keyTextField.text;
        attribute.value = self.valueTextField.text;
        [self.delegate onModifyAttribute:attribute index:self.tag];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
