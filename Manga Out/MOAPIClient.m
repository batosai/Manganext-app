// AFTwitterAPIClient.h
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MOAPIClient.h"

#import "AFNetworking.h"
#import "AFJSONRequestOperation.h"

@implementation MOAPIClient

+ (MOAPIClient *)sharedClient {
    static MOAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[MOAPIClient alloc] initWithBaseURL:[NSURL URLWithString:DOMAINEURI]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];

	[self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFJSONParameterEncoding];

    return self;
}

#pragma mark - AFIncrementalStore

- (NSURLRequest *)requestForFetchRequest:(NSFetchRequest *)fetchRequest
                             withContext:(NSManagedObjectContext *)context
{
    NSMutableURLRequest *mutableURLRequest = nil;
    if ([fetchRequest.entityName isEqualToString:@"Book"]) {
        mutableURLRequest = [self requestWithMethod:@"GET" path:BOOKSURI parameters:nil];
    }

    return mutableURLRequest;
}

- (NSMutableURLRequest *)requestForInsertedObject:(NSManagedObject *)insertedObject {
//    if ([insertedObject class] isSubclassOfClass:[Signet class])
    return nil;
}

- (NSMutableURLRequest *)requestForUpdatedObject:(NSManagedObject *)updatedObject {
    return nil;
}

- (NSMutableURLRequest *)requestForDeletedObject:(NSManagedObject *)deletedObject {
    return nil;
}

- (id)representationOrArrayOfRepresentationsFromResponseObject:(id)responseObject {
    return responseObject[@"result"];
}

- (id)representationOrArrayOfRepresentationsOfEntity:(NSEntityDescription *)entity
                                  fromResponseObject:(id)responseObject{

    if ([entity.name isEqualToString:@"Book"]) {
        if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"result"]) {
            return responseObject[@"result"];
        }
    }
    return [super representationOrArrayOfRepresentationsOfEntity:entity fromResponseObject:responseObject];
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation
                                     ofEntity:(NSEntityDescription *)entity
                                 fromResponse:(NSHTTPURLResponse *)response
{
    if (representation == (id)[NSNull null])
        return nil;

    NSMutableDictionary *mutablePropertyValues = [[super attributesForRepresentation:representation ofEntity:entity fromResponse:response] mutableCopy];

    if (![entity.name isEqualToString:@"Book"])
        return mutablePropertyValues;

    [mutablePropertyValues setValue:[NSNumber numberWithInt:[representation[@"id"] intValue]] forKey:@"uid"];
    [mutablePropertyValues setValue:representation[@"name"] forKey:@"name"];
    [mutablePropertyValues setValue:representation[@"editor_name"] forKey:@"editor_name"];
    [mutablePropertyValues setValue:representation[@"author_name"] forKey:@"author_name"];
    [mutablePropertyValues setValue:representation[@"text"] forKey:@"text"];
    [mutablePropertyValues setValue:representation[@"number"] forKey:@"number"];
    [mutablePropertyValues setValue:representation[@"state"] forKey:@"state"];
    [mutablePropertyValues setValue:representation[@"image_src"] forKey:@"image_src"];
    [mutablePropertyValues setValue:[NSNumber numberWithInt:[representation[@"image_version"] intValue]] forKey:@"image_version"];
    [mutablePropertyValues setValue:representation[@"image"] forKey:@"image"];
    [mutablePropertyValues setValue:[NSNumber numberWithFloat: [representation[@"price"] floatValue]] forKey:@"price"];
    [mutablePropertyValues setValue:AFDateFromISO8601String(representation[@"published_at"]) forKey:@"published_at"];
    [mutablePropertyValues setValue:AFDateFromISO8601String(representation[@"updated_at"]) forKey:@"updated_at"];
    [mutablePropertyValues setValue:AFDateFromISO8601String(representation[@"created_at"]) forKey:@"created_at"];

    return mutablePropertyValues;
}

- (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID *)objectID
                                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    return NO;
}

- (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship
                               forObjectWithID:(NSManagedObjectID *)objectID
                        inManagedObjectContext:(NSManagedObjectContext *)context
{
    return NO;
}

@end
