//
//  MOSubscription.m
//  Manga Next
//
//  Created by Jeremy on 29/01/13.
//  Copyright (c) 2013 Jérémy Chaufourier. All rights reserved.
//

#import "MOSubscriptionDocument.h"
#import "Book.h"

@implementation MOSubscriptionDocument

@synthesize dictionary = _dictionary;

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError
{
    if ([contents length] > 0) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:contents];
        _dictionary = [[unarchiver decodeObjectForKey:@"subscriptions"] retain];
        [unarchiver finishDecoding];
        [unarchiver release];
    } else {
        _dictionary = [NSMutableDictionary dictionary];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SUBSCRIPTION_MODIFIED object:self];

    return YES;
}

- (id)contentsForType:(NSString *)typeName error:(NSError **)outError
{
    if (!_dictionary) {
        _dictionary = [NSMutableDictionary dictionary];
    }

    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_dictionary forKey:@"subscriptions"];
    [archiver finishEncoding];
    [archiver release];

    return data;
}

- (void)setBook:(Book *)book
{
    if (!_dictionary) {
        _dictionary = [NSMutableDictionary dictionary];
    }

    if (![_dictionary objectForKey:book.name]) {

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-DD HH:MM:SS ±HHMM"];

        NSDictionary *dictionary = @{
                                     @"name" : book.name,
                                     @"created_at" : [formatter stringFromDate:[NSDate date]],
                                };
        [_dictionary setValue:dictionary forKey:book.name];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SUBSCRIPTION_MODIFIED_DICTIONARY object:self];
}

- (void)deleteBook:(Book *)book
{
    [self deleteAtKey:book.name];
}

- (void)deleteAtKey:(NSString *)key
{
    if ([_dictionary objectForKey:key]) {
        [_dictionary removeObjectForKey:key];
        [self saveToURL:[self fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SUBSCRIPTION_MODIFIED_DICTIONARY object:self];
}

@end
