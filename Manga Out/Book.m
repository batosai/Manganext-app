//
//  Book.m
//  Manga Out
//
//  Created by Jérémy chaufourier on 19/03/12.
//  Copyright (c) 2012 Jérémy Chaufourier. All rights reserved.
//

#import "Book.h"
#import "Signet.h"


@implementation Book

@synthesize thumbnail = _thumbnail;
@synthesize cover = _cover;

@dynamic uid;
@dynamic editor_name;
@dynamic name;
@dynamic author_name;
@dynamic text;
@dynamic number;
@dynamic state;
@dynamic image_src;
@dynamic image_version;
@dynamic image;
@dynamic price;
@dynamic published_at;
@dynamic updated_at;
@dynamic created_at;
@dynamic signet;

- (void)dealloc
{
    [_thumbnail release];
    [_cover release];
    [super dealloc];
}

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (!self) {
        return nil;
    }

    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@/%@.png",path, THUMBNAILS_CACHE_DIRECTORY, self.uid];
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL isDir = NO;
    
    if([fileManager fileExistsAtPath:pngFilePath isDirectory:&isDir]) {
        NSURL *img = [NSURL fileURLWithPath:pngFilePath];
        NSData* data = [NSData dataWithContentsOfURL:img];
        self.thumbnail = [UIImage imageWithData:data];
        self.cover = [UIImage imageWithData:data];
        //NSLog(@"A tester. Prend P-E bcp trop de temps, faire plutôt autrement, dans la tableView lancer une methode genre [book loadImage] si true ok sinon load image par thumbnailDownloader");
    }

    return self;
}

- (NSString *)getPublishedAtFromString
{
    // Affichage de la date au format FR
    NSLocale *frLocale = [[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale preferredLanguages] objectAtIndex:0]] autorelease];
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setLocale:frLocale];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    
    return [formatter stringFromDate:self.published_at];
}

- (void)updateWithDictionary:(NSDictionary *) dictionary
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    new_image_version = [NSNumber numberWithInt:[[dictionary valueForKeyPath:@"image_version"] intValue]];
    old_image_version = self.image_version;
    
    [self setUid: [NSNumber numberWithInt:[[dictionary valueForKeyPath:@"id"] intValue]]];
    [self setName: [dictionary valueForKeyPath:@"name"]];

    if ([dictionary valueForKeyPath:@"editor_name"] != [NSNull null]) {
        [self setEditor_name: [dictionary valueForKeyPath:@"editor_name"]];
    }

    if ([dictionary valueForKeyPath:@"author_name"] != [NSNull null]) {
        [self setAuthor_name: [dictionary valueForKeyPath:@"author_name"]];
    }
 
    if ([dictionary valueForKeyPath:@"text"] != [NSNull null]) {
        [self setText: [dictionary valueForKeyPath:@"text"]];
    }
    
    if ([dictionary valueForKeyPath:@"number"] != [NSNull null]) {
        [self setNumber: [dictionary valueForKeyPath:@"number"]];
    }

    if ([dictionary valueForKeyPath:@"state"] != [NSNull null]) {
        [self setState: [dictionary valueForKeyPath:@"state"]];
    }
    
    if ([dictionary valueForKeyPath:@"image_src"] != [NSNull null]) {
        [self setImage_src: [dictionary valueForKeyPath:@"image_src"]];
    }
    
    if ([dictionary valueForKeyPath:@"image"] != [NSNull null]) {
        [self setImage: [dictionary valueForKeyPath:@"image"]];
    }

    if ([dictionary valueForKeyPath:@"price"] != [NSNull null]) {
        [self setPrice: [NSNumber numberWithFloat: [[dictionary valueForKeyPath:@"price"] floatValue]]];
    }

    [self setPublished_at: [formatter dateFromString:[dictionary valueForKeyPath:@"published_at"]]];
    [self setCreated_at: [formatter dateFromString:[dictionary valueForKeyPath:@"created_at"]]];
    [self setUpdated_at: [formatter dateFromString:[dictionary valueForKeyPath:@"updated_at"]]];
    [self setImage_version: new_image_version];

    /*if (imageVersion != self.image_version) {
        [self setImage_version: imageVersion];

        [NSThread detachNewThreadSelector:@selector(downloadImages) toTarget:self withObject:nil];
    }*/
}

- (void)setAndSaveThumbnail:(UIImage *)thumbnail
{
    [self setThumbnail:thumbnail];

    [NSThread detachNewThreadSelector:@selector(downloadImages) toTarget:self withObject:nil];

    /*dispatch_async(dispatch_get_main_queue(), ^{
        [self downloadImages];
    });*/
}

- (void)downloadImages
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@/%@.png",path, THUMBNAILS_CACHE_DIRECTORY, self.uid];

    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL isDir = NO;

    if((self.image && ![fileManager fileExistsAtPath:pngFilePath isDirectory:&isDir]) ||
       (self.image && new_image_version != old_image_version)) {
    //if(self.image) {
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.image]]];

        NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
        [data1 writeToFile:pngFilePath atomically:YES];
        [image release];
    }

    [pool release];
}

- (void)deleteImages
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@/%@.png",path, THUMBNAILS_CACHE_DIRECTORY, self.uid];
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSError *error;
    BOOL isDir = NO;

    if([fileManager fileExistsAtPath:pngFilePath isDirectory:&isDir]) {
        [fileManager removeItemAtPath:pngFilePath error:&error];
    }
}

- (void)createSignet
{
    NSError *error;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Signet" inManagedObjectContext:self.managedObjectContext];
    Signet *signet = [[Signet alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    signet.book = self;
    [self.managedObjectContext save:&error];
    [signet release];
}

- (void)deleteSignet
{
    NSError *error;
    [self.managedObjectContext deleteObject:self.signet];
    [self.managedObjectContext save:&error];
}

- (void)remove
{
    [self deleteImages];

    NSError *error;
    [self.managedObjectContext deleteObject:self];
    [self.managedObjectContext save:&error];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, \"uid\": \"%@\", \"name\": \"%@\", \"edithor_name\": \"%@\", \"author_name\": \"%@\", \"text\": \"%@\", \"state\": \"%@\", \"image_src\": \"%@\", \"image_src\": \"%@\", \"image_version\": \"%@\", \"price\": \"%@\", \"published_at\": \"%@\">", NSStringFromClass([self class]), self, self.uid, self.name, self.editor_name, self.author_name, self.text, self.state, self.image_src, self.image, self.image_version, self.price, self.published_at];
}


@end
