//
//  MultithreadNotificationSupport.h
//  ExchangeClient
//
//  Created by LSA on 14/12/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

@interface MultithreadNotificationSupport : NSObject <NSMachPortDelegate>

@property (assign) NSMutableArray *notifications;
@property (assign) NSThread *notificationThread;
@property (assign) NSLock *notificationLock;
@property (assign) NSMachPort *notificationPort;

- (void) startNewThread;
- (void) handleMachMessage:(void *)msg;
- (void) processNotification:(NSNotification *)notification;

@end
