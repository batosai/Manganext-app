//
//  AFIncrementalStore.m
//  Manga Next
//
//  Created by Jeremy on 20/04/13.
//  Copyright (c) 2013 Jeremy Chaufourier. All rights reserved.
//

#import "MOIncrementalStore.h"
#import "MOAPIClient.h"

@implementation MOIncrementalStore

+ (void)initialize {
    [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:[self type]];
}

+ (NSString *)type {
    return NSStringFromClass(self);
}

+ (NSManagedObjectModel *)model {
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"manga-out" withExtension:@"xcdatamodeld"]];
}

- (id<AFIncrementalStoreHTTPClient>)HTTPClient {
    return [MOAPIClient sharedClient];
}

@end
