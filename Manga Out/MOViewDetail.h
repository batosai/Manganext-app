//
//  MOViewDetail.h
//  Manga Next
//
//  Created by Jeremy on 13/05/13.
//  Copyright (c) 2013 J√©r√©my Chaufourier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Book, AwesomeMenu;

@interface MOViewDetail : UIView {
    UILabel *labelName;
    UILabel *labelNumber;
    UILabel *labelDate;
    UILabel *labelEditor;
    UILabel *labelAuthor;
    UILabel *labelState;
    UILabel *labelPrice;
    UIImageView *imageView;
    UITextView *description;

    UIView *backgroundView;
}

@property (weak, nonatomic, readwrite) Book *book;
@property (weak, nonatomic, readwrite) AwesomeMenu *menu;

@end
