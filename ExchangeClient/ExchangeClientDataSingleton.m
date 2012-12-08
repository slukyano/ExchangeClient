//
//  ExchangeClientDataSingleton.m
//  ExchangeClient
//
//  Created by Администратор on 20.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "ExchangeClientDataSingleton.h"
#import "Defines.h"
#import "DataBaseManager.h"
#import "ServerWhisperer.h"

@interface ExchangeClientDataSingleton () {
    NSMutableArray *dataArray;
}

- (void) updateData;

@end

@implementation ExchangeClientDataSingleton

@synthesize messageRootFolderID = _messageRootFolderID;

static ExchangeClientDataSingleton *_instance;

+ (ExchangeClientDataSingleton *) instance {
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [[ExchangeClientDataSingleton alloc] init];
            [_instance updateData];
            
            /*NSDictionary *folderRoot = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"Folder", @"Type",
                                        @"111", @"FolderID",
                                       @"", @"ParentFolderID",
                                       @"Root", @"DisplayName",
                                        @"0", @"UnreadCount", nil];
            NSDictionary *folderInbox = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"Folder", @"Type",
                                        @"222", @"FolderID",
                                        @"111", @"ParentFolderID",
                                        @"Inbox", @"DisplayName",
                                        @"0", @"UnreadCount", nil];
            NSDictionary *folderSent = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"Folder", @"Type",
                                        @"333", @"FolderID",
                                        @"111", @"ParentFolderID",
                                        @"Sent", @"DisplayName",
                                        @"0", @"UnreadCount", nil];
            NSDictionary *folderImportant = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"Folder", @"Type",
                                        @"444", @"FolderID",
                                        @"222", @"ParentFolderID",
                                        @"Important", @"DisplayName",
                                        @"1", @"UnreadCount", nil];
            
            NSDictionary *mail1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Mail", @"Type",
                                   @"m1", @"ItemID",
                                   @"222", @"ParentFolderID",
                                   @"Subject of mail1", @"Subject",
                                   @"Body of mail1", @"Body",
                                   [NSNumber numberWithUnsignedInteger:EMailContentTypePlainText], @"BodyType", nil];
            NSDictionary *mail2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Mail", @"Type",
                                   @"m2", @"ItemID",
                                   @"222", @"ParentFolderID",
                                   @"Subject of mail2", @"Subject",
                                   @"Body of mail2", @"Body",
                                   [NSNumber numberWithUnsignedInteger:EMailContentTypePlainText], @"BodyType", nil];
            NSDictionary *mail3 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Mail", @"Type",
                                   @"m3", @"ItemID",
                                   @"444", @"ParentFolderID",
                                   @"Subject of mail3", @"Subject",
                                   @"Body of mail3", @"Body",
                                   [NSNumber numberWithUnsignedInteger:EMailContentTypePlainText], @"BodyType", nil];
            NSDictionary *mail4 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Mail", @"Type",
                                   @"m1", @"ItemID",
                                   @"333", @"ParentFolderID",
                                   @"Subject of mail4", @"Subject",
                                   @"Body of mail4", @"Body",
                                   [NSNumber numberWithUnsignedInteger:EMailContentTypePlainText], @"BodyType", nil];
            _instance.dataArray = [NSMutableArray arrayWithObjects:folderRoot,folderInbox,folderSent, folderImportant,mail1,mail2,mail3,mail4, nil];*/
            
        }
    }
    
    return _instance;
}

- (id) init {
    self = [super init];
    if (self) {
        dataArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSUInteger) count {
    return [dataArray count];
}

- (id) objectAtIndex:(NSUInteger)index {
    return [dataArray objectAtIndex:index];
}

- (void) addObject:(id)anObject {
    [dataArray addObject:anObject];
}

- (void) removeObjectAtIndex:(NSUInteger)index {
    [dataArray removeObjectAtIndex:index];
}

- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [dataArray replaceObjectAtIndex:index withObject:anObject];
}

- (NSMutableArray *) ItemsInFolderWithID:(NSString *)currentFolderID{
    NSMutableArray *result = [NSMutableArray array];
    if (![currentFolderID isEqualToString:_messageRootFolderID]){
        NSDictionary *backItem = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInteger:DataTypeFolder], @"DataType",
                                  @"/...", @"DisplayName", nil];
        [result addObject:backItem];
    }
    
    for (NSDictionary *dict in dataArray) {
        if ([[dict valueForKey:@"ParentFolderID"] isEqualToString:currentFolderID])
            [result addObject:dict];
    }
    return result;
}

- (NSString *)ParentIDForFolderWithID:(NSString *)currentFolderID{
    for (NSDictionary *dict in dataArray) {
        if ([dict valueForKey:@"FolderID"] == currentFolderID)
            return [dict valueForKey:@"ParentFolderID"];
    }
    return @"error";
}

- (void) updateData {
    //DataBaseManager *dataBaseManager = [[DataBaseManager alloc] initWithDatabaseForUser:@"sed2"];
    
    //NSDictionary *changes = [dataBaseManager updateDatabaseSynchronously];
    
    //[dataBaseManager release];
    
    ServerWhisperer *whisperer = [[ServerWhisperer alloc] initWithUserDefaults];
    NSMutableArray *createFolders = [[whisperer syncFolderHierarchyUsingSyncState:nil] objectForKey:@"Create"];
    NSMutableArray *createItems = [NSMutableArray array];
    for (NSDictionary *dict in createFolders) {
        [createItems addObjectsFromArray:[[whisperer syncItemsInFoldeWithID:[dict objectForKey:@"FolderID"] usingSyncState:nil] objectForKey:@"Create"]];
    }
    
    [dataArray addObjectsFromArray:createFolders];
    [dataArray addObjectsFromArray:createItems];
    
    NSString *inboxID = [[whisperer getFolderWithDistinguishedID:@"inbox"] objectForKey:@"FolderID"];
    for (NSDictionary *dict in dataArray) {
        if ([dict objectForKey:@"ParentFolderID"] == inboxID)
            NSLog(@"%@", dict);
    }
    NSLog(@"%@", [whisperer getItemsInFolderWithDistinguishedID:@"inbox"]);
    [whisperer release];
    //[dataArray addObjectsFromArray:[changes objectForKey:@"Create"]];
    /*
    for (NSDictionary *objectToUpdate in [changes objectForKey:@"Update"]) {
        for (NSDictionary *currentObject in dataArray)
            if (([[currentObject objectForKey:@"DataType"] isEqualToNumber:[NSNumber numberWithInt:DataTypeFolder]]
                 && [[objectToUpdate objectForKey:@"DataType"] isEqualToNumber:[NSNumber numberWithInt:DataTypeFolder]]
                 && [[currentObject objectForKey:@"FolderID"] isEqualToString:[objectToUpdate objectForKey:@"FolderID"]])
                || ([[currentObject objectForKey:@"DataType"] isEqualToNumber:[NSNumber numberWithInt:DataTypeEMail]]
                    && [[objectToUpdate objectForKey:@"DataType"] isEqualToNumber:[NSNumber numberWithInt:DataTypeEMail]]
                    && [[currentObject objectForKey:@"ItemID"] isEqualToString:[objectToUpdate objectForKey:@"ItemID"]]))
            {
                [dataArray removeObject:currentObject];
                [dataArray addObject:objectToUpdate];
            }
    }
    
    for (NSDictionary *objectToDelete in [changes objectForKey:@"Delete"]) {
        for (NSDictionary *currentObject in dataArray)
            if (([[currentObject objectForKey:@"DataType"] isEqualToNumber:[NSNumber numberWithInt:DataTypeFolder]]
                 && [[objectToDelete objectForKey:@"DataType"] isEqualToNumber:[NSNumber numberWithInt:DataTypeFolder]]
                 && [[currentObject objectForKey:@"FolderID"] isEqualToString:[objectToDelete objectForKey:@"FolderID"]])
                || ([[currentObject objectForKey:@"DataType"] isEqualToNumber:[NSNumber numberWithInt:DataTypeEMail]]
                    && [[objectToDelete objectForKey:@"DataType"] isEqualToNumber:[NSNumber numberWithInt:DataTypeEMail]]
                    && [[currentObject objectForKey:@"ItemID"] isEqualToString:[objectToDelete objectForKey:@"ItemID"]]))
            {
                [dataArray removeObject:currentObject];
            }
    }*/
}

- (NSString *) messageRootFolderID {
    if (!_messageRootFolderID) {
        ServerWhisperer *whisperer = [[ServerWhisperer alloc] initWithUserDefaults];
        
        NSDictionary *messageRootFolder = [whisperer getFolderWithDistinguishedID:@"msgfolderroot"];
        
        _messageRootFolderID = [[messageRootFolder objectForKey:@"FolderID"] retain];
        
        [whisperer release];
    }
    return _messageRootFolderID;
}

@end
