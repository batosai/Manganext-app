//
//  NavivationViewController.m
//  test
//
//  Created by Jérémy chaufourier on 02/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MONavivationViewController.h"
#import "MOAppDelegate.h"
#import "MOSubscriptionDocument.h"

@implementation MONavivationViewController

@synthesize managedObjectContext = _managedObjectContext;

- (id) initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if ([rootViewController class] == [MOTableViewController class]) {
        tableViewController = (MOTableViewController*)rootViewController;
    }
//    else if([rootViewController class] ==  [MOSignetViewController class]) {
//        signetTableViewController = (MOSignetViewController*)rootViewController;
//    }
    else if([rootViewController class] ==  [MOSubscriptionViewController class]) {
        subscriptionTableViewController = (MOSubscriptionViewController*)rootViewController;
    }
    else {
        appSettingsViewController = (IASKAppSettingsViewController*)rootViewController;
    }

    if (self) {
        _managedObjectContext = [[MOAppDelegate sharedAppDelegate] managedObjectContext];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh)
                                                 name:NOTIFICATION_REFRESH
                                               object:nil];

    
    return self;
}

- (void)refresh {
    
    if ([self.visibleViewController class] == [MOTableViewController class]) {
        tableViewController.books = [[MOBooks alloc] initWithManagedObjectContext:_managedObjectContext andType:tableViewController.type];

        if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"autoload_preference"] == nil || [[NSUserDefaults standardUserDefaults] boolForKey:@"autoload_preference"]) {
            tableViewController.tableView.contentOffset = CGPointMake(0, -1 * tableViewController.tableView.tableHeaderView.frame.size.height);
            [tableViewController startLoading];
            [tableViewController refresh];
        }
    }
}

- (void)dealloc
{
    [super dealloc];
    [tableViewController release];
    bannerView.delegate = nil;
    [bannerView release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (tableViewController != nil && ![tableViewController.books.books count])
    {
        [self refresh];
    }
    else if (subscriptionTableViewController != nil)
    {
        subscriptionTableViewController.books = [[MOBooks alloc] initWithManagedObjectContext:_managedObjectContext andType:subscriptionTableViewController.type];
        [subscriptionTableViewController.books filterByObject:[MOAppDelegate sharedAppDelegate].subscriptionDocument.dictionary];

        [subscriptionTableViewController.tableView reloadData];
    }
//    else if (signetTableViewController != nil)
//    {
//        signetTableViewController.books = [[MOBooks alloc] initWithManagedObjectContext:_managedObjectContext andType:signetTableViewController.type];
//
//        [signetTableViewController.tableView reloadData];
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // If this view is no longer on the view controller stack,
    // then the back button has been pressed.
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound)
    {
        // *** your code here ***
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    UITabBar *tabBar = [self.tabBarController tabBar];
    NSUInteger index = 0;

    for (UIView *view in tabBar.subviews)
    {
        
        if ([NSStringFromClass([view class]) isEqualToString:@"UITabBarButton"])
        {
            for (UIView *subview in view.subviews)
            {
                if ([subview isKindOfClass:[UIImageView class]])
                {
                    UIImageView *imageView = (UIImageView *)subview;
                    imageView.center = CGPointMake(40, 24);
                }

                if ([subview isKindOfClass:[UILabel class]])
                {
                    UILabel *label = (UILabel *)subview;
                    
                    /*[label setFont:[UIFont fontWithName:@"NothingYouCouldDoBold" size: 8.0]];
                    if (index == self.tabBarController.selectedIndex){
                        label.textColor = [UIColor yellowColor];
                    }
                    else {
                        label.textColor = [UIColor whiteColor];
                    }*/
                    [label removeFromSuperview];
                    index++;
                }
            }
        }
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && !bannerView) {
        bannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
        bannerView.delegate = self;

        CGRect frame = bannerView.frame;
        frame.origin.y = self.view.frame.size.height;
        bannerView.frame = frame;

        bannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait,ADBannerContentSizeIdentifierLandscape,nil];

        if (self.interfaceOrientation == 4) {
            bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
        }
        else {
            bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        }

        bannerIsVisible = NO;
        
        [self.view addSubview:bannerView];
    }
}

- (void)viewDidLoad
{
    //[tbView release];
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    else
        bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect frame = bannerView.frame;
    //NSLog(@"%f", self.view.frame.size.height - bannerView.frame.size.height);
    if (bannerIsVisible) {
        frame.origin.y = self.view.frame.size.height - bannerView.frame.size.height;
    }
    else {
        frame.origin.y = self.view.frame.size.height;
    }

    bannerView.frame = frame;
}

#pragma mark - Banner view

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);

        [UIView commitAnimations];
        bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (bannerIsVisible)
    {NSLog(@"error");
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // banner is visible and we move it out of the screen, due to connection issue
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
        bannerIsVisible = NO;
    }
}

@end
