//
//  main.m
//  CoreFoundation
//
//  Created by master on 16.12.17.
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
//      Пример для конспекта :
        CFSocketRef socketServer = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, handleConnect/* указатель на функцию */, NULL);

        /*
         Указатель на функцию обратного вызова объявлен в CF:
         void(*CFSocketCallBack)(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);
         
         То есть функция обратного вызова должна иметь такой вид:
          void ИмяФункции(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);
         1. Указатель на CFSocket
         2. Тип обратного вызова
         3. Последние параметры зависят от типа обратного вызова
         */
    
        struct sockaddr_in sin;
        memset(&sin, 0, sizeof(sin));
        sin.sin_len = sizeof(sin);
        sin.sin_family = PF_INET;
        sin.sin_port = htons(4000);
        sin.sin_addr.s_addr = htonl(ipToInt(192,168,1,108));
        CFDataRef sincfd = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sin, sizeof(sin));
        CFSocketSetAddress(socketServer, sincfd);
        CFRelease(sincfd); // После привязки CFDataRef не нужен
        
        // ###
//         Создание источника события для RunLoop
        CFRunLoopSourceRef socketSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socketServer, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), socketSource, kCFRunLoopDefaultMode);
        
        CFRunLoopRun();
        

    }
    return 0;
}


void handleConnect(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
//    data - описатель сокета который был создан в результате соединения
    int clientDesc = *(int *)data;
    
    NSLog(@"Соединение с клиентским сокетом");

    
    CFSocketRef socketClient = CFSocketCreateWithNative(kCFAllocatorDefault, clientDesc, kCFSocketDataCallBack, handleRead, NULL);
    
    CFRunLoopSourceRef socketSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socketClient, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), socketSource, kCFRunLoopDefaultMode);
    
    
}

void handleRead(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {

//    long lenght = CFDataGetLength(address);
//    const UInt8 *p = CFDataGetBytePtr(address);
//    NSString *msg = [[NSString alloc] initWithBytes:p length:lenght encoding:NSUTF8StringEncoding];
//    printf("%s", data);
//    NSLog(@"Answer %p", p);
//    NSLog(@"address: %p, data: %p, info: %p", address, data, info);
    
    
    CFDataRef dataRef = (CFDataRef) data;
    NSLog(@"Данные от клиента получены и готовы для чтения   lenght %li", CFDataGetLength(dataRef));

    unsigned char *array = malloc(CFDataGetLength(dataRef));
    long lenght = CFDataGetLength(dataRef);
    CFDataGetBytes(dataRef, CFRangeMake(0, CFDataGetLength(dataRef)), array);
    NSString *msg = [[NSString alloc] initWithBytes:array length:lenght encoding:NSUTF8StringEncoding];
    
    
    
    // ***
    struct sockaddr_in sin;
    CFDataGetBytes(address, CFRangeMake(0, CFDataGetLength(address)), (unsigned char *)&sin);
    
    sin.sin_port = htons(4000);
    int ip[4];
    intToIp(htonl(sin.sin_addr.s_addr), ip);
    NSLog(@"IP %i:%i:%i:%i", ip[0], ip[1], ip[2], ip[3]);
    
    
    
    NSLog(@"(%li) : %@", lenght, msg);
    free(array);
    
    
    
    // ### Обработка сообщения и отправить ответ

    msg = [NSString stringWithFormat:@"Server !!! %@ !!! ", msg];
    
    NSData *D = [msg dataUsingEncoding:NSUTF8StringEncoding];
    CFDataRef data1 = CFDataCreate(kCFAllocatorDefault, [D bytes], [D length]);
    CFSocketError result = CFSocketSendData(s, NULL, data1, 5.0);
    if (result!=kCFSocketSuccess) {
        printf("error %i", errno);
        if (result == kCFSocketError) {
            printf("Ошибка отправки данных сокетом kCFSocketError %i", errno);
        }
        else if (result == kCFSocketTimeout) {
            printf("Ошибка : Таймаут передачи данных kCFSocketTimeout %i", errno);
        }
    }
    
    
    
    
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

/*
      Сетевое программирование в CoreFoundation ( CF )

 CFSocketRef CFSocketCreate(CFAllocatorRef allocator,
 SInt32 protocolFamily,
 SInt32 socketType,
 SInt32 protocol,
 CFOptionFlags callBackTypes,
 CFSocketCallBack callout,
 const CFSocketContext *context);

    1. allocator - объект предназначен для выделения памяти при создании сокета.  Принимает kCFAllocatorDefault или NULL
    2. protocolFamily - семейство протокола   PF_INET
    3. socketType     - тип сокета            SOCK_STREAM
    4. protocol       - протокол              IPPROTO_TCP
    5. callBackTypes  - какие обратные вызова мы хотим получать при работе с сокетом.
                                                Обратный вызова это метот (функция)
                                                которая будет вызвана по наступлению
                                                какого-либо события
            callBackTypes:
        (
            - kCFSocketNoCallBack         - означает что не надо обратных вызовов
            - kCFSocketReadCallBack       - обратный вызов когда полученны данные
                                                                или новое соединение
                                                                требует подтверждения
                                                                данные не будут автоматически
                                                                прочитанны и установление связи
                                                                не будет автоматически
            - kCFSocketAcceptCallBack     - срабатывает когдазапрос на установление
                                                                        связи подтвержден
            - kCFSocketDataCallBack       - обратный вызов когда входящщие данные будут
                                                считывать частями(фрагментами) в фоновом режиме
                                                Метод обратного вызова будет получать указатель
                                                на объект CFData (аналог NSData) который будет
                                                содержать прочитанный фрагмент данных.
            - kCFSocketConnectCallBack    - Когда произошло соединение с серверным сокетом
            - kCFSocketWriteCallBack      - Когда произошла отправка данных
        );
    6. callout        - указатель на функцию обратного вызова котрая будет вызываться по
                                                событию определенном в предыдущем параметре
    7. context        - указатель на область памяти в которой содержиться дополнительная
                                                    информация и создаваемом объекте сокета.(структура которую реализует сам разработчик). (Может быть равен NULL) параметр не обязателен.
метод вернет указатель на CFSocketRef ---->> указатель на CFSocket;


 -----  Привязка к сокету адреса и порта  ----

  CFSocketError CFSocketSetAddress(CFSocketRef s, CFDataRef address);
  Параметра:
  1. Объект полученный в результате CFSocketCreate;
  2. Укзатель на объект CFData содержащий информацию об адресе и порте
  ****
  -----  Создание объекта CFData:  -----

  CFDataRef CFDataCreate(CFAllocatorRef allocator, const UInt8 *bytes, CFIndex lenght);
  1. allocator    - объект предназначен для выделения памяти при создании сокета.  Принимает
                                                                kCFAllocatorDefault или NULL
  2. bytes        - указатель на байты которые поместяться (будут скопированны) в CFData
  3. lenght       - сколько байтов нужно скопировать
 
 
 
 
 
 
 
 
 
 
 
 Native - родной
 Нативный метод создания сокета
 CFSocketRef CFSocketCreateWithNative(CFAllocatorRef allocator,
 CFSocketNativeHandle sock,   (clientFileDesc)
 CFOptionFlags callBackTypes,
 CFSocketCallBack callout,
 const CFSocketContext *context);
 RunLoop - цыкл обработки поступающих сообщений потоку исполения предоставляемый компанией Apple.
 CFRunLoopRef CFRunLoopGetCurrent(); // RunLoop текущего потока
 CFRunLoopRef CFRunLoopGetMain();    // RunLoop главного потока
 или
 создаем источник от сокета который генирирует события поступающие в RunLoop.
 CFRunLoopSourceRef CFSocketCreateRunLoopSource(CFAllocatorRef allocator,
 CFSocketRef s,
 CFIndex order);
 Создание RunLoop приведет к созданию потока
 Параметры:
 1. allocator    - объект предназначен для выделения памяти при создании сокета.  Принимает kCFAllocatorDefault или NULL
 2. s            - объект сокета
 3. order        - приоритет
 На один RunLoop можно повесить несколько событий order раставит приоритет выполнения.
 Далее это источник добавляеться к RunLoop с помощью метода
 void CFRunLoopAddSource(CFRunLoopRef rl, CFRunLoopSourceRef source, CFRunLoopMode mode);
 Параметры:
 1. rl     -  указатель на RunLoop к которому мы добавляем источник
 2. source -  указатель на сам источник
 3. mode   -  режим цыкла обработки к которому мы добавляем источник.
 mode:
 kCFRunLoopCommonModes - означает что источники добавленные в цыкл обработки сообщений контролируються/обрабатываються всеми режимами цыкла
 kCFRunLoopDefaultMode - означает что должен использоваться когда поток находиться в режиме ожидания
 
 Ожидаем события с помощью метода:
 void CFRunLoopRun();

 
 
 Для отправки данных:
 
 CFSocketError CFSocketSendData (CFSocketRef s,
                                 CFDataRef address,
                                 CFDataRef data,
                                 CFTimerInterval timeout); 
 Параметры:
 1. s       -
 2. address -
 3. data    -
 4. timeout -
 
 
 */
