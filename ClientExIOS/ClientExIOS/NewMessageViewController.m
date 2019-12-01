//
//  NewMessageViewController.m
//  ClientExIOS
//
//  Created by master on 02.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import "NewMessageViewController.h"

@interface NewMessageViewController ()

@end

@implementation NewMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendClick:(id)sender {
    
    NSString *result = [self.CVC sendMessageToServer:_textView.text];
    
    if(result == nil) {
        [self dismissViewControllerAnimated:true completion:nil];

    }
    else {
        _errorLabel.text = result;
    }
}

- (IBAction)cancelClick:(id)sender {
    NSLog(@"%@", [self.presentingViewController class]);
    [self dismissViewControllerAnimated:true completion:nil];
    
}
@end
