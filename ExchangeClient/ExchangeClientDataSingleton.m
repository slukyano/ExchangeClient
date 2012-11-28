//
//  ExchangeClientDataSingleton.m
//  ExchangeClient
//
//  Created by Администратор on 20.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "ExchangeClientDataSingleton.h"
#import "Defines.h"

@implementation ExchangeClientDataSingleton

@synthesize dataArray;

static ExchangeClientDataSingleton *_instance;

+ (ExchangeClientDataSingleton *) instance {
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [[ExchangeClientDataSingleton alloc] init];
            
            NSDictionary *folderRoot = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"Folder", @"Type",
                                        @"111", @"FolderID",
                                       @"", @"ParentFolderID",
                                       @"Root", @"DisplayName", nil];
            NSDictionary *folderInbox = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"Folder", @"Type",
                                        @"222", @"FolderID",
                                        @"111", @"ParentFolderID",
                                        @"Inbox", @"DisplayName", nil];
            NSDictionary *folderSent = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"Folder", @"Type",
                                        @"333", @"FolderID",
                                        @"111", @"ParentFolderID",
                                        @"Sent", @"DisplayName", nil];
            NSDictionary *folderImportant = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"Folder", @"Type",
                                        @"444", @"FolderID",
                                        @"222", @"ParentFolderID",
                                        @"Important", @"DisplayName", nil];
            
            NSDictionary *mail1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Mail", @"Type",
                                   @"m1", @"ItemID",
                                   @"222", @"ParentFolderID",
                                   @"Subject of mail1", @"Subject",
                                   @"Body of mail1", @"Body",
                                   EMailContentTypePlainText, @"BodyType", nil];
            NSDictionary *mail2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Mail", @"Type",
                                   @"m2", @"ItemID",
                                   @"222", @"ParentFolderID",
                                   @"Subject of mail2", @"Subject",
                                   @"Body of mail2", @"Body",
                                   EMailContentTypePlainText, @"BodyType", nil];
            NSDictionary *mail3 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Mail", @"Type",
                                   @"m3", @"ItemID",
                                   @"444", @"ParentFolderID",
                                   @"Subject of mail3", @"Subject",
                                   @"Body of mail3", @"Body",
                                   EMailContentTypePlainText, @"BodyType", nil];
            NSDictionary *mail4 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Mail", @"Type",
                                   @"m1", @"ItemID",
                                   @"333", @"ParentFolderID",
                                   @"Subject of mail4", @"Subject",
                                   @"Body of mail4", @"Body",
                                   EMailContentTypePlainText, @"BodyType", nil];
            _instance.dataArray = [NSMutableArray arrayWithObjects:folderRoot,folderInbox,folderSent, folderImportant,mail1,mail2,mail3,mail4, nil];
            
        }
    }
    
    return _instance;
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
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (currentFolderID != @"111"){
        NSDictionary *backItem = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"Folder", @"Type",
                                  @"/...", @"DisplayName", nil];
        [result addObject:backItem];
    } 
    for (NSDictionary *dict in dataArray) {
        if ([dict valueForKey:@"ParentFolderID"] == currentFolderID)
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
@end
