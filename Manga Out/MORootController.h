//
//  MORootController.h
//  Manga Out
//
//  Created by Jérémy chaufourier on 12/02/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MOTableViewController.h"
#import "MOAppDelegate.h"
//#import "MOSignetViewController.h"
#import "MOSubscriptionViewController.h"
#import "MONavivationViewController.h"
#import "IASKAppSettingsViewController.h"
#import "MOBooks.h"

@interface MORootController : UITabBarController {
    MOTableViewController *newBooksTableViewController;
    MOTableViewController *futureBooksTableViewController;
    //MOSignetViewController *signetViewController;
    MOSubscriptionViewController *subscriptionTableViewController;
    IASKAppSettingsViewController *appSettingsViewController;
    
    UISplitViewController *splitForNewBooksViewController;
    UISplitViewController *splitForFutureBooksViewController;
    
    MOBooks *books;
}

@property (nonatomic, retain) MONavivationViewController *freshBooksNavigationController;
@property (nonatomic, retain) MONavivationViewController *futureBooksNavigationController;
@property (nonatomic, retain) MONavivationViewController *subscriptionNavigationController;
@property (nonatomic, retain) MONavivationViewController *settingsNavigationController;

- (void)badgeValue:(NSUInteger) value;
- (void)badgeRefresh;

@end
