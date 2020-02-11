//
//  ViewController.m
//  test
//
//  Created by HY on 2020/1/10.
//  Copyright © 2020 HY. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *vcNames;

@end

@implementation ViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.titles = @[@"单例模式", @"代理模式", @"观察者模式", @"工厂模式", @"中介者模式"];
    self.vcNames = @[@"", @"HYProxyAViewController", @"HYObserveController", @"HYFactoryViewController", @"HYMediatorViewController"];
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell"];
    cell.textLabel.text = self.titles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *name = self.vcNames[indexPath.row];
    if (name.length) {
        UIViewController *vc = [NSClassFromString(name) new];
        vc.title = self.titles[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
