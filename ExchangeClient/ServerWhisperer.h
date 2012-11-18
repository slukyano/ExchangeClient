//
//  ServerWhisperer.h
//  ExchangeClient
//
//  Created by LSA on 15/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConnectionManager.h"

@interface ServerWhisperer : NSObject <ConnectionManagerDelegate>

@property (nonatomic, retain) NSURL *serverURL;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *password;

// Предполагается, что инициализирует его LoginViewController, и он же назначит делегатом TableViewController'а. Можно и по другому, на работу не влияет.
- (id) initWithServerURL:(NSURL *)server withUserName:(NSString *)userName withPassword:(NSString *)password;

/* Метод возвращает словарь для папки. Ключи (Все ключи и значения - NSString):
 FolderID - по нему и нужно делать запрос
 FolderIDChangeKey - пока не используем
 ParentFolderID
 ParentFolderIDChangeKey
 DisplayName - это имя сервер предлагает вывести
 TotalCount - число элементов в папке
 UnreadCount - число непрочитанных писем
*/
- (NSDictionary *) getFolderWithID:(NSString *)folderID;

/* Метод возвращает словарь для письма. Ключи (Все ключи - NSString, все значения, кроме BodyType, Recipients и From - NSString):
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

// Возвращает массив словарей, как в getItemWithID
- (NSArray *) getItemsInFoldeWithID:(NSString *)folderID;

// Возвращает массив словарей, как в getFolderWithID
- (NSArray *) getFolderHierarchy;

@end
