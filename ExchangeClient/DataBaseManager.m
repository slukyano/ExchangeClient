//
//  DataBaseManager.m
//  ExchangeClient
//
//  Created by LSA on 06/12/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "DataBaseManager.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#import "Defines.h"
#import "ServerWhisperer.h"

@interface DataBaseManager () {
    NSString *databasePath;
    NSString *hierarchySyncState;
}

+ (NSString *) dataBasePathForUser:(NSString *)username;

- (NSDictionary *) dictionaryForFolderFromResultSet:(FMResultSet *)resultSet;
- (NSDictionary *) dictionaryForItemFromResultSet:(FMResultSet *)resultSet;
- (NSDictionary *) dictionaryForMailboxFromResultSet:(FMResultSet *)resultSet;

- (void) setHierarchySyncState:(NSString *)newSyncState;
- (void) setHierarchySyncStateFromDatabase;

- (void) addFolderUsingDictionary:(NSDictionary *)folderDictionary inDatabase:(FMDatabase *)db;
- (void) updateFolderUsingDictionary:(NSDictionary *)folderDictionary inDatabase:(FMDatabase *)db;
- (void) updateSyncStateForFolder:(NSString *)folderID usingSyncState:(NSString *)syncState inDatabase:(FMDatabase *)db;
- (void) deleteFoldeUsingDictionary:(NSDictionary *)folderDictionary inDatabase:(FMDatabase *)db;

- (void) addItemUsingDictionary:(NSDictionary *)itemDictionary inDatabase:(FMDatabase *)db;
- (void) updateItemUsingDictionary:(NSDictionary *)itemDictionary inDatabase:(FMDatabase *)db;
- (void) deleteItemUsingDictionary:(NSDictionary *)itemDictionary inDatabase:(FMDatabase *)db;

- (void) addRecipientForMessageWithID:(NSString *)itemID usingDictionary:(NSDictionary *)recipientDictionary inDatabase:(FMDatabase *)db;
- (void) addRecipientsForMessageWithID:(NSString *) itemID usingArray:(NSArray *)recipientsArray inDatabase:(FMDatabase *)db;
- (void) updateRecipientsForMessageWithID:(NSString *) itemID usingArray:(NSArray *)recipientsArray inDatabase:(FMDatabase *)db;
- (void) deleteRecipientsForMessageWithID:(NSString *)itemID inDatabase:(FMDatabase *)db;

- (void) updateDatabaseAsynchronously;

@end

@implementation DataBaseManager

@synthesize updateReciever = _updateReciever;

+ (NSString *) dataBasePathForUser:(NSString *)username {
    NSString *dataBaseFileName = [NSString stringWithFormat:@"%@db.sqlite3", username];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory stringByAppendingPathComponent:dataBaseFileName];
    return documentsPath;
}

- (void) dealloc {
    [databasePath release];
    [hierarchySyncState release];
    
    [super dealloc];
}

- (id) init {
    self = [super init];
    if (self) {
        databasePath = [[DataBaseManager dataBasePathForUser:@"default"] retain];
        [self resetDatabase];
        hierarchySyncState = [[NSString string] retain];
    }
    
    return self;
}

- (id) initWithDatabaseForUser:(NSString *)username {
    self = [super init];
    if (self) {
        databasePath = [[DataBaseManager dataBasePathForUser:username] retain];
        [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
        if (![[NSFileManager defaultManager] fileExistsAtPath:databasePath])
            [self resetDatabase];
        else
            [self setHierarchySyncStateFromDatabase];
    }
    
    return self;
}

- (id) initWithDatabaseForUser:(NSString *)username withUpdateReciever:(id<DataBaseManagerUpdateReciever>)reciever {
    self = [super init];
    if (self) {
        databasePath = [[DataBaseManager dataBasePathForUser:username] retain];
        //[[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
        if (![[NSFileManager defaultManager] fileExistsAtPath:databasePath])
            [self resetDatabase];
        else
            [self setHierarchySyncStateFromDatabase];
        
        self.updateReciever = reciever;
    }
    
    return self;
}

- (void) setHierarchySyncState:(NSString *)newSyncState {
    [newSyncState retain];
    if (hierarchySyncState)
        [hierarchySyncState release];
    hierarchySyncState = newSyncState;
    
    FMDatabase *db = [[FMDatabase alloc] initWithPath:databasePath];
    if (![db open]) {
        NSLog(@"Database open error");
        [db release];
        return;
    }
    
    [db executeUpdateWithFormat:@"UPDATE PARAMETERS SET ParameterValue = %@ WHERE ParameterName = %@", newSyncState, @"HierarchySyncState"];
    
    [db close];
    [db release];
}

- (void) setHierarchySyncStateFromDatabase {
    FMDatabase *db = [[FMDatabase alloc] initWithPath:databasePath];
    if (![db open]) {
        NSLog(@"Database open error");
        [db release];
        return;
    }

    NSString *result = @"";
    
    /*FMResultSet *resultSetDebug = [db executeQueryWithFormat:@"SELECT * FROM PARAMETERS"];
    while ([resultSetDebug next]) {
        NSLog(@"%@ - %@", [resultSetDebug stringForColumn:@"ParameterName"], [resultSetDebug stringForColumn:@"ParameterValue"]);
    }*/
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM PARAMETERS WHERE ParameterName = %@", @"HierarchySyncState"];
    if ([resultSet next]) {
        result = [resultSet stringForColumn:@"ParameterValue"];
    }
    
    [db close];
    [db release];
    
    [self setHierarchySyncState:result];
}

- (NSDictionary *) dictionaryForFolderFromResultSet:(FMResultSet *)resultSet {
    NSString *folderID = [resultSet stringForColumn:@"FolderID"];
    NSString *folderIDChangeKey = [resultSet stringForColumn:@"FolderIDChangeKey"];
    NSString *parentFolderID = [resultSet stringForColumn:@"ParentFolderID"];
    NSString *parentFolderIDChangeKey = [resultSet stringForColumn:@"ParentFolderIDChangeKey"];
    NSString *displayName = [resultSet stringForColumn:@"DisplayName"];
    NSNumber *totalCount = [NSNumber numberWithInteger:[resultSet intForColumn:@"TotalCount"]];
    NSNumber *unreadCount = [NSNumber numberWithInteger:[resultSet intForColumn:@"UnreadCount"]];
    NSString *folderSyncState = [resultSet stringForColumn:@"SyncState"];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:DataTypeFolder], @"DataType",
            folderID, @"FolderID",
            folderIDChangeKey, @"FolderIDChangeKey",
            parentFolderID, @"ParentFolderID",
            parentFolderIDChangeKey, @"ParentFolderIDChangeKey",
            displayName, @"DisplayName",
            totalCount, @"TotalCount",
            unreadCount, @"UnreadCount",
            folderSyncState, @"SyncState", nil];
}

- (NSDictionary *) dictionaryForMailboxFromResultSet:(FMResultSet *)resultSet {
    NSString *name = [resultSet stringForColumn:@"Name"];
    NSString *emailAddress = [resultSet stringForColumn:@"EmailAddress"];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:name, @"Name", emailAddress, @"EmailAddress", nil];
}

- (NSDictionary *) dictionaryForItemFromResultSet:(FMResultSet *)resultSet {
    NSString *itemID = [resultSet stringForColumn:@"ItemID"];
    NSString *itemIDChangeKey = [resultSet stringForColumn:@"ItemIDChangeKey"];
    NSString *parentFolderID = [resultSet stringForColumn:@"ParentFolderID"];
    NSString *parentFolderIDChangeKey = [resultSet stringForColumn:@"ParentFolderID"];
    NSString *subject = [resultSet stringForColumn:@"Subject"];
    NSString *body = [resultSet stringForColumn:@"Body"];
    NSUInteger bodyType = [[resultSet stringForColumn:@"BodyType"] isEqualToString:@"HTML"] ? EMailContentTypeHTML : EMailContentTypePlainText;
    
    NSMutableArray *recipients = [NSMutableArray array];
    
    FMDatabase *db = [[FMDatabase alloc] initWithPath:databasePath];
    if (![db open]) {
        NSLog(@"Database open error");
        [db release];
        return nil;
    }
    
    FMResultSet *recipientsResultSet = [db executeQueryWithFormat:@"SELECT * FROM RECIPIENTS WHERE ItemID = %@", itemID];
    while ([recipientsResultSet next]) {
        [recipients addObject:[self dictionaryForMailboxFromResultSet:recipientsResultSet]];
    }
    
    [db close];
    [db release];
    
    NSString *fromName = [resultSet stringForColumn:@"FromName"];
    NSString *fromEmailAddress = [resultSet stringForColumn:@"FromEmailAddress"];
    NSDictionary *from = [NSDictionary dictionaryWithObjectsAndKeys:fromName, @"Name", fromEmailAddress, @"EmailAddress", nil];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:DataTypeEMail], @"DataType",
            itemID, @"ItemID",
            itemIDChangeKey, @"ItemIDChangeKey",
            parentFolderID, @"ParentFolderID",
            parentFolderIDChangeKey, @"ParentFolderIDChangeKey",
            subject, @"Subject",
            body, @"Body",
            [NSNumber numberWithUnsignedInteger:bodyType], @"BodyType",
            recipients, @"Recipients",
            from, @"From", nil];
}

- (NSDictionary *) folderWithID:(NSString *)folderID {
    FMDatabase *db = [[FMDatabase alloc] initWithPath:databasePath];
    if (![db open]) {
        NSLog(@"Database open error");
        [db release];
        return nil;
    }
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM FOLDERS WHERE FolderID = %@", folderID];
    NSDictionary *result;
    
    if ([resultSet next]) {
        result = [self dictionaryForFolderFromResultSet:resultSet];
    }
    else {
        ServerWhisperer *whisperer = [[ServerWhisperer alloc] initWithUserDefaults];
        result = [whisperer getFolderWithID:folderID];
        [whisperer release];
        
        [self addFolderUsingDictionary:result inDatabase:db];
        
        if (!result)
            NSLog(@"no folders with FolderID == %@", folderID);
    }
    
    [db close];
    [db release];
    
    return result;
}

- (NSDictionary *) itemWithID:(NSString *)itemID {
    FMDatabase *db = [[FMDatabase alloc] initWithPath:databasePath];
    if (![db open]) {
        NSLog(@"Database open error");
        [db release];
        return nil;
    }
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM ITEMS WHERE ItemID = %@", itemID];
    NSDictionary *result;
    
    if ([resultSet next]) {
        result = [self dictionaryForItemFromResultSet:resultSet];
    }
    else {
        ServerWhisperer *whisperer = [[ServerWhisperer alloc] initWithUserDefaults];
        result = [whisperer getItemWithID:itemID];
        [whisperer release];
        
        [self addItemUsingDictionary:result inDatabase:db];
        [self addRecipientsForMessageWithID:[result objectForKey:@"ItemID"] usingArray:[result objectForKey:@"Recipients"] inDatabase:db];
        
        if (!result)
            NSLog(@"no folders with FolderID == %@", itemID);
    }
    
    [db close];
    [db release];
    
    return result;
}

- (NSArray *) foldersInFolderWithID:(NSString *)folderID {
    FMDatabase *db = [[FMDatabase alloc] initWithPath:databasePath];
    if (![db open]) {
        NSLog(@"Database open error");
        [db release];
        return nil;
    }
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM FOLDERS WHERE ParentFolderID = %@", folderID];
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[self dictionaryForFolderFromResultSet:resultSet]];
    }
    
    [db close];
    [db release];
    
    return result;
}

- (NSArray *) itemsInFolderWithID:(NSString *)folderID {
    FMDatabase *db = [[FMDatabase alloc] initWithPath:databasePath];
    if (![db open]) {
        NSLog(@"Database open error");
        [db release];
        return nil;
    }
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM ITEMS WHERE ParentFolderID = %@", folderID];
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[self dictionaryForItemFromResultSet:resultSet]];
    }
    
    [db close];
    [db release];
    
    return result;
}

- (NSArray *) foldersAndItemsInFolderWithID:(NSString *)folderID {
    NSMutableArray *result = [NSMutableArray arrayWithArray:[self foldersInFolderWithID:folderID]];
    [result addObjectsFromArray:[self itemsInFolderWithID:folderID]];
    
    return result;
}

- (NSString *) ParentIDForFolderWithID:(NSString *)folderID {
    return [[self folderWithID:folderID] objectForKey:@"ParentFolderID"];
}

- (BOOL) sendMessageUsingDictionary:(NSDictionary *)messageDictionary {
    ServerWhisperer *whisperer = [[ServerWhisperer alloc] initWithUserDefaults];
    BOOL result;
    
    if ([whisperer sendMessageUsingDictionary:messageDictionary]) {
        FMDatabase *db = [[FMDatabase alloc] initWithPath:databasePath];
        if ([db open]) {
            [self addItemUsingDictionary:messageDictionary inDatabase:db];
            
            [db close];
            [db release];
            
            result = YES;
        }
        else {
            NSLog(@"Database open error");
            [db release];
            result =  NO;
        }
    }
    else {
        NSLog(@"Can't create new message");
        result =  NO;
    }
    
    [whisperer release];
    
    return result;
}

- (void) addFolderUsingDictionary:(NSDictionary *)folderDictionary inDatabase:(FMDatabase *)db {
    [db executeUpdate:@"INSERT INTO FOLDERS VALUES ((:FolderID), (:FolderIDChangeKey), (:ParentFolderID), (:ParentFolderIDChangeKey), (:DisplayName), (:TotalCount), (:UnreadCount), (:SyncState))" withParameterDictionary:folderDictionary];
}

- (void) updateFolderUsingDictionary:(NSDictionary *)folderDictionary inDatabase:(FMDatabase *)db {
    [db executeUpdate:@"UPDATE FOLDERS SET FolderIDChangeKey = (:FolderIDChangeKey), ParentFolderID = (:ParentFolderID), ParentFolderIDChangeKey = (:ParentFolderIDChangeKey), DisplayName = (:DisplayName), TotalCount = (:TotalCount), UnreadCount = (:UnreadCount), SyncState = (:SyncState) WHERE FolderID = (:FolderID)" withParameterDictionary:folderDictionary];
}

- (void) updateSyncStateForFolder:(NSString *)folderID usingSyncState:(NSString *)syncState inDatabase:(FMDatabase *)db {
    [db executeUpdateWithFormat:@"UPDATE FOLDERS SET SyncState = %@ WHERE FolderID = %@", syncState, folderID];
}

- (void) deleteFoldeUsingDictionary:(NSDictionary *)folderDictionary inDatabase:(FMDatabase *)db {
    [db executeUpdateWithFormat:@"DELETE FROM FOLDERS WHERE FolderID = %@", [folderDictionary objectForKey:@"FolderID"]];
}

- (void) addItemUsingDictionary:(NSDictionary *)itemDictionary inDatabase:(FMDatabase *)db {
    NSDictionary *from = [itemDictionary objectForKey:@"From"];
    NSString *fromName = [from objectForKey:@"Name"];
    NSString *fromEmailAddress = [from objectForKey:@"EmailAddress"];
    
    NSDictionary *modifiedItemDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                   [itemDictionary objectForKey:@"ItemID"], @"ItemID",
                                                   [itemDictionary objectForKey:@"ItemIDChangeKey"], @"ItemIDChangeKey",
                                                   [itemDictionary objectForKey:@"ParentFolderID"], @"ParentFolderID",
                                                   [itemDictionary objectForKey:@"ParentFolderIDChangeKey"], @"ParentFolderIDChangeKey",
                                                   [itemDictionary objectForKey:@"Subject"], @"Subject",
                                                   [itemDictionary objectForKey:@"Body"], @"Body",
                                                   [itemDictionary objectForKey:@"BodyType"], @"BodyType",
                                                   fromName, @"FromName",
                                                   fromEmailAddress, @"FromEmailAddress", nil];
    
    
    [db executeUpdate:@"INSERT INTO ITEMS VALUES ((:ItemID), (:ItemIDChangeKey), (:ParentFolderID), (:ParentFolderIDChangeKey), (:Subject), (:Body), (:BodyType), (:FromName), (:FromEmailAddress))" withParameterDictionary:modifiedItemDictionary];
    
    [modifiedItemDictionary release];
}

- (void) updateItemUsingDictionary:(NSDictionary *)itemDictionary inDatabase:(FMDatabase *)db {
    NSDictionary *from = [itemDictionary objectForKey:@"From"];
    NSString *fromName = [from objectForKey:@"Name"];
    NSString *fromEmailAddress = [from objectForKey:@"EmailAddress"];
    
    NSMutableDictionary *modifiedItemDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                   [itemDictionary objectForKey:@"ItemID"], @"ItemID",
                                                   [itemDictionary objectForKey: @"ItemIDChangeKey"], @"ItemIDChangeKey",
                                                   [itemDictionary objectForKey:@"ParentFolderID"], @"ParentFolderID",
                                                   [itemDictionary objectForKey:@"ParentFolderIDChangeKey"], @"ParentFolderIDChangeKey",
                                                   [itemDictionary objectForKey:@"Subject"], @"Subject",
                                                   [itemDictionary objectForKey:@"Body"], @"Body",
                                                   [itemDictionary objectForKey:@"BodyType"], @"BodyType",
                                                   fromName, @"FromName",
                                                   fromEmailAddress, @"FromEmailAddress", nil];
    
    [db executeUpdate:@"UPDATE ITEMS SET ItemIDChangeKey = (:ItemIDChangeKey), ParentFolderID = (:ParentFolderID), ParentFolderIDChangeKey = (:ParentFolderIDChangeKey), Subject = (:Subject), Body = (:Body), BodyType = (:BodyType), FromName = (:FromName), FromEmailAddress = (:FromEmailAddress)" withParameterDictionary:modifiedItemDictionary];
    
    [modifiedItemDictionary release];
}

- (void) deleteItemUsingDictionary:(NSDictionary *)itemDictionary inDatabase:(FMDatabase *)db {
    [db executeUpdateWithFormat:@"DELETE FROM ITEMS WHERE ItemID = %@", [itemDictionary objectForKey:@"ItemID"]];
}

- (void) addRecipientForMessageWithID:(NSString *)itemID usingDictionary:(NSDictionary *)recipientDictionary inDatabase:(FMDatabase *)db {
    NSDictionary *modifiedRecipientDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:itemID, @"ItemID",
                                                 [recipientDictionary objectForKey:@"Name"], @"Name",
                                                 [recipientDictionary objectForKey:@"EmailAddress"], @"EmailAddress", nil];
    
    [db executeUpdate:@"INSERT INTO RECIPIENTS VALUES ((:ItemID), (:Name), (:EmailAddress))" withParameterDictionary:modifiedRecipientDictionary];
    
    [modifiedRecipientDictionary release];
}

- (void) addRecipientsForMessageWithID:(NSString *) itemID usingArray:(NSArray *)recipientsArray inDatabase:(FMDatabase *)db {
    for (NSDictionary *recipient in recipientsArray)
        [self addRecipientForMessageWithID:itemID usingDictionary:recipient inDatabase:db];
}

- (void) updateRecipientsForMessageWithID:(NSString *) itemID usingArray:(NSArray *)recipientsArray inDatabase:(FMDatabase *)db {
    [self deleteRecipientsForMessageWithID:itemID inDatabase:db];
    [self addRecipientsForMessageWithID:itemID usingArray:recipientsArray inDatabase:db];
}

- (void) deleteRecipientsForMessageWithID:(NSString *)itemID inDatabase:(FMDatabase *)db {
    [db executeUpdateWithFormat:@"DELETE FROM RECIPIENTS WHERE ItemID = %@", itemID];
}

- (void) updateDatabaseAsynchronously {
    FMDatabase *db = [[FMDatabase alloc] initWithPath:databasePath];
    [db setLogsErrors:YES];
    if (![db open]) {
        NSLog(@"Database open error");
        [db release];
        return;
    }
    
    NSString *folderID = [self.updateReciever currentFolderID];
    BOOL updateNeeded = NO;
    
    ServerWhisperer *whisperer = [[ServerWhisperer alloc] initWithUserDefaults];
    NSDictionary *hierarchyChanges = [whisperer syncFolderHierarchyUsingSyncState:hierarchySyncState];
    if (![hierarchySyncState isEqualToString:[hierarchyChanges objectForKey:@"SyncState"]]) {
        NSArray *hierarchyCreates = [hierarchyChanges objectForKey:@"Create"];
        NSArray *hierarchyUpdates = [hierarchyChanges objectForKey:@"Update"];
        NSArray *hierarchyDeletes = [hierarchyChanges objectForKey:@"Delete"];
        
        for (NSDictionary *folderToCreate in hierarchyCreates) {
            [self addFolderUsingDictionary:folderToCreate inDatabase:db];
            if (!updateNeeded && [[folderToCreate objectForKey:@"ParentFolderID"] isEqualToString:folderID])
                updateNeeded = YES;
        }
        for (NSDictionary *folderToUpdate in hierarchyUpdates) {
            [self updateFolderUsingDictionary:folderToUpdate inDatabase:db];
            if (!updateNeeded && [[folderToUpdate objectForKey:@"ParentFolderID"] isEqualToString:folderID])
                updateNeeded = YES;
        }
        for (NSDictionary *folderToDelete in hierarchyDeletes) {
            [self deleteFoldeUsingDictionary:folderToDelete inDatabase:db];
            if (!updateNeeded && [[folderToDelete objectForKey:@"ParentFolderID"] isEqualToString:folderID])
                updateNeeded = YES;
        }
        
        [self setHierarchySyncState:[hierarchyChanges objectForKey:@"SyncState"]];
    }
    
    FMResultSet *folders = [db executeQuery:@"SELECT * FROM FOLDERS"];
    while ([folders next]) {
        NSString *currentFolderID = [folders stringForColumn:@"FolderID"];
        NSString *currentSyncState = [folders stringForColumn:@"SyncState"];
        
        NSDictionary *folderChanges = [whisperer syncItemsInFoldeWithID:currentFolderID usingSyncState:currentSyncState];
        NSString *folderChangesSyncState = [folderChanges objectForKey:@"SyncState"];
        
        if (![currentSyncState isEqualToString:folderChangesSyncState]) {
            NSArray *folderCreates = [folderChanges objectForKey:@"Create"];
            NSArray *folderUpdates = [folderChanges objectForKey:@"Update"];
            NSArray *folderDeletes = [folderChanges objectForKey:@"Delete"];
            
            for (NSDictionary *itemToCreate in folderCreates) {
                [self addItemUsingDictionary:itemToCreate inDatabase:db];
                [self addRecipientsForMessageWithID:[itemToCreate objectForKey:@"ItemID"] usingArray:[itemToCreate objectForKey:@"Recipients"] inDatabase:db];
                if (!updateNeeded && [[itemToCreate objectForKey:@"ParentFolderID"] isEqualToString:folderID])
                    updateNeeded = YES;
            }
            for (NSDictionary *itemToUpdate in folderUpdates) {
                [self updateItemUsingDictionary:itemToUpdate inDatabase:db];
                [self updateRecipientsForMessageWithID:[itemToUpdate objectForKey:@"ItemID"] usingArray:[itemToUpdate objectForKey:@"Recipients"] inDatabase:db];
                if (!updateNeeded && [[itemToUpdate objectForKey:@"ParentFolderID"] isEqualToString:folderID])
                    updateNeeded = YES;
            }
            for (NSDictionary *itemToDelete in folderDeletes) {
                [self deleteItemUsingDictionary:itemToDelete inDatabase:db];
                [self deleteRecipientsForMessageWithID:[itemToDelete objectForKey:@"ItemID"] inDatabase:db];
                if (!updateNeeded && [[itemToDelete objectForKey:@"ParentFolderID"] isEqualToString:folderID])
                    updateNeeded = YES;
            }
            
            [self updateSyncStateForFolder:currentFolderID usingSyncState:folderChangesSyncState inDatabase:db];
        }
    }
    
    [db close];
    [db release];
    [whisperer release];
    
    if (updateNeeded) {
        [self.updateReciever dataBaseManager:self haveAnUpdate:[self foldersAndItemsInFolderWithID:folderID]];
    }
}

- (NSDictionary *) updateDatabaseSynchronously {
    FMDatabase *db = [[FMDatabase alloc] initWithPath:databasePath];
    [db setLogsErrors:YES];
    if (![db open]) {
        NSLog(@"Database open error");
        [db release];
        return nil;
    }
    
    NSMutableArray *allCreated = [[NSMutableArray alloc] init];
    NSMutableArray *allUpdated = [[NSMutableArray alloc] init];
    NSMutableArray *allDeleted = [[NSMutableArray alloc] init];
    
    ServerWhisperer *whisperer = [[ServerWhisperer alloc] initWithUserDefaults];
    NSDictionary *hierarchyChanges = [whisperer syncFolderHierarchyUsingSyncState:hierarchySyncState];
    if (![hierarchySyncState isEqualToString:[hierarchyChanges objectForKey:@"SyncState"]]) {
        NSArray *hierarchyCreates = [hierarchyChanges objectForKey:@"Create"];
        [allCreated addObjectsFromArray:hierarchyCreates];
        NSArray *hierarchyUpdates = [hierarchyChanges objectForKey:@"Update"];
        [allUpdated addObjectsFromArray:hierarchyUpdates];
        NSArray *hierarchyDeletes = [hierarchyChanges objectForKey:@"Delete"];
        [allDeleted addObjectsFromArray:hierarchyDeletes];
        
        for (NSDictionary *folderToCreate in hierarchyCreates)
            [self addFolderUsingDictionary:folderToCreate inDatabase:db];
        for (NSDictionary *folderToUpdate in hierarchyUpdates)
            [self updateFolderUsingDictionary:folderToUpdate inDatabase:db];
        for (NSDictionary *folderToDelete in hierarchyDeletes)
            [self deleteFoldeUsingDictionary:folderToDelete inDatabase:db];
        
        [self setHierarchySyncState:[hierarchyChanges objectForKey:@"SyncState"]];
    }
    
    FMResultSet *folders = [db executeQuery:@"SELECT * FROM FOLDERS"];
    while ([folders next]) {
        NSString *currentFolderID = [folders stringForColumn:@"FolderID"];
        NSString *currentSyncState = [folders stringForColumn:@"SyncState"];
        
        NSDictionary *folderChanges = [whisperer syncItemsInFoldeWithID:currentFolderID usingSyncState:currentSyncState];
        NSString *folderChangesSyncState = [folderChanges objectForKey:@"SyncState"];
        
        if (![currentSyncState isEqualToString:folderChangesSyncState]) {
            NSArray *folderCreates = [folderChanges objectForKey:@"Create"];
            [allCreated addObjectsFromArray:folderCreates];
            NSArray *folderUpdates = [folderChanges objectForKey:@"Update"];
            [allUpdated addObjectsFromArray:folderUpdates];
            NSArray *folderDeletes = [folderChanges objectForKey:@"Delete"];
            [allDeleted addObjectsFromArray:folderDeletes];
            
            for (NSDictionary *itemToCreate in folderCreates) {
                [self addItemUsingDictionary:itemToCreate inDatabase:db];
                [self addRecipientsForMessageWithID:[itemToCreate objectForKey:@"ItemID"] usingArray:[itemToCreate objectForKey:@"Recipients"] inDatabase:db];
            }
            for (NSDictionary *itemToUpdate in folderUpdates) {
                [self updateItemUsingDictionary:itemToUpdate inDatabase:db];
                [self updateRecipientsForMessageWithID:[itemToUpdate objectForKey:@"ItemID"] usingArray:[itemToUpdate objectForKey:@"Recipients"] inDatabase:db];
            }
            for (NSDictionary *itemToDelete in folderDeletes) {
                [self deleteItemUsingDictionary:itemToDelete inDatabase:db];
                [self deleteRecipientsForMessageWithID:[itemToDelete objectForKey:@"ItemID"] inDatabase:db];
            }
            
            [self updateSyncStateForFolder:currentFolderID usingSyncState:folderChangesSyncState inDatabase:db];
        }
    }
    
    [db close];
    [db release];
    [whisperer release];
    
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:allCreated, @"Create",
                                allUpdated, @"Update",
                                allDeleted, @"Delete", nil];
    
    [allCreated release];
    [allDeleted release];
    [allUpdated release];
    
    return result;
}

- (void) resetDatabase {
    FMDatabase *db = [[FMDatabase alloc] initWithPath:databasePath];
    if (![db open]) {
        NSLog(@"Database open error");
        [db release];
        return;
    }
    
    [db executeUpdate:@"DROP TABLE IF EXISTS FOLDERS"];
    [db executeUpdate:@"DROP TABLE IF EXISTS ITEMS"];
    [db executeUpdate:@"DROP TABLE IF EXISTS RECIPIETNS"];
    
    [db executeUpdate:@"CREATE TABLE FOLDERS (FolderID, FolderIDChangeKey, ParentFolderID, ParentFolderIDChangeKey, DisplayName, TotalCount, UnreadCount, SyncState)"];
    [db executeUpdate:@"CREATE TABLE ITEMS (ItemID, ItemIDChangeKey, ParentFolderID, ParentFolderIDChangeKey, Subject, Body, BodyType, FromName, FromEmailAddress)"];
    [db executeUpdate:@"CREATE TABLE RECIPIENTS (ItemID, Name, EmailAddress)"];
    [db executeUpdate:@"CREATE TABLE PARAMETERS (ParameterName, ParameterValue)"];
    [db executeUpdateWithFormat:@"INSERT INTO PARAMETERS VALUES (%@, %@)", @"HierarchySyncState", @""];
    
    /*FMResultSet *resultSetDebug = [db executeQueryWithFormat:@"SELECT * FROM PARAMETERS"];
    while ([resultSetDebug next]) {
        NSLog(@"%@ - %@", [resultSetDebug stringForColumn:@"ParameterName"], [resultSetDebug stringForColumn:@"ParameterValue"]);
    }*/
    
    if (hierarchySyncState)
        [hierarchySyncState release];
    hierarchySyncState = @"";
    [hierarchySyncState retain];
    
    [db close];
    [db release];
}

@end
