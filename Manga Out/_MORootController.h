//
//  MORootController.h
//  Manga Out
//
//  Created by Jérémy chaufourier on 12/02/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MOBookViewController.h"
#import "MOAppDelegate.h"
#import "MOSignetViewController.h"
#import "MOSubscriptionDocument.h"
#import "MOSubscriptionViewController.h"
//#import "MONavivationViewController.h"
#import "IASKAppSettingsViewController.h"
#import "MOBooks.h"

@interface MORootController : UITabBarController {
    MOBookViewController *newBooksTableViewController;
    MOBookViewController *futureBooksTableViewController;
    MOSignetViewController *signetViewController;
    MOSubscriptionViewController *subscriptionTableViewController;
    IASKAppSettingsViewController *appSettingsViewController;
    
    UISplitViewController *splitForNewBooksViewController;
    UISplitViewController *splitForFutureBooksViewController;
    
    MOBooks *books;
}

//@property (nonatomic, retain) MONavivationViewController *signetNavigationController;
//@property (nonatomic, retain) MONavivationViewController *subscriptionNavigationController;
//@property (nonatomic, retain) MONavivationViewController *settingsNavigationController;

//- (void)badgeValue:(NSUInteger) value;
//- (void)badgeRefresh;

#warning TODO navigation
#warning TODO detail view
#warning TODO menu path left(home, new, future, subscription, list, setting), right for detail(add subscription, add list, facebook, twitter, mail)
#warning TODO subscription
#warning TODO list
#warning TODO setting
#warning TODO PUSH
#warning TODO iCloud
#warning TODO collection
#warning TODO Notification interne ?
#warning TODO verif iPad

@end
