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
    ServerWhispererCurrentOperationSyncFolderHierarchy
} ServerWhispererCurrentOperation;

@interface ServerWhisperer () {
    ServerWhispererCurrentOperation _currentOperation;
}

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

- (id) initWithServerURL:(NSURL *)serverURL withUserName:(NSString *)userName withPassword:(NSString *)password withDelegate:(id<ServerWhispererDelegate>)delegate {
    self = [super init];
    if (self) {
        _serverURL = [serverURL retain];
        _userName = [userName retain];
        _password = [password retain];
        _delegate = delegate;
    }
    
    return self;
}

- (void) getFolderWithID:(NSString *)folderID {
    _currentOperation = ServerWhispererCurrentOperationGetFolder;
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userName
                                                             password:self.password
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    ConnectionManager *connection = [[ConnectionManager alloc] initWithDelegate:self];
    
    [connection sendRequestToServer:_serverURL withCredential:credential withBody:[XMLHandler XMLRequestSyncItemsInFolderWithID:folderID]];
}

- (void) getItemWithID:(NSString *)itemID {
    _currentOperation = ServerWhispererCurrentOperationGetItem;
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userName
                                                             password:self.password
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    ConnectionManager *connection = [[ConnectionManager alloc] initWithDelegate:self];
    
    [connection sendRequestToServer:_serverURL withCredential:credential withBody:[XMLHandler XMLRequestGetItemWithID:itemID]];
}

- (void) getItemsInFoldeWithID:(NSString *)folderID {
    _currentOperation = ServerWhispererCurrentOperationSyncFolderItems;
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userName
                                                             password:self.password
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    ConnectionManager *connection = [[ConnectionManager alloc] initWithDelegate:self];
    
    [connection sendRequestToServer:_serverURL withCredential:credential withBody:[XMLHandler XMLRequestSyncItemsInFolderWithID:folderID]];
}

- (void) getFolderHierarchy {
    NSLog(@"getFolderHierarchy called");
    
    _currentOperation = ServerWhispererCurrentOperationSyncFolderHierarchy;
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userName
                                                             password:self.password
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    ConnectionManager *connection = [[ConnectionManager alloc] initWithDelegate:self];
    
    [connection sendRequestToServer:_serverURL withCredential:credential withBody:[XMLHandler XMLRequestSyncFolderHierarchy]];
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
                //NSError *error = NSError er
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
            case ServerWhispererCurrentOperationSyncFolderHierarchy: {
                NSMutableArray *result = [NSMutableArray array];
                
                NSArray *folders = [response nodesForXPath:@"//t:Folder"
                                                namespaces:namespaces
                                                     error:nil];
                for (GDataXMLElement *currentFolder in folders) {
                    [result addObject:[XMLHandler dictionaryForFolderXML:currentFolder]];
                }
                
                [self.delegate serverWhisperer:self didFinishLoadingFolderHierarchy:result];
                break;
            }
            
            default:
                break;
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
