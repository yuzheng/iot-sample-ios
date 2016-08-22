//
//  ViewController.m
//  iotapp
//
//  Created by chttl on 2016/8/19.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "ViewController.h"
#import "ControllerClientBuilder.h"

@interface ViewController () <ControllerClientBuilderDelegate>

@property (nonatomic, strong, readonly) ControllerClientBuilder *udpConnection;
//@property (nonatomic, strong, readonly) ControllerClient *client;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self testClient];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) testClient {
    NSLog(@"testClient");
    
    _udpConnection = [[ControllerClientBuilder alloc] init];
    _udpConnection.delegate = self;
    [_udpConnection setupAnnouncementSocket:10400];
    
    //dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //dispatch_async(q, ^{
        //_client = [[ControllerClient alloc] init];
    
        //[_client connectWithPort:10400];
    //});
    
}



#pragma mark - test functions

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

- (void)findController:(Session*)session{
    NSLog(@"findController: %@/%@/%@/%@",session.vendor, session.model, session.series, session.name);

    
}

/*
#pragma mark -
//連結成功
- (void)socketDidConnectToAddress:(NSData*)address
{
    NSLog(@"socketDidConnectToAddress");
}
//連結失敗的代理,外界操作处理,比如停止发送心跳包,申请重连
- (void)socketDidDisconnectWithError:(NSError*)error{
    NSLog(@"socketDidDisconnectWithError");
    
}
//读取Socket数据

*/


@end