//
//  ServerWhisperer.m
//  ExchangeClient
//
//  Created by LSA on 15/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "ServerWhisperer.h"
#import "GDataXMLNode.h"
#import "ConnectionManager.h"
#import "Defines.h"

typedef enum {
    ServerWhispererCurrentOperationGetFolder,
    ServerWhispererCurrentOperationGetItem,
    ServerWhispererCurrentOperationSyncFolderItems,
    ServerWhispererCurrentOperationSyncFolderHierarchy
} ServerWhispererCurrentOperation;

@interface ServerWhisperer () {
    ServerWhispererCurrentOperation _currentOperation;
    id _currentOperationResult;
}

@end

@implementation ServerWhisperer

@synthesize serverURL = _serverURL;
@synthesize userName = _userName;
@synthesize password = _password;

- (void) dealloc {
    self.serverURL = nil;
    self.userName = nil;
    self.password = nil;
    
    [super dealloc];
}

- (id) initWithServerURL:(NSURL *)serverURL withUserName:(NSString *)userName withPassword:(NSString *)password {
    self = [super init];
    if (self) {
        _serverURL = [serverURL retain];
        _userName = [userName retain];
        _password = [password retain];
    }
    
    return self;
}

- (NSDictionary *) getFolderWithID:(NSString *)folderID {
    _currentOperation = ServerWhispererCurrentOperationGetFolder;
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userName
                                                             password:self.password
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    ConnectionManager *connection = [[ConnectionManager alloc] initWithDelegate:self];
    
    [connection sendRequestToServer:_serverURL withCredential:credential withBody:[self XMLRequestSyncItemsInFolderWithID:folderID]];
    
    return _currentOperationResult;
}

- (NSDictionary *) getItemWithID:(NSString *)itemID {
    _currentOperation = ServerWhispererCurrentOperationGetItem;
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userName
                                                             password:self.password
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    ConnectionManager *connection = [[ConnectionManager alloc] initWithDelegate:self];
    
    [connection sendRequestToServer:_serverURL withCredential:credential withBody:[self XMLRequestGetItemWithID:itemID]];
    
    return _currentOperationResult;
}

- (NSArray *) getItemsInFoldeWithID:(NSString *)folderID {
    _currentOperation = ServerWhispererCurrentOperationGetItem;
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userName
                                                             password:self.password
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    ConnectionManager *connection = [[ConnectionManager alloc] initWithDelegate:self];
    
    [connection sendRequestToServer:_serverURL withCredential:credential withBody:[self XMLRequestGetItemWithID:folderID]];
    
    return _currentOperationResult;
}

- (NSArray *) getFolderHierarchy {
    _currentOperation = ServerWhispererCurrentOperationGetItem;
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userName
                                                             password:self.password
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    ConnectionManager *connection = [[ConnectionManager alloc] initWithDelegate:self];
    
    [connection sendRequestToServer:_serverURL withCredential:credential withBody:[self XMLRequestSyncFolderHierarchy]];
    
    return _currentOperationResult;
}

- (NSData *) XMLRequestGetFolderWithID:(NSString *)folderID {
    NSString *string = [NSString stringWithFormat:@"<?xmlversion=\"1.0\"encoding=\"utf-8\"?>\
                        <soap:Envelope\
                        xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <GetFolder xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <FolderShape>\
                        <t:BaseShape>Default</t:BaseShape>\
                        </FolderShape>\
                        <FolderIds>\
                        <t:FolderId Id=\"%@\"/>\
                        </FolderIds>\
                        </GetFolder>\
                        </soap:Body>\
                        </soap:Envelope>", folderID];
    
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

- (NSData *) XMLRequestSyncItemsInFolderWithID:(NSString *)folderID {
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
                        <Ignore>\
                        </Ignore>\
                        <MaxChangesReturned>100</MaxChangesReturned>\
                        </SyncFolderItems>\
                        </soap:Body>\
                        </soap:Envelope>", folderID];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) XMLRequestSyncFolderHierarchy {
    NSString *string = @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                                            xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <SyncFolderHierarchy  xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\">\
                        <FolderShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </FolderShape>\
                        <SyncState>H4sIA=</SyncState>\
                        </SyncFolderHierarchy>\
                        </soap:Body>\
                        </soap:Envelope>";
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

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
    
    return [NSDictionary dictionaryWithObjectsAndKeys:folderID, @"FolderID",
            folderIDChangeKey, @"FolderIDChangeKey",
            parentFolderID, @"ParentFolderID",
            parentFolderIDChangeKey, @"ParentFolderIDChangeKey",
            displayName, @"DisplayName",
            totalCount, @"TotalCount",
            unreadCount, @"UnreadCount", nil];
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
    NSString *bodyTypeString = [[bodyXML attributeForName:@"BodyType"] stringValue];
    NSUInteger bodyType = [bodyTypeString isEqualToString:@"HTML"] ? EMailContentTypeHTML : EMailContentTypePlainText;
    
    NSArray *recipientsXML = [messageXML nodesForXPath:@"//t:ToRecipients/t:Mailbox" error:nil];
    NSMutableArray *recipients = [NSMutableArray array];
    for (GDataXMLElement *singleRecipientXML in recipientsXML) {
        NSString *name = [[[singleRecipientXML elementsForName:@"t:Name"] objectAtIndex:0] stringValue];
        NSString *email = [[[singleRecipientXML elementsForName:@"t:EmailAddress"] objectAtIndex:0] stringValue];
        
        [recipients addObject:[NSDictionary dictionaryWithObjectsAndKeys:name, @"Name", email, @"EmailAddress", nil]];
    }
    
    GDataXMLElement *senderXML = [[messageXML nodesForXPath:@"//t:From" error:nil] objectAtIndex:0];
    NSString *senderName = [[[senderXML nodesForXPath:@"//t:Name" error:nil] objectAtIndex:0] stringValue];
    NSString *senderEMail = [[[senderXML nodesForXPath:@"//t:EmailAddress" error:nil] objectAtIndex:0] stringValue];
    NSDictionary *sender = [NSDictionary dictionaryWithObjectsAndKeys:senderName, @"Name", senderEMail, @"EmailAddress", nil];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:itemID, @"ItemID",
            itemIDChangeKey, @"ItemIDChangeKey",
            parentFolderID, @"ParentFolderID",
            parentFolderIDChangeKey, @"ParentFolderIDChangeKey",
            subject, @"Subject",
            body, @"Body",
            bodyType, @"BodyType",
            recipients, @"Recipients",
            sender, @"From", nil];
}

- (void) connectionManager:(ConnectionManager *)manager didFinishLoadingData:(NSData *)data {
    GDataXMLDocument *response = [[GDataXMLDocument alloc] initWithData:data options:nil error:nil];
    
    // Вывод ответа сервера. Не забыть выкинуть к релизу
    NSString *debugString = [NSString stringWithUTF8String:[data bytes]];
    NSLog(@"%@", debugString);
    
    switch (_currentOperation) {
        case ServerWhispererCurrentOperationGetFolder: {
            NSString *getFolderResponseCode = [[[response nodesForXPath:@"//m:ResponseCode" error:nil] objectAtIndex:0] stringValue];
            if ([getFolderResponseCode isEqualToString:@"NoError"]) {
                GDataXMLElement *folderXML = [[response nodesForXPath:@"//t:Folder" error:nil] objectAtIndex:0];
                
                _currentOperationResult = [self dictionaryForFolderXML:folderXML];
            }
            else
                NSLog(@"Error response");
            break;
        }
            
        case ServerWhispererCurrentOperationGetItem: {
            NSString *getItemResponseCode = [[[response nodesForXPath:@"//m:ResponseCode" error:nil] objectAtIndex:0] stringValue];
            if ([getItemResponseCode isEqualToString:@"NoError"]) {
                GDataXMLElement *messageXML = [[response nodesForXPath:@"//t:Message" error:nil] objectAtIndex:0];
                
                _currentOperationResult = [self dictionaryForMessageXML:messageXML];
            }
            else
                NSLog(@"Error response");
            break;
        }
            
        case ServerWhispererCurrentOperationSyncFolderItems: {
            NSString *getItemResponseCode = [[[response nodesForXPath:@"//m:ResponseCode" error:nil] objectAtIndex:0] stringValue];
            if ([getItemResponseCode isEqualToString:@"NoError"]) {
                NSMutableArray *result = [NSMutableArray array];
                
                NSArray *messages = [response nodesForXPath:@"//t:Message" error:nil];
                for (GDataXMLElement *currentMessage in messages) {
                    [result addObject:[self dictionaryForMessageXML:currentMessage]];
                }
                
                _currentOperationResult = result;
            }
            else
                NSLog(@"Error response");
            break;
        }
        case ServerWhispererCurrentOperationSyncFolderHierarchy: {
            NSString *getItemResponseCode = [[[response nodesForXPath:@"//m:ResponseCode" error:nil] objectAtIndex:0] stringValue];
            if ([getItemResponseCode isEqualToString:@"NoError"]) {
                NSMutableArray *result = [NSMutableArray array];
                
                NSArray *folders = [response nodesForXPath:@"//t:Folder" error:nil];
                for (GDataXMLElement *currentFolder in folders) {
                    [result addObject:[self dictionaryForFolderXML:currentFolder]];
                }
                
                _currentOperationResult = result;
            }
            else
                NSLog(@"Error response");
            break;
        }
            
        default:
            break;
    }

    [manager release];
    [response release];
}

@end
