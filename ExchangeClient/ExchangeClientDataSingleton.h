//
//  ExchangeClientDataSingleton.h
//  ExchangeClient
//
//  Created by Администратор on 20.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExchangeClientDataSingleton : NSObject

@property (nonatomic, readonly, getter = messageRootFolderID) NSString *messageRootFolderID;

+ (ExchangeClientDataSingleton *)instance;

- (NSUInteger) count;
- (id) objectAtIndex:(NSUInteger)index;
- (void) addObject:(id)anObject;
- (void) removeObjectAtIndex:(NSUInteger)index;
- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

- (void) ItemsInFolderWithID:(NSString *)currentFolderID;
- (NSString *)ParentIDForFolderWithID:(NSString *)currentFolderID;

- (NSString *)messageRootFolderID;

@end
