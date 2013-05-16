//
//  MOSignetViewController.h
//  Manga Out
//
//  Created by Jérémy chaufourier on 26/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MODetailViewController.h"
#import "MOViewCell.h"
#import "MOBooks.h"

@interface MOSignetViewController : UITableViewController

@property (assign) NSUInteger type;
@property (nonatomic, retain) MOBooks *books;
@property (strong, nonatomic) MODetailViewController *detailViewController;

@end
