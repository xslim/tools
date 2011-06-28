//
//  ImageCache.m
//  Ekipazh
//
//  Created by Taras Kalapun on 08.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageCache.h"
#import "SynthesizeSingleton.h"
#import <RestKit/RestKit.h>
#import "RKClient+Blocks.h"

NSString *kNImageLoaded = @"network.loaded.image";
NSString *kNGalleryImageLoaded = @"network.loaded.image.gallery";

static NSInteger const kCacheSize = 20;
static NSInteger const kImageFileLifetime = 864000;


@interface ImageCache ()
- (void)addImageToMemoryCache:(UIImage *)image withKey:(NSString *)key;

@end


@implementation ImageCache

SYNTHESIZE_SINGLETON_FOR_CLASS(ImageCache);

@synthesize cacheDirectory, useCacheOnly, customClient;


- (id)init
{
	self = [super init];
	if (self != nil)
	{
		fileManager = [NSFileManager defaultManager];
        
        mCache     = [[NSMutableDictionary alloc] initWithCapacity:kCacheSize];
        mCacheKeys = [[NSMutableArray alloc] initWithCapacity:kCacheSize];
        netUrlsLoading = [[NSMutableSet alloc] init];
        
		[[NSNotificationCenter defaultCenter] 
         addObserver:self
         selector:@selector(removeAllImagesInMemory)
         name:UIApplicationDidReceiveMemoryWarningNotification
         object:nil];
        
	}
	
	return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    self.customClient = nil;
    
    [mCache release]; mCache = nil;
    [mCacheKeys release]; mCacheKeys = nil;
    fileManager = nil;
    
    [netUrlsLoading release]; netUrlsLoading = nil;
    
    [cacheDirectory release];
    [super dealloc];
}

- (NSString *)pathForImageNamed:(NSString *)name size:(int)size
{
    return [[self.cacheDirectory 
             stringByAppendingPathComponent:[[NSNumber numberWithInt:size] stringValue]] 
             stringByAppendingPathComponent:name];
}

- (BOOL)hasImageWithName:(NSString *)name size:(int)size
{
    if (!name || [name isEqualToString:@""]) return NO;
    
    BOOL hasImage = NO;
    BOOL isThumb = (size == 0) ? YES : NO;
    
    
    if (isThumb) {
        UIImage *img = nil;
        img = [mCache objectForKey:name];
        
        if (!img) {
            NSString *path = [self  pathForImageNamed:name size:size];
            
            if ([fileManager fileExistsAtPath:path]) {
                img = [UIImage imageWithContentsOfFile:path];
                [self addImageToMemoryCache:img withKey:name];
                //NSLog(@"Loading image from file: %@", name);
                hasImage = YES;
            }
        } else {
            //NSLog(@"Loading image from mem: %@", name);
            hasImage = YES;
        }
    } else {
    
        NSString *path = [self pathForImageNamed:name size:size];
        
        if ([fileManager fileExistsAtPath:path]) {
            hasImage = YES;
        }
    }
    
    return hasImage;
}



- (UIImage *)imageWithName:(NSString *)name size:(int)size
{
    UIImage *img = nil;
    BOOL isThumb = (size == 0) ? YES : NO;
    
    if (isThumb) {
        
        img = [mCache objectForKey:name];
        
        if (!img) {
            NSString *path = [self pathForImageNamed:name size:size];
            
            if ([fileManager fileExistsAtPath:path]) {
                img = [UIImage imageWithContentsOfFile:path];
                [self addImageToMemoryCache:img withKey:name];
                //NSLog(@"Loading image from file: %@", name);
            }
        }
    } else {
        NSString *path = [self pathForImageNamed:name size:size];
        
        if ([fileManager fileExistsAtPath:path]) {
            img = [UIImage imageWithContentsOfFile:path];
        }
    }
    
    return img;
}

#pragma mark - Load Image

- (void)loadImageNamed:(NSString *)name size:(int)size withCustomProperties:(NSDictionary *)customProperties
{
    if (self.useCacheOnly) return;
 
    NSString *filePath = [@"/files/images/" stringByAppendingString:name];
    
    RKClient *request = [RKObjectManager sharedManager].client;
    [request requestWithResourcePath:filePath withCompletionHandler:^(RKResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error requesting image %@ : %@", name, error);
        } else {
            
            [self saveImageData:[response body] withName:name size:size];
            
            
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithDictionary:customProperties] autorelease];
            [dict setObject:name forKey:@"imageId"];
            [dict setObject:[NSNumber numberWithInt:size] forKey:@"size"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNImageLoaded object:nil userInfo:dict];
        }
    }];
     
  
}


- (void)loadImageNamed:(NSString *)name fromUrl:(NSString *)url size:(int)size withCustomProperties:(NSDictionary *)customProperties
{
    if (self.useCacheOnly) return;
    
    if (!self.customClient) {
        self.customClient = [RKClient clientWithBaseURL:nil];
    }
    
    //NSURL *baseURL = [NSURL URLWithString:url];
    //self.customClient.baseURL = [baseURL host];
    
 //   url = [baseURL ]
    
    RKClient *request = self.customClient;
    [request requestWithResourcePath:url withCompletionHandler:^(RKResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error requesting image %@ : %@", name, error);
        } else {
            
            [self saveImageData:[response body] withName:name size:size];
            
            
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithDictionary:customProperties] autorelease];
            [dict setObject:name forKey:@"imageId"];
            [dict setObject:[NSNumber numberWithInt:size] forKey:@"size"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNImageLoaded object:nil userInfo:dict];
        }
    }];
    
    
}


#pragma mark -
#pragma mark Save Image

- (void)saveImage:(UIImage *)image withName:(NSString *)name toPath:(NSString *)path
{
    if ([fileManager fileExistsAtPath:path]) {
        return;
    }
    
    if (image) {
        
        // Is it PNG or JPG/JPEG?
        // Running the image representation function writes the data from the image to a file
        if([name rangeOfString: @".png" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
        }
        else if(
                [name rangeOfString: @".jpg" options:NSCaseInsensitiveSearch].location != NSNotFound || 
                [name rangeOfString: @".jpeg" options:NSCaseInsensitiveSearch].location != NSNotFound
                )
        {
            [UIImageJPEGRepresentation(image, 0.9) writeToFile:path atomically:YES];
        }
        
    }
}

- (void)saveImage:(UIImage *)image withName:(NSString *)name size:(int)size
{
    NSString *path = [self pathForImageNamed:name size:size];
    
    [self saveImage:image withName:name toPath:path];
}

- (void)saveImageData:(NSData *)imageData withName:(NSString *)name toPath:(NSString *)path
{
    if ([fileManager fileExistsAtPath:path]) {
        return;
    }
    
    if (imageData) {
        [fileManager createFileAtPath:path contents:imageData attributes:nil];
    }
}

- (void)saveImageData:(NSData *)imageData withName:(NSString *)name size:(int)size
{
    NSString *path = [self pathForImageNamed:name size:size];
    [self saveImageData:imageData withName:name toPath:path];
}



#pragma mark -
#pragma mark @synthesize

- (NSString *)cacheDirectory 
{
    if (cacheDirectory) return cacheDirectory;
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    cacheDirectory = [[path stringByAppendingPathComponent:@"images"] retain];
    
    // create size dirs
    NSError *error = nil;
    for (int i = ICImageSizeThumbnail; i <= ICImageSizeFullScreen; i++) {
        NSString *imageSizePath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", i]];

        if (![fileManager fileExistsAtPath:imageSizePath] && ![fileManager createDirectoryAtPath:imageSizePath
                    withIntermediateDirectories:YES
                                     attributes:nil 
                                          error:&error]) {
            NSLog(@"Error creating size directory: %@", [error localizedDescription]);
        }
        
    }
    
    
    return cacheDirectory;
}

- (void)removeAllImagesInMemory
{
	[mCache removeAllObjects];
    [mCacheKeys removeAllObjects];
}

- (void)removeOldImages
{
	NSError *err = nil;
	NSArray *items = [fileManager contentsOfDirectoryAtPath:self.cacheDirectory error:&err];
	assert(err == nil);
	for (NSString *item in items)
	{
		NSString *path = [self.cacheDirectory stringByAppendingPathComponent:item];
		NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:nil];
		NSDate *creationDate = [attributes valueForKey:NSFileCreationDate];
		if (abs([creationDate timeIntervalSinceNow]) > kImageFileLifetime)
        {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
        }
	}
    
	[self removeAllImagesInMemory];
}

- (void)deleteAllImages
{
	NSError *err = nil;
	NSArray *items = [fileManager contentsOfDirectoryAtPath:self.cacheDirectory error:&err];
	assert(err == nil);
	for (NSString *item in items)
	{
		NSString *path = [self.cacheDirectory stringByAppendingPathComponent:item];

		NSError *error = nil;
		[fileManager removeItemAtPath:path error:&error];
        
	}
    cacheDirectory = nil;
}

- (UIImage *)defaultLoadingImage {
    return [UIImage imageNamed:@"photos.png"];
}

#pragma mark - Private

- (void)addImageToMemoryCache:(UIImage *)image withKey:(NSString *)key
{
    if (!image) return;
    if (!key) return;
    
	[mCache setObject:image forKey:key];
	[mCacheKeys insertObject:key atIndex:0];
	
	if ([mCacheKeys count] > kCacheSize) {
		NSString *lastObjectKey = [mCacheKeys lastObject];
		[mCache removeObjectForKey:lastObjectKey];
		[mCacheKeys removeLastObject];
	}
}


@end
