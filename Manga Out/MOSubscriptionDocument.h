//
//  MOSubscription.h
//  Manga Next
//
//  Created by Jeremy on 29/01/13.
//  Copyright (c) 2013 Jérémy Chaufourier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Book;

@interface MOSubscriptionDocument : UIDocument

@property (strong) NSMutableDictionary * dictionary;

- (void)setBook:(Book *)book;
- (void)deleteBook:(Book *)book;
- (void)deleteAtKey:(NSString *)key;

@end
