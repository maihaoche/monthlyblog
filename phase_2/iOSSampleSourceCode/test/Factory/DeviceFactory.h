//
//  DeviceFactory.h
//  test
//
//  Created by HY on 2020/1/10.
//  Copyright © 2020 HY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYiPhoneDevice.h"
#import "HYandroidDevice.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HYDeviceType) {
    HYDeviceTypeIPhone,
    HYDeviceTypeAndroid,
};

@interface DeviceFactory : NSObject

+ (id <HYDeviceProtocol>)createPhoneWithType:(HYDeviceType)type;

@end

NS_ASSUME_NONNULL_END
