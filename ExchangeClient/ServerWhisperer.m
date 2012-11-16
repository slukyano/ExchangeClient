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
    ServerWhispererCurrentOperationSyncFolderItems
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

- (NSDictionary *) getFolderWithName:(NSString *)folder {
    _currentOperation = ServerWhispererCurrentOperationGetFolder;
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userName
                                                             password:self.password
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    ConnectionManager *connection = [[ConnectionManager alloc] initWithDelegate:self];
    
    [connection sendRequestToServer:_serverURL withCredential:credential withBody:[self XMLRequestGetFolderWithName:folder]];
    
    return _currentOperationResult;
}

- (id) getItemWithID:(NSString *)itemID {
    _currentOperation = ServerWhispererCurrentOperationGetItem;
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userName
                                                             password:self.password
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    ConnectionManager *connection = [[ConnectionManager alloc] initWithDelegate:self];
    
    [connection sendRequestToServer:_serverURL withCredential:credential withBody:[self XMLRequestGetItemWithID:itemID]];
    
    return _currentOperationResult;
}

- (NSData *) XMLRequestGetFolderWithName:(NSString *)folder {
    NSString *string = [NSString stringWithFormat:@"<?xmlversion=\"1.0\"encoding=\"utf-8\"?><soap:Envelopexmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\"><soap:Body><GetFolderxmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\"><FolderShape><t:BaseShape>Default</t:BaseShape></FolderShape><FolderIds><t:DistinguishedFolderIdId=\"%@\"/></FolderIds></GetFolder></soap:Body></soap:Envelope>", folder];
    
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
    <t:BaseShape>Default</t:BaseShape>\
    <t:IncludeMimeContent>true</t:IncludeMimeContent>\
    </ItemShape>\
    <ItemIds>\
    <t:ItemId Id=\"%@\" ChangeKey=\"\" />\
    </ItemIds>\
    </GetItem>\
    </soap:Body>\
                        </soap:Envelope>", itemID];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (void) connectionManager:(ConnectionManager *)manager didFinishLoadingData:(NSData *)data {
    GDataXMLDocument *response = [[GDataXMLDocument alloc] initWithData:data options:nil error:nil];
    
    // Не забыть выкинуть к релизу
    NSString *debugString = [NSString stringWithUTF8String:[data bytes]];
    NSLog(@"%@", debugString);
    
    switch (_currentOperation) {
        case ServerWhispererCurrentOperationGetFolder:
            ;
            NSString *getFolderResponseCode = [[[response nodesForXPath:@"//m:ResponseCode" error:nil] objectAtIndex:0] stringValue];
            if ([getFolderResponseCode isEqualToString:@"NoError"]) {
                GDataXMLElement *folderXML = [[response nodesForXPath:@"//t:Folder" error:nil] objectAtIndex:0];
                
                GDataXMLElement *folderIDXML = [[folderXML elementsForName:@"t:FolderId"] objectAtIndex:0];
                NSString *folderID = [[folderIDXML attributeForName:@"Id"] stringValue];
                NSString *folderIDChangeKey = [[folderIDXML attributeForName:@"ChangeKey"] stringValue];
                
                NSString *displayName = [[[folderXML elementsForName:@"t:DisplayName"] objectAtIndex:0] stringValue];
                
                NSString *totalCount = [[[folderXML elementsForName:@"t:TotalCount"] objectAtIndex:0] stringValue];
                
                NSString *unreadCount = [[[folderXML elementsForName:@"t:UnreadCount"] objectAtIndex:0] stringValue];
                
                _currentOperationResult = [NSDictionary dictionaryWithObjectsAndKeys:folderID, @"FolderID", folderIDChangeKey, @"FolderIDChangeKey", displayName, @"DisplayName", totalCount, @"TotalCount", unreadCount, @"UnreadCount", nil];
            }
            else {
                NSLog(@"Error response");
            }
            break;
            
        case ServerWhispererCurrentOperationGetItem:
            ;
            NSString *getItemResponseCode = [[[response nodesForXPath:@"//m:ResponseCode" error:nil] objectAtIndex:0] stringValue];
            if ([getItemResponseCode isEqualToString:@"NoError"]) {
                GDataXMLElement *itemXML = [[response nodesForXPath:@"//t:Message" error:nil] objectAtIndex:0];
                
                GDataXMLElement *itemIDXML = [[itemXML elementsForName:@"t:ItemId"] objectAtIndex:0];
                NSString *itemID = [[itemIDXML attributeForName:@"Id"] stringValue];
                NSString *itemIDChangeKey = [[itemIDXML attributeForName:@"ChangeKey"] stringValue];
                
                NSString *subject = [[[itemXML elementsForName:@"t:Subject"] objectAtIndex:0] stringValue];
                
                GDataXMLElement *bodyXML = [[itemXML elementsForName:@"t:Body"] objectAtIndex:0];
                NSString *body = [bodyXML stringValue];
                NSString *bodyTypeString = [[bodyXML attributeForName:@"BodyType"] stringValue];
                NSUInteger bodyType = [bodyTypeString isEqualToString:@"HTML"] ? EMailContentTypeHTML : EMailContentTypePlainText;
                
                NSArray *recipientsXML = [itemXML nodesForXPath:@"//t:ToRecipients/t:Mailbox" error:nil];
                NSMutableArray *recipients = [NSMutableArray array];
                for (GDataXMLElement *singleRecipientXML in recipientsXML) {
                    NSString *name = [[[singleRecipientXML elementsForName:@"t:Name"] objectAtIndex:0] stringValue];
                    NSString *email = [[[singleRecipientXML elementsForName:@"t:EmailAddress"] objectAtIndex:0] stringValue];
                    
                    [recipients addObject:[NSDictionary dictionaryWithObjectsAndKeys:name, @"Name", email, @"EmailAddress", nil]];
                }
                
                GDataXMLElement *senderXML = [[itemXML nodesForXPath:@"//t:From" error:nil] objectAtIndex:0];
                NSString *senderName = [[[senderXML nodesForXPath:@"//t:Name" error:nil] objectAtIndex:0] stringValue];
                NSString *senderEMail = [[[senderXML nodesForXPath:@"//t:EmailAddress" error:nil] objectAtIndex:0] stringValue];
                NSDictionary *sender = [NSDictionary dictionaryWithObjectsAndKeys:senderName, @"Name", senderEMail, @"EmailAddress", nil];
                
                _currentOperationResult = [NSDictionary dictionaryWithObjectsAndKeys:itemID, @"ItemID", itemIDChangeKey, @"ItemIDChangeKey", subject, @"Subject", bodyType, @"BodyType", recipients, @"Recipients", sender, @"From", nil];
            }
            else {
                NSLog(@"Error response");
            }
            break;
            
        case ServerWhispererCurrentOperationSyncFolderItems:
            
            break;
            
        default:
            break;
    }

    [manager release];
    
    [response release];
}

@end
