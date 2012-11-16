//
//  ConnectionManager.m
//  ExchangeClient
//
//  Created by LSA on 14/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "ConnectionManager.h"

//static ConnectionManager *_instance;

@interface ConnectionManager () {
    NSMutableData *_recievedData;
    NSURLCredential *_credential;
}

@end

@implementation ConnectionManager

@synthesize delegate = _delegate;

- (void) dealloc {
    [_credential release];
    
    [super dealloc];
}

- (id) initWithDelegate:(id<ConnectionManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    
    return self;
}

// Отправка xml-запроса
- (void) sendRequestToServer:(NSURL *)serverURL withCredential:(NSURLCredential *)credential withBody:(NSData *)bodyData
{
    _credential = credential;
    
    NSMutableURLRequest *request = [NSURLRequest requestWithURL:serverURL];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:bodyData];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection == nil)
        NSLog(@"Connection cannot be created");
}

// Методы NSURLConnectionDelegate
- (void) connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [[challenge sender] useCredential:_credential forAuthenticationChallenge:challenge];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection error: %@", [error localizedDescription]);
}

- (void) connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"Authentification error");
}

- (void) connection:(NSURLConnection *)connection didRecieveResponse:(NSURLResponse *) response {
    [_recievedData setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_recievedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.delegate connectionManager:self didFinishLoadingData:_recievedData];
    
    [_recievedData release];
    _recievedData = nil;
}

@end
