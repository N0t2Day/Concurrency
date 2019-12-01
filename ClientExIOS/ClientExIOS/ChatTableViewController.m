//
//  ChatTableViewController.m
//  ClientExIOS
//
//  Created by master on 02.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import "ChatTableViewController.h"
#import "NewMessageViewController.h"
#import <errno.h>
@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.dataSource = self;
    _usersOnlineList = [NSMutableArray array];
    _messagesList = [NSMutableArray array];
    //--- Запуск потока получения списка клиентов online ---
    _threadClientList = [[NSThread alloc] initWithTarget:self selector:@selector(runMethodClientList:) object:nil];
    [_threadClientList start];
    NSLog(@"main %li", [NSThread mainThread].hash);
    NSLog(@"threadClientList %li", _threadClientList.hash);
    
    //--- Запуск потока получения новых сообщений ---
    _threadNewMsgList = [[NSThread alloc] initWithTarget:self selector:@selector(runMethodNewMsgList:) object:nil];
    NSLog(@"_threadNewMsgList %li", _threadNewMsgList.hash);

    [_threadNewMsgList start];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - work methods

- (void) runMethodClientList:(id)param {
    NSThread *curThread = [NSThread currentThread];
    NSLog(@"%li", curThread.hash);
    while (curThread.isCancelled == false) {
        [NSThread sleepForTimeInterval:5.0];
        if (curThread.isCancelled) {
            break;
        }
        NSString *answer;
        @synchronized (self) {
            [self isSendString:@"USERLIST|"];
            answer = [self receiveString];
        }
        if ([answer hasPrefix:@"USERLIST|"]) {
            NSString *data = [answer substringFromIndex:9];
            _usersOnlineList = [NSMutableArray arrayWithArray:[data componentsSeparatedByString:@"^"]];
            NSLog(@"reloadData");
            NSLog(@"%p", self.tableView);
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:false];
//            [self.tableView reloadData];
        }
        NSLog(@"%@", _usersOnlineList);
    }
    
}

- (void) runMethodNewMsgList:(id)param {
    
    NSThread *curThread = [NSThread currentThread];
    while (curThread.isCancelled == false) {
        [NSThread sleepForTimeInterval:3.0];
        if (curThread.isCancelled) {
            break;
        }

        NSString *answer;
        @synchronized (self) {
            [self isSendString:[NSString stringWithFormat:@"MSGLIST|%i", _lastMsgID]];
            answer = [self receiveString];
        }
        // ######
            NSString *data = [answer substringFromIndex:8];
            NSArray<NSString *> *arr = [data componentsSeparatedByString:@"&"];
            for (NSString *str in arr) {
                if ([str isEqualToString:@""]) {
                    break;
                }
                NSArray<NSString *> *arrM = [str componentsSeparatedByString:@"^"];
                _lastMsgID = [[arrM objectAtIndex:0] intValue];
                [_messagesList addObject:[arrM objectAtIndex:1]];
            }
        }
        [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:false];
}
/**
*   1. Авторизация
*   Клиент:"LOGIN|ник"
*   Сервер:"LOGINOK|" или "LOGINERROR|текст_ссобщения_об_ошибке"
*/
 -(NSString *) loginToServer:(NSString *)login {
     NSString *msg = [NSString stringWithFormat:@"LOGIN|%@", login];
     
     if ([self isSendString:msg] == false) {
         return @"Ошибка посылки запроса на сервер (отправка данных)";
     }
     msg = [self receiveString];
     if (msg == nil) {
         return @"Ошибка посылки запроса на сервер (получение данных)";
     }
     if ([msg hasPrefix:@"LOGINERROR|"]) {
         return [NSString stringWithFormat:@"Ошибка: %@", [msg substringFromIndex:10]];
     }
     if ([msg isEqualToString:@"LOGINOK|"]) {
         return nil;
     }
     return @"Получен неизвестный ответ от сервера";
}
- (BOOL) isSendString : (NSString *) msg {
    NSLog(@"-- >>>%@", msg);
    const char *packet = [msg cStringUsingEncoding:NSUTF8StringEncoding];
    long res = write(_clientDescr, packet, [msg lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    if(res <= 0){
        NSLog(@"Error sending message: %i", errno);
        return false;
    }
    return true;
}

- (NSString *) receiveString {
    char buf[256];
    NSMutableData *data = [NSMutableData data];
    long cnt = -2;
    do {
        cnt = read(_clientDescr, buf, sizeof(buf));
        if (cnt <= 0) {
            printf("Ошибка чтения данных (разрыв связи) : %i", errno);
            return nil;
        }
        [data appendBytes:buf length:cnt];
        if (cnt != sizeof(buf)) {
            break;
        }
    } while (cnt!=0);
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return msg;
}

- (NSString *) sendMessageToServer:(NSString *)msgText {
    NSLog(@"sendMessageToServer");
    NSString *msg = [NSString stringWithFormat:@"NEWMSG|%@", msgText];
    if ([self isSendString:msg] == false) {
        return @"Ошибка посылки запроса на сервер (отправка данных)";
    }
    msg = [self receiveString];
    if (msg == nil) {
        return @"Ошибка посылки запроса на сервер (получение данных)";
    }
    
    
    return nil;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    

    switch (section) {
        case 0: // пользователи онлайн
            return _usersOnlineList.count;
            break;
        case 1:// список сообщений
            return _messagesList.count;
            break;
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCellId"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"userCellId"];
            }
            cell.textLabel.text = [_usersOnlineList objectAtIndex:indexPath.row];
            return cell;
        }
            break;
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCellId"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"messageCellId"];
            }
            cell.textLabel.text = [_messagesList objectAtIndex:indexPath.row];
            return cell;
        }
            break;
    }
    return nil;
    // Configure the cell...
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Пользователи Online";
            break;
        case 1:
            return @"Сообщения";
            break;
        default:
            return @"N/A";
            break;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)writeNewMessage:(id)sender {
    
    NewMessageViewController *NMVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([NewMessageViewController class])];
    NMVC.CVC = self;
    [self presentViewController:NMVC animated:true completion:nil];
    
}

- (IBAction)exitClick:(id)sender {
    
    [_threadNewMsgList cancel];
    [_threadClientList cancel];
    [self dismissViewControllerAnimated:true completion:nil];
    close(_clientDescr);
    
}
@end
