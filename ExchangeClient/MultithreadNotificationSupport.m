//
//  MultithreadNotificationSupport.m
//  ExchangeClient
//
//  Created by LSA on 14/12/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "MultithreadNotificationSupport.h"
#import "DataBaseManager.h"
#import "ExchangeClientDataSingleton.h"

@implementation MultithreadNotificationSupport

@synthesize notifications;
@synthesize notificationLock;
@synthesize notificationPort;
@synthesize notificationThread;

- (void) dealloc {
    if (self.notifications)
        [self.notifications release];
    if (self.notificationLock)
        [self.notificationLock release];
    if (self.notificationPort)
        [self.notificationPort release];
    
    [super dealloc];
}

- (id) init {
    self = [super init];
    if (self) {
        self.notifications      = [[NSMutableArray alloc] init];
        self.notificationLock   = [[NSLock alloc] init];
        self.notificationThread = [NSThread currentThread];
        
        self.notificationPort = [[NSMachPort alloc] init];
        [self.notificationPort setDelegate:self];
        [[NSRunLoop currentRunLoop] addPort:self.notificationPort
                                    forMode:(NSString *)kCFRunLoopCommonModes];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(processNotification:)
         name:@"DatabaseHasAnUpdate"
         object:nil];
    }
    
    return self;
}

- (void) startNewThread {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(processNotification:)
     name:@"DatabaseHasAnUpdate"
     object:nil];
    
    DataBaseManager *dbManager = [[DataBaseManager alloc] initWithDatabaseForUser:@"sed2"];
    [dbManager startUpdating];
}

- (void) handleMachMessage:(void *)msg {
    
    [self.notificationLock lock];
    
    while ([self.notifications count]) {
        NSNotification *notification = [self.notifications objectAtIndex:0];
        [self.notifications removeObjectAtIndex:0];
        [self.notificationLock unlock];
        [self processNotification:notification];
        [self.notificationLock lock];
    };
    
    [self.notificationLock unlock];
}

- (void)processNotification:(NSNotification *)notification {
    
    if ([NSThread currentThread] != self.notificationThread) {
        // Forward the notification to the correct thread.
        [self.notificationLock lock];
        [self.notifications addObject:notification];
        [self.notificationLock unlock];
        [self.notificationPort sendBeforeDate:[NSDate date]
                                   components:nil
                                         from:nil
                                     reserved:0];
    }
    else {
        [[ExchangeClientDataSingleton instance] databaseUpdated];
    }
}

@end
