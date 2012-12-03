//
//  XMLHandler.h
//  ExchangeClient
//
//  Created by LSA on 20/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface XMLHandler : NSObject

// Генерация запросов
- (NSData *) XMLRequestGetFolderWithID:(NSString *)folderID;
- (NSData *) XMLRequestGetFolderWithDistinguishedID:(NSString *)distinguishedFolderId;
- (NSData *) XMLRequestGetItemWithID:(NSString *)itemID;
- (NSData *) XMLRequestSyncItemsInFolderWithID:(NSString *)folderID usingSyncState:(NSString *)syncState;
- (NSData *) XMLRequestSyncFolderHierarchyUsingSyncState:(NSString *)syncState;
- (NSData *) XMLRequestFindFoldersInFolderWithID:(NSString *)folderID;
- (NSData *) XMLRequestFindFoldersInFolderWithDistinguishedID:(NSString *)distinguishedFolderID;
- (NSData *) XMLRequestFindItemsInFolderWithID:(NSString *)folderID;
- (NSData *) XMLRequestFindItemsInFolderWithDistinguishedID:(NSString *)distinguishedFolderID;

// Обработка ответов
- (NSDictionary *) parseGetFolderResponse:(NSData *)responseData;
- (NSDictionary *) parseGetItemResponse:(NSData *)responseData;
- (NSArray *) parseFindFolderResponse:(NSData *)responseData;
- (NSArray *) parseFindItemResponse:(NSData *)responseData;
- (NSDictionary *) parseSyncFolderHierarchyResponse:(NSData *)responseData;
- (NSDictionary *) parseSyncFolderItemsResponse:(NSData *)responseData;

@end
