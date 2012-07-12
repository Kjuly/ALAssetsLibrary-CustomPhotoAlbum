//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Copyright (c) 2011 Marin Todorov. All rights reserved.
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@implementation ALAssetsLibrary (CustomPhotoAlbum)

-(void)saveImage:(UIImage *)image
         toAlbum:(NSString *)albumName
      completion:(SaveImageCompletion)completion {
  // write the image data to the assets library (camera roll)
  [self writeImageToSavedPhotosAlbum:image.CGImage
                         orientation:(ALAssetOrientation)image.imageOrientation 
                     completionBlock:^(NSURL *assetURL, NSError *error) {
                       //error handling
                       if (error != nil) {
                         completion(error);
                         return;
                       }
                       
                       //add the asset to the custom photo album
                       [self addAssetURL:assetURL 
                                 toAlbum:albumName 
                              completion:completion];
                     }];
}

-(void)addAssetURL:(NSURL *)assetURL
           toAlbum:(NSString *)albumName
        completion:(SaveImageCompletion)completion {
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
              
              // run the completion block
              completion(nil);
            }
           failureBlock:completion];
      
      // album was found, bail out of the method
      return;
    }
    
    if (group == nil && albumWasFound == NO) {
      // photo albums are over, target album does not exist, thus create it
      __weak ALAssetsLibrary * weakSelf = self;
      
      // create new assets album
      [self addAssetsGroupAlbumWithName:albumName 
                            resultBlock:^(ALAssetsGroup *group) {
                              // get the photo's instance
                              [weakSelf assetForURL: assetURL 
                                        resultBlock:^(ALAsset *asset) {
                                          // add photo to the newly created album
                                          [group addAsset: asset];
                                          
                                          // call the completion block
                                          completion(nil);
                                        }
                                       failureBlock:completion];
                            }
                           failureBlock:completion];
      
      // should be the last iteration anyway, but just in case
      return;
    }
  };
  
  // search all photo albums in the library
  [self enumerateGroupsWithTypes:ALAssetsGroupAlbum 
                      usingBlock:enumerationBlock
                    failureBlock:completion];
}

@end
