//
//  MOBookViewController.m
//  Manga Next
//
//  Created by Jeremy on 20/04/13.
//  Copyright (c) 2013 Jeremy Chaufourier. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MOBookViewController.h"
#import "MODetailViewController.h"

#import "Book.h"
#import "AFIncrementalStore.h"

#import "MOViewCell.h"

@interface MOBookViewController ()

@end

@implementation MOBookViewController

@synthesize
    type                    = _type,
    searchBar               = _searchBar
;

- (void)refetchData {
    [_fetchedResultsController performSelectorOnMainThread:@selector(performFetch:) withObject:nil waitUntilDone:YES modes:@[ NSRunLoopCommonModes ]];
}

- (void)setType:(NSUInteger)type {
    _type = type;

    [self configure];
}

- (void)configure {
    NSFetchRequest *fetchRequest;
    NSPredicate *predicate;
    NSString *cacheName;
    NSString *where;

    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Book"];

    if (_type == NEW) {
        fetchRequest.sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"published_at" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];

        where = @"published_at <= %@";
        cacheName = @"NextBook";
    }
    else {
        fetchRequest.sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"published_at" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];

        where = @"published_at > %@";
        cacheName = @"FutureBook";
    }

    if (_searchBar.text && _searchBar.text.length > 0) {
        cacheName = [NSString stringWithFormat:@"search %@: %@", cacheName, _searchBar.text];
        predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(%@) %@", where, @"AND (name contains[cd] %@ OR editor_name contains[cd] %@)"], [NSDate date], _searchBar.text, _searchBar.text];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:where, [NSDate date]];
    }

    [fetchRequest setPredicate:predicate];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[(id)[[UIApplication sharedApplication] delegate] managedObjectContext] sectionNameKeyPath:nil cacheName:cacheName];
    _fetchedResultsController.delegate = self;

    [self refetchData];
}

#pragma mark - UIViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refresh)
                                                     name:NOTIFICATION_REFRESH
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [searchButton setImage:[UIImage imageNamed:@"bt-search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonPress:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    //UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonPress:)];

    self.navigationItem.rightBarButtonItem = searchButtonItem;

    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 44.0f)];
    _searchBar.delegate = self;
    _searchBar.tintColor = [UIColor orangeColor];
    _searchBar.placeholder = NSLocalizedString(@"Recherche", @"Recherche");
    _searchBar.backgroundImage = [UIImage imageNamed: @"BarBackground.png"];

    UITextField *searchTextfield = [_searchBar.subviews objectAtIndex:1];
    searchTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;

    self.tableView.rowHeight = 70.0f;

    [[NSNotificationCenter defaultCenter] addObserverForName:AFIncrementalStoreContextDidFetchRemoteValues object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self stopLoading];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    MOViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[MOViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    Book *book = (Book *)[_fetchedResultsController objectAtIndexPath:indexPath];
    cell.book = book;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Book *book = (Book *)[_fetchedResultsController objectAtIndexPath:indexPath];

    if (!detailViewController) {
        detailViewController = [[MODetailViewController alloc] init];
    }

    detailViewController.book = book;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else {
        UINavigationController *navigationDetailController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        self.navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closePressed)];
        detailViewController.navigationItem.leftBarButtonItem = cancelButton;

        [self presentModalViewController:navigationDetailController animated:YES];
    }
}

#pragma mark - PullRefreshTableViewController data source

- (void)refresh {
    _fetchedResultsController.fetchRequest.resultType = NSManagedObjectResultType;
    [_fetchedResultsController performFetch:nil];
}

#pragma button action

- (void)searchButtonPress:(id)sender {
    self.tableView.tableHeaderView = _searchBar;
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];

    UITextField *searchTextfield = [_searchBar.subviews objectAtIndex:1];
    [searchTextfield becomeFirstResponder];
}

#pragma mark (UISearchBarDelegate)

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:YES animated:YES];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _searchBar.text = nil;
    [_searchBar setShowsCancelButton:NO animated:YES];
    self.tableView.tableHeaderView = nil;

//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [self configure];
    [_searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [self configure];
    [_searchBar resignFirstResponder];
}

#pragma mark - NSFetchedResultsControllerDelegate - Pre-iOS 4.0

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {NSLog(@"reloadData");
    [self.tableView reloadData];
}

@end
