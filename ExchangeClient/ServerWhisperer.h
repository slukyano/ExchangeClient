//
//  ServerWhisperer.h
//  ExchangeClient
//
//  Created by LSA on 15/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConnectionManager.h"

@protocol ServerWhispererDelegate;

@interface ServerWhisperer : NSObject <ConnectionManagerDelegate>

@property (nonatomic, retain) NSURL *serverURL;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, assign) id<ServerWhispererDelegate> delegate;

// Предполагается, что инициализирует его LoginViewController, и он же назначит делегатом TableViewController'а. Можно и по другому, на работу не влияет.
- (id) initWithServerURL:(NSURL *)serverURL withUserName:(NSString *)userName withPassword:(NSString *)password withDelegate:(id<ServerWhispererDelegate>)delegate;
// Получения свойств папки
- (void) getFolderWithID:(NSString *)folderID;
- (void) getFolderWithDistinguishedID:(NSString *)distinguishedFolderID;
// Получение свойств элемента
- (void) getItemWithID:(NSString *)itemID;
// Получение изменений содержимого папки
- (void) syncItemsInFoldeWithID:(NSString *)folderID usingSyncState:(NSString *)syncState;
// Получение изменений дерева папок
- (void) syncFolderHierarchyUsingSyncState:(NSString *)syncState;
// Получение дочерних папок (только первый уровень вложенности) указанной папки
- (void) getFoldersInFolderWithID:(NSString *)folderID;
- (void) getFoldersInFolderWithDistinguishedID:(NSString *)distinguishedFolderID;
// Получение содержимого папки
- (void) getItemsInFolderWithID:(NSString *)folderID;
- (void) getItemsInFolderWithDistinguishedID:(NSString *)distinguishedFolderID;

@end

@protocol ServerWhispererDelegate <NSObject>

/* Метод передает словарь папки. Ключи (Все ключи и значения - NSString):
 FolderID - по нему и нужно делать запрос
 FolderIDChangeKey - пока не используем
 ParentFolderID
 ParentFolderIDChangeKey
 DisplayName - это имя сервер предлагает вывести
 TotalCount - число элементов в папке
 UnreadCount - число непрочитанных писем
 */
- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingFolder:(NSDictionary *)folder;

/* Метод передает словарь письма. Ключи (Все ключи - NSString, все значения, кроме BodyType, Recipients и From - NSString):
 ItemID - по нему и нужно делать запрос
 ItemIDChangeKey - пока не используем
 ParentFolderID
 ParentFolderIDChangeKey
 Subject - тема письма
 Body - содержимое
 BodyType - тип содержимого письма (EMailContentType-константа, определены в Defines.h)
 Recipients - NSArray словарей получателей. Ключи словарей получателей:
 Name
 EmailAddress
 From - словарь отправителя. Ключи:
 Name
 EmailAddress
 */
- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingMessage:(NSDictionary *)message;

// Передает массив словарей, как в getItemWithID
- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingFolders:(NSArray *)folders;

// Передает массив словарей, как в getFolderWithID
- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingItems:(NSArray *)items;

// Передает словарь изменений. Ключи - @"Create", @"Update", @"Delete", значения - массивы словарей писем.
- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingItemsToSync:(NSDictionary *)itemsToSync;

// Передает словарь изменений. Ключи - @"Create", @"Update", @"Delete", значения - массивы словарей папок.
- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingFoldersToSync:(NSDictionary *)foldersToSync;

@end
