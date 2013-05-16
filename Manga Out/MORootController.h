//
//  MORootController.h
//  Manga Next
//
//  Created by Jeremy on 06/05/13.
//  Copyright (c) 2013 Jeremy Chaufourier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AwesomeMenu.h"

@class MONavigationController;

@interface MORootController : UIViewController<AwesomeMenuDelegate>{
//    MOSignetViewController *signetViewController;

    MONavigationController *navigationHomeController;
    MONavigationController *navigationNewBooksController;
    MONavigationController *navigationFutureBooksController;
    MONavigationController *navigationSubscriptionController;
    MONavigationController *navigationSignetController;
    MONavigationController *navigationAppSettingsController;

    AwesomeMenu *menu;
}

@end
