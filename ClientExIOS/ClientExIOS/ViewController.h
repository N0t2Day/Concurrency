//
//  ViewController.h
//  ClientExIOS
//
//  Created by master on 02.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface ViewController : UIViewController
@property (assign, nonatomic) int socketdescr;
@property (weak, nonatomic) IBOutlet UITextField *serverIp;

@property (weak, nonatomic) IBOutlet UITextField *serverPort;

@property (weak, nonatomic) IBOutlet UITextField *userNick;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;


- (IBAction)connectClick:(id)sender;

@end

