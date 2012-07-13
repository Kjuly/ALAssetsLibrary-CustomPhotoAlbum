ALAssetsLibrary-CustomPhotoAlbum
================================

A nice ALAssetsLibrary category for saving images into custom photo album by @MarinTodorov.


    -(void)saveImage:(UIImage *)image
             toAlbum:(NSString *)albumName
     completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
        failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock;


#### REFERENCE:

[ALAssetsLibrary Class Reference][1]  
[iOS5: Saving photos in custom photo album][2]

[1]: http://developer.apple.com/library/ios/#documentation/AssetsLibrary/Reference/ALAssetsLibrary_Class/Reference/Reference.html#//apple_ref/occ/instm/ALAssetsLibrary/addAssetsGroupAlbumWithName:resultBlock:failureBlock:
[2]: http://www.touch-code-magazine.com/ios5-saving-photos-in-custom-photo-album-category-for-download/
