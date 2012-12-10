//
//  DataBaseManager.h
//  ExchangeClient
//
//  Created by LSA on 06/12/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@protocol DataBaseManagerUpdateReciever;

@interface DataBaseManager : NSObject

@property (nonatomic, assign) id<DataBaseManagerUpdateReciever> updateReciever;

- (id) initWithDatabaseForUser:(NSString *)username;
- (id) initWithDatabaseForUser:(NSString *)username withUpdateReciever:(id<DataBaseManagerUpdateReciever>)reciever;
- (NSDictionary *) folderWithID:(NSString *)folderID;
- (NSDictionary *) itemWithID:(NSString *)itemID;
- (NSArray *) foldersInFolderWithID:(NSString *)folderID;
- (NSArray *) itemsInFolderWithID:(NSString *)folderID;
- (NSArray *) foldersAndItemsInFolderWithID:(NSString *)folderID;
- (NSString *) parentIDForFolderWithID:(NSString *)folderID;
- (NSDictionary *) updateDatabaseSynchronously;
- (BOOL) sendMessageUsingDictionary:(NSDictionary *)messageDictionary;

@end

@protocol DataBaseManagerUpdateReciever <NSObject>

- (NSString *) currentFolderID;
- (void) dataBaseManager:(DataBaseManager *)db haveAnUpdate:(NSArray *)newFolderContent;

@end