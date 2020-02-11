//
//  HYConfig.h
//  test
//
//  Created by HY on 2020/1/10.
//  Copyright © 2020 HY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HYConfigLevel) {
  HYConfigLevelDefault = 0,
  HYConfigLevelLow,
  HYConfigLevelNormal,
  HYConfigLevelHigh
};

@interface HYConfig : NSObject

/// 级别
@property (nonatomic, assign) HYConfigLevel level;
/// 级别描述
@property (nonatomic, strong, readonly) NSString *name;
/// 是否使用
@property (nonatomic, assign, getter=isUsed) BOOL used;

/// 获取用户单例对象
+ (instancetype)shareConfig;

@end
