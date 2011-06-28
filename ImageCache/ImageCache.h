//
//  ImageCache.h
//  Ekipazh
//
//  Created by Taras Kalapun on 08.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kNImageLoaded;

typedef enum {
    ICImageSizeThumbnail,
    ICImageSizeMiddle,
    ICImageSizeFullScreen,
} ICImageSizeType;

@class RKClient;

@interface ImageCache : NSObject 
{
    NSString *cacheDirectory;
    
    NSMutableDictionary *mCache;
    NSMutableArray		*mCacheKeys;
    NSMutableSet *netUrlsLoading;
    
    NSFileManager *fileManager;
}

@property (nonatomic, readonly, retain) NSString *cacheDirectory;
@property (nonatomic, assign) BOOL useCacheOnly;
@property (nonatomic, retain) RKClient *customClient;

+ (ImageCache *)sharedImageCache;


- (NSString *)pathForImageNamed:(NSString *)name size:(int)size;

- (BOOL)hasImageWithName:(NSString *)name size:(int)size;

- (UIImage *)imageWithName:(NSString *)name size:(int)size;

- (void)loadImageNamed:(NSString *)name size:(int)size withCustomProperties:(NSDictionary *)customProperties;
//- (void)loadImageFromURL:(NSURL *)url withCustomProperties:(NSDictionary *)customProperties;
- (void)loadImageNamed:(NSString *)name fromUrl:(NSString *)url size:(int)size withCustomProperties:(NSDictionary *)customProperties;

- (void)saveImage:(UIImage *)image withName:(NSString *)name size:(int)size;
- (void)saveImage:(UIImage *)image withName:(NSString *)name toPath:(NSString *)path;

- (void)saveImageData:(NSData *)imageData withName:(NSString *)name toPath:(NSString *)path;
- (void)saveImageData:(NSData *)imageData withName:(NSString *)name size:(int)size;

- (void)deleteAllImages;
- (void)removeAllImagesInMemory;
- (void)removeOldImages;

- (UIImage *)defaultLoadingImage;

@end
