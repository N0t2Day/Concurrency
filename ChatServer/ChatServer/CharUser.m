//
//  CharUser.m
//  ChatServer
//
//  Created by master on 02.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import "CharUser.h"

@implementation CharUser
-(instancetype) initWithUser:(NSString *)user socketDescr:(int)socket
{
    self = [super init];
    if (self) {
        _user = user;
        _socketDescr = socket;
    }
    return self;
}
@end
