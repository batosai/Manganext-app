//
//  MOSubscriptionViewController.m
//  Manga Next
//
//  Created by Jeremy on 11/02/13.
//  Copyright (c) 2013 Jérémy Chaufourier. All rights reserved.
//

#import "MOSubscriptionViewController.h"
#import "MOAppDelegate.h"
#import "MOSubscriptionDocument.h"
#import "MOSubscriptionManagementViewController.h"
#import "MOBaseNavivationViewController.h"

@interface MOSubscriptionViewController () {
    MODetailViewController *detailViewController;
    UIBarButtonItem *managedButton;
}
@end

@implementation MOSubscriptionViewController

@synthesize type = _type;
@synthesize books = _books;

- (id)init
{
    self = [super init];
    if (self) {
        self.books = [[[MOBooks alloc] init] autorelease];
        
        managedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                   target:self
                                                                                   action:@selector(managedSubscriptionPressed)];
        self.navigationItem.rightBarButtonItem = managedButton;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [[MOAppDelegate sharedAppDelegate].tracker trackView:@"Liste des abonnements"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_books.books count] ? [_books.books count] : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    int nodeCount = [_books.books count];
    
	if (nodeCount == 0 && indexPath.row == 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil)
		{
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										   reuseIdentifier:PlaceholderCellIdentifier] autorelease];
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        CGRect frame = CGRectMake(0, 32, cell.frame.size.width, 14);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.text = NSLocalizedString(@"Aucune sélèction", @"");
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor grayColor];
        label.textAlignment = UITextAlignmentCenter;
        [cell addSubview:label];
        [label release];
        
		return cell;
    }
    
    Book *book = [_books getBookAtIndex:indexPath.row];
    
    MOViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MOViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [cell setValuesWithBook:book];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 78.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![_books.books count]) {
        return;
    }

    Book *book = [_books.books objectAtIndex:indexPath.row];
    
    if (!detailViewController) {
        detailViewController = [[MODetailViewController alloc] init];
    }

    detailViewController.book = book;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else {
        MOBaseNavivationViewController *navigationController = [[MOBaseNavivationViewController alloc] initWithRootViewController:detailViewController];
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closePressed)] autorelease];
        detailViewController.navigationItem.leftBarButtonItem = cancelButton;
        
        [self presentModalViewController:navigationController animated:YES];
    }

}

- (void)dealloc {
    [_books release];
    [detailViewController release];
    [super dealloc];
}

#pragma delegate

- (void)closePressed {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)managedSubscriptionPressed {
    MOSubscriptionManagementViewController *subscriptionManagementViewController = [[MOSubscriptionManagementViewController alloc] init];

    [self presentModalViewController:[subscriptionManagementViewController navigationController] animated:YES];
}

@end
