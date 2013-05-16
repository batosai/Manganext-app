//
//  MOSubscriptionViewController.m
//  Manga Next
//
//  Created by Jeremy on 07/05/13.
//  Copyright (c) 2013 Jeremy Chaufourier. All rights reserved.
//

#import "MOSubscriptionViewController.h"
#import "MOAppDelegate.h"
#import "MONavigationController.h"
#import "MOSubscriptionDocument.h"
#import "MOSubscriptionManagementViewController.h"

@interface MOSubscriptionViewController () {
    UIBarButtonItem *managedButton;
}

@end

@implementation MOSubscriptionViewController

- (void)configure {
    NSFetchRequest *fetchRequest;
    NSPredicate *predicate;

    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Book"];

    fetchRequest.sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"published_at" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];

    NSDictionary *dictionary = [[(MOAppDelegate *)[[UIApplication sharedApplication] delegate] subscriptionDocument] dictionary];
    NSArray *keys;

    if ([dictionary count]) {
        keys = [dictionary allKeys];
    }
    else {
        keys = @[];
    }

    NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
    [dateComponent setDay:-1];

    NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponent toDate:[NSDate date] options:0];

    predicate = [NSPredicate predicateWithFormat:@"(published_at > %@) AND name IN %@", date, keys];

    [fetchRequest setPredicate:predicate];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[(id)[[UIApplication sharedApplication] delegate] managedObjectContext] sectionNameKeyPath:nil cacheName:@"SubscriptionBook"];
    _fetchedResultsController.delegate = self;

    [self refetchData];
}

#pragma mark - UIViewController

- (id)init
{
    self = [super init];
    if (self) {
        managedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                      target:self
                                                                      action:@selector(managedSubscriptionPressed)];
        self.navigationItem.rightBarButtonItem = managedButton;
    }
    return self;
}

#pragma button action

- (void)managedSubscriptionPressed {
    MOSubscriptionManagementViewController *subscriptionManagementViewController = [[MOSubscriptionManagementViewController alloc] init];

    MONavigationController *navigationController = [[MONavigationController alloc] initWithRootViewController:subscriptionManagementViewController];

    [self presentModalViewController:navigationController animated:YES];
}

@end
