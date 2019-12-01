//
//  Server.h
//  ServerTest
//
//  Created by Артем on 28.11.2017.
//  Copyright © 2017 ArtemKedrovTM. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <sys/un.h>

#import "ReadWriteThread.h"


@interface Server : NSObject

@property (assign, nonatomic) int port;
@property (assign, nonatomic) int ip;
@property (assign, nonatomic) int socketDescr;

- (instancetype) initWithIp:(int) i port:(int)p;

- (void) runMethod: (id)param;
- (void) doneServer;

@end
