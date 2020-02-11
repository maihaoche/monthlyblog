//
//  HYProxyBViewController.m
//  test
//
//  Created by HY on 2020/1/10.
//  Copyright © 2020 HY. All rights reserved.
//

#import "HYProxyBViewController.h"

@interface HYProxyBViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@end

@implementation HYProxyBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.refreshBtn addTarget:self action:@selector(clickRefreshBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.sendBtn addTarget:self action:@selector(clickSendBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSLog(@"----viewDidLoad: %@ ", NSStringFromClass(self.class));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"----will Appear: %@ ", NSStringFromClass(self.class));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"----did Appear: %@ ", NSStringFromClass(self.class));
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"----will disappear: %@ ", NSStringFromClass(self.class));
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSLog(@"----did disappear: %@ ", NSStringFromClass(self.class));
}

- (void)dealloc {
    NSLog(@"---dealloc %@", NSStringFromClass(self.class));
}

- (void)clickRefreshBtn:(id)sender {
    NSLog(@"-----点击了B页面的刷新按钮");
    
    if ([self.delegate respondsToSelector:@selector(HYProxyBViewControllerClickRefresh)]) {
        [self.delegate HYProxyBViewControllerClickRefresh];
    }
    
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickSendBtn:(id)sender {
    NSLog(@"----点击了B页面的发送内容: %@", self.textfield.text);
    // 默认require的方法，是必须实现的，否则因无法调用会crash
    // 但是一般为了防止其他人忘记了。。。。所以实际开发中还是会做判断
    if ([self.delegate respondsToSelector:@selector(HYProxyBViewController:clickToSay:)]) {
        [self.delegate HYProxyBViewController:self clickToSay:self.textfield.text];
    }
    
//    [self.navigationController popViewControllerAnimated:YES];
}

@end
