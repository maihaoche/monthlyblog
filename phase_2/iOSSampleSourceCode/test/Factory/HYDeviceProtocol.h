//
//  HYDeviceProtocol.h
//  test
//
//  Created by HY on 2020/1/10.
//  Copyright © 2020 HY. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HYDeviceProtocol <NSObject>

@required

/// 打电话
- (void)call;

/// 发短信
- (void)sendMessage;

@end
