//
//  DataBaseManager.h
//  ExchangeClient
//
//  Created by LSA on 06/12/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBaseManager : NSObject

- (id) initWithDatabaseForUser:(NSString *)username;
- (NSDictionary *) folderWithID:(NSString *)folderID;
- (NSDictionary *) itemWithID:(NSString *)itemID;
- (NSArray *) foldersInFolderWithID:(NSString *)folderID;
- (NSArray *) itemsInFolderWithID:(NSString *)folderID;
- (NSArray *) foldersAndItemsInFolderWithID:(NSString *)folderID;
- (NSArray *) foldersAndItemsInParentFolderOfFolderWithID:(NSString *)folderID;
- (NSDictionary *) updateDatabaseSynchronously;
- (BOOL) sendMessageUsingDictionary:(NSDictionary *)messageDictionary;

@end
