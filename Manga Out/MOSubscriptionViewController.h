//
//  MOSubscriptionViewController.h
//  Manga Next
//
//  Created by Jeremy on 11/02/13.
//  Copyright (c) 2013 Jérémy Chaufourier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOAppDelegate.h"
#import "MODetailViewController.h"
#import "MOViewCell.h"
#import "MOBooks.h"

@interface MOSubscriptionViewController : UITableViewController

@property (assign) NSUInteger type;
@property (nonatomic, retain) MOBooks *books;

@end
