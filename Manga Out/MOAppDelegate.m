//
//  MOAppDelegate.m
//  Manga Out
//
//  Created by Jérémy chaufourier on 12/02/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import "MOAppDelegate.h"
#import "MOIncrementalStore.h"
#import "MORootController.h"
//#import "MONotifications.h"
#import "MOSubscriptionDocument.h"

#import "GPPSignIn.h"
#import "GPPURLHandler.h"


@implementation MOAppDelegate

static NSString * const kClientID = GPP_APIKEY;

#ifdef DEBUG
static NSString *const kAnalyticsAccountId = ANALYTICS_ACCOUND_ID_DEBUG;
static const NSInteger kDispatchPeriodSeconds = ANALYTICS_DISPACH_PERIOD_SECONDS_DEBUG;
#else
static NSString *const kAnalyticsAccountId = ANALYTICS_ACCOUND_ID_PROD;
static const NSInteger kDispatchPeriodSeconds = ANALYTICS_DISPACH_PERIOD_SECONDS_PROD;
#endif

@synthesize window = _window;
@synthesize rootController = _rootController;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize subscriptionDocument = _subscriptionDocument;
@synthesize query = _query;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GPPSignIn sharedInstance].clientID = kClientID;

    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:8 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];

    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.backgroundColor = [UIColor colorWithHexString:@"#ffb650"];
    _rootController = [[MORootController alloc] init];

    [self loadSubscriptionDocument];
    [self tracking];
/*
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    application.applicationIconBadgeNumber = 0;

    [[NSNotificationCenter defaultCenter] addObserver:self
               selector:@selector(userDefaultsChanged:)
                   name:NSUserDefaultsDidChangeNotification
                 object:nil];
  */
    _window.rootViewController = _rootController;
    [_window makeKeyAndVisible];

    // Read Google+ deep-link data.
    [GPPDeepLink setDelegate:self];
    [GPPDeepLink readDeepLinkAfterInstall];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"%@", sourceApplication);
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

- (void)loadSubscriptionDocument
{
#if !TARGET_IPHONE_SIMULATOR
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    if (
        ([[NSUserDefaults standardUserDefaults] objectForKey:@"icloud_preference"] == nil || [[NSUserDefaults standardUserDefaults] boolForKey:@"icloud_preference"])
        && ubiq) {

        NSLog(@"iCloud access at %@", ubiq);
        [self.tracker trackEventWithCategory:@"iCloud"
                                  withAction:@"Stockage"
                                   withLabel:@"Activer"
                                   withValue:nil];

        [self loadDocument];

        useIcloud = YES;
    }
    else {
#endif
        [self.tracker trackEventWithCategory:@"iCloud"
                                  withAction:@"Stockage"
                                   withLabel:@"Desactiver"
                                   withValue:nil];

        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",path, SUBSCRIPTION_FILE];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        useIcloud = NO;

        _subscriptionDocument = [[MOSubscriptionDocument alloc] initWithFileURL:url];

        [_subscriptionDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
                //NSLog(@"%@", _subscriptionDocument.dictionary);
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"icloud_preference"];
            }
            else {
                [self cacheSubscription];
            }
        }];
#if !TARGET_IPHONE_SIMULATOR
    }
#endif
}

- (void)cacheSubscription{
    // cache subscription mode iCloud disable.
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",path, SUBSCRIPTION_FILE];
    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL isDir = NO;

    if(![fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
        [_subscriptionDocument saveToURL:[_subscriptionDocument fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if(!useIcloud && success) {
                [self loadSubscriptionDocument];
            }
        }];
    }
}

- (void)tracking
{
    // Optional: automatically track uncaught exceptions with Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = kDispatchPeriodSeconds;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = NO;
    // Create tracker instance.
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kAnalyticsAccountId];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [_subscriptionDocument closeWithCompletionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"close file");
        }
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESH object:self];

    [self loadSubscriptionDocument];
}

#pragma mark - notification center

- (void)userDefaultsChanged:(NSNotification *)notification {
#if !TARGET_IPHONE_SIMULATOR
    //NSLog(@"%@", [defaults dictionaryRepresentation]);

    NSUserDefaults *defaults = (NSUserDefaults *)[notification object];
    NSDictionary *dictionnary = [_subscriptionDocument.dictionary copy];
    NSArray *keys = [dictionnary allKeys];
    NSURL *url;

    
    if ([defaults boolForKey:@"icloud_preference"] && !useIcloud) {
        NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        url = [[ubiq URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:SUBSCRIPTION_FILE];
    }
    else if (![defaults boolForKey:@"icloud_preference"] && useIcloud) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",path, SUBSCRIPTION_FILE];
        url = [NSURL fileURLWithPath:filePath];
    }
    
    if ( ([defaults boolForKey:@"icloud_preference"] && !useIcloud) ||
        (![defaults boolForKey:@"icloud_preference"] && useIcloud) ) {
        _subscriptionDocument = nil;
        _subscriptionDocument = [[MOSubscriptionDocument alloc] initWithFileURL:url];

        [_subscriptionDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
                
                if (![defaults boolForKey:@"icloud_preference"]) {
                    _subscriptionDocument.dictionary = nil;
                    _subscriptionDocument.dictionary = [NSMutableDictionary dictionaryWithDictionary:dictionnary];
                }
                else {
                    for (NSString *key in keys) {
                        if(![_subscriptionDocument.dictionary objectForKey:key]) {
                            [_subscriptionDocument.dictionary setObject:[dictionnary objectForKey:key] forKey:key];
                        }
                    }
                }

                [_subscriptionDocument saveToURL:[_subscriptionDocument fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:nil];
            }
        }];

        useIcloud = !useIcloud;

        [self.tracker trackEventWithCategory:@"iCloud"
                                  withAction:@"Stockage"
                                   withLabel:@"status"
                                   withValue:[NSNumber numberWithBool:useIcloud]];
    }

#endif
}

#pragma mark - iCloud

- (void)loadDocument {
    
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    _query = query;
    [query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
    NSPredicate *pred = [NSPredicate predicateWithFormat: @"%K == %@", NSMetadataItemFSNameKey, SUBSCRIPTION_FILE];
    [query setPredicate:pred];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidFinishGathering:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:query];

    [query startQuery];
    
}

- (void)queryDidFinishGathering:(NSNotification *)notification {
    
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:query];
    
    _query = nil;
    
	[self loadData:query];

}

- (void)loadData:(NSMetadataQuery *)query {

    if ([query resultCount] == 1) {
        NSMetadataItem *item = [query resultAtIndex:0];
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        _subscriptionDocument = [[MOSubscriptionDocument alloc] initWithFileURL:url];

        [_subscriptionDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"iCloud document opened");
            } else {
                NSLog(@"failed opening document from iCloud");
            }
        }];
	}
    else {
        NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *ubiquitousPackage = [[ubiq URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:SUBSCRIPTION_FILE];
        
        _subscriptionDocument = [[MOSubscriptionDocument alloc] initWithFileURL:ubiquitousPackage];
        
        [_subscriptionDocument saveToURL:[_subscriptionDocument fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                [_subscriptionDocument openWithCompletionHandler:^(BOOL success) {
                    NSLog(@"new document opened from iCloud");
                }];
            }
        }];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processStateDocChange:)
                                                 name:UIDocumentStateChangedNotification
                                               object:nil];
}

- (void)processStateDocChange: (NSNotification *)notification {
    if (_subscriptionDocument.documentState == UIDocumentStateInConflict)
    {
        NSArray *versionsInConflit = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:_subscriptionDocument.fileURL];

        if (versionsInConflit) {
            [self mergeWithDocument:_subscriptionDocument];
        }

        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIDocumentStateChangedNotification
                                                      object:nil];
    }
}

- (void)mergeWithDocument:(MOSubscriptionDocument*)document
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-DD HH:MM:SS ±HHMM"];
 
    NSMutableDictionary *recentDictionary = [document.dictionary copy];

    NSDate *recentModificationDate = [[NSFileVersion currentVersionOfItemAtURL:document.fileURL] modificationDate];

    NSArray* conflictVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:document.fileURL];
    for (NSFileVersion* fileVersion in conflictVersions) {
        fileVersion.resolved = YES;

        [fileVersion replaceItemAtURL:document.fileURL options:0 error:nil];
        [document revertToContentsOfURL:document.fileURL completionHandler:^(BOOL success) {
            [document updateChangeCount:UIDocumentChangeDone];

            NSArray *keys = [recentDictionary allKeys];

            for (NSString *key in keys) {
                if(![document.dictionary objectForKey:key]) {

                    NSDate *date = [formatter dateFromString:[[document.dictionary objectForKey:key] objectForKey:@"created_at"]];
                    
                    if (!([date compare:recentModificationDate] == NSOrderedDescending))
                    {
                        [document.dictionary setObject:[recentDictionary objectForKey:key] forKey:key];
                    }
                }
            }
        }];
    }

    [NSFileVersion removeOtherVersionsOfItemAtURL:document.fileURL error:nil];
}

#pragma mark - Core Data stack

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }

    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"manga-out" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }

    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    AFIncrementalStore *incrementalStore = (AFIncrementalStore *)[__persistentStoreCoordinator addPersistentStoreWithType:[MOIncrementalStore type] configuration:nil URL:nil options:nil error:nil];

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"manga-out.sqlite"];


    NSDictionary *options = @{
        NSInferMappingModelAutomaticallyOption : @(YES),
        NSMigratePersistentStoresAutomaticallyOption: @(YES)
    };

    NSError *error = nil;
    if (![incrementalStore.backingPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    NSLog(@"SQLite URL: %@", storeURL);

    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - NOTIFICATION PUSH

/* 
 * --------------------------------------------------------------------------------------------------------------
 *  BEGIN APNS CODE 
 * --------------------------------------------------------------------------------------------------------------
 */

/**
 * Fetch and Format Device Token and Register Important Information to Remote Server
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
#if !TARGET_IPHONE_SIMULATOR
//    [[[MONotifications alloc] initNotificationsWithDeviceToken:devToken] autorelease];
#endif
}

/**
 * Failed to Register for Remote Notifications
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	
#if !TARGET_IPHONE_SIMULATOR
	NSLog(@"Error in registration. Error: %@", error);
#endif
}

/**
 * Remote Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	
#if !TARGET_IPHONE_SIMULATOR
/*	NSLog(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
	
	NSString *alert = [apsInfo objectForKey:@"alert"];
	NSLog(@"Received Push Alert: %@", alert);
	
	NSString *sound = [apsInfo objectForKey:@"sound"];
	NSLog(@"Received Push Sound: %@", sound);
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

	NSString *badge = [apsInfo objectForKey:@"badge"];
	NSLog(@"Received Push Badge: %@", badge);
	application.applicationIconBadgeNumber = [badge integerValue];*/
#endif
}

#pragma Delegate - GPPDeepLinkDelegate

- (void)didReceiveDeepLink:(GPPDeepLink *)deepLink {
    // An example to handle the deep link data.
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Deep-link Data"
                          message:[deepLink deepLinkID]
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

@end
