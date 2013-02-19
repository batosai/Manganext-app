//
//  MOSignetViewController.m
//  Manga Out
//
//  Created by Jérémy chaufourier on 26/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import "MOSignetViewController.h"
#import "MORootController.h"

@interface MOSignetViewController ()

@end

@implementation MOSignetViewController

@synthesize type = _type;
@synthesize books = _books;
@synthesize detailViewController = _detailViewController;

- (id)init
{
    self = [super init];
    if (self) {
        //self.title = NSLocalizedString(@"Master", @"Master");
    }
    self.books = [[[MOBooks alloc] init] autorelease];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([_books.books count]) {
        self.editButtonItem.enabled = YES;
    }
    else {
        self.editButtonItem.enabled = NO;
    }
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return [_books.books count] ? YES : NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        Book *book = [_books.books objectAtIndex:indexPath.row];
        [book deleteSignet];

        [_books.books removeObjectAtIndex:indexPath.row];

        [[[MOAppDelegate sharedAppDelegate] tabBarController] badgeRefresh];
        
        if (![_books.books count]) {
            self.editButtonItem.enabled = NO;
            [tableView reloadData];
            //tableView.editing = NO;
        }
        else {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![_books.books count]) {
        return;
    }

    Book *book = [_books.books objectAtIndex:indexPath.row];

    if (!self.detailViewController) {
        self.detailViewController = [[[MODetailViewController alloc] init] autorelease];
    }

    self.detailViewController.book = book;

    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

- (void)dealloc {
    [_books release];
    [_detailViewController release];
    [super dealloc];
}

@end
