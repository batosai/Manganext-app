//
//  MOViewDetail.m
//  Manga Next
//
//  Created by Jeremy on 13/05/13.
//  Copyright (c) 2013 J√©r√©my Chaufourier. All rights reserved.
//

#import "MOViewDetail.h"
#import "Book.h"
#import "AwesomeMenu.h"

@implementation MOViewDetail

@synthesize book = _book;
@synthesize menu = _menu;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor colorWithHexString:SECONDAIRYCOLOR];

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

        [self addSubview:backgroundView];
        [self addSubview:labelName];
        [self addSubview:labelNumber];
        [self addSubview:labelDate];
        [self addSubview:labelEditor];
        [self addSubview:labelAuthor];
        [self addSubview:labelState];
        [self addSubview:labelPrice];
        [self addSubview:imageView];
        [self addSubview:description];
    }
    return self;
}

- (void)setBook:(Book*) book
{
    _book = book;

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setPaddingPosition:NSNumberFormatterPadAfterSuffix];
    [numberFormatter setFormatWidth:2];

    // values

    labelName.text = _book.name;
    labelNumber.text = _book.number;
    labelDate.text = [book getPublishedAtFromString];
    labelEditor.text = _book.editor_name;
    labelAuthor.text = _book.author_name;
    labelState.text = _book.state;
    description.text = _book.text;

    if ([[NSDate date] isSameDay:_book.published_at]) {
        labelDate.textColor = [UIColor colorWithHexString:@"#C60800"];
    }
    else {
        labelDate.textColor = [UIColor colorWithHexString:@"#FBFCFA"];
    }

    if (_book.price) {
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

    [imageView setImageWithURL:[NSURL URLWithString:_book.image] placeholderImage:[UIImage imageNamed:@"Placeholder"]];

    // ----- styles

    labelName.font = [UIFont boldSystemFontOfSize:16];
    labelName.textColor = [UIColor whiteColor];
    labelName.backgroundColor = [UIColor clearColor];
    labelName.numberOfLines = 0;
    
    labelNumber.font = [UIFont boldSystemFontOfSize:11];
    labelNumber.textColor = [UIColor colorWithHexString:@"#FBFCFA"];
    labelNumber.backgroundColor = [UIColor clearColor];

    labelDate.font = [UIFont boldSystemFontOfSize:11];
    labelDate.backgroundColor = [UIColor clearColor];

    labelEditor.font = [UIFont boldSystemFontOfSize:11];
    labelEditor.textColor = [UIColor colorWithHexString:@"#FBFCFA"];
    labelEditor.backgroundColor = [UIColor clearColor];

    labelAuthor.font = [UIFont boldSystemFontOfSize:11];
    labelAuthor.textColor = [UIColor colorWithHexString:@"#FBFCFA"];
    labelAuthor.backgroundColor = [UIColor clearColor];

    labelState.font = [UIFont boldSystemFontOfSize:11];
    labelState.textColor = [UIColor colorWithHexString:@"#FBFCFA"];
    labelState.backgroundColor = [UIColor clearColor];

    labelPrice.font = [UIFont boldSystemFontOfSize:11];
    labelPrice.backgroundColor = [UIColor clearColor];

    [self setNeedsLayout];
}

- (void)setMenu:(AwesomeMenu *)menu {
    _menu = menu;
    _menu.startPoint = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(backgroundView.frame));

    [self addSubview:_menu];
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];

    float width;
    NSUInteger y;
    CGRect frame;

    width = 180;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        width = 400;
    }

    frame = CGRectMake(10, 10, width+130, 14);
    labelName.frame = frame;
    [labelName sizeToFit];

    y = labelName.frame.size.height + labelName.frame.origin.y + 10;
    frame = CGRectMake(120, y, width, 11);
    labelNumber.frame = frame;

    y = labelNumber.frame.size.height + labelNumber.frame.origin.y + 5;
    frame = CGRectMake(120, y, width, 11);
    labelDate.frame = frame;

    y = labelDate.frame.size.height + labelDate.frame.origin.y + 20;
    frame = CGRectMake(120, y, width, 11);
    labelEditor.frame = frame;

    y = labelEditor.frame.size.height + labelEditor.frame.origin.y + 5;
    frame = CGRectMake(120, y, width, 11);
    labelAuthor.frame = frame;

    y = labelAuthor.frame.size.height + labelAuthor.frame.origin.y + 5;
    frame = CGRectMake(120, y, width, 11);
    labelState.frame = frame;

    if (_book.price) {
        y = labelState.frame.size.height + labelState.frame.origin.y + 5;
        frame = CGRectMake(120, y, width, 11);
        labelPrice.frame = frame;
    }

    y = labelName.frame.size.height + labelName.frame.origin.y + 10;
    imageView.frame = CGRectMake(10, y, 98, 147);

    y = imageView.frame.size.height + imageView.frame.origin.y + 25;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        description.frame = CGRectMake(5, y, width+130, 395 - imageView.frame.origin.y);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) {//iphone5
        description.frame = CGRectMake(5, y, width+130, 333 - imageView.frame.origin.y);
    }
    else {
        description.frame = CGRectMake(5, y, width+130, 245 - imageView.frame.origin.y);
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        CGSize size = description.contentSize;
        size.height += 44;
        description.contentSize = size;
    }

    backgroundView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(imageView.frame) + CGRectGetHeight(labelName.frame) + 25);

    if (_menu)
        _menu.startPoint = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(backgroundView.frame));
}

@end
