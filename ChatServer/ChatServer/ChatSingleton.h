//
//  CharSingleton.h
//  ChatServer
//
//  Created by master on 02.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CharUser.h"
#import "ChatMessage.h"
static const NSString *syncObject = @"Hello Singleton";

@interface ChatSingleton : NSObject

//@property (strong, nonatomic) NSMutableArray<CharUser *> *userList;
//
//@property (strong, nonatomic) NSMutableArray<ChatMessage *> *msgList;
//@property (assign, nonatomic) int curMsgId;

+(ChatSingleton *) sharedChat;
- (void) addMessage:(ChatMessage *)msg;
- (BOOL) addUser:(CharUser *) user;
- (void) removeUserBySocket:(int) socketDescr;
- (NSString *) userListt;
- (NSString *) msgList :(int) msgId;

- (NSString *)getUserNickBySocket:(int) socketDescr;



-(int) getCurMsgId;

@end
