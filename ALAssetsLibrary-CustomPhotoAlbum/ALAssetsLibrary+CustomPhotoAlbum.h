//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Copyright (c) 2011 Marin Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (CustomPhotoAlbum)

/*! Write the image data to the assets library (camera roll).
 *
 * \param image The target image to be saved
 * \param albumName Custom album name
 * \param completionBlock Block to be executed when succeed to write the image data to the assets library (camera roll)
 * \param failureBlock Block to be executed when failed to add the asset to the custom photo album
 */
-(void)saveImage:(UIImage *)image
         toAlbum:(NSString *)albumName
 completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
    failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock;

/*! write the video to the assets library (camera roll).
 *
 * \param videoUrl The target video to be saved
 * \param albumName Custom album name
 * \param completionBlock Block to be executed when succeed to write the image data to the assets library (camera roll)
 * \param failureBlock block to be executed when failed to add the asset to the custom photo album
 */
-(void)saveVideo:(NSURL *)videoUrl
         toAlbum:(NSString *)albumName
 completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
    failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock;

/*! Write the image data with meta data to the assets library (camera roll).
 * 
 * \param imageData The image data to be saved
 * \param albumName Custom album name
 * \param metadata Meta data for image
 * \param completionBlock Block to be executed when succeed to write the image data
 * \param failureBlock block to be executed when failed to add the asset to the custom photo album
 *
 */
- (void)saveImageData:(NSData *)imageData
              toAlbum:(NSString *)albumName
             metadata:(NSDictionary *)metadata
      completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
         failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock;

@end