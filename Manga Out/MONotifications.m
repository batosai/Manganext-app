//
//  MONotifications.m
//  Manga News
//
//  Created by Jérémy chaufourier on 14/04/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import "MONotifications.h"

@implementation MONotifications

-(id)initNotificationsWithDeviceToken:(NSData *)devToken{
    self = [super init];
    if (!self) {
        return nil;
    }

    // Get Bundle Info for Remote Registration (handy if you have more than one app)
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	// Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	
	// Set the defaults to disabled unless we find otherwise...
	NSString *pushBadge = (rntypes & UIRemoteNotificationTypeBadge) ? @"enabled" : @"disabled";
	NSString *pushAlert = (rntypes & UIRemoteNotificationTypeAlert) ? @"enabled" : @"disabled";
	NSString *pushSound = (rntypes & UIRemoteNotificationTypeSound) ? @"enabled" : @"disabled";	
	
	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
	UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid;
	if ([dev respondsToSelector:@selector(uniqueIdentifier)])
		deviceUuid = dev.uniqueIdentifier;
	else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		id uuid = [defaults objectForKey:@"deviceUuid"];
		if (uuid)
			deviceUuid = (NSString *)uuid;
		else {
			CFStringRef cfUuid = CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
			deviceUuid = (NSString *)cfUuid;
			CFRelease(cfUuid);
			[defaults setObject:deviceUuid forKey:@"deviceUuid"];
		}
	}
	NSString *deviceName = dev.name;
	NSString *deviceModel = dev.model;
	NSString *deviceSystemVersion = dev.systemVersion;
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
	
	// Prepare the Device Token for Registration (remove spaces and < >)
	NSString *deviceToken = [[[[devToken description] 
                               stringByReplacingOccurrencesOfString:@"<"withString:@""] 
                              stringByReplacingOccurrencesOfString:@">" withString:@""] 
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    
	NSString *urlString = [NSString stringWithFormat:@"/apns?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@&locale=%@", @"register", appName, appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound, locale];
	//NSLog(@"%@", urlString);
	// Register the Device Data
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:DOMAINE path:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	//NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	//NSLog(@"Register URL: %@", url);
	//NSLog(@"Return Data: %@", returnData);

    [url release];
    [request release];

    return self;
}

@end
