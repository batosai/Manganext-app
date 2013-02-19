//
//  MOViewCell.m
//  Manga Out
//
//  Created by Jérémy chaufourier on 28/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import "MOViewCell.h"

@implementation MOViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        //self.textLabel.text = book.name;

        CGRect frame = CGRectMake(70, 15, 230, 14);
        label = [[UILabel alloc] initWithFrame:frame];
        label.font = [UIFont boldSystemFontOfSize:14];
        //label.numberOfLines = 2;
        [self.contentView addSubview:label];

        CGRect sublabelFrame = CGRectMake(70, 33, 230, 14);
        subLabel = [[UILabel alloc] initWithFrame:sublabelFrame];
        subLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:subLabel];
        
        CGRect sublabelDateFrame = CGRectMake(70, 49, 230, 14);
        subLabelDate = [[UILabel alloc] initWithFrame:sublabelDateFrame];
        subLabelDate.font = [UIFont italicSystemFontOfSize:12];
        [self.contentView addSubview:subLabelDate];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setValuesWithBook:(Book*) book
{
    label.text = book.name;

    if (book.number != nil) {
     subLabel.text = [NSString stringWithFormat:@"%@ - %@", book.editor_name, book.number];   
    }
    else {
        subLabel.text = [NSString stringWithFormat:@"%@", book.editor_name];
    }
    subLabelDate.text = [book getPublishedAtFromString];

    if ([[NSDate date] isSameDay:book.published_at]) {
        subLabelDate.textColor = [UIColor redColor];
    }
    else {
        subLabelDate.textColor = [UIColor grayColor];
    }

    if (book.thumbnail) {
        self.imageView.image = book.thumbnail;
    }
    else {
        self.imageView.image = [UIImage imageNamed:@"Placeholder.png"]; 
    }
}

- (void)dealloc
{
    [label release];
    [subLabel release];
    [super dealloc];
}

@end
