//
//  MODetailViewController.m
//  Manga Out
//
//  Created by Jérémy chaufourier on 26/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import "MODetailViewController.h"
#import <Twitter/TWTweetComposeViewController.h>
#import "DEFacebookComposeViewController.h"
#import "MOSubscriptionDocument.h"
#import "MOViewDetail.h"

#import "Book.h"
#import "Signet.h"

#define kSubject @"subject"


@interface MODetailViewController () {
    NSString *bodyString;
}
- (void)configureView;
@end

@implementation MODetailViewController

@synthesize
    book = _book
;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");

        self.view.backgroundColor = [UIColor whiteColor];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        [label setFont:[UIFont fontWithName:@"NothingYouCouldDo" size: 25.0]];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = self.title;
        [self.navigationItem setTitleView:label];
    }
    return self;
}

- (void)loadView {
    view = [[MOViewDetail alloc] init];

    [self setView:view];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && !bannerView) {
        bannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
        bannerView.delegate = self;

        CGRect frame = bannerView.frame;
        frame.origin.y = self.view.frame.size.height;
        bannerView.frame = frame;

        bannerView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
        bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;

        bannerIsVisible = NO;

        [self.view addSubview:bannerView];
    }

    if (!menu)
        [self awesomeMenu];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma Method

- (void)setBook:(id)newBook
{
    if (_book != newBook) {
        _book = newBook;

        MOAppDelegate *appDelegate = (MOAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.tracker trackView:[NSString stringWithFormat:@"Detail manga : %@", _book.name]];

        view.book = _book;

        if ([[NSDate date] isSameDay:_book.published_at]) {
            bodyString = [NSString stringWithFormat:NSLocalizedString(@"Bonjour, %@ %@ vient de sortir", nil), _book.name, _book.number];
        }
        else if ([_book.published_at compare:[NSDate date]] == NSOrderedAscending) {
            bodyString = [NSString stringWithFormat:NSLocalizedString(@"Bonjour, %@ %@ est sorti le %@", nil), _book.name, _book.number, [_book getPublishedAtFromString]];
        }
        else {
            bodyString = [NSString stringWithFormat:NSLocalizedString(@"Bonjour, %@ %@ sort le %@", nil), _book.name, _book.number, [_book getPublishedAtFromString]];
        }

        [self configureView];
    }
}

- (void)configureView
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [backButton setImage:[UIImage imageNamed:@"bt-back"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;

    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [addButton setImage:[UIImage imageNamed:@"bt-plus"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonPress) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = addButtonItem;

    [GPPShare sharedInstance].delegate = self;
    

//    if (_book.signet == nil) {
//        UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSignet:)] autorelease];
//        self.navigationItem.rightBarButtonItem = addButton;
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    }
//    else {
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//    }
    
//    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSignet:)] autorelease];
//    self.navigationItem.rightBarButtonItem = addButton;
//
//    if (![[MOAppDelegate sharedAppDelegate].subscriptionDocument.dictionary objectForKey:_book.name]) {
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    }
//    else {
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//    }
}

- (void)awesomeMenu {
    AwesomeMenuItem *starMenuItem1 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-menuitem-fb"]
                                                           highlightedImage:[UIImage imageNamed:@"bg-menuitem-highlighted-fb"]
                                                               ContentImage:[UIImage imageNamed:@"icon-fb"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem2 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-menuitem-twitter"]
                                                           highlightedImage:[UIImage imageNamed:@"bg-menuitem-highlighted-twitter"]
                                                               ContentImage:[UIImage imageNamed:@"icon-twitter"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem3 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-menuitem-g+"]
                                                           highlightedImage:[UIImage imageNamed:@"bg-menuitem-highlighted-g+"]
                                                               ContentImage:[UIImage imageNamed:@"icon-g+"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem4 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-menuitem-mail"]
                                                           highlightedImage:[UIImage imageNamed:@"bg-menuitem-highlighted-mail"]
                                                               ContentImage:[UIImage imageNamed:@"icon-mail"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem5 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-menuitem-sms"]
                                                           highlightedImage:[UIImage imageNamed:@"bg-menuitem-highlighted-sms"]
                                                               ContentImage:[UIImage imageNamed:@"icon-sms"]
                                                    highlightedContentImage:nil];

    NSArray *menus = [NSArray arrayWithObjects:starMenuItem5, starMenuItem4, starMenuItem3, starMenuItem2, starMenuItem1, nil];

    menu = [[AwesomeMenu alloc] initWithFrame:self.view.bounds menus:menus];
    menu.rotateAngle = M_PI/1.5;
	menu.menuWholeAngle = M_PI/1.2;
    [menu setImage:[UIImage imageNamed:@"bg-addbutton-share"]];
    [menu setHighlightedImage:[UIImage imageNamed:@"bg-addbutton-share"]];
    [menu setContentImage:[UIImage imageNamed:@"icon-share"]];
    [menu setHighlightedContentImage:[UIImage imageNamed:@"icon-share-highlighted"]];
    menu.delegate = self;

    view.menu = menu;
}

#pragma press button

- (void)addButtonPress {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Annuler", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Suivre cette série", nil), NSLocalizedString(@"Ajouter à ma shopping list", nil), nil];

    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

#pragma Delegate UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MOAppDelegate *appDelegate = (MOAppDelegate *)[[UIApplication sharedApplication] delegate];

	if (buttonIndex == 0) {
        [appDelegate.subscriptionDocument setBook:_book];
        [appDelegate.subscriptionDocument saveToURL:[appDelegate.subscriptionDocument fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:nil];

        [appDelegate.tracker trackEventWithCategory:@"Bouton"
                                         withAction:@"Ajouter un abonnement"
                                          withLabel:_book.name
                                          withValue:nil];
	}
    else if (buttonIndex == 1) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Signet" inManagedObjectContext:appDelegate.managedObjectContext];
        Signet *signet = [[Signet alloc] initWithEntity:entity insertIntoManagedObjectContext:appDelegate.managedObjectContext];
        signet.book = _book;
        [appDelegate.managedObjectContext save:nil];
    }
}

#pragma Delegate AwesomeMenuDelegate

- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx {
    switch (idx) {
        case 4:
            [self facebook];
            break;
        case 3:
            [self twitter];
            break;
        case 2:
            [self googleplus];
            break;
        case 1:
            [self mail];
            break;
        case 0:
            [self iMessage];
            break;
    }
}

#pragma Social network

- (void)facebook {
    DEFacebookComposeViewController *facebookViewComposer = [[DEFacebookComposeViewController alloc] init];

    // If you want to use the Facebook app with multiple iOS apps you can set an URL scheme suffix
    //    facebookViewComposer.urlSchemeSuffix = @"facebooksample";

    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    [facebookViewComposer setInitialText:bodyString];

    // optional
    [facebookViewComposer addImage:[UIImage imageNamed:@"icn"]];
    // and/or
    // optional
    //[facebookViewComposer addURL:[NSURL URLWithString:_book.website]];

    [facebookViewComposer setCompletionHandler:^(DEFacebookComposeViewControllerResult result) {
        switch (result) {
            case DEFacebookComposeViewControllerResultCancelled:
                NSLog(@"Facebook Result: Cancelled");
                break;
            case DEFacebookComposeViewControllerResultDone:
                NSLog(@"Facebook Result: Sent");
                break;
        }

        [self dismissViewControllerAnimated:YES completion:nil];
    }];

    [self presentViewController:facebookViewComposer animated:YES completion:nil];
}

- (void)twitter {
    TWTweetComposeViewController *tweetView = [[TWTweetComposeViewController alloc] init];

    TWTweetComposeViewControllerCompletionHandler
    completionHandler =
    ^(TWTweetComposeViewControllerResult result) {
        switch (result)
        {
            case TWTweetComposeViewControllerResultCancelled:
                NSLog(@"Twitter Result: canceled");
                break;
            case TWTweetComposeViewControllerResultDone:
                NSLog(@"Twitter Result: sent");
                break;
            default:
                NSLog(@"Twitter Result: default");
                break;
        }
        [self dismissModalViewControllerAnimated:YES];
    };
    [tweetView setCompletionHandler:completionHandler];

    [tweetView setInitialText:bodyString];
    [tweetView addImage:[UIImage imageNamed:@"icn"]];
    [tweetView addURL:[NSURL URLWithString:@"http://www.chaufourier.fr" ]];
    [self presentModalViewController:tweetView animated:YES];
}

- (void)googleplus {
    id<GPPShareBuilder> shareBuilder = [[GPPShare sharedInstance] shareDialog];
    [shareBuilder setURLToShare:[NSURL URLWithString:@"http://www.chaufourier.fr"]];

    /*[shareBuilder setContentDeepLinkID:@""];
    [shareBuilder setTitle:kSubject
               description:bodyString
              thumbnailURL:[NSURL URLWithString:_book.image]];*/

    [shareBuilder open];
}

- (void)mail {
    NSString *mailString = [NSString stringWithFormat:@"mailto:?subject=%@&body=%@",
                            [kSubject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                            [bodyString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
}

- (void)iMessage {
#if !TARGET_IPHONE_SIMULATOR
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;

    picker.body = bodyString;

    [self presentModalViewController:picker animated:YES];
#endif
}

#pragma Delegate MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result)
    {
        case MessageComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MessageComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MessageComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }

    [self dismissModalViewControllerAnimated:YES];
    
}

#pragma Delegate ADBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
        bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // banner is visible and we move it out of the screen, due to connection issue
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
        bannerIsVisible = NO;
    }
}

#pragma Delegate GPPShareDelegate

- (void)finishedSharing:(BOOL)shared {}

@end
