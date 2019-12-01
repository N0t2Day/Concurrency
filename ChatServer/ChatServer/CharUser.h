//
//  CharUser.h
//  ChatServer
//
//  Created by master on 02.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CharUser : NSObject
@property (strong, nonatomic) NSString *user;
@property (assign, nonatomic) int socketDescr;


-(instancetype) initWithUser:(NSString *)user socketDescr:(int)socket;

@end
