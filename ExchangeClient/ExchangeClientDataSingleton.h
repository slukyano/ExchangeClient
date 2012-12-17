//
//  ExchangeClientDataSingleton.h
//  ExchangeClient
//
//  Created by Администратор on 20.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBaseManager.h"

@interface ExchangeClientDataSingleton : NSObject <DataBaseManagerUpdateReciever>

@property (nonatomic, readonly, getter = messageRootFolderID) NSString *messageRootFolderID;
@property (retain, getter = currentFolderID) NSString *currentFolderID;

+ (ExchangeClientDataSingleton *)instance;

- (NSUInteger) count;
- (id) objectAtIndex:(NSUInteger)index;
- (void) addObject:(id)anObject;
- (void) removeObjectAtIndex:(NSUInteger)index;
- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

- (void) loadItemsInFolderWithID:(NSString *)currentFolderID;
- (void) reloadItemsInCurrentFolder;
- (NSString *)parentIDForFolderWithID:(NSString *)currentFolderID;
- (NSString *)parentIDForCurrentFolder;

- (NSString *)messageRootFolderID;

- (void) databaseUpdated;

@end
