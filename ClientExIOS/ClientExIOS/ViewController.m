//
//  ViewController.m
//  ClientExIOS
//
//  Created by master on 02.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import "ViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <sys/un.h>
#import "ChatTableViewController.h"
#import <errno.h>
int ipToInt(int a1, int a2, int a3, int a4)
{
    
    return a1 << 24 | a2 << 16 | a3 << 8 | a4;
}


void intToIp(int ip, int arr[])
{
    arr[0] = (ip & 0xFF000000) >> 24;
    arr[1] = (ip & 0x00FF0000) >> 16;
    arr[2] = (ip & 0xFF00FF00) >> 8;
    arr[3] = (ip & 0x000000FF);
    
}



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)sendButtonClick:(id)sender {

//    int socketdescr = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
//    if (socketdescr == -1) {
//        NSLog(@"ошибка создания сокета");
//        exit(0);
//    }
//    struct sockaddr_in sin;
//    memset(&sin, 0, sizeof(sin));// Заполнение полей структуры нулями;
//    sin.sin_len = sizeof(sin);
//    sin.sin_family = AF_INET;
//    sin.sin_port = htons(4000);
//    sin.sin_addr.s_addr = htonl(ipToInt(10, 3, 211, 11));
//    if (connect(socketdescr, (const struct sockaddr *)&sin, sizeof(sin)) == -1) {
//        printf("Ошибка подключения к серверу: %i", errno);
//        exit(0);
//    }
//    printf("Соединение с сервером установленно успешно");
//    
//    
//    NSString *msg = _textField.text;
//    
//    long res = write(socketdescr, [msg cStringUsingEncoding:NSUTF8StringEncoding], [msg lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
//    printf("Результат отправки: %li", res);
//    if (res == -1) {
//
//        printf("Ошибка отправки данных (разрыв связи) : %i", errno);
//        return;
//    }
//    
//    char buf[1024];
//    NSMutableData *data = [NSMutableData data];
//    long cnt = -2;
//    do {
//        cnt = read(socketdescr, buf, sizeof(buf));
//        if (cnt <= 0) {
//            printf("Ошибка чтения данных (разрыв связи) : %i", errno);
//           // close(socketdescr);
//            return;
//        }
//        [data appendBytes:buf length:cnt];
//        if (cnt != sizeof(buf)) {
//            break;
//        }
//    } while (cnt != 0);
//    NSString *answer = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"Полученно от сервера : %@", answer);
    
    
    
    
    
    
}
- (IBAction)connectClick:(id)sender {
    
    _socketdescr = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (_socketdescr == -1) {
        _errorLabel.text = [NSString stringWithFormat:@"Ошибка создания клиентского сокета: %i", errno];
        return;
    }
    int port = [[_serverPort text] intValue];
    
    
    int ip[4];
    [self convertStringToByteArray:[_serverIp text] array:ip];
    
    struct sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));// Заполнение полей структуры нулями;
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET;
    sin.sin_port = htons(port);
    sin.sin_addr.s_addr = htonl(ipToInt(ip[0], ip[1], ip[2], ip[3]));
    if (connect(_socketdescr, (const struct sockaddr *)&sin, sizeof(sin)) == -1) {
       _errorLabel.text = [NSString stringWithFormat:@"Ошибка подключения к серверу: %i", errno];
        return;
    }

    
    ChatViewController *chatTableVC = [self.storyboard instantiateViewControllerWithIdentifier:
                                              NSStringFromClass([ChatViewController class])];
    chatTableVC.clientDescr = _socketdescr;
    
    
    NSString *loginResult = [chatTableVC loginToServer:[_userNick text]];
    if (loginResult == nil) {
        _errorLabel.text = @"";
        [self presentViewController:chatTableVC animated:true completion:nil];
    }
    else
    {
        _errorLabel.text = loginResult;
    }
    
    
    
}

-(void)convertStringToByteArray:(NSString *)text array:(int *)ip
{
    NSArray<NSString *> *components = [text componentsSeparatedByString:@"."];
    for (int i = 0; i < components.count; i++) {
        ip[i] = [[components objectAtIndex:i] intValue];
    }
}









































@end
