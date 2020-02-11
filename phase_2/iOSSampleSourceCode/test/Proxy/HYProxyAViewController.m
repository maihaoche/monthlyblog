//
//  HYProxyAViewController.m
//  test
//
//  Created by HY on 2020/1/10.
//  Copyright © 2020 HY. All rights reserved.
//

#import "HYProxyAViewController.h"
#import "HYProxyBViewController.h"

@interface HYProxyAViewController ()<HYProxyBDelegate>
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *refreshLabel;

@property (weak, nonatomic) IBOutlet UILabel *label2;

@end

@implementation HYProxyAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshLabel.hidden = YES;
    
    self.label2.text = @"label2";
    
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

- (IBAction)clickGoB:(id)sender {
    HYProxyBViewController *vc = [[HYProxyBViewController alloc] initWithNibName:@"HYProxyBViewController" bundle:nil];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)HYProxyBViewControllerClickRefresh {
    NSLog(@"----A响应刷新");
    self.refreshLabel.hidden = NO;
}

- (void)HYProxyBViewController:(HYProxyBViewController *)vc
                    clickToSay:(NSString *)sayText {
    NSLog(@"----A响应: %@", vc);
    self.textLabel.text = sayText;
}

- (void)dealloc {
    NSLog(@"---dealloc %@", NSStringFromClass(self.class));
}

@end
