//
//  MOViewCell.m
//  Manga Out
//
//  Created by Jérémy chaufourier on 28/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import "MOViewCell.h"
#import "Book.h"

@implementation MOViewCell

@synthesize book = _book;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        subLabelDate = [[UILabel alloc] init];
        [self.contentView addSubview:subLabelDate];
    }
    return self;
}

- (void)setBook:(Book*) book
{
    _book = book;

    self.textLabel.text = book.name;

    if (book.number != nil) {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", book.editor_name, book.number];   
    }
    else {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@", book.editor_name];
    }
    subLabelDate.text = [book getPublishedAtFromString];

    if ([[NSDate date] isSameDay:book.published_at]) {
        subLabelDate.textColor = [UIColor colorWithHexString:SECONDAIRYCOLOR];
    }
    else {
        subLabelDate.textColor = [UIColor grayColor];
    }

    [self.imageView setImageWithURL:[NSURL URLWithString:_book.image] placeholderImage:[UIImage imageNamed:@"Placeholder"]];

    [self setNeedsLayout];
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];

    self.textLabel.frame = CGRectMake(70, 10, 230, 14);
    self.detailTextLabel.frame = CGRectMake(70, 33, 230, 14);
    subLabelDate.frame = CGRectMake(70, 49, 230, 14);

    self.textLabel.font = [UIFont boldSystemFontOfSize:14];
    self.detailTextLabel.font = [UIFont systemFontOfSize:12];
    subLabelDate.font = [UIFont italicSystemFontOfSize:12];
}

@end
