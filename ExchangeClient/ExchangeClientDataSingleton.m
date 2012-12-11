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

@end

@implementation ExchangeClientDataSingleton

@synthesize messageRootFolderID = _messageRootFolderID;

static ExchangeClientDataSingleton *_instance;

+ (ExchangeClientDataSingleton *) instance {
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [[ExchangeClientDataSingleton alloc] init];
        }
    }
    
    return _instance;
}

- (id) init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

// Работа с массивом

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

// Подготовка массива

- (void) loadItemsInFolderWithID:(NSString *)currentFolderID{
    DataBaseManager *dataBaseManager = [[DataBaseManager alloc] initWithDatabaseForUser:@"sed2"];
    [dataBaseManager setUpdateAlways:YES];
    
    NSMutableArray *newDataArray = [[NSMutableArray alloc] init];
    if (![currentFolderID isEqualToString:_messageRootFolderID]){
        NSDictionary *backItem = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInteger:DataTypeFolder], @"DataType",
                                  @"/...", @"DisplayName", nil];
        [newDataArray addObject:backItem];
    }
    [newDataArray addObjectsFromArray:[dataBaseManager foldersAndItemsInFolderWithID:currentFolderID]];
    
    if (dataArray)
        [dataArray release];
    dataArray = newDataArray;
    
    //[dataBaseManager setUpdateReciever:self];
    //[dataBaseManager updateDatabaseAsynchronously];
    
    [dataBaseManager release];
}

- (void) reloadItemsInCurrentFolder {
    [self loadItemsInFolderWithID:self.currentFolderID];
}

- (NSString *) parentIDForCurrentFolder {
    return [self parentIDForFolderWithID:self.currentFolderID];
}

// Работа с folderID's

- (NSString *) parentIDForFolderWithID:(NSString *)currentFolderID{
    DataBaseManager *dataBaseManager = [[DataBaseManager alloc] initWithDatabaseForUser:@"sed2"];
    NSString *result = [dataBaseManager parentIDForFolderWithID:currentFolderID];
    [dataBaseManager release];
    
    return result;
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

// Методы DataBaseManagerUpdateReciever

- (void) dataBaseManager:(DataBaseManager *)db haveAnUpdate:(NSArray *)newFolderContent forFolderWithID:(NSString *)folderID {
    if ([folderID isEqualToString:self.currentFolderID])
        [self reloadItemsInCurrentFolder];
}

@end
