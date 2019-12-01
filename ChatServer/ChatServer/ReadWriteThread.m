//
//  ReadWriteThread.m
//  ServerTest
//
//  Created by Артем on 28.11.2017.
//  Copyright © 2017 ArtemKedrovTM. All rights reserved.
//

#import "ReadWriteThread.h"
#import "ChatSingleton.h"
@implementation ReadWriteThread
-(instancetype) initWithSocket:(int)sockDescr
{
    self = [super init];
    if (self) {
        self->clientSocketDescr = sockDescr;
    }
    return self;
}
-(void) runMethod:(id)patam
{
    char buf[16]; // - 16 bytes
    while (true)
    {
        
        
        NSMutableData *data = [NSMutableData data];
        long cnt = -1;
        do
        {
            cnt = read(self->clientSocketDescr, buf, sizeof(buf));
            printf("\nПолученно cnt = %li", cnt);
            if (cnt <= 0)
            {
                printf("\nОшибка чтения данных:%i", errno);
                [[ChatSingleton sharedChat] removeUserBySocket:self->clientSocketDescr];
                return;
            }
            NSLog(@"***");
            [data appendBytes:buf length:cnt];
            if(cnt != sizeof(buf))
            {
                break;
            }
            
            
        }
        while (cnt != 0);
        
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Получено : %@ %li", msg, data.length);
        
        NSString *answer = [self handleRequest:msg];
        write(self->clientSocketDescr, [answer cStringUsingEncoding:NSUTF8StringEncoding], [answer lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
        printf("\nОтправлен ответ удаленному компьютеру (клиентский сокет)");
        
        
        
        
    }
}
- (NSString *) handleRequest:(NSString *)request {
    
    
    
    NSArray<NSString *> *operations = [request componentsSeparatedByString:@"|"];
    NSLog(@"%@", operations);
    NSString *cmd = [operations firstObject];
    NSString *data = [operations lastObject];
    
    
    if ([cmd isEqualToString:@"LOGIN"])
    {
        if ([[ChatSingleton sharedChat] addUser:[[CharUser alloc]
                                                 initWithUser:data
                                                 socketDescr:self->clientSocketDescr]] == true)
        {
            return @"LOGINOK|";
        }
        else
        {
            return @"LOGINERROR|Такой пользователь уже есть";
        }
    
    }
    // ***
    if ([cmd isEqualToString:@"USERLIST"]) {
        return [NSString stringWithFormat:@"USERLIST|%@",[[ChatSingleton sharedChat] userListt]];
    }
    if ([cmd isEqualToString:@"MSGLIST"]) {
        int ID = [data intValue];
        return [NSString stringWithFormat:@"MSGLIST|%@",[[ChatSingleton sharedChat] msgList:ID]];
    }
    if ([cmd isEqualToString:@"NEWMSG"]) {
        if (data.length > 100) {
            return @"NEWMSGERROR|Слишком длинное сообщение";
        }
        [[ChatSingleton sharedChat] addMessage:[[ChatMessage alloc] initWithId:[[ChatSingleton sharedChat] getCurMsgId] message:data user:[[ChatSingleton sharedChat] getUserNickBySocket:self->clientSocketDescr]]];
        return @"NEWMSGOK";
    }
    return @"ERROR|Полученна неизвестная команда";
}
@end
