//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Copyright (c) 2011 Marin Todorov. All rights reserved.
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface ALAssetsLibrary (Private)

-(void)_addAssetURL:(NSURL *)assetURL
            toAlbum:(NSString *)albumName
       failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock;

@end


@implementation ALAssetsLibrary (CustomPhotoAlbum)

#pragma mark - Public Method

- (void)saveImage:(UIImage *)image
          toAlbum:(NSString *)albumName
  completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
     failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock {
  [self writeImageToSavedPhotosAlbum:image.CGImage
                         orientation:(ALAssetOrientation)image.imageOrientation 
                     completionBlock:[self addToAlbum:albumName
                                           onComplete:completionBlock
                                            onFailure:failureBlock]];
}

- (void)saveImageData:(NSData *)imageData
              toAlbum:(NSString *)albumName
             metadata:(NSDictionary *)metadata
      completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
     failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock {
    [self writeImageDataToSavedPhotosAlbum:imageData
                                  metadata:metadata
                           completionBlock:[self addToAlbum:albumName
                                                 onComplete:completionBlock
                                                  onFailure:failureBlock]];
    
}

- (void)saveVideo:(NSURL *)videoUrl
          toAlbum:(NSString *)albumName
  completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
     failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock {
    [self writeVideoAtPathToSavedPhotosAlbum: videoUrl
                             completionBlock:[self addToAlbum:albumName
                                                   onComplete:completionBlock
                                                    onFailure:failureBlock]];
}

- (ALAssetsLibraryWriteImageCompletionBlock)addToAlbum:(NSString *)albumName
                                            onComplete:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
                                             onFailure:(ALAssetsLibraryAccessFailureBlock)failureBlock
{
    ALAssetsLibraryWriteImageCompletionBlock onComplete = ^(NSURL *assetURL, NSError *error) {
        // run the completion block for writing image to saved
        //   photos album
        if (completionBlock) completionBlock(assetURL, error);
        
        // if an error occured, do not try to add the asset to
        //   the custom photo album
        if (error != nil)
            return;
        
        // add the asset to the custom photo album
        [self _addAssetURL:assetURL
                   toAlbum:albumName
              failureBlock:failureBlock];
    };
    return [onComplete copy];
}

#pragma mark - Private Method

-(void)_addAssetURL:(NSURL *)assetURL
            toAlbum:(NSString *)albumName
       failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock {
  __block BOOL albumWasFound = NO;
  
  ALAssetsLibraryGroupsEnumerationResultsBlock enumerationBlock;
  enumerationBlock = ^(ALAssetsGroup *group, BOOL *stop) {
    // compare the names of the albums
    if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
      // target album is found
      albumWasFound = YES;
      
      // get a hold of the photo's asset instance
      [self assetForURL:assetURL 
            resultBlock:^(ALAsset *asset) {
              // add photo to the target album
              [group addAsset:asset];
            }
           failureBlock:failureBlock];
      
      // album was found, bail out of the method
      return;
    }
    
    if (group == nil && albumWasFound == NO) {
      // photo albums are over, target album does not exist, thus create it
      
      // Since you use the assets library inside the block,
      //   ARC will complain on compile time that there’s a retain cycle.
      //   When you have this – you just make a weak copy of your object.
      //
      //   __weak ALAssetsLibrary * weakSelf = self;
      //
      // by @Marin.
      //
      // I don't use ARC right now, and it leads a warning.
      // by @Kjuly
      ALAssetsLibrary * weakSelf = self;
      
      // if iOS version is lower than 5.0, throw a warning message
      if (! [self respondsToSelector:@selector(addAssetsGroupAlbumWithName:resultBlock:failureBlock:)])
        NSLog(@"![WARNING][LIB:ALAssetsLibrary+CustomPhotoAlbum]: \
              |-addAssetsGroupAlbumWithName:resultBlock:failureBlock:| \
              only available on iOS 5.0 or later. \
              ASSET cannot be saved to album!");
      // create new assets album
      else [self addAssetsGroupAlbumWithName:albumName
                                 resultBlock:^(ALAssetsGroup *group) {
                                   // get the photo's instance
                                   [weakSelf assetForURL:assetURL
                                             resultBlock:^(ALAsset *asset) {
                                               // add photo to the newly created album
                                               [group addAsset:asset];
                                             }
                                            failureBlock:failureBlock];
                                 }
                                failureBlock:failureBlock];
      
      // should be the last iteration anyway, but just in case
      return;
    }
  };
  
  // search all photo albums in the library
  [self enumerateGroupsWithTypes:ALAssetsGroupAlbum 
                      usingBlock:enumerationBlock
                    failureBlock:failureBlock];
}

@end
