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
#import "XMLHandler.h"

typedef enum {
    ServerWhispererCurrentOperationGetFolder,
    ServerWhispererCurrentOperationGetItem,
    ServerWhispererCurrentOperationSyncFolderItems,
    ServerWhispererCurrentOperationSyncFolderHierarchy,
    ServerWhispererCurrentOperationFindFolder,
    ServerWhispererCurrentOperationFindItem
} ServerWhispererCurrentOperation;

@interface ServerWhisperer () {
    ServerWhispererCurrentOperation _currentOperation;
}

- (void) sendRequestWithBody:(NSData *)requestBody;

@end

@implementation ServerWhisperer

@synthesize serverURL = _serverURL;
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize delegate = _delegate;

- (void) dealloc {
    self.serverURL = nil;
    self.userName = nil;
    self.password = nil;
    
    [super dealloc];
}

- (id) initWithServerURL:(NSURL *)serverURL
            withUserName:(NSString *)userName
            withPassword:(NSString *)password
            withDelegate:(id<ServerWhispererDelegate>)delegate
{
    self = [super init];
    if (self) {
        _serverURL = [serverURL retain];
        _userName = [userName retain];
        _password = [password retain];
        _delegate = delegate;
    }
    
    return self;
}

- (void) sendRequestWithBody:(NSData *)requestBody {
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userName
                                                             password:self.password
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    ConnectionManager *connection = [[ConnectionManager alloc] initWithDelegate:self];
    
    [connection sendRequestToServer:_serverURL withCredential:credential withBody:requestBody];
}

- (void) getFolderWithID:(NSString *)folderID {
    _currentOperation = ServerWhispererCurrentOperationGetFolder;
    
    [self sendRequestWithBody:[XMLHandler XMLRequestGetFolderWithID:folderID]];
}

- (void) getFolderWithDistinguishedID:(NSString *)distinguishedFolderID {
    _currentOperation = ServerWhispererCurrentOperationGetFolder;
    
    [self sendRequestWithBody:[XMLHandler XMLRequestGetFolderWithDistinguishedID:distinguishedFolderID]];
}

- (void) getItemWithID:(NSString *)itemID {
    _currentOperation = ServerWhispererCurrentOperationGetItem;

    [self sendRequestWithBody:[XMLHandler XMLRequestGetItemWithID:itemID]];
}

- (void) syncItemsInFoldeWithID:(NSString *)folderID usingSyncState:(NSString *)syncState {
    _currentOperation = ServerWhispererCurrentOperationSyncFolderItems;

    [self sendRequestWithBody:[XMLHandler XMLRequestSyncItemsInFolderWithID:folderID usingSyncState:syncState]];
}

- (void) syncFolderHierarchyUsingSyncState:(NSString *)syncState {
    _currentOperation = ServerWhispererCurrentOperationSyncFolderHierarchy;
    
    [self sendRequestWithBody:[XMLHandler XMLRequestSyncFolderHierarchyUsingSyncState:syncState]];
}

- (void) getFoldersInFolderWithID:(NSString *)folderID {
    _currentOperation = ServerWhispererCurrentOperationFindFolder;
    
    [self sendRequestWithBody:[XMLHandler XMLRequestFindFoldersInFolderWithID:folderID]];
}

- (void) getFoldersInFolderWithDistinguishedID:(NSString *)distinguishedFolderID {
    _currentOperation = ServerWhispererCurrentOperationFindFolder;
    
    [self sendRequestWithBody:[XMLHandler
                               XMLRequestFindFoldersInFolderWithDistinguishedID:distinguishedFolderID]];
}

- (void) getItemsInFolderWithID:(NSString *)folderID {
    _currentOperation = ServerWhispererCurrentOperationFindItem;
    
    [self sendRequestWithBody:[XMLHandler XMLRequestFindItemsInFolderWithID:folderID]];
}

- (void) getItemsInFolderWithDistinguishedID:(NSString *)distinguishedFolderID {
    _currentOperation = ServerWhispererCurrentOperationFindItem;
    
    [self sendRequestWithBody:[XMLHandler
                               XMLRequestFindItemsInFolderWithDistinguishedID:distinguishedFolderID]];
}

- (void) connectionManager:(ConnectionManager *)manager didFinishLoadingData:(NSData *)data {
    NSLog(@"didFinishLoadingData starts");
    
    GDataXMLDocument *response = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    
    // Вывод ответа сервера. Не забыть выкинуть к релизу
    NSString *debugString = [NSString stringWithUTF8String:[data bytes]];
    NSLog(@"%@", debugString);
    
    NSDictionary *namespaces = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"http://schemas.microsoft.com/exchange/services/2006/messages", @"m",
                                @"http://schemas.microsoft.com/exchange/services/2006/types", @"t",
                                @"http://www.w3.org/2001/XMLSchema-instance", @"xsi",
                                @"http://www.w3.org/2001/XMLSchema", @"xsd",
                                @"http://schemas.xmlsoap.org/soap/envelope/", @"s", nil];
    
    NSString *getFolderResponseCode = [[[response nodesForXPath:@"//m:ResponseCode"
                                                     namespaces:namespaces
                                                          error:nil] objectAtIndex:0] stringValue];
    if ([getFolderResponseCode isEqualToString:@"NoError"]) {
        switch (_currentOperation) {
            case ServerWhispererCurrentOperationGetFolder: {
                GDataXMLElement *folderXML = [[response nodesForXPath:@"//t:Folder"
                                                           namespaces:namespaces
                                                                error:nil] objectAtIndex:0];
                
                [self.delegate serverWhisperer:self
                        didFinishLoadingFolder:[XMLHandler dictionaryForFolderXML:folderXML]];
                break;
            }
                
            case ServerWhispererCurrentOperationGetItem: {
                GDataXMLElement *messageXML = [[response nodesForXPath:@"//t:Message"
                                                            namespaces:namespaces
                                                                 error:nil] objectAtIndex:0];
                
                [self.delegate serverWhisperer:self
                       didFinishLoadingMessage:[XMLHandler dictionaryForMessageXML:messageXML]];
                break;
            }
                
            case ServerWhispererCurrentOperationSyncFolderItems: {
                NSMutableArray *messagesToCreate = [NSMutableArray array];
                NSArray *messagesToCreateXML = [response nodesForXPath:@"//t:Create/t:Message"
                                                 namespaces:namespaces
                                                      error:nil];
                for (GDataXMLElement *currentMessage in messagesToCreateXML)
                    [messagesToCreate addObject:[XMLHandler dictionaryForMessageXML:currentMessage]];
                
                NSMutableArray *messagesToUpdate = [NSMutableArray array];
                NSArray *messagesToUpdateXML = [response nodesForXPath:@"//t:Create/t:Message"
                                                            namespaces:namespaces
                                                                 error:nil];
                for (GDataXMLElement *currentMessage in messagesToUpdateXML)
                    [messagesToUpdate addObject:[XMLHandler dictionaryForMessageXML:currentMessage]];
                
                NSMutableArray *messagesToDelete = [NSMutableArray array];
                NSArray *messagesToDeleteXML = [response nodesForXPath:@"//t:Create/t:Message"
                                                            namespaces:namespaces
                                                                 error:nil];
                for (GDataXMLElement *currentMessage in messagesToDeleteXML)
                    [messagesToDelete addObject:[XMLHandler dictionaryForMessageXML:currentMessage]];
                
                NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:messagesToCreate, @"Create",
                                        messagesToUpdate, @"Update",
                                        messagesToDelete, @"Delete" nil];
                [self.delegate serverWhisperer:self didFinishLoadingItemsToSync:result];
                break;
            }
                
            case ServerWhispererCurrentOperationSyncFolderHierarchy: {
                NSArray *foldersToCreateXML = [response nodesForXPath:@"//t:Create/t:Folder"
                                                namespaces:namespaces
                                                     error:nil];
                NSMutableArray *foldersToCreate = [NSMutableArray array];
                for (GDataXMLElement *currentFolder in foldersToCreateXML)
                    [foldersToCreate addObject:[XMLHandler dictionaryForFolderXML:currentFolder]];
                
                NSArray *foldersToUpdateXML = [response nodesForXPath:@"//t:Create/t:Folder"
                                                           namespaces:namespaces
                                                                error:nil];
                NSMutableArray *foldersToUpdate = [NSMutableArray array];
                for (GDataXMLElement *currentFolder in foldersToUpdateXML)
                    [foldersToUpdate addObject:[XMLHandler dictionaryForFolderXML:currentFolder]];
                
                NSArray *foldersToDeleteXML = [response nodesForXPath:@"//t:Create/t:Folder"
                                                           namespaces:namespaces
                                                                error:nil];
                NSMutableArray *foldersToDelete = [NSMutableArray array];
                for (GDataXMLElement *currentFolder in foldersToDeleteXML)
                    [foldersToDelete addObject:[XMLHandler dictionaryForFolderXML:currentFolder]];
                
                NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:foldersToCreate, @"Create",
                                        foldersToUpdate, @"Update",
                                        foldersToDelete, @"Delete", nil];
                [self.delegate serverWhisperer:self didFinishLoadingFoldersToSync:result];
                break;
            }
                
            case ServerWhispererCurrentOperationFindFolder: {
                NSMutableArray *result = [NSMutableArray array];
                
                NSArray *folders = [response nodesForXPath:@"//t:Folder"
                                                namespaces:namespaces
                                                     error:nil];
                for (GDataXMLElement *currentFolder in folders) {
                    [result addObject:[XMLHandler dictionaryForFolderXML:currentFolder]];
                }
                
                [self.delegate serverWhisperer:self didFinishLoadingFolders:result];
                break;
            }
                
            case ServerWhispererCurrentOperationFindItem: {
                NSMutableArray *result = [NSMutableArray array];
                
                NSArray *messages = [response nodesForXPath:@"//t:Message"
                                                 namespaces:namespaces
                                                      error:nil];
                for (GDataXMLElement *currentMessage in messages) {
                    [result addObject:[XMLHandler dictionaryForMessageXML:currentMessage]];
                }
                
                [self.delegate serverWhisperer:self didFinishLoadingItems:result];
                break;
            }
                
            default: {
                NSLog(@"Wrong current operation code");
                break;
            }
        }
    }
    else {
        NSLog(@"Error response");
        NSLog(@"%@", [[[response nodesForXPath:@"//m:ResponseCode"
                                    namespaces:namespaces
                                         error:nil] objectAtIndex:0] stringValue]);
    }
    
    [manager release];
    [response release];
}

@end
