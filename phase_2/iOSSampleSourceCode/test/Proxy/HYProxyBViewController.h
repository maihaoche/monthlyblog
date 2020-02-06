//
//  HYProxyBViewController.h
//  test
//
//  Created by HY on 2020/1/10.
//  Copyright © 2020 HY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HYProxyBViewController;

@protocol HYProxyBDelegate <NSObject>

- (void)HYProxyBViewController:(HYProxyBViewController *)vc
                    clickToSay:(NSString *)sayText;

@optional
- (void)HYProxyBViewControllerClickRefresh;

@end


@interface HYProxyBViewController : UIViewController

@property (nonatomic, weak) id<HYProxyBDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
