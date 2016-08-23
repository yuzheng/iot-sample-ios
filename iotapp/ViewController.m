//
//  ViewController.m
//  iotapp
//
//  Created by chttl on 2016/8/19.
//  Copyright © 2016年 chttl. All rights reserved.
//

#import "ViewController.h"
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
    // Do any additional setup after loading the view, typically from a nib.
    [self testClient];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) testClient {
    NSLog(@"testClient");
    
    sessions = [[NSMutableArray alloc] init];
    
    _udpConnection = [[ControllerClientBuilder alloc] init];
    _udpConnection.delegate = self;
    [_udpConnection setupAnnouncementSocket:10400];
    
    //dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //dispatch_async(q, ^{
        //_client = [[ControllerClient alloc] init];
    
        //[_client connectWithPort:10400];
    //});
    _udpCotroller = [[ControllerClient alloc] init];
    _udpCotroller.delegate = self;
    [_udpCotroller setupSocket:0];
    
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

- (void)findController:(LocalSession*)session{
    NSLog(@"findController: %@/%@/%@/%@",session.vendor, session.model, session.series, session.name);
    //[_udpConnection closeAnnouncementSocket];
    
    if(![self existsSession:session]){
        NSLog(@" Find new controller!");
        [_udpCotroller linkController:session];
        [sessions addObject:session];
    }
    
}

- (Boolean) existsSession:(LocalSession*) session {
    for(LocalSession* msession in sessions){
        if([msession isEqual:session]){
            return true;
        }
    }
    return false;
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