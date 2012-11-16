//
//  ServerWhisperer.h
//  ExchangeClient
//
//  Created by LSA on 15/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConnectionManager.h"

@interface ServerWhisperer : NSObject <ConnectionManagerDelegate>

@property (nonatomic, retain) NSURL *serverURL;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *password;

- (id) initWithServerURL:(NSURL *)server withUserName:(NSString *)userName withPassword:(NSString *)password;

@end
