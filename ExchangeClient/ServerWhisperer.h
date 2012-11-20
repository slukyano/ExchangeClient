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
- (void) getFolderWithID:(NSString *)folderID;
- (void) getItemWithID:(NSString *)itemID;
- (void) getItemsInFoldeWithID:(NSString *)folderID;
- (void) getFolderHierarchy;

@end

@protocol ServerWhispererDelegate <NSObject>

/* Метод передает словарь для папки. Ключи (Все ключи и значения - NSString):
 FolderID - по нему и нужно делать запрос
 FolderIDChangeKey - пока не используем
 ParentFolderID
 ParentFolderIDChangeKey
 DisplayName - это имя сервер предлагает вывести
 TotalCount - число элементов в папке
 UnreadCount - число непрочитанных писем
 */
- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingFolder:(NSDictionary *)folder;

/* Метод передает словарь для письма. Ключи (Все ключи - NSString, все значения, кроме BodyType, Recipients и From - NSString):
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
- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingMessage:(NSDictionary *)folder;

// Передает массив словарей, как в getItemWithID
- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingFolderHierarchy:(NSArray *)hierarchy;

// Передает массив словарей, как в getFolderWithID
- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingItems:(NSArray *)items;

@end
