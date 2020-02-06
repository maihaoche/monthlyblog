//
//  HYObserveCViewController.m
//  test
//
//  Created by HY on 2020/1/10.
//  Copyright © 2020 HY. All rights reserved.
//

#import "HYObserveCViewController.h"

@interface HYObserveCViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textfield;

@end

@implementation HYObserveCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)sendThey:(id)sender {
    NSString *text = self.textfield.text;
    if (!text.length) {
        text = @"";
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HYObserveNof" object:nil userInfo:@{@"content": text}];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
