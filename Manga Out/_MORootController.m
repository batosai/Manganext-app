//
//  MORootController.m
//  Manga Out
//
//  Created by Jérémy chaufourier on 12/02/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import "MORootController.h"

@implementation MORootController

//@synthesize
//    signetNavigationController          = _signetNavigationController,
//    subscriptionNavigationController    = _subscriptionNavigationController,
//    settingsNavigationController        = _settingsNavigationController
//;

- (id)init
{
    self = [super init];
    if (self) {
        newBooksTableViewController = [[MOBookViewController alloc] init];
        newBooksTableViewController.title = NSLocalizedString(@"Nouveautes", nil);
        newBooksTableViewController.type = NEW;

        futureBooksTableViewController = [[MOBookViewController alloc] init];
        futureBooksTableViewController.title = NSLocalizedString(@"Prochainement", nil);
        futureBooksTableViewController.type = FUTURE;

//        signetViewController = [[MOSignetViewController alloc] init];
//        signetViewController.title = NSLocalizedString(@"Mes selections", nil);
//        signetViewController.type = SIGNET;

//        subscriptionTableViewController = [[MOSubscriptionViewController alloc] init];
//        subscriptionTableViewController.title = NSLocalizedString(@"Ma liste", nil);
//        subscriptionTableViewController.type = SUBSCRIPTION;

//        appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
//		appSettingsViewController.delegate = self;
//        appSettingsViewController.showDoneButton = NO;
//        appSettingsViewController.title = NSLocalizedString(@"Parametres", @"Parametres");

//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(badgeRefresh)
//                                                     name:NOTIFICATION_SUBSCRIPTION_MODIFIED_DICTIONARY
//                                                   object:nil];


        UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"news"] tag:1];
        newBooksTableViewController.navigationController.tabBarItem = tabItem;

        UITabBarItem *tabItem2 = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"future"] tag:2];
        futureBooksTableViewController.navigationController.tabBarItem = tabItem2;

        //-----------------
/*
        _newBooksNavigationController = [[MONavivationViewController alloc] initWithRootViewController:newBooksTableViewController];
        
        UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"news"] tag:1];//_newBooksNavigationController.title
        
        _newBooksNavigationController.tabBarItem = tabItem;

        //-----------------

        _futureBooksNavigationController = [[MONavivationViewController alloc] initWithRootViewController:futureBooksTableViewController];
        
        UITabBarItem *tabItem2 = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"future"] tag:2];//futureBooksTableViewController.title
        
        _futureBooksNavigationController.tabBarItem = tabItem2;

        //-----------------

        _subscriptionNavigationController = [[MONavivationViewController alloc] initWithRootViewController:subscriptionTableViewController];

        UITabBarItem *tabItem3 = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"alignJust"] tag:3];//signetViewController.title

        _subscriptionNavigationController.tabBarItem = tabItem3;

        //-----------------

        _signetNavigationController = [[MONavivationViewController alloc] initWithRootViewController:signetViewController];

        UITabBarItem *tabItem4 = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"signet"] tag:4];//signetViewController.title

        _signetNavigationController.tabBarItem = tabItem4;

        //-----------------

        _settingsNavigationController = [[MONavivationViewController alloc] initWithRootViewController:appSettingsViewController];
        
        UITabBarItem *tabItem5 = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"settings"] tag:5];//NSLocalizedString(@"Parametres", @"Parametres")
        
        _settingsNavigationController.tabBarItem = tabItem5;

        //-----------------

        self.viewControllers = [NSArray arrayWithObjects:_newBooksNavigationController, _futureBooksNavigationController, _subscriptionNavigationController, _signetNavigationController, _settingsNavigationController, nil];
*/

        self.viewControllers = [NSArray arrayWithObjects:newBooksTableViewController.navigationController, futureBooksTableViewController.navigationController, nil];


        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
            self.tabBar.tintColor = [UIColor whiteColor];
            self.tabBar.selectedImageTintColor = [UIColor whiteColor];
            
            UIImage* tabBarBackground = [UIImage imageNamed:@"tabbar"];
            [[UITabBar appearance] setBackgroundImage:tabBarBackground];

            [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"selection-tab"]];
        }
    }
    return self;
}

//- (void)badgeRefresh
//{
//    books = [[MOBooks alloc] initWithManagedObjectContext:[[MOAppDelegate sharedAppDelegate] managedObjectContext] andType:SUBSCRIPTION];
//
//    [books filterByObject:[MOAppDelegate sharedAppDelegate].subscriptionDocument.dictionary];
//    [self badgeValue:[books getCountSignetToday]];
//}
//
//- (void)badgeValue:(NSUInteger) badge
//{    
//    if (badge) {
//        _subscriptionNavigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", badge];
//    }
//    else {
//        _subscriptionNavigationController.tabBarItem.badgeValue = nil;
//    }
//}
//
//- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForKey:(NSString*)key {
//	if ([key isEqualToString:@"ButtonSettingsAction"]) {
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Effacer toutes les données", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Annuler", @"") otherButtonTitles:NSLocalizedString(@"Supprimer", @""), nil];
//        [alert show];
//        
//        [[MOAppDelegate sharedAppDelegate].tracker trackEventWithCategory:@"Button"
//                                                               withAction:@"Reinitialiser"
//                                                                withLabel:@"Reinitialiser"
//                                                                withValue:nil];
//
//	}
//    else if ([key isEqualToString:@"ButtonNoteAction"]) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/manga-next/id524486749?mt=8&ign-mpt=uo%3D4"]];
//
//        [[MOAppDelegate sharedAppDelegate].tracker trackEventWithCategory:@"Button"
//                                                               withAction:@"Noter app"
//                                                                withLabel:@"Noter app"
//                                                                withValue:nil];
//    }
//}
//
//- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    // the user clicked one of the OK/Cancel buttons
//    if (buttonIndex == 0)
//    {
//        //NSLog(@"annuler");
//    }
//    else
//    {
//        [[[MOBooks alloc] initWithManagedObjectContext:[[MOAppDelegate sharedAppDelegate] managedObjectContext]]deleteBooks];
//
//        newBooksTableViewController.books = nil;
//        [newBooksTableViewController.imageDownloadsInProgress removeAllObjects];
//        [newBooksTableViewController.tableView reloadData];
//
//        futureBooksTableViewController.books = nil;
//        [futureBooksTableViewController.imageDownloadsInProgress removeAllObjects];
//        [futureBooksTableViewController.tableView reloadData];
//
//        subscriptionTableViewController.books = nil;
//        [subscriptionTableViewController.tableView reloadData];
//        
//        [_newBooksNavigationController popViewControllerAnimated:YES];
//        [_futureBooksNavigationController popViewControllerAnimated:YES];
//        [_settingsNavigationController popViewControllerAnimated:YES];
//
//    }
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    return YES;
    //return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
