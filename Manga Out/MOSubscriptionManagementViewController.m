//
//  MOSubscriptionManagementViewController.m
//  Manga Next
//
//  Created by Jeremy on 12/02/13.
//  Copyright (c) 2013 Jérémy Chaufourier. All rights reserved.
//

#import "MOSubscriptionManagementViewController.h"
#import "MOAppDelegate.h"
#import "MOSubscriptionDocument.h"

@interface MOSubscriptionManagementViewController () {
    NSMutableArray *items;
}

@end

@implementation MOSubscriptionManagementViewController

- (id)init
{
    self = [super init];
    if (self) {

        MOAppDelegate *appDelegate = (MOAppDelegate *)[[UIApplication sharedApplication] delegate];

        self.navigationItem.rightBarButtonItem = self.editButtonItem;

        NSArray *keys = [[appDelegate.subscriptionDocument.dictionary allKeys] copy];
        
        if ([keys count]) {
            items = [NSMutableArray arrayWithArray:keys];
        }
        else {
            items = NSMutableArray.new;
        }

        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self
                                                                                      action:@selector(cancelPressed)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    MOAppDelegate *appDelegate = (MOAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.tracker trackView:@"Liste gestion des abonnements"];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier];
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
        MOAppDelegate *appDelegate = (MOAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.subscriptionDocument deleteAtKey:[items objectAtIndex:indexPath.row]];

        [appDelegate.tracker trackEventWithCategory:@"Bouton"
                                         withAction:@"Supprimer un abonnement"
                                          withLabel:[items objectAtIndex:indexPath.row]
                                          withValue:nil];

        [items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma delegate

- (void)cancelPressed {
    [self dismissModalViewControllerAnimated:YES];
}

@end
