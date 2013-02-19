//
//  MOViewCell.h
//  Manga Out
//
//  Created by Jérémy chaufourier on 28/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface MOViewCell : UITableViewCell {
    UILabel *label;
    UILabel *subLabel;
    UILabel *subLabelDate;
}

- (void)setValuesWithBook:(Book*) book;

@end
