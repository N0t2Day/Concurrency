//
//  ReadWriteThread.h
//  ServerTest
//
//  Created by Артем on 28.11.2017.
//  Copyright © 2017 ArtemKedrovTM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReadWriteThread : NSObject
{
    int clientSocketDescr; // описатель клиентского сокета
}
-(instancetype) initWithSocket:(int)sockDescr;
-(void) runMethod:(id)patam;
-(NSString *) handleRequest:(NSString *) request;
@end
