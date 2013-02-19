//
//  MOAppDelegate.h
//  Manga Out
//
//  Created by Jérémy chaufourier on 12/02/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@class MORootController, MOSubscriptionDocument;

@interface MOAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (assign, nonatomic) MORootController *tabBarController;

@property (readwrite, strong, nonatomic) MOSubscriptionDocument *subscriptionDocument;
@property (strong) NSMetadataQuery *query;

+ (MOAppDelegate *)sharedAppDelegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)loadSubscriptionDocument;

@end
