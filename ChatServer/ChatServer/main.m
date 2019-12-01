//
//  main.m
//  ChatServer
//
//  Created by master on 02.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"
#import "ReadWriteThread.h"
#import "ChatMessage.h"
#import "CharUser.h"
#import "ChatSingleton.h"




int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        /*
        Сетевое приложение Чат
        ----------------------
        
        У клиента будет:
        - Список пользователей online   (будет обновляться каждые 5 секунды)
        - Список сообщений              (будет обновляться каждые 3 секунды)
        - Возможность отправлять сообщения
        
        При запуске клиента ему необходимо будет авторизоваться (просто ввести ник)
        (Можно указать IP адресс и порт сервера)
        
        Протокол
        --------
        
        1. Авторизация
        Клиент:"LOGIN|ник"
        Сервер:"LOGINOK|" или "LOGINERROR|текст_ссобщения_об_ошибке"
        
        2. Посылка сообщения
        Клиент:"NEWMSG|Текст_сообщения"
        Сервер:"NEWMSGOK|" или "NEWMSGERROR|текст_сообщения_об_ошибке"
        
        3. Получение списка пользователей online
        Клиент:"USERLIST|"
        Сервер:"USERLIST|User1^User2^UserN"
        
        4. Получение новых сообщений
        Клиент:"MSGLIST|id_последнего_полученного_сообщения"
        Сервер:"MSG|id^сообщения&id^сообщение&id^сообщение"
        */
        
//        https://habrahabr.ru/post/322380/
//        https://tools.ietf.org/html/rfc3696
        
        Server *ST = [[Server alloc] initWithIp:ipToInt(192,168,1,108) port:4000];
        NSThread *T = [[NSThread alloc] initWithTarget:ST selector:@selector(runMethod:) object:nil];
        [T start];
        int a;
        scanf("%i", &a);
        
        
        
        
        [ST doneServer];
    }
    return 0;
}
