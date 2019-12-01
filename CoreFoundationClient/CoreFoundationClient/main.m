//
//  main.m
//  CoreFoundationClient
//
//  Created by master on 23.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <sys/un.h>

void handleConnect(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);

void handleRead(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);



int ipToInt(int a1, int a2, int a3, int a4);
void intToIp(int ip, int arr[]);


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"%@", [[NSHost currentHost] address]);
        CFSocketRef clientSocket = CFSocketCreate(kCFAllocatorDefault, AF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketDataCallBack, handleRead/* указатель на функцию */, NULL);
        
//        Для соединения с сервером:
//        CFSocketError CFSocketConnectToAdress(CFSocketRef s, CFDataRef address, CFTimeInterval timeout);
        
        struct sockaddr_in sin;
        memset(&sin, 0, sizeof(sin));
        sin.sin_len = sizeof(sin);
        sin.sin_family = AF_INET;
        sin.sin_port = htons(4000);
        sin.sin_addr.s_addr = htonl(ipToInt(192, 168, 1, 108));
        
        CFDataRef sincfd = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sin, sizeof(sin));
        CFSocketError result = CFSocketConnectToAddress(clientSocket, sincfd, 10.0);
        CFRelease(sincfd);
        if (result!=kCFSocketSuccess) {
            printf("error %i", errno);
        }
        NSLog(@"Connected to server OK");
        
        // Метод отправки данных
//        CFSocketError CFSocketSendData(CFSocketRef s,
//                                       CFDataRef address, // куда, если NULL то отправляються данные туда, куда сокет соединен.
//                                       CFDataRef data,    // что
//                                       CFTimeInterval timeout // через сколько отправить
//                                       );
        NSString *str = @"дтифодмть жд! Apple Forever";
        
        
        NSData *D = [str dataUsingEncoding:NSUTF8StringEncoding];
        
        
        CFDataRef data = CFDataCreate(kCFAllocatorDefault, [D bytes], [D length]);
        
        result = CFSocketSendData(clientSocket, NULL, data, 1.0);
        if (result != kCFSocketSuccess) {
            printf("error %i", errno);
        }
        // Добавление в RunLoop и его запуск.
    
        CFRunLoopSourceRef socketSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, clientSocket, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), socketSource, kCFRunLoopDefaultMode);
        
        CFRunLoopRun(); // лучше это делать в вторичном потоке.
        
        
        
        
        
        
        
        
        
    }
    return 0;
}




int ipToInt(int a1, int a2, int a3, int a4)
{
    //     №1 байта   №2 байта   №3 байта  №4 байта
    return a1 << 24 | a2 << 16 | a3 << 8 | a4;
}

void intToIp(int ip, int arr[])
{
    arr[0] = (ip & 0xFF000000) >> 24;
    arr[1] = (ip & 0x00FF0000) >> 16;
    arr[2] = (ip & 0x0000FF00) >> 8;
    arr[3] = (ip & 0x000000FF);
}





void handleConnect(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {

    
    
}

void handleRead(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    CFDataRef dataRef = (CFDataRef) data;
    NSLog(@"Данные от сервера получены и готовы для чтения   lenght %li", CFDataGetLength(dataRef));
    
    unsigned char *array = malloc(CFDataGetLength(dataRef));
    long lenght = CFDataGetLength(dataRef);
    CFDataGetBytes(dataRef, CFRangeMake(0, CFDataGetLength(dataRef)), array);
    NSString *msg = [[NSString alloc] initWithBytes:array length:lenght encoding:NSUTF8StringEncoding];
    NSLog(@"%@", msg);
    
    
    // ***
    struct sockaddr_in sin;
    CFDataGetBytes(address, CFRangeMake(0, CFDataGetLength(address)), (unsigned char *)&sin);
    
    sin.sin_port = htons(4000);
    int ip[4];
    intToIp(htonl(sin.sin_addr.s_addr), ip);
    NSLog(@"IP %i:%i:%i:%i", ip[0], ip[1], ip[2], ip[3]);

    free(array);
    
    
    
    
    
    
}
