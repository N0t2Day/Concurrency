//
//  CharSingleton.m
//  ChatServer
//
//  Created by master on 02.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import "ChatSingleton.h"

@interface ChatSingleton ()
@property (strong, nonatomic) NSMutableArray<CharUser *> *userList;

@property (strong, nonatomic) NSMutableArray<ChatMessage *> *msgList;
@property (assign, nonatomic) int curMsgId;
@end

@implementation ChatSingleton

- (instancetype)init
{
    NSLog(@"Error ChatSingleton");
    return nil;
}
+(ChatSingleton *) sharedChat
{
    static ChatSingleton *obj = nil;
    @synchronized (syncObject) {
        if (obj == nil) {
            obj = [ChatSingleton alloc];
            obj.userList = [NSMutableArray array];
            obj.msgList = [NSMutableArray array];
        }
    }
    return obj;
}


- (void) addMessage:(ChatMessage *)msg
{
    @synchronized (_msgList) {
        [_msgList addObject:msg];
        NSLog(@"Добавленно новое сообщение %@", msg.msg);
    }
    
    
}
- (BOOL) addUser:(CharUser *) user
{
    @synchronized (_userList) {
        // Проверка существования логина
        for (CharUser *curUser in _userList) {
            if ([curUser.user isEqualToString:user.user]) {
                return false;
            }
        }
        [_userList addObject:user];
        return true;
    }
}
- (void) removeUserBySocket:(int) socketDescr
{
    @synchronized (_userList) {
        for (int i = 0; i < _userList.count; i++) {
            CharUser *user = [_userList objectAtIndex:i];
            if (user.socketDescr == socketDescr) {
                [_userList removeObjectAtIndex:i];
                break;
            }
        }
    }
}
- (NSString *) userListt
{
    NSMutableString *str = [NSMutableString string];
    @synchronized (_userList) {
        NSLog(@"Users : %li", _userList.count);
        for (int i = 0; i < _userList.count; i++) {
            CharUser *user = [_userList objectAtIndex:i];
            [str appendString:user.user];
            if (i != _userList.count-1) {
                [str appendString:@"^"];
            }
        }
    }
    
    
    return str;
}
- (NSString *)msgList :(int) msgId
{
    NSMutableString *str = [NSMutableString string];
    @synchronized (_msgList) {
        for (int i = 0; i < _msgList.count; i++) {
            ChatMessage *msg = [_msgList objectAtIndex:i];
            if (msgId >= msg.ID) {
                continue;
            }
            [str appendString:[NSString stringWithFormat:@"%i^(%@) : %@", msg.ID, msg.user, msg.msg]];
            if (i != _msgList.count -1) {
                [str appendString:@"^"];
            }
        }
    }
    
    
    return str;
}


- (NSString *) getUserNickBySocket:(int)socketDescr
{
    @synchronized (_userList) {
        for (CharUser *user in _userList) {
            if (user.socketDescr == socketDescr) {
                return user.user;
            }
        }
    }

    return @"N/A";
}
-(int)getCurMsgId{
    return ++_curMsgId;
}
@end
