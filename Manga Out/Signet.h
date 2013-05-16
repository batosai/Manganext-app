//
//  Signet.h
//  Manga Out
//
//  Created by Jérémy chaufourier on 19/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Book;

@interface Signet : NSManagedObject

@property (nonatomic, strong) Book *book;

@end
