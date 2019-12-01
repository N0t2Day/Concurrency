//
//  Server.m
//  ServerTest
//
//  Created by Артем on 28.11.2017.
//  Copyright © 2017 ArtemKedrovTM. All rights reserved.
//

#import "Server.h"



int ipToInt(int a1, int a2, int a3, int a4) // превращает IP адрес в целое значение
{
    // №1 байта    №2 байта №3 байта   №4 байта
    return a1 << 24 | a2 << 16 | a3 << 8 | a4;
}
//                    int 4 байта
//        ---------------------------------
//        |       |       |       |       |
//        | a1    |  a2   |  a3   |  a4   |
//        |       |       |       |       |
//        ---------------------------------

void intToIp(int ip, int arr[])
{
    arr[0] = (ip & 0xFF000000) >> 24;
    arr[1] = (ip & 0x00FF0000) >> 16;
    arr[2] = (ip & 0xFF00FF00) >> 8;
    arr[3] = (ip & 0x000000FF);
    
}

@implementation Server

- (instancetype) initWithIp:(int)i port:(int)p
{
    self = [super init];
    if (self) {
        _ip = i;
        _port = p;
    }
    return self;
}

- (void) runMethod : (id) param
{
    _socketDescr = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (_socketDescr == -1) {
        printf("Ошибка создания сокета: %i", errno);
    }
    struct sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    
    sin.sin_len         = sizeof(sin);
    sin.sin_family      = AF_INET;
    sin.sin_port        = htons(_port);
    sin.sin_addr.s_addr = htonl(_ip);
    
    if (bind(_socketDescr, (const struct sockaddr *)&sin, sizeof(sin)) ==  -1)
    {
        printf("Ошибка привязки сокета: %i", errno);
    }
    
    if (listen(_socketDescr, 5) == -1) {
        printf("Ошибка прослушивания запросов на установление связи: %i", errno);
    }
    
    struct sockaddr_in  peer_addr;
    socklen_t           peer_addr_len = sizeof(struct sockaddr);
    
    
    while (true)
    {
        printf("Ожидание запроса на установление связи");
        
        int clientDescr = accept(_socketDescr, (struct sockaddr *)&peer_addr, &peer_addr_len);
        printf("Ожидание второго игрока запроса на установление связи");
        int clientDescr1 = accept(_socketDescr, (struct sockaddr *)&peer_addr, &peer_addr_len);

        if (clientDescr == -1)
        {
            printf("Ошибка функции \"accept\"", errno);
        }
        
        int A[4];
        intToIp(htonl(peer_addr.sin_addr.s_addr), A);
        printf("\n Соединение установленно c ip : %i.%i.%i.%i   port: %i \n", A[0], A[1], A[2], A[3], peer_addr.sin_port);
        
        ReadWriteThread *RW = [[ReadWriteThread alloc] initWithSocket:clientDescr];
        
        NSThread *T = [[NSThread alloc] initWithTarget:RW selector:@selector(runMethod:) object:nil];
        
        [T start];
        
    }
    
    
}




- (void) doneServer
{
    close(_socketDescr);
}



@end
