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

@implementation XMLHandler

+ (NSDictionary *) dictionaryForFolderXML:(GDataXMLElement *)folderXML {
    NSLog(@"dictionaryForFolderXML called");
    
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

+ (NSDictionary *) dictionaryForMailboxXML:(GDataXMLElement *)mailboxXML {
    NSLog(@"dictionaryForMailboxXML called");
    
    NSString *name = [[[mailboxXML elementsForName:@"t:Name"] objectAtIndex:0] stringValue];
    NSString *email = [[[mailboxXML elementsForName:@"t:EmailAddress"] objectAtIndex:0] stringValue];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:name, @"Name", email, @"EmailAddress", nil];
}

+ (NSDictionary *) dictionaryForMessageXML:(GDataXMLElement *)messageXML {
    NSLog(@"dictionaryForMessageXML called");
    
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

+ (NSData *) XMLRequestGetFolderWithID:(NSString *)folderID {
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

+ (NSData *) XMLRequestGetItemWithID:(NSString *)itemID {
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

+ (NSData *) XMLRequestSyncItemsInFolderWithID:(NSString *)folderID {
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

+ (NSData *) XMLRequestSyncFolderHierarchy {
    NSString *string = @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
    <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
    xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
    <soap:Body>\
    <SyncFolderHierarchy  xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\">\
    <FolderShape>\
    <t:BaseShape>AllProperties</t:BaseShape>\
    </FolderShape>\
    </SyncFolderHierarchy>\
    </soap:Body>\
    </soap:Envelope>";
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

@end
