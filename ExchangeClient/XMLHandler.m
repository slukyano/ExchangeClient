//
//  XMLHandler.m
//  ExchangeClient
//
//  Created by LSA on 20/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "XMLHandler.h"
#import "GDataXMLNode.h"
#import "Defines.h"

@interface XMLHandler () {
    NSDictionary *namespaces;
}

- (NSDictionary *) dictionaryForFolderXML:(GDataXMLElement *)folderXML;
- (NSDictionary *) dictionaryForMailboxXML:(GDataXMLElement *)mailboxXML;
- (NSDictionary *) dictionaryForMessageXML:(GDataXMLElement *)messageXML;

@end

@implementation XMLHandler

- (void) dealloc {
    [namespaces release];
    
    [super dealloc];
}

- (id) init {
    self = [super init];
    if (self) {
        namespaces = [[NSDictionary alloc] initWithObjectsAndKeys:
                      @"http://schemas.microsoft.com/exchange/services/2006/messages", @"m",
                      @"http://schemas.microsoft.com/exchange/services/2006/types", @"t",
                      @"http://www.w3.org/2001/XMLSchema-instance", @"xsi",
                      @"http://www.w3.org/2001/XMLSchema", @"xsd",
                      @"http://schemas.xmlsoap.org/soap/envelope/", @"s", nil];
    }
    
    return self;
}

// Обработка элементов
- (NSDictionary *) dictionaryForFolderXML:(GDataXMLElement *)folderXML {
    GDataXMLElement *folderIDXML = [[folderXML elementsForName:@"t:FolderId"] objectAtIndex:0];
    NSString *folderID = [[folderIDXML attributeForName:@"Id"] stringValue];
    NSString *folderIDChangeKey = [[folderIDXML attributeForName:@"ChangeKey"] stringValue];
    
    GDataXMLElement *parentFolderIDXML = [[folderXML elementsForName:@"t:ParentFolderId"] objectAtIndex:0];
    NSString *parentFolderID = [[parentFolderIDXML attributeForName:@"Id"] stringValue];
    NSString *parentFolderIDChangeKey = [[parentFolderIDXML attributeForName:@"ChangeKey"] stringValue];
    
    NSString *displayName = [[[folderXML elementsForName:@"t:DisplayName"] objectAtIndex:0] stringValue];
    
    NSString *totalCount = [[[folderXML elementsForName:@"t:TotalCount"] objectAtIndex:0] stringValue];
    
    NSString *unreadCount = [[[folderXML elementsForName:@"t:UnreadCount"] objectAtIndex:0] stringValue];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:DataTypeFolder], @"DataType",
            folderID, @"FolderID",
            folderIDChangeKey, @"FolderIDChangeKey",
            parentFolderID, @"ParentFolderID",
            parentFolderIDChangeKey, @"ParentFolderIDChangeKey",
            displayName, @"DisplayName",
            totalCount, @"TotalCount",
            unreadCount, @"UnreadCount", nil];
}

- (NSDictionary *) dictionaryForMailboxXML:(GDataXMLElement *)mailboxXML {
    NSString *name = [[[mailboxXML elementsForName:@"t:Name"] objectAtIndex:0] stringValue];
    NSString *email = [[[mailboxXML elementsForName:@"t:EmailAddress"] objectAtIndex:0] stringValue];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:name, @"Name", email, @"EmailAddress", nil];
}

- (NSDictionary *) dictionaryForMessageXML:(GDataXMLElement *)messageXML {
    GDataXMLElement *itemIDXML = [[messageXML elementsForName:@"t:ItemId"] objectAtIndex:0];
    NSString *itemID = [[itemIDXML attributeForName:@"Id"] stringValue];
    NSString *itemIDChangeKey = [[itemIDXML attributeForName:@"ChangeKey"] stringValue];
    
    GDataXMLElement *parentFolderIDXML = [[messageXML elementsForName:@"t:ParentFolderId"] objectAtIndex:0];
    NSString *parentFolderID = [[parentFolderIDXML attributeForName:@"Id"] stringValue];
    NSString *parentFolderIDChangeKey = [[parentFolderIDXML attributeForName:@"ChangeKey"] stringValue];
    
    NSString *subject = [[[messageXML elementsForName:@"t:Subject"] objectAtIndex:0] stringValue];
    
    GDataXMLElement *bodyXML = [[messageXML elementsForName:@"t:Body"] objectAtIndex:0];
    NSString *body = [bodyXML stringValue];
    NSString *bodyTypeString = [[bodyXML attributeForName:@"t:BodyType"] stringValue];
    NSUInteger bodyType = [bodyTypeString isEqualToString:@"HTML"] ? EMailContentTypeHTML : EMailContentTypePlainText;
    
    GDataXMLElement *toRecipientsXML = [[messageXML elementsForName:@"t:ToRecipients"] objectAtIndex:0];
    NSArray *recipientsXML = [toRecipientsXML elementsForName:@"t:Mailbox"];
    NSMutableArray *recipients = [NSMutableArray array];
    for (GDataXMLElement *singleRecipientXML in recipientsXML)
        [recipients addObject:[self dictionaryForMailboxXML:singleRecipientXML]];
    
    GDataXMLElement *senderXML = [[messageXML elementsForName:@"t:From"] objectAtIndex:0];
    GDataXMLElement *senderMailboxXML = [[senderXML elementsForName:@"t:Mailbox"] objectAtIndex:0];
    NSDictionary *sender = [self dictionaryForMailboxXML:senderMailboxXML];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:DataTypeEMail], @"DataType",
            itemID, @"ItemID",
            itemIDChangeKey, @"ItemIDChangeKey",
            parentFolderID, @"ParentFolderID",
            parentFolderIDChangeKey, @"ParentFolderIDChangeKey",
            subject, @"Subject",
            body, @"Body",
            bodyType, @"BodyType",
            recipients, @"Recipients",
            sender, @"From", nil];
}

// Обработка ответов
- (NSDictionary *) parseGetFolderResponse:(NSData *)responseData {
    GDataXMLDocument *response = [[GDataXMLDocument alloc] initWithData:responseData
                                                                options:0
                                                                  error:nil];
    
    NSString *responseCode = [[[response nodesForXPath:@"//m:ResponseCode"
                                            namespaces:namespaces
                                                 error:nil] objectAtIndex:0] stringValue];
    if (![responseCode isEqualToString:@"NoError"]) {
        NSLog(@"Error response");
        NSLog(@"%@", [[[response nodesForXPath:@"//m:ResponseCode"
                                    namespaces:namespaces
                                         error:nil] objectAtIndex:0] stringValue]);
        return nil;
    }
    
    GDataXMLElement *folderXML = [[response nodesForXPath:@"//t:Folder"
                                               namespaces:namespaces
                                                    error:nil] objectAtIndex:0];
    NSDictionary *folderDictionary = [self dictionaryForFolderXML:folderXML];
    
    [response release];
    
    return folderDictionary;
}

- (NSDictionary *) parseGetItemResponse:(NSData *)responseData {
    GDataXMLDocument *response = [[GDataXMLDocument alloc] initWithData:responseData
                                                                options:0
                                                                  error:nil];
    
    NSString *responseCode = [[[response nodesForXPath:@"//m:ResponseCode"
                                            namespaces:namespaces
                                                 error:nil] objectAtIndex:0] stringValue];
    if (![responseCode isEqualToString:@"NoError"]) {
        NSLog(@"Error response");
        NSLog(@"%@", [[[response nodesForXPath:@"//m:ResponseCode"
                                    namespaces:namespaces
                                         error:nil] objectAtIndex:0] stringValue]);
        return nil;
    }
    
    GDataXMLElement *itemXML = [[response nodesForXPath:@"//t:Message"
                                             namespaces:namespaces
                                                  error:nil] objectAtIndex:0];
    NSDictionary *itemDictionary = [self dictionaryForMessageXML:itemXML];
    
    [response release];
    
    return itemDictionary;
}

- (NSArray *) parseFindFolderResponse:(NSData *)responseData {
    GDataXMLDocument *response = [[GDataXMLDocument alloc] initWithData:responseData
                                                                options:0
                                                                  error:nil];
    
    NSString *responseCode = [[[response nodesForXPath:@"//m:ResponseCode"
                                            namespaces:namespaces
                                                 error:nil] objectAtIndex:0] stringValue];
    if (![responseCode isEqualToString:@"NoError"]) {
        NSLog(@"Error response");
        NSLog(@"%@", [[[response nodesForXPath:@"//m:ResponseCode"
                                    namespaces:namespaces
                                         error:nil] objectAtIndex:0] stringValue]);
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray array];
    
    NSArray *folders = [response nodesForXPath:@"//t:Folder"
                                    namespaces:namespaces
                                         error:nil];
    for (GDataXMLElement *currentFolder in folders) {
        [result addObject:[self dictionaryForFolderXML:currentFolder]];
    }
    
    [response release];
    
    return result;
}

- (NSArray *) parseFindItemResponse:(NSData *)responseData {
    GDataXMLDocument *response = [[GDataXMLDocument alloc] initWithData:responseData
                                                                options:0
                                                                  error:nil];
    
    NSString *responseCode = [[[response nodesForXPath:@"//m:ResponseCode"
                                            namespaces:namespaces
                                                 error:nil] objectAtIndex:0] stringValue];
    if (![responseCode isEqualToString:@"NoError"]) {
        NSLog(@"Error response");
        NSLog(@"%@", [[[response nodesForXPath:@"//m:ResponseCode"
                                    namespaces:namespaces
                                         error:nil] objectAtIndex:0] stringValue]);
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray array];
    
    NSArray *messages = [response nodesForXPath:@"//t:Message"
                                     namespaces:namespaces
                                          error:nil];
    for (GDataXMLElement *currentMessage in messages) {
        [result addObject:[self dictionaryForMessageXML:currentMessage]];
    }
    
    [response release];
    
    return result;
}

- (NSDictionary *) parseSyncFolderHierarchyResponse:(NSData *)responseData {
    GDataXMLDocument *response = [[GDataXMLDocument alloc] initWithData:responseData
                                                                options:0
                                                                  error:nil];
    
    NSString *responseCode = [[[response nodesForXPath:@"//m:ResponseCode"
                                            namespaces:namespaces
                                                 error:nil] objectAtIndex:0] stringValue];
    if (![responseCode isEqualToString:@"NoError"]) {
        NSLog(@"Error response");
        NSLog(@"%@", [[[response nodesForXPath:@"//m:ResponseCode"
                                    namespaces:namespaces
                                         error:nil] objectAtIndex:0] stringValue]);
        return nil;
    }
    
    NSArray *foldersToCreateXML = [response nodesForXPath:@"//t:Create/t:Folder"
                                               namespaces:namespaces
                                                    error:nil];
    NSMutableArray *foldersToCreate = [NSMutableArray array];
    for (GDataXMLElement *currentFolder in foldersToCreateXML)
        [foldersToCreate addObject:[self dictionaryForFolderXML:currentFolder]];
    
    NSArray *foldersToUpdateXML = [response nodesForXPath:@"//t:Create/t:Folder"
                                               namespaces:namespaces
                                                    error:nil];
    NSMutableArray *foldersToUpdate = [NSMutableArray array];
    for (GDataXMLElement *currentFolder in foldersToUpdateXML)
        [foldersToUpdate addObject:[self dictionaryForFolderXML:currentFolder]];
    
    NSArray *foldersToDeleteXML = [response nodesForXPath:@"//t:Create/t:Folder"
                                               namespaces:namespaces
                                                    error:nil];
    NSMutableArray *foldersToDelete = [NSMutableArray array];
    for (GDataXMLElement *currentFolder in foldersToDeleteXML)
        [foldersToDelete addObject:[self dictionaryForFolderXML:currentFolder]];
    
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:foldersToCreate, @"Create",
                            foldersToUpdate, @"Update",
                            foldersToDelete, @"Delete", nil];
    
    [response release];
    
    return result;
}

- (NSDictionary *) parseSyncFolderItemsResponse:(NSData *)responseData {
    GDataXMLDocument *response = [[GDataXMLDocument alloc] initWithData:responseData
                                                                options:0
                                                                  error:nil];
    
    NSString *responseCode = [[[response nodesForXPath:@"//m:ResponseCode"
                                            namespaces:namespaces
                                                 error:nil] objectAtIndex:0] stringValue];
    if (![responseCode isEqualToString:@"NoError"]) {
        NSLog(@"Error response");
        NSLog(@"%@", [[[response nodesForXPath:@"//m:ResponseCode"
                                    namespaces:namespaces
                                         error:nil] objectAtIndex:0] stringValue]);
        return nil;
    }
    
    NSArray *messagesToCreateXML = [response nodesForXPath:@"//t:Create/t:Message"
                                                namespaces:namespaces
                                                     error:nil];
    NSMutableArray *messagesToCreate = [NSMutableArray array];
    for (GDataXMLElement *currentMessage in messagesToCreateXML)
        [messagesToCreate addObject:[self dictionaryForMessageXML:currentMessage]];
    
    NSArray *messagesToUpdateXML = [response nodesForXPath:@"//t:Create/t:Message"
                                                namespaces:namespaces
                                                     error:nil];
    NSMutableArray *messagesToUpdate = [NSMutableArray array];
    for (GDataXMLElement *currentMessage in messagesToUpdateXML)
        [messagesToUpdate addObject:[self dictionaryForMessageXML:currentMessage]];
    
    NSArray *messagesToDeleteXML = [response nodesForXPath:@"//t:Create/t:Message"
                                                namespaces:namespaces
                                                     error:nil];
    NSMutableArray *messagesToDelete = [NSMutableArray array];
    for (GDataXMLElement *currentMessage in messagesToDeleteXML)
        [messagesToDelete addObject:[self dictionaryForMessageXML:currentMessage]];
    
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:messagesToCreate, @"Create",
                            messagesToUpdate, @"Update",
                            messagesToDelete, @"Delete", nil];
    
    [response release];
    
    return result;
}

// Генерация запросов

- (NSData *) XMLRequestGetFolderWithID:(NSString *)folderID {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <GetFolder xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <FolderShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </FolderShape>\
                        <FolderIds>\
                        <t:FolderId Id=\"%@\"/>\
                        </FolderIds>\
                        </GetFolder>\
                        </soap:Body>\
                        </soap:Envelope>", folderID];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) XMLRequestGetFolderWithDistinguishedID:(NSString *)distinguishedFolderId {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <GetFolder xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <FolderShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </FolderShape>\
                        <FolderIds>\
                        <t:DistinguishedFolderId Id=\"%@\"/>\
                        </FolderIds>\
                        </GetFolder>\
                        </soap:Body>\
                        </soap:Envelope>", distinguishedFolderId];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) XMLRequestGetItemWithID:(NSString *)itemID {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope\
                        xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\
                        xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"\
                        xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <GetItem\
                        xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <ItemShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        <t:IncludeMimeContent>true</t:IncludeMimeContent>\
                        </ItemShape>\
                        <ItemIds>\
                        <t:ItemId Id=\"%@\"/>\
                        </ItemIds>\
                        </GetItem>\
                        </soap:Body>\
                        </soap:Envelope>", itemID];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) XMLRequestSyncItemsInFolderWithID:(NSString *)folderID usingSyncState:(NSString *)syncState {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <SyncFolderItems xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\">\
                        <ItemShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </ItemShape>\
                        <SyncFolderId>\
                        <t:FolderId Id=\"%@\"/>\
                        </SyncFolderId>\
                        <SyncState>%@</SyncState>\
                        <Ignore>\
                        </Ignore>\
                        <MaxChangesReturned>100</MaxChangesReturned>\
                        </SyncFolderItems>\
                        </soap:Body>\
                        </soap:Envelope>", folderID, syncState ? syncState : @""];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) XMLRequestSyncFolderHierarchyUsingSyncState:(NSString *)syncState {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <SyncFolderHierarchy  xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\">\
                        <FolderShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </FolderShape>\
                        <SyncState>%@</SyncState>\
                        </SyncFolderHierarchy>\
                        </soap:Body>\
                        </soap:Envelope>", syncState ? syncState : @""];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) XMLRequestFindFoldersInFolderWithID:(NSString *)folderID {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <FindFolder Traversal=\"Shallow\" xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\">\
                        <FolderShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </FolderShape>\
                        <ParentFolderIds>\
                        <t:FolderId Id=\"%@\"/>\
                        </ParentFolderIds>\
                        </FindFolder>\
                        </soap:Body>\
                        </soap:Envelope>", folderID];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) XMLRequestFindFoldersInFolderWithDistinguishedID:(NSString *)distinguishedFolderID {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <FindFolder Traversal=\"Shallow\" xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\">\
                        <FolderShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </FolderShape>\
                        <ParentFolderIds>\
                        <t:DistinguishedFolderId Id=\"%@\"/>\
                        </ParentFolderIds>\
                        </FindFolder>\
                        </soap:Body>\
                        </soap:Envelope>", distinguishedFolderID];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) XMLRequestFindItemsInFolderWithID:(NSString *)folderID {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <FindItem xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\"\
                        Traversal=\"Shallow\">\
                        <ItemShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </ItemShape>\
                        <ParentFolderIds>\
                        <t:FolderId Id=\"%@\"/>\
                        </ParentFolderIds>\
                        </FindItem>\
                        </soap:Body>\
                        </soap:Envelope>", folderID];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) XMLRequestFindItemsInFolderWithDistinguishedID:(NSString *)distinguishedFolderID {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <FindItem xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\"\
                        Traversal=\"Shallow\">\
                        <ItemShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </ItemShape>\
                        <ParentFolderIds>\
                        <t:DistinguishedFolderId Id=\"%@\"/>\
                        </ParentFolderIds>\
                        </FindItem>\
                        </soap:Body>\
                        </soap:Envelope>", distinguishedFolderID];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

@end
