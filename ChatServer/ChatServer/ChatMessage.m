//
//  ChatMessage.m
//  ChatServer
//
//  Created by master on 02.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import "ChatMessage.h"

@implementation ChatMessage
-(instancetype) initWithId:(int)ID message:(NSString *)msg user:(NSString *)u
{
    self = [super init];
    if (self) {
        _ID = ID;
        _msg = msg;
        _user = u;
    }
    return self;
}
@end
