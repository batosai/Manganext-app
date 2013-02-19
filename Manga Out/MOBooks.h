//
//  MOBaseBook.h
//  Manga Out
//
//  Created by Jérémy chaufourier on 26/02/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"

@interface MOBooks : NSObject {
    NSUInteger type;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *books;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext andType:(NSUInteger)type;
- (id)initWithDictionary:(NSDictionary *)dictionary andManagedObjectContext:(NSManagedObjectContext *)managedObjecttContext;
- (Book*)getBookAtIndex:(NSUInteger)index;
- (Book*)getBookAtId:(NSUInteger)uid;
- (NSUInteger)getCountSignetToday;
- (void)refreshWithDictionary:(NSDictionary *)dictionary;
- (void)createOrUpdateBooks:(NSDictionary *)dictionary;
- (void)deleteOldBooks;
- (void)deleteBooks;
- (void)filterByObject:(id)filter;
- (id)lastUpdate;

@end
