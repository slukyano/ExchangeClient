//
//  ExchangeClientDataSingleton.m
//  ExchangeClient
//
//  Created by Администратор on 20.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "ExchangeClientDataSingleton.h"

@implementation ExchangeClientDataSingleton

@synthesize dataArray;

static ExchangeClientDataSingleton *_instance;

+ (ExchangeClientDataSingleton *) instance {
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [[ExchangeClientDataSingleton alloc] init];
        }
    }
    
    return _instance;
}

- (NSUInteger) count {
    return [dataArray count];
}

- (id) objectAtIndex:(NSUInteger)index {
    return [dataArray objectAtIndex:index];
}

- (void) addObject:(id)anObject {
    [dataArray addObject:anObject];
}

- (void) removeObjectAtIndex:(NSUInteger)index {
    [dataArray removeObjectAtIndex:index];
}

- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [dataArray replaceObjectAtIndex:index withObject:anObject];
}

@end
