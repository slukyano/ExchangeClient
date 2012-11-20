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

+ (NSData *) XMLRequestGetFolderWithID:(NSString *)folderID;
+ (NSData *) XMLRequestGetItemWithID:(NSString *)itemID;
+ (NSData *) XMLRequestSyncItemsInFolderWithID:(NSString *)folderID;
+ (NSData *) XMLRequestSyncFolderHierarchy;
+ (NSDictionary *) dictionaryForFolderXML:(GDataXMLElement *)folderXML;
+ (NSDictionary *) dictionaryForMailboxXML:(GDataXMLElement *)mailboxXML;
+ (NSDictionary *) dictionaryForMessageXML:(GDataXMLElement *)messageXML;

@end
