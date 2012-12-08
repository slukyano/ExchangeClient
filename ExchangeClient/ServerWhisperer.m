//
//  ServerWhisperer.m
//  ExchangeClient
//
//  Created by LSA on 15/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "ServerWhisperer.h"
#import "Defines.h"
#import "XMLHandler.h"
#import "ASIHTTPRequest.h"

@interface ServerWhisperer () {
    XMLHandler *aXMLHandlerInstance;
}

- (NSData *) sendRequestToServer:(NSURL *)serverURL
                      withUsername:(NSString *)username
                      withPassword:(NSString *)password
                          withBody:(NSData *)bodyData;

@end

@implementation ServerWhisperer

@synthesize serverURL = _serverURL;
@synthesize username = _username;
@synthesize password = _password;

- (void) dealloc {
    self.serverURL = nil;
    [aXMLHandlerInstance release];
    
    [super dealloc];
}

- (id) initWithServerURL:(NSURL *)serverURL withUsername:(NSString *)username withPassword:(NSString *)password
{
    self = [super init];
    if (self) {
        _serverURL = [serverURL retain];
        _username = [username retain];
        _password = [password retain];
        aXMLHandlerInstance = [[XMLHandler alloc] init];
    }
    
    return self;
}

- (id) initWithUserDefaults {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        _serverURL = [NSURL URLWithString:[defaults stringForKey:@"address"]];
        _username = [defaults stringForKey:@"name"];
        _password = [defaults stringForKey:@"password"];
        aXMLHandlerInstance = [[XMLHandler alloc] init];
    }
    
    return self;
}

// Отправка xml-запроса
- (NSData *) sendRequestToServer:(NSURL *)serverURL
                      withUsername:(NSString *)username
                      withPassword:(NSString *)password
                          withBody:(NSData *)bodyData
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:serverURL];
    [request addRequestHeader:@"Content-Type" value:@"text/xml; charset=UTF-8;"];
    [request setUsername:username];
    [request setPassword:password];
    [request setRequestMethod:@"POST"];
    [request setPostBody:[NSMutableData dataWithData:bodyData]];

    [request startSynchronous];
    
    if ([request error]) {
        NSLog(@"%@", [[request error] localizedDescription]);
        return nil;
    }
    
    // Вывод ответа сервера. Не забыть выкинуть к релизу
    NSLog(@"%@", [request responseString]);
    
    return [request responseData];
}

// Формирование запроса
- (BOOL) testUserCredential {
    NSData *responseData = [self sendRequestToServer:_serverURL
                                        withUsername:_username
                                        withPassword:_password
                                            withBody:nil];
    return (responseData ? YES : NO);
}

- (NSDictionary *) getFolderWithID:(NSString *)folderID {
    NSData *responseData = [self sendRequestToServer:_serverURL
                                            withUsername:_username
                                            withPassword:_password
                                                withBody:[aXMLHandlerInstance XMLRequestGetFolderWithID:folderID]];
    return [aXMLHandlerInstance parseGetFolderResponse:responseData];
}

- (NSDictionary *) getFolderWithDistinguishedID:(NSString *)distinguishedFolderID {
    NSData *responseData = [self sendRequestToServer:_serverURL
                                        withUsername:_username
                                        withPassword:_password
                                            withBody:[aXMLHandlerInstance XMLRequestGetFolderWithDistinguishedID:distinguishedFolderID]];
    return [aXMLHandlerInstance parseGetFolderResponse:responseData];
}

- (NSDictionary *) getItemWithID:(NSString *)itemID {
    NSData *responseData = [self sendRequestToServer:_serverURL
                                        withUsername:_username
                                        withPassword:_password
                                            withBody:[aXMLHandlerInstance XMLRequestGetItemWithID:itemID]];
    return [aXMLHandlerInstance parseGetItemResponse:responseData];
}

- (NSDictionary *) syncItemsInFoldeWithID:(NSString *)folderID usingSyncState:(NSString *)syncState {
    NSData *responseData = [self sendRequestToServer:_serverURL
                                        withUsername:_username
                                        withPassword:_password
                                            withBody:[aXMLHandlerInstance XMLRequestSyncItemsInFolderWithID:folderID
                                                                                             usingSyncState:syncState]];
    return [aXMLHandlerInstance parseSyncFolderItemsResponse:responseData];
}

- (NSDictionary *) syncFolderHierarchyUsingSyncState:(NSString *)syncState {
    NSData *responseData = [self sendRequestToServer:_serverURL
                                        withUsername:_username
                                        withPassword:_password
                                            withBody:[aXMLHandlerInstance XMLRequestSyncFolderHierarchyUsingSyncState:syncState]];
    return [aXMLHandlerInstance parseSyncFolderHierarchyResponse:responseData];
}

- (NSArray *) getFoldersInFolderWithID:(NSString *)folderID {
    NSData *responseData = [self sendRequestToServer:_serverURL
                                        withUsername:_username
                                        withPassword:_password
                                            withBody:[aXMLHandlerInstance XMLRequestFindFoldersInFolderWithID:folderID]];
    return [aXMLHandlerInstance parseFindFolderResponse:responseData];
}

- (NSArray *) getFoldersInFolderWithDistinguishedID:(NSString *)distinguishedFolderID {
    NSData *responseData = [self sendRequestToServer:_serverURL
                                        withUsername:_username
                                        withPassword:_password
                                            withBody:[aXMLHandlerInstance XMLRequestFindFoldersInFolderWithDistinguishedID:distinguishedFolderID]];
    return [aXMLHandlerInstance parseFindFolderResponse:responseData];
}

- (NSArray *) getItemsInFolderWithID:(NSString *)folderID {
    NSData *responseData = [self sendRequestToServer:_serverURL
                                        withUsername:_username
                                        withPassword:_password
                                            withBody:[aXMLHandlerInstance XMLRequestFindItemsInFolderWithID:folderID]];
    return [aXMLHandlerInstance parseFindItemResponse:responseData];
}

- (NSArray *) getItemsInFolderWithDistinguishedID:(NSString *)distinguishedFolderID {
    NSData *responseData = [self sendRequestToServer:_serverURL
                                        withUsername:_username
                                        withPassword:_password
                                            withBody:[aXMLHandlerInstance XMLRequestFindItemsInFolderWithDistinguishedID:distinguishedFolderID]];
    return [aXMLHandlerInstance parseFindItemResponse:responseData];
}

@end
