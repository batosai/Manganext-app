//
//  MOSubscriptionManagementViewController.m
//  Manga Next
//
//  Created by Jeremy on 12/02/13.
//  Copyright (c) 2013 Jérémy Chaufourier. All rights reserved.
//

#import "MOSubscriptionManagementViewController.h"
#import "MOBaseNavivationViewController.h"
#import "MOAppDelegate.h"
#import "MOSubscriptionDocument.h"

@interface MOSubscriptionManagementViewController () {
    NSMutableArray *items;
    MOBaseNavivationViewController *navigationController;
}

@property (nonatomic, retain) MOBaseNavivationViewController *navigationController;

@end

@implementation MOSubscriptionManagementViewController

@synthesize navigationController = _navigationController;

- (id)init
{
    self = [super init];
    if (self) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;

        NSArray *keys = [[[MOAppDelegate sharedAppDelegate].subscriptionDocument.dictionary allKeys] copy];
        
        if ([keys count]) {
            items = [NSMutableArray arrayWithArray:keys];
            [items retain];
        }
        else {
            items = NSMutableArray.new;
        }

        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self
                                                                                      action:@selector(cancelPressed)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        [keys release];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[MOAppDelegate sharedAppDelegate].tracker trackView:@"Liste gestion des abonnements"];
}

- (MOBaseNavivationViewController *)navigationController {
    if (navigationController == nil) {
        navigationController = [[MOBaseNavivationViewController alloc] initWithRootViewController:self];
        self.navigationController = navigationController;
    }

    return navigationController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.detailTextLabel.text = [items objectAtIndex:indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [items count] ? YES : NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[MOAppDelegate sharedAppDelegate].subscriptionDocument deleteAtKey:[items objectAtIndex:indexPath.row]];
        [items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [[MOAppDelegate sharedAppDelegate].tracker trackEventWithCategory:@"Bouton"
                                                               withAction:@"Ajouter un abonnement"
                                                                withLabel:[items objectAtIndex:indexPath.row]
                                                                withValue:nil];
    }
}

- (void)dealloc {
    [navigationController release];
    [_navigationController release];
    [items release];
    [super dealloc];
}

#pragma delegate

- (void)cancelPressed {
    [self dismissModalViewControllerAnimated:YES];
}

@end
