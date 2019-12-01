//
//  ChatMessage.h
//  ChatServer
//
//  Created by master on 02.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *Хранит в себе одно сообщение
 */
@interface ChatMessage : NSObject


@property (assign, nonatomic) int ID;
@property (strong, nonatomic) NSString *msg;
@property (strong, nonatomic) NSString *user;

-(instancetype) initWithId:(int)ID
                   message:(NSString *)msg
                      user:(NSString *)u;

@end
