//
//  MODetailViewController.h
//  Manga Out
//
//  Created by Jérémy chaufourier on 26/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "MOAppDelegate.h"

#import "Book.h"
#import "Signet.h"

@class MOSubscriptionDocument;

@interface MODetailViewController : UIViewController <ADBannerViewDelegate> {
    UILabel *labelName;
    UILabel *labelNumber;
    UILabel *labelDate;
    UILabel *labelEditor;
    UILabel *labelAuthor;
    UILabel *labelState;
    UILabel *labelPrice;
    UIImageView *imageView;
    UITextView *description;

    BOOL bannerIsVisible;
    ADBannerView *bannerView;
    
    MOSubscriptionDocument *subscriptionDocument;
}

@property (strong, nonatomic) Book *book;

@end
