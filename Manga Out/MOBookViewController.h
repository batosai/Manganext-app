//
//  MOBookViewController.h
//  Manga Next
//
//  Created by Jeremy on 20/04/13.
//  Copyright (c) 2013 Jeremy Chaufourier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"

@class MODetailViewController;

@interface MOBookViewController : PullRefreshTableViewController<UISearchBarDelegate, NSFetchedResultsControllerDelegate> {
    MODetailViewController *detailViewController;

@protected
    NSFetchedResultsController *_fetchedResultsController;
}

@property (nonatomic, readwrite) NSUInteger type;
@property (readonly) UISearchBar *searchBar;

- (void)refetchData;

@end
