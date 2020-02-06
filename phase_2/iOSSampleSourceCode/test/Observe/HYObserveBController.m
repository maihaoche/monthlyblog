//
//  HYObserveBController.m
//  test
//
//  Created by HY on 2020/1/10.
//  Copyright © 2020 HY. All rights reserved.
//

#import "HYObserveBController.h"
#import "HYObserveCViewController.h"

@interface HYObserveBController ()

@property (weak, nonatomic) IBOutlet UILabel *textfield;

@end

@implementation HYObserveBController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNof:) name:@"HYObserveNof" object:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"去C页面" style:UIBarButtonItemStylePlain target:self action:@selector(goC)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)goC {
    [self.navigationController pushViewController:[HYObserveCViewController new] animated:YES];
}

- (void)receiveNof:(NSNotification *)nof {
    NSLog(@"------B收到: %@", nof);
    self.textfield.text = nof.userInfo[@"content"];
}

@end
