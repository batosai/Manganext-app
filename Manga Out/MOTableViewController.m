//
//  RootViewController.m
//  PullToRefresh
//
//  Created by Jérémy chaufourier on 02/07/11.
//  Copyright Plancast 2010. All rights reserved.
//
#import "MOTableViewController.h"
#import "MOBaseNavivationViewController.h"

#import "MOAPIClient.h"

@interface MOTableViewController ()
- (void)startIconDownload:(Book *)book forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MOTableViewController

@synthesize type = _type;
@synthesize books = _books;
@synthesize imageDownloadsInProgress = _imageDownloadsInProgress;
@synthesize detailViewController = _detailViewController;


@synthesize searchBar = _searchBar;

- (id) init {
    self  = [super init];
    if (self) {
        self.books = [[[MOBooks alloc] init] autorelease];
        self.imageDownloadsInProgress = [NSMutableDictionary dictionary];

        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        
//        UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(startLoading)] autorelease];
//        self.navigationItem.rightBarButtonItem = addButton;


        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 44.0f)];
        _searchBar.delegate = self;
        _searchBar.tintColor = [UIColor orangeColor];
        _searchBar.placeholder = NSLocalizedString(@"Recherche", @"Recherche");
        
        UITextField *searchtextfield = [_searchBar.subviews objectAtIndex:1];
        searchtextfield.clearButtonMode = UITextFieldViewModeWhileEditing;

        self.tableView.tableHeaderView = _searchBar;
    }

    return self;
}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    
//    // terminate all pending download connections
//    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
//    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
//}

- (void)viewWillAppear:(BOOL)animated
{
    if (_type == NEW) {
        [[MOAppDelegate sharedAppDelegate].tracker trackView:@"Liste des nouveautés"];
    }
    else {
        [[MOAppDelegate sharedAppDelegate].tracker trackView:@"Liste des prochaines sorties"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_books.books count] ? [_books.books count] : 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    
//    return @"test";
//}
//
//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
//{
//    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
//    [headerView setBackgroundColor:[UIColor brownColor]];
//    
//    UIImageView *headerImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BarBackground.png"]] autorelease];
//    headerImage.frame = CGRectMake(0, 0, tableView.bounds.size.width, 22);
//    [headerView addSubview:headerImage];
//    
//    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 1, tableView.bounds.size.width - 10, 18)] autorelease];
//    label.text = @"test";
//    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75];
//    label.backgroundColor = [UIColor clearColor];
//    [headerView addSubview:label];
//   
//    return headerView;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"CellIdentifier";
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
        
		//cell.detailTextLabel.text = @"Aucune sortie";
        //cell.detailTextLabel.textAlignment = UITextAlignmentCenter;

        CGRect frame = CGRectMake(0, 32, cell.frame.size.width, 14);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.text = NSLocalizedString(@"Aucune sortie", @"");
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor grayColor];
        label.textAlignment = UITextAlignmentCenter;
        [cell addSubview:label];
        [label release];

		return cell;
    }

    Book *book = [_books getBookAtIndex:indexPath.row];
	
    MOViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[MOViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    [cell setValuesWithBook:book];

    if (!book.thumbnail)
    {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self startIconDownload:book forIndexPath:indexPath];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (![_books.books count]) return;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Book *book = [_books.books objectAtIndex:indexPath.row];
        [book remove];

        [_books.books removeObjectAtIndex:indexPath.row];

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 78.;
}

- (void)refresh {
    [self performSelector:@selector(addItem) withObject:nil afterDelay:.0];
}

- (void)addItem {

    id dictionary;
    NSString *stringUrl = _type == NEW ? NEWBOOKSURI : FUTUREBOOKSURI;

    /*id last_update = [self.books lastUpdate];

    if (last_update) {
        dictionary = [NSDictionary dictionaryWithObject:last_update forKey:@"updated_at"];
    }
    else {*/
        dictionary = nil;
    //}

    [[MOAPIClient sharedClient] getPath:stringUrl parameters:dictionary success:^(AFHTTPRequestOperation *operation, id JSON) {

        NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:JSON];

        [_books refreshWithDictionary:dictionary];

        [self.tableView reloadData];
        [self stopLoading];
        _searchBar.text = nil;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            CGSize size = self.tableView.contentSize;
            size.height += 66;
            self.tableView.contentSize = size;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Mise à jour impossible.", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];

        [alert show];
        [alert release];
        [self stopLoading];
    }];
}

- (void)setupStrings{
    textPull = [[NSString alloc] initWithString:NSLocalizedString(@"Tirez pour actualiser...", @"")];
    textRelease = [[NSString alloc] initWithString:NSLocalizedString(@"Relâchez pour actualiser...", @"")];
    textLoading = [[NSString alloc] initWithString:NSLocalizedString(@"Chargement...", @"")];
}

- (void)startIconDownload:(Book *)book forIndexPath:(NSIndexPath *)indexPath
{
    MOThumbnailDownloader *iconDownloader = [_imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[MOThumbnailDownloader alloc] init];
        iconDownloader.book = book;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [_imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([_books.books count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            Book *book = [_books getBookAtIndex:indexPath.row];
            
            if (!book.thumbnail) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:book forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    MOThumbnailDownloader *iconDownloader = [_imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil && iconDownloader.book.thumbnail != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];

        // Display the newly loaded image
        CGRect frame = CGRectZero;
        frame.size.width = iconDownloader.book.thumbnail.size.width;
        frame.size.height = iconDownloader.book.thumbnail.size.height;
        cell.imageView.frame = frame;
        cell.imageView.image = iconDownloader.book.thumbnail;
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
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    }
    else {
        MOBaseNavivationViewController *navigationController = [[MOBaseNavivationViewController alloc] initWithRootViewController:self.detailViewController];
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closePressed)] autorelease];
        self.detailViewController.navigationItem.leftBarButtonItem = cancelButton;

        [self presentModalViewController:navigationController animated:YES];
    }
}

- (void)closePressed {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [_books release];
    [_imageDownloadsInProgress release];
    [_detailViewController release];
    [_searchBar release];
    [super dealloc];
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

#pragma mark (UISearchBarDelegate)

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = nil;
    [_searchBar setShowsCancelButton:NO animated:YES];

    [_books filterByObject:nil];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    /*NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchBar.text];
    NSArray *items = [[NSArray alloc] initWithObjects:@"test", @"plop test", nil];
    NSLog(@"%@", [items filteredArrayUsingPredicate:predicate]);*/
    
    [_books filterByObject:searchBar.text];
    [self.tableView reloadData];
    
    [searchBar resignFirstResponder];
}

@end

