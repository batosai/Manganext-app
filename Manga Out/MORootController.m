//
//  MORootController.m
//  Manga Next
//
//  Created by Jeremy on 06/05/13.
//  Copyright (c) 2013 Jeremy Chaufourier. All rights reserved.
//

#import "MORootController.h"
#import "MONavigationController.h"
#import "MOHomeViewController.h"
#import "MOBookViewController.h"
#import "MOSignetViewController.h"
#import "MOSubscriptionViewController.h"
#import "IASKAppSettingsViewController.h"

@interface MORootController ()

@end

@implementation MORootController

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self showViewAtIndex:0];
    [self awesomeMenu];
}

- (void)awesomeMenu {
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];

    AwesomeMenuItem *starMenuItem1 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:[UIImage imageNamed:@"icon-home"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem2 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:[UIImage imageNamed:@"icon-new"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem3 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:[UIImage imageNamed:@"icon-future"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem4 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:[UIImage imageNamed:@"icon-list"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem5 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:[UIImage imageNamed:@"icon-signet"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem6 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:[UIImage imageNamed:@"icon-setting"]
                                                    highlightedContentImage:nil];

    NSArray *menus = [NSArray arrayWithObjects:starMenuItem1, starMenuItem2, starMenuItem3, starMenuItem4, starMenuItem5, starMenuItem6, nil];

    menu = [[AwesomeMenu alloc] initWithFrame:self.view.bounds menus:menus];
    menu.menuWholeAngle = M_PI/1.7;
    menu.startPoint = CGPointMake(25.0, CGRectGetHeight(self.view.bounds) - 25);
    menu.delegate = self;

    [self.view insertSubview:menu atIndex:1];
}

- (void)showViewAtIndex:(NSUInteger)index {
    [navigationHomeController.view removeFromSuperview];
    [navigationNewBooksController.view removeFromSuperview];
    [navigationFutureBooksController.view removeFromSuperview];
    [navigationSignetController.view removeFromSuperview];
    [navigationSubscriptionController.view removeFromSuperview];
    [navigationAppSettingsController.view removeFromSuperview];

    switch (index) {
            case 0:
            if (!navigationHomeController) {
                MOHomeViewController *homeTableViewController = [[MOHomeViewController alloc] init];
                homeTableViewController.title = NSLocalizedString(@"Manga Next", nil);

                navigationHomeController = [[MONavigationController alloc] initWithRootViewController:homeTableViewController];
                navigationHomeController.view.frame = self.view.bounds;
            }
            [self.view insertSubview:navigationHomeController.view atIndex:0];
            break;
        case 1:
            if (!navigationNewBooksController) {
                MOBookViewController *newBooksTableViewController = [[MOBookViewController alloc] init];
                newBooksTableViewController.title = NSLocalizedString(@"Nouveautes", nil);
                newBooksTableViewController.type = NEW;

                navigationNewBooksController = [[MONavigationController alloc] initWithRootViewController:newBooksTableViewController];
                navigationNewBooksController.view.frame = self.view.bounds;
            }
            [self.view insertSubview:navigationNewBooksController.view atIndex:0];
            break;
        default:
        case 2:
            if (!navigationFutureBooksController) {
                MOBookViewController *futureBooksTableViewController = [[MOBookViewController alloc] init];
                futureBooksTableViewController.title = NSLocalizedString(@"Prochainement", nil);
                futureBooksTableViewController.type = FUTURE;

                navigationFutureBooksController = [[MONavigationController alloc] initWithRootViewController:futureBooksTableViewController];
                navigationFutureBooksController.view.frame = self.view.bounds;
            }
            [self.view insertSubview:navigationFutureBooksController.view atIndex:0];
            break;
        case 3:
            if (!navigationSubscriptionController) {
                MOSubscriptionViewController *subscriptionTableViewController = [[MOSubscriptionViewController alloc] init];
                subscriptionTableViewController.title = NSLocalizedString(@"Ma liste", nil);
                subscriptionTableViewController.type = SUBSCRIPTION;

                navigationSubscriptionController = [[MONavigationController alloc] initWithRootViewController:subscriptionTableViewController];
                navigationSubscriptionController.view.frame = self.view.bounds;
            }
            [self.view insertSubview:navigationSubscriptionController.view atIndex:0];
            break;
        case 4:
            if (!navigationSignetController) {
                MOSignetViewController *signetTableViewController = [[MOSignetViewController alloc] init];
                signetTableViewController.title = NSLocalizedString(@"Liste d'achat", nil);
                signetTableViewController.type = SIGNET;

                navigationSignetController = [[MONavigationController alloc] initWithRootViewController:signetTableViewController];
                navigationSignetController.view.frame = self.view.bounds;
            }
            [self.view insertSubview:navigationSignetController.view atIndex:0];
            break;
        case 5:
            if (!navigationAppSettingsController) {
                IASKAppSettingsViewController *appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
//                appSettingsViewController.delegate = self;
                appSettingsViewController.showDoneButton = NO;
                appSettingsViewController.title = NSLocalizedString(@"Parametres", @"Parametres");

                navigationAppSettingsController = [[MONavigationController alloc] initWithRootViewController:appSettingsViewController];
                navigationAppSettingsController.view.frame = self.view.bounds;
            }
            [self.view insertSubview:navigationAppSettingsController.view atIndex:0];
            break;
    }
}

#pragma delegate

- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx {
    [self showViewAtIndex:idx];
}

@end
