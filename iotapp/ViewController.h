//
//  ViewController.h
//  iotapp
//
//  Created by chttl on 2016/8/19.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalSession.h"
#import "GCDAsyncUdpSocket.h"

@interface ViewController : UIViewController
{
    NSMutableArray<LocalSession*> *sessions;
}



@property (weak, nonatomic) IBOutlet UIButton *btnGo;
- (IBAction)onGo:(id)sender;

@end

