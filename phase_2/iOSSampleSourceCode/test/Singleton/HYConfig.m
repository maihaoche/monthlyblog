//
//  HYConfig.m
//  test
//
//  Created by HY on 2020/1/10.
//  Copyright © 2020 HY. All rights reserved.
//

#import "HYConfig.h"

static HYConfig *_config = nil;

@interface HYConfig()<NSCopying, NSMutableCopying>

@end

@implementation HYConfig

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _config = [super allocWithZone:zone];
    });
    return _config;
}

+ (instancetype)shareConfig {
    return [[self alloc] init];
}

- (id)copyWithZone:(NSZone *)zone {
    return _config;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _config;
}

- (NSString *)name {
    switch (self.level) {
      case HYConfigLevelLow:
        return @"低";
      case HYConfigLevelNormal:
        return @"正常";
      case HYConfigLevelHigh:
        return @"高";
      default:
        return @"默认";
    }
}

@end
