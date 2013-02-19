//
//  MOAppDelegate.m
//  Manga Out
//
//  Created by Jérémy chaufourier on 12/02/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import "MOAppDelegate.h"
#import "MORootController.h"
#import "MONotifications.h"
#import "MOSubscriptionDocument.h"

@implementation MOAppDelegate

+ (MOAppDelegate *)sharedAppDelegate
{
    return (MOAppDelegate *) [UIApplication sharedApplication].delegate;
}

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize tabBarController = _tabBarController;
@synthesize subscriptionDocument = _subscriptionDocument;
@synthesize query = _query;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _tabBarController = [[MORootController alloc] init];

    [self cacheDir];
    [self loadSubscriptionDocument];

    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    application.applicationIconBadgeNumber = 0;
    
    _window.rootViewController = _tabBarController;
    [_window makeKeyAndVisible];
    return YES;
}

- (void)loadSubscriptionDocument
{
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    if (ubiq) {
        NSLog(@"iCloud access at %@", ubiq);
        [self loadDocument];
    }

//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *filePath = [NSString stringWithFormat:@"%@/%@",path, SUBSCRIPTION_FILE];
//    NSURL *url = [NSURL fileURLWithPath:filePath];
//
//    _subscriptionDocument = [[MOSubscriptionDocument alloc] initWithFileURL:url];
//    
//    [_subscriptionDocument openWithCompletionHandler:^(BOOL success) {
//        if (success) {
//            NSLog(@"%@", _subscriptionDocument.dictionary);
//        }
//    }];
}

- (void)cacheDir
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

    NSString *dirImage = [NSString stringWithFormat:@"%@/%@", path, IMAGES_CACHE_DIRECTORY];
    NSString *dirThumbnails = [NSString stringWithFormat:@"%@/%@", path, THUMBNAILS_CACHE_DIRECTORY];

    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL isDir = YES;
    NSError *error;
    
    if(![fileManager fileExistsAtPath:dirImage isDirectory:&isDir]) {
        if([fileManager createDirectoryAtPath:dirImage withIntermediateDirectories:YES attributes:nil error:&error]) {
            if(![fileManager fileExistsAtPath:dirThumbnails isDirectory:&isDir]) {
                [fileManager createDirectoryAtPath:dirThumbnails withIntermediateDirectories:YES attributes:nil error:&error];
            }
        }
    }
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
    [_tabBarController badgeRefresh];
    application.applicationIconBadgeNumber = 0;

    [self loadSubscriptionDocument];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
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
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"manga-out.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: */
         NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

         /*Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.*/

        if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
            abort();
        }
    }    
    
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
    [[[MONotifications alloc] initNotificationsWithDeviceToken:devToken] autorelease];
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
    
	NSLog(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
	
	NSString *alert = [apsInfo objectForKey:@"alert"];
	NSLog(@"Received Push Alert: %@", alert);
	
	NSString *sound = [apsInfo objectForKey:@"sound"];
	NSLog(@"Received Push Sound: %@", sound);
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

	NSString *badge = [apsInfo objectForKey:@"badge"];
	NSLog(@"Received Push Badge: %@", badge);
	application.applicationIconBadgeNumber = [badge integerValue];
	
#endif
}

/* 
 * --------------------------------------------------------------------------------------------------------------
 *  END APNS CODE 
 * --------------------------------------------------------------------------------------------------------------
 */

- (void)dealloc
{
    [_window release];
    [_subscriptionDocument release];
    [_query release];

    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

@end
