//
//  NavivationViewController.h
//  test
//
//  Created by Jérémy chaufourier on 02/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOBaseNavivationViewController.h"

#import "AFJSONRequestOperation.h"
#import "MOTableViewController.h"
//#import "MOSignetViewController.h"
#import "MOSubscriptionViewController.h"
#import "IASKAppSettingsViewController.h"

@interface MONavivationViewController : MOBaseNavivationViewController<ADBannerViewDelegate> {
    MOTableViewController *tableViewController;
    //MOSignetViewController *signetTableViewController;
    MOSubscriptionViewController *subscriptionTableViewController;
    IASKAppSettingsViewController *appSettingsViewController;
    
    BOOL bannerIsVisible;
    ADBannerView *bannerView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
