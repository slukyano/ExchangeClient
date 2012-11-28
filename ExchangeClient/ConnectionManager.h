//
//  ConnectionManager.h
//  ExchangeClient
//
//  Created by LSA on 14/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConnectionManagerDelegate;

@interface ConnectionManager : NSObject <NSURLConnectionDelegate>

@property (nonatomic, assign) id<ConnectionManagerDelegate> delegate;

- (id) initWithDelegate:(id<ConnectionManagerDelegate>)delegate;
- (void) sendRequestToServer:(NSURL *)serverURL withCredential:(NSURLCredential *)credential withBody:(NSData *)bodyData;

@end

@protocol ConnectionManagerDelegate <NSObject>

- (void) connectionManager:(ConnectionManager *)manager didFinishLoadingData:(NSData *)data;

@end
