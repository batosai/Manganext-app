//
//  MOBaseNavivationViewController.m
//  Manga Next
//
//  Created by Jeremy on 01/01/13.
//  Copyright (c) 2013 Jérémy Chaufourier. All rights reserved.
//

#import "MONavigationController.h"

@implementation MONavigationController

- (id) initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.navigationBar.tintColor = [UIColor darkGrayColor];

        UIImage *image = [UIImage imageNamed: @"BarBackground.png"];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
            [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        [label setFont:[UIFont fontWithName:@"NothingYouCouldDo" size: 25.0]];
        label.textAlignment = UITextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = self.title;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            label.textAlignment = UITextAlignmentCenter;
        }

        [self.navigationBar.topItem setTitleView:label];
    }
    return self;
}

@end
