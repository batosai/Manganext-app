//
//  Book.h
//  Manga Out
//
//  Created by Jérémy chaufourier on 19/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Signet;

@interface Book : NSManagedObject {
    NSNumber * new_image_version, *old_image_version;
}

@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * editor_name;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * author_name;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * image_src;
@property (nonatomic, retain) NSNumber * image_version;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSDate * published_at;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) Signet *signet;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) UIImage *cover;

- (NSString *)getPublishedAtFromString;
- (void)updateWithDictionary:(NSDictionary *) dictionary;
- (void)downloadImages;
- (void)remove;
- (void)deleteImages;
- (void)createSignet;
- (void)deleteSignet;
- (void)setAndSaveThumbnail:(UIImage *)thumbnail;

@end
