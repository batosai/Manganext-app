//
//  MOAppDelegate.h
//  Manga Out
//
//  Created by Jérémy chaufourier on 12/02/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

#import "GAI.h"
#import "GPPDeepLink.h"

@class MORootController, MOSubscriptionDocument;
@class GTMOAuth2Authentication;

@interface MOAppDelegate : UIResponder <UIApplicationDelegate, GPPDeepLinkDelegate> {
    BOOL useIcloud;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) id<GAITracker> tracker;
@property (readonly, nonatomic) MORootController *rootController;

#pragma CORE DATA
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
#

#pragma ICOULD
@property (readwrite, strong, nonatomic) MOSubscriptionDocument *subscriptionDocument;
@property (strong) NSMetadataQuery *query;

- (void)loadSubscriptionDocument;
#

@end
