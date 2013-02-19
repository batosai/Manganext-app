//
//  MODetailViewController.m
//  Manga Out
//
//  Created by Jérémy chaufourier on 26/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import "MODetailViewController.h"
#import "MORootController.h"

#import "MOSubscriptionDocument.h"

@interface MODetailViewController ()
- (void)configureView;
@end

@implementation MODetailViewController

@synthesize book = _book;

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
        [label release];

        labelName = [[UILabel alloc] init];
        labelNumber = [[UILabel alloc] init];
        labelDate = [[UILabel alloc] init];
        labelEditor = [[UILabel alloc] init];
        labelAuthor = [[UILabel alloc] init];
        labelState = [[UILabel alloc] init];
        labelPrice = [[UILabel alloc] init];
        imageView = [[UIImageView alloc] init];
        description = [[UITextView alloc] init];
        [description setEditable:NO];
        
        subscriptionDocument = [MOAppDelegate sharedAppDelegate].subscriptionDocument;

        [self.view addSubview:labelName];
        [self.view addSubview:labelNumber];
        [self.view addSubview:labelDate];
        [self.view addSubview:labelEditor];
        [self.view addSubview:labelAuthor];
        [self.view addSubview:labelState];
        [self.view addSubview:labelPrice];
        [self.view addSubview:imageView];
        [self.view addSubview:description];
    }
    return self;
}

- (void)setBook:(id)newBook
{
    if (_book != newBook) {
        [_book release];
        _book = [newBook retain];

        [[MOAppDelegate sharedAppDelegate] loadSubscriptionDocument];

        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    float width;
    NSUInteger y;
    CGRect frame;
    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setPaddingPosition:NSNumberFormatterPadAfterSuffix];
    [numberFormatter setFormatWidth:2];
    
    width = 180;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        width = 400;
    }

    frame = CGRectMake(120, 10, width, 14);
    labelName.frame = frame;
    labelName.font = [UIFont boldSystemFontOfSize:14];
    labelName.text = _book.name;
    labelName.lineBreakMode = UILineBreakModeWordWrap;
    labelName.numberOfLines = 0;
    [labelName sizeToFit];
    
    y = labelName.frame.size.height + labelName.frame.origin.y + 5;
    frame = CGRectMake(120, y, width, 11);
    labelNumber.frame = frame;
    labelNumber.font = [UIFont boldSystemFontOfSize:11];
    labelNumber.text = _book.number;
    labelNumber.textColor = [UIColor grayColor];
    
    y = labelNumber.frame.size.height + labelNumber.frame.origin.y + 5;
    frame = CGRectMake(120, y, width, 11);
    labelDate.frame = frame;
    labelDate.font = [UIFont boldSystemFontOfSize:11];
    labelDate.text = [NSString stringWithFormat:@"Sortie le %@", [_book getPublishedAtFromString]];

    if ([[NSDate date] isSameDay:_book.published_at]) {
        labelDate.textColor = [UIColor redColor];
    }
    else {
        labelDate.textColor = [UIColor grayColor];
    }

    y = labelDate.frame.size.height + labelDate.frame.origin.y + 25;
    frame = CGRectMake(120, y, width, 11);
    labelEditor.frame = frame;
    labelEditor.font = [UIFont boldSystemFontOfSize:11];
    labelEditor.text = _book.editor_name;
    labelEditor.textColor = [UIColor grayColor];

    y = labelEditor.frame.size.height + labelEditor.frame.origin.y + 5;
    frame = CGRectMake(120, y, width, 11);
    labelAuthor.frame = frame;
    labelAuthor.font = [UIFont boldSystemFontOfSize:11];
    labelAuthor.text = _book.author_name;
    labelAuthor.textColor = [UIColor grayColor];

    y = labelAuthor.frame.size.height + labelAuthor.frame.origin.y + 5;
    frame = CGRectMake(120, y, width, 11);
    labelState.frame = frame;
    labelState.font = [UIFont boldSystemFontOfSize:11];
    labelState.text = _book.state;
    labelState.textColor = [UIColor grayColor];

    if (_book.price) {
        y = labelState.frame.size.height + labelState.frame.origin.y + 5;
        frame = CGRectMake(120, y, width, 11);
        labelPrice.frame = frame;
        labelPrice.font = [UIFont boldSystemFontOfSize:11];

        if (![_book.price isEqualToNumber: [NSNumber numberWithInt:0]]) {
            
            if ([_book.price intValue] == [_book.price floatValue]) {
                labelPrice.text = [NSString stringWithFormat:@"Prix : %i €", [_book.price intValue]];
            }
            else {
                labelPrice.text = [NSString stringWithFormat:@"Prix : %@ €", [numberFormatter stringFromNumber:_book.price]];
            }
            
        }
        else {
            labelPrice.text = @"";
        }
    }

    if (_book.cover) {
        imageView.image = _book.cover;
    }
    else {
        imageView.image = [UIImage imageNamed:@"Placeholder.png"];
    }
    imageView.frame = CGRectMake(10, 10, 98, 147);

//    if (_book.signet == nil) {
//        UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSignet:)] autorelease];
//        self.navigationItem.rightBarButtonItem = addButton;
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    }
//    else {
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//    }
    
    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSignet:)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
    
    if (![subscriptionDocument.dictionary objectForKey:_book.name]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        description.frame = CGRectMake(5, imageView.frame.size.height + 20, width+130, 400);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) {//iphone5
        description.frame = CGRectMake(5, imageView.frame.size.height + 20, width+130, 235);
    }
    else {
        description.frame = CGRectMake(5, imageView.frame.size.height + 20, width+130, 155);
    }

    description.text = _book.text;
}

- (void)addSignet:(id)sender
{
    //[_book createSignet];
    [[[MOAppDelegate sharedAppDelegate] tabBarController] badgeRefresh];

    [subscriptionDocument setBook:_book];
    [subscriptionDocument saveToURL:[subscriptionDocument fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:nil];

    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc
{
    [labelName release];
    [labelNumber release];
    [labelDate release];
    [labelEditor release];
    [labelAuthor release];
    [labelState release];
    [labelPrice release];
    [_book release];

    bannerView.delegate = nil;
    [bannerView release];
    [super dealloc];
}

#pragma mark - Banner view

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
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            banner.frame = CGRectOffset(banner.frame, 0, -50);
        }
        else {
            banner.frame = CGRectOffset(banner.frame, 0, -66);
        }
        [UIView commitAnimations];
        bannerIsVisible = NO;
    }
}

@end
