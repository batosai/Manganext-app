//
//  MOViewCell.h
//  Manga Out
//
//  Created by Jérémy chaufourier on 28/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Book;

@interface MOViewCell : UITableViewCell {
    UILabel *subLabelDate;
}

@property (weak, nonatomic, readwrite) Book *book;

@end
