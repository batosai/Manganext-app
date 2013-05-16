//
//  MODetailViewController.h
//  Manga Out
//
//  Created by Jérémy chaufourier on 26/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "MOAppDelegate.h"
#import "AwesomeMenu.h"
#import "GPPShare.h"

@class MOViewDetail;
@class Book, Signet;

@interface MODetailViewController : UIViewController <ADBannerViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, AwesomeMenuDelegate, GPPShareDelegate> {

    BOOL bannerIsVisible;
    ADBannerView *bannerView;

    MOViewDetail *view;
    AwesomeMenu *menu;
}

@property (strong, nonatomic) Book *book;

@end
