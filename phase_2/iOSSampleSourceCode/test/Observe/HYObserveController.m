//
//  HYObserveController.m
//  test
//
//  Created by HY on 2020/1/10.
//  Copyright © 2020 HY. All rights reserved.
//

#import "HYObserveController.h"
#import "HYObserveBController.h"

@interface HYObserveController ()

@property (weak, nonatomic) IBOutlet UILabel *textfield;

@end

@implementation HYObserveController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNof:) name:@"HYObserveNof" object:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"去B页面" style:UIBarButtonItemStylePlain target:self action:@selector(goB)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)goB {
    [self.navigationController pushViewController:[HYObserveBController new] animated:YES];
}

- (void)receiveNof:(NSNotification *)nof {
    NSLog(@"------A收到: %@", nof);
    self.textfield.text = nof.userInfo[@"content"];
}

@end
