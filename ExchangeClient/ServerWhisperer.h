//
//  ServerWhisperer.h
//  ExchangeClient
//
//  Created by LSA on 15/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerWhispererDelegate;

@interface ServerWhisperer : NSObject
@property (nonatomic, retain) NSURL *serverURL;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

- (id) initWithServerURL:(NSURL *)serverURL withUsername:(NSString *)username withPassword:(NSString *)password;

// Запрос для проверки пользовательских данных
- (BOOL) testUserCredential;
// Получение свойств папки
/* Методы возвращают словарь папки. Ключи (Все ключи и значения, кроме DataType, - NSString):
 DataType - тип объекта (ключ - NSString, значение - NSNumber, содержащий DataTypeFolder)
 FolderID - по нему и нужно делать запрос
 FolderIDChangeKey - пока не используем
 ParentFolderID
 ParentFolderIDChangeKey
 DisplayName - это имя сервер предлагает вывести
 TotalCount - число элементов в папке
 UnreadCount - число непрочитанных писем
 */
- (NSDictionary *) getFolderWithID:(NSString *)folderID;
- (NSDictionary *) getFolderWithDistinguishedID:(NSString *)distinguishedFolderID;

// Получение свойств элемента
/* Метод передает словарь письма. Ключи (Все ключи - NSString, все значения, кроме DataType, BodyType, Recipients и From - NSString):
 DataType - тип объекта (ключ - NSString, значение - NSNumber, содержащий DataTypeItem)
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
- (NSDictionary *) getItemWithID:(NSString *)itemID;

// Получение изменений содержимого папки
// Возвращает словарь изменений. Ключи - @"Create", @"Update", @"Delete", значения - массивы словарей писем.
- (NSDictionary *) syncItemsInFoldeWithID:(NSString *)folderID usingSyncState:(NSString *)syncState;

// Получение изменений дерева папок
// Возвращает словарь изменений. Ключи - @"Create", @"Update", @"Delete", значения - массивы словарей папок.
- (NSDictionary *) syncFolderHierarchyUsingSyncState:(NSString *)syncState;

// Получение дочерних папок (только первый уровень вложенности) указанной папки
// Возвращает массив словарей, как в getFolderWithID
- (NSArray *) getFoldersInFolderWithID:(NSString *)folderID;
- (NSArray *) getFoldersInFolderWithDistinguishedID:(NSString *)distinguishedFolderID;

// Получение содержимого папки
// Возвращает массив словарей, как в getItemWithID
- (NSArray *) getItemsInFolderWithID:(NSString *)folderID;
- (NSArray *) getItemsInFolderWithDistinguishedID:(NSString *)distinguishedFolderID;

@end
