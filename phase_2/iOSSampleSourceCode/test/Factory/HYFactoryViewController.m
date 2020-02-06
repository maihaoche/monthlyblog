//
//  HYFactoryViewController.m
//  test
//
//  Created by HY on 2020/1/10.
//  Copyright © 2020 HY. All rights reserved.
//

#import "HYFactoryViewController.h"
#import "DeviceFactory.h"

@interface HYFactoryViewController ()

@end

@implementation HYFactoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HYiPhoneDevice *iPhone = [DeviceFactory createPhoneWithType:HYDeviceTypeIPhone];
    [iPhone call];
    
    [iPhone sendMessage];
    
    [iPhone faceId];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
