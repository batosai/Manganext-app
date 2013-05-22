//
//  Book.h
//  Manga Out
//
//  Created by Jérémy chaufourier on 19/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Signet;

@interface Book : NSManagedObject/* {
    NSNumber * new_image_version, *old_image_version;
}*/

@property (nonatomic, strong) NSNumber * uid;
@property (nonatomic, strong) NSString * editor_name;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * author_name;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSString * number;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * image_src;
@property (nonatomic, strong) NSNumber * image_version;
@property (nonatomic, strong) NSString * image;
@property (nonatomic, strong) NSNumber * price;
@property (nonatomic, strong) NSString * website;
@property (nonatomic, strong) NSDate * published_at;
@property (nonatomic, strong) NSDate * updated_at;
@property (nonatomic, strong) NSDate * created_at;
@property (nonatomic, strong) Signet *signet;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) UIImage *cover;

- (NSString *)getPublishedAtFromString;
//- (void)updateWithDictionary:(NSDictionary *) dictionary;
//- (void)downloadImages;
//- (void)remove;
//- (void)deleteImages;
//- (void)createSignet;
//- (void)deleteSignet;
//- (void)setAndSaveThumbnail:(UIImage *)thumbnail;

@end
