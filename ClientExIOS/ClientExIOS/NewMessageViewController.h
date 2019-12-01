//
//  NewMessageViewController.h
//  ClientExIOS
//
//  Created by master on 02.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatTableViewController.h"
@interface NewMessageViewController : UIViewController


@property (strong, nonatomic) ChatViewController *CVC;

@property (weak, nonatomic) IBOutlet UITextView *textView;


- (IBAction)sendClick:(id)sender;
- (IBAction)cancelClick:(id)sender;



@property (weak, nonatomic) IBOutlet UILabel *errorLabel;





@end
