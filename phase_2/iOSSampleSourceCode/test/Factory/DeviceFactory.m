//
//  DeviceFactory.m
//  test
//
//  Created by HY on 2020/1/10.
//  Copyright © 2020 HY. All rights reserved.
//

#import "DeviceFactory.h"



@implementation DeviceFactory
+ (id <HYDeviceProtocol>)createPhoneWithType:(HYDeviceType)type {
    HYBaseDevice *device = nil;
    
    if (type == HYDeviceTypeIPhone) {
        device = [[HYiPhoneDevice alloc] init];
    } else if (type == HYDeviceTypeAndroid) {
        device = [[HYandroidDevice alloc] init];
    }
    
    return device;
}
@end
