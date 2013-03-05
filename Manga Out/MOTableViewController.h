//
//  RootViewController.h
//  PullToRefresh
//
//  Created by Jérémy chaufourier on 02/07/11.
//  Copyright Plancast 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import "MOAppDelegate.h"
#import "MODetailViewController.h"
#import "MOThumbnailDownloader.h"
#import "MOViewCell.h"
#import "MOBooks.h"

@interface MOTableViewController : PullRefreshTableViewController <UIScrollViewDelegate, UISearchBarDelegate, IconDownloaderDelegate>

@property (assign) NSUInteger type;
@property (nonatomic, retain) MOBooks *books;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (strong, nonatomic) MODetailViewController *detailViewController;

@property (nonatomic, retain) UISearchBar *searchBar;

@end
