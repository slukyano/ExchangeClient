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

typedef enum {
    ServerWhispererCurrentOperationGetFolder,
    ServerWhispererCurrentOperationGetItem
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

- (id) getFolderWithName:(NSString *)folder {
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
    
    switch (_currentOperation) {
        case ServerWhispererCurrentOperationGetFolder:
            // Здесь формируем объект, чтобы вернуть создателю (DataManager'у)
            break;
            
        case ServerWhispererCurrentOperationGetItem:
            
            break;
            
        default:
            break;
    }

    [manager release];
}

@end
