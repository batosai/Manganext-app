//
//  MOSignetViewController.m
//  Manga Next
//
//  Created by Jeremy on 09/05/13.
//  Copyright (c) 2013 Jeremy Chaufourier. All rights reserved.
//

#import "MOSignetViewController.h"
#import "MODetailViewController.h"

#import "Book.h"
#import "AFIncrementalStore.h"

@interface MOSignetViewController ()

@end

@implementation MOSignetViewController

- (void)configure {
    NSFetchRequest *fetchRequest;
    NSPredicate *predicate;

    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Book"];

    fetchRequest.sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"published_at" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];

    predicate = [NSPredicate predicateWithFormat:@"signet != NULL"];

    [fetchRequest setPredicate:predicate];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[(id)[[UIApplication sharedApplication] delegate] managedObjectContext] sectionNameKeyPath:nil cacheName:@"ShopList"];
    _fetchedResultsController.delegate = self;
    
    [self refetchData];
}

#pragma mark - UIViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
#warning TODO custom button edit
    }

    return self;
}

@end
