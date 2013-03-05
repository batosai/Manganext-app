//
//  MOBaseBook.m
//  Manga Out
//
//  Created by Jérémy chaufourier on 26/02/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import "MOBooks.h"

@implementation MOBooks

@synthesize books = _books;
@synthesize managedObjectContext = _managedObjectContext;

- (void)dealloc
{
    [_books release];
    [_managedObjectContext release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.books = [[[NSMutableArray alloc] init] autorelease];

    return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext 
{
    self = [self init];
    _managedObjectContext = managedObjectContext;

    return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext andType:(NSUInteger)t
{
    self = [self initWithManagedObjectContext:managedObjectContext];

    type = t;

    if (type != SUBSCRIPTION) {
        [self filterByObject:nil];
    }

    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary andManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    self = [self initWithManagedObjectContext:managedObjectContext];

    [self createOrUpdateBooks:dictionary];

    return self;
}

- (Book*)getBookAtIndex:(NSUInteger)index
{
    // return MOBook à l'index
    return [_books objectAtIndex:index];
}

- (Book*)getBookAtId:(NSUInteger)uid
{
    Book * book = nil;
    // rechercher l'element dans le tableau avec l'id uid
    for (Book * b in _books) {
        if ([b.uid intValue] == uid) {
            book = b;
        }
    }
    return book;
}

- (NSUInteger)getCountSignetToday
{
    NSUInteger count = 0;
    for (Book * book in self.books) {
        if ([[NSDate date] isSameDay:book.published_at]) {
            count++;
        }
    }

    return count;
}

- (void)refreshWithDictionary:(NSDictionary *)dictionary
{
    [self createOrUpdateBooks:dictionary];
}

- (void)createOrUpdateBooks:(NSDictionary *)dictionary
{
    NSError *error;

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:_managedObjectContext];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setFetchLimit:1];

    for (NSDictionary *book in [dictionary valueForKeyPath:@"result"]) {
        Book *b;

        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"uid == %@", [book valueForKeyPath:@"id"]];
        [request setPredicate:predicate];

        NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];

        if ([results count]) {
            b = [results objectAtIndex:0];
        }
        else {
            b = (Book *)[NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_managedObjectContext];
        }

        [b updateWithDictionary:book];
    }

    [self deleteOldBooks];
    [_managedObjectContext save:&error];

    [self filterByObject:nil];
}

- (void)deleteOldBooks
{
    NSError *error;
    NSDateComponents *dateComponent = [[[NSDateComponents alloc] init] autorelease];
    [dateComponent setMonth:2];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:_managedObjectContext];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];

    NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];

    for (Book * b in results) {
        NSDate *dateLimit = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponent toDate:b.published_at options:0];

        if ([dateLimit compare:[NSDate date]] == NSOrderedAscending) {
            [b deleteImages];
            [_managedObjectContext deleteObject:b];
        }
    }

    [request release];
}

- (void)deleteBooks
{
    NSError *error;

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:_managedObjectContext];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];

    NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];
#warning TODO faire des test, il y a un doublon avec  deletedObjects et le for deletedObject:
    [_managedObjectContext deletedObjects];
    
    for (Book * b in results) {
        //[b deleteImages];
        [_managedObjectContext deleteObject:b];
    }
    [_managedObjectContext save:&error];
    
    //delete images
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dirThumbnails = [NSString stringWithFormat:@"%@/%@", path, THUMBNAILS_CACHE_DIRECTORY];
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL isDir = YES;
    
    if([fileManager fileExistsAtPath:dirThumbnails isDirectory:&isDir]) {
        [fileManager removeItemAtPath:dirThumbnails error:&error];
        [fileManager createDirectoryAtPath:dirThumbnails withIntermediateDirectories:YES attributes:nil error:&error];
    }

    [request release];
}

- (void)filterByObject:(id)filter
{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor;
    NSPredicate *predicate;

    if (type == NEW) {
        if (filter) {
            predicate = [NSPredicate predicateWithFormat:@"(published_at <= %@) AND (name contains[cd] %@ OR editor_name contains[cd] %@)", [NSDate date], filter, filter];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"published_at <= %@", [NSDate date]];
        }

        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"published_at" ascending:NO];
    }
    else if (type == FUTURE) {
        if (filter) {
            predicate = [NSPredicate predicateWithFormat:@"(published_at > %@) AND (name contains[cd] %@ OR editor_name contains[cd] %@)", [NSDate date], filter, filter];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"published_at > %@", [NSDate date]];
        }

        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"published_at" ascending:YES];
    }
    else {
//        predicate = [NSPredicate predicateWithFormat:@"signet != NULL"];

        NSDictionary *dictionary = filter;
        NSArray *keys;
        
        if ([filter count]) {
            keys = [dictionary allKeys];
        }
        else {
            keys = @[];
        }

        NSDateComponents *dateComponent = [[[NSDateComponents alloc] init] autorelease];
        [dateComponent setDay:-1];
        
        NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponent toDate:[NSDate date] options:0];

        predicate = [NSPredicate predicateWithFormat:@"(published_at > %@) AND name IN %@", date, keys];
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"published_at" ascending:YES];
    }

    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];

    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, sortDescriptor2, nil];

    [request setSortDescriptors:sortDescriptors];
    [request setPredicate:predicate];
    NSError *error;
    
    self.books = [NSMutableArray arrayWithArray:[_managedObjectContext executeFetchRequest:request error:&error]];
    
    [sortDescriptor release];
    [sortDescriptor2 release];
    [request release];
}

- (id)lastUpdate
{
    NSError *error;
    NSPredicate *predicate;
    NSSortDescriptor *sortDescriptor;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setFetchLimit:1];

    if (type == NEW) {
        predicate = [NSPredicate predicateWithFormat:@"published_at <= %@", [NSDate date]];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"published_at > %@", [NSDate date]];
    }

    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updated_at" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];

    [request setPredicate:predicate];
    [request setSortDescriptors:sortDescriptors];

    NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];
    Book *b = [results lastObject];

    if (b.updated_at) {
        NSLocale *frLocale = [[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale preferredLanguages] objectAtIndex:0]] autorelease];
        
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [formatter setLocale:frLocale];
        
        return [formatter stringFromDate:b.updated_at];
    }

    return nil;
}

@end
