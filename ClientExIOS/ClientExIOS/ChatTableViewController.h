//
//  ChatTableViewController.h
//  ClientExIOS
//
//  Created by master on 02.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController<UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSThread *threadClientList;
@property (strong, nonatomic) NSThread *threadNewMsgList;

@property (assign, nonatomic) int lastMsgID; // ID последнего полученного сообщения.
@property (assign, nonatomic) int clientDescr;
@property (strong, nonatomic) NSMutableArray<NSString *> *usersOnlineList;
@property (strong, nonatomic) NSMutableArray<NSString *> *messagesList;

- (IBAction)writeNewMessage :(id) sender;
- (IBAction)exitClick       :(id) sender;


- (void) runMethodClientList:(id) param;
- (void) runMethodNewMsgList:(id) param;

- (NSString *) sendMessageToServer: (NSString *) msgText;

- (NSString *) loginToServer: (NSString *) login;
@end
