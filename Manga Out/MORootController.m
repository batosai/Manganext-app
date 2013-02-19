//
//  MORootController.m
//  Manga Out
//
//  Created by Jérémy chaufourier on 12/02/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import "MORootController.h"

@implementation MORootController

@synthesize freshBooksNavigationController = _newBooksNavigationController;
@synthesize futureBooksNavigationController = _futureBooksNavigationController;
//@synthesize signetNavigationController = _signetNavigationController;
@synthesize subscriptionNavigationController = _subscriptionNavigationController;
@synthesize settingsNavigationController = _settingsNavigationController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        newBooksTableViewController = [[[MOTableViewController alloc] init] autorelease];
        newBooksTableViewController.title = NSLocalizedString(@"Nouveautes", nil);
        newBooksTableViewController.type = NEW;

        futureBooksTableViewController = [[[MOTableViewController alloc] init] autorelease];
        futureBooksTableViewController.title = NSLocalizedString(@"Prochainement", nil);
        futureBooksTableViewController.type = FUTURE;

//        signetViewController = [[[MOSignetViewController alloc] init] autorelease];
//        signetViewController.title = NSLocalizedString(@"Mes selections", nil);
//        signetViewController.type = SIGNET;
        
        subscriptionTableViewController = [[[MOSubscriptionViewController alloc] init] autorelease];
        subscriptionTableViewController.title = NSLocalizedString(@"Ma liste", nil);
        subscriptionTableViewController.type = SUBSCRIPTION;

        appSettingsViewController = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
		appSettingsViewController.delegate = self;
        appSettingsViewController.showDoneButton = NO;
        appSettingsViewController.title = NSLocalizedString(@"Parametres", @"Parametres");

        
        //-----------------

        _newBooksNavigationController = [[MONavivationViewController alloc] initWithRootViewController:newBooksTableViewController];
        
        UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"news"] tag:1];//_newBooksNavigationController.title
        
        _newBooksNavigationController.tabBarItem = tabItem;

        //-----------------

        _futureBooksNavigationController = [[MONavivationViewController alloc] initWithRootViewController:futureBooksTableViewController];
        
        UITabBarItem *tabItem2 = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"future"] tag:2];//futureBooksTableViewController.title
        
        _futureBooksNavigationController.tabBarItem = tabItem2;
        
        //-----------------

        _subscriptionNavigationController = [[MONavivationViewController alloc] initWithRootViewController:subscriptionTableViewController];

        UITabBarItem *tabItem3 = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"signet"] tag:3];//signetViewController.title

        _subscriptionNavigationController.tabBarItem = tabItem3;

        //-----------------

        _settingsNavigationController = [[MONavivationViewController alloc] initWithRootViewController:appSettingsViewController];
        
        UITabBarItem *tabItem4 = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"settings"] tag:2];//NSLocalizedString(@"Parametres", @"Parametres")
        
        _settingsNavigationController.tabBarItem = tabItem4;

        //-----------------

        [self badgeRefresh];
        
        self.viewControllers = [NSArray arrayWithObjects:_newBooksNavigationController, _futureBooksNavigationController, _subscriptionNavigationController, _settingsNavigationController, nil];
        
        //self.tabBar.tintColor = [UIColor greenColor];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
            self.tabBar.tintColor = [UIColor whiteColor];
            self.tabBar.selectedImageTintColor = [UIColor whiteColor];
            
            UIImage* tabBarBackground = [UIImage imageNamed:@"tabbar"];
            [[UITabBar appearance] setBackgroundImage:tabBarBackground];

            [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"selection-tab"]];
        }
        
        [tabItem release];
        [tabItem2 release];
        [tabItem3 release];
    }
    return self;
}

- (void)badgeRefresh
{
    //books = [[MOBooks alloc] initWithManagedObjectContext:[[MOAppDelegate sharedAppDelegate] managedObjectContext] andType:SIGNET];
    //[self badgeValue:[books getCountSignetToday]];
}

- (void)badgeValue:(NSUInteger) badge
{    
    if (badge) {
        _subscriptionNavigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", badge];
    }
    else {
        _subscriptionNavigationController.tabBarItem.badgeValue = nil;
    }
}

- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForKey:(NSString*)key {
	if ([key isEqualToString:@"ButtonSettingsAction"]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Effacer toutes les données", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Annuler", @"") otherButtonTitles:NSLocalizedString(@"Supprimer", @""), nil];
        [alert show];
        [alert release];

	}
    else if ([key isEqualToString:@"ButtonNoteAction"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/manga-next/id524486749?mt=8&ign-mpt=uo%3D4"]];
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 0)
    {
        //NSLog(@"annuler");
    }
    else
    {
        [[[MOBooks alloc] initWithManagedObjectContext:[[MOAppDelegate sharedAppDelegate] managedObjectContext]]deleteBooks];

        newBooksTableViewController.books = nil;
        [newBooksTableViewController.imageDownloadsInProgress removeAllObjects];
        [newBooksTableViewController.tableView reloadData];

        futureBooksTableViewController.books = nil;
        [futureBooksTableViewController.imageDownloadsInProgress removeAllObjects];
        [futureBooksTableViewController.tableView reloadData];

        subscriptionTableViewController.books = nil;
        [subscriptionTableViewController.tableView reloadData];
        
        [_newBooksNavigationController popViewControllerAnimated:YES];
        [_futureBooksNavigationController popViewControllerAnimated:YES];
        [_settingsNavigationController popViewControllerAnimated:YES];

    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [newBooksTableViewController release];
    newBooksTableViewController = nil;
    [futureBooksTableViewController release];
    futureBooksTableViewController = nil;
    [subscriptionTableViewController release];
    subscriptionTableViewController = nil;
    [IASKAppSettingsViewController release];

    [splitForNewBooksViewController release];
    splitForNewBooksViewController = nil;
    [splitForFutureBooksViewController release];
    splitForFutureBooksViewController = nil;

    [_newBooksNavigationController release];
    _newBooksNavigationController = nil;
    [_futureBooksNavigationController release];
    _futureBooksNavigationController = nil;
    [_subscriptionNavigationController release];
    _subscriptionNavigationController = nil;
    [_settingsNavigationController release];
    _settingsNavigationController = nil;
}

- (void)dealloc
{
    [super dealloc];
    [newBooksTableViewController release];
    [futureBooksTableViewController release];
    [subscriptionTableViewController release];
    [IASKAppSettingsViewController release];

    [_newBooksNavigationController release];
    [_subscriptionNavigationController release];
    [_futureBooksNavigationController release];
    [_settingsNavigationController release];
    [books release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    return YES;
    //return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
