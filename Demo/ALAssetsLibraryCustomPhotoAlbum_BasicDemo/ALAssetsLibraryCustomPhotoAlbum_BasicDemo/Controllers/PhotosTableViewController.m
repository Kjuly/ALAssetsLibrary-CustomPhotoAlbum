//
//  PhotosTableViewController.m
//  ALAssetsLibraryCustomPhotoAlbum_BasicDemo
//
//  Created by Kjuly on 1/7/13.
//  Copyright (c) 2013 Kjuly. All rights reserved.
//

#import "PhotosTableViewController.h"

#import "PhotoViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <MobileCoreServices/MobileCoreServices.h>

// Name for the custom photo album
#define kKYCustomPhotoAlbumName_ @"Custom Photo Album"


@interface PhotosTableViewController () {
 @private
  ALAssetsLibrary * assetsLibrary_;
  NSMutableArray  * photoURLs_;
}

@property (nonatomic, strong) ALAssetsLibrary * assetsLibrary;
@property (nonatomic, strong) NSMutableArray  * photoURLs;

- (void)_takePhoto:(id)sender;

@end


@implementation PhotosTableViewController

@synthesize assetsLibrary = assetsLibrary_;
@synthesize photoURLs     = photoURLs_;

- (id)initWithStyle:(UITableViewStyle)style
{
  if (self = [super initWithStyle:style]) {
    
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self setTitle:@"Demo"];
  
  // Right bar button (Take Photo) on navigation bar
  UIBarButtonItem * takePhotoButton = [UIBarButtonItem alloc];
  (void)[takePhotoButton initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                              target:self
                                              action:@selector(_takePhoto:)];
  (void)[takePhotoButton initWithTitle:@"Take"
                                 style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(_takePhoto:)];
  [takePhotoButton setStyle:UIBarButtonItemStyleBordered];
  [self.navigationItem setRightBarButtonItem:takePhotoButton];
  
  [self.assetsLibrary loadAssetsForProperty:ALAssetPropertyAssetURL
                                  fromAlbum:kKYCustomPhotoAlbumName_
                                 completion:^(NSMutableArray *array, NSError *error) {
                                   self.photoURLs = (array ?: [NSMutableArray array]);
                                   [self.tableView reloadData];
                                 }];
  
  // Note:
  //
  //  This code snippet is for testing |ALAssetsLibrary+CustomPhotoAlbum| lib's method:
  //   |-loadPhotosFromAlbum:completion:|.
  //
  /*
  [self.assetsLibrary loadImagesFromAlbum:kKYCustomPhotoAlbumName_
                               completion:^(NSMutableArray *images, NSError *error) {
                                 NSLog(@"%s: %@", __PRETTY_FUNCTION__, images);
                               }];*/
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  
  // Dispose of any resources that can be recreated.
  assetsLibrary_ = nil;
}

#pragma mark - Custom Getter

- (ALAssetsLibrary *)assetsLibrary
{
  if (assetsLibrary_) {
    return assetsLibrary_;
  }
  assetsLibrary_ = [[ALAssetsLibrary alloc] init];
  return assetsLibrary_;
}

#pragma mark - Table view data source

// Return the number of sections.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return [self.photoURLs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString * cellIdentifier = @"cell";
  UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier];
  
  // Configure the cell...
  NSURL * photoURL = (NSURL *)(self.photoURLs)[indexPath.row];
  [cell.textLabel setText:[photoURL absoluteString]];
  return cell;
}

#pragma mark - Table view delegate

- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  PhotoViewController * photoViewController = [[PhotoViewController alloc] init];
  [photoViewController setModalPresentationStyle:UIModalPresentationFullScreen];
  [photoViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
  [self presentViewController:photoViewController animated:YES completion:^{
    // Get image from Custom Photo Album for the selected photo url.
    [self.assetsLibrary assetForURL:(self.photoURLs)[indexPath.row]
                        resultBlock:^(ALAsset *asset) {
                          //
                          //  thumbnail: asset.thumbnail
                          //             asset.aspectRatioThumbnail
                          // fullscreen: asset.defaultRepresentation.fullScreenImage
                          //             asset.defaultRepresentation.fullResolutionImage
                          //
                          [photoViewController updateWithImage:
                            [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage]];
                        }
                       failureBlock:^(NSError *error) {
                         NSLog(@"%s: Cannot get image: %@", __PRETTY_FUNCTION__, [error description]);
                       }];
  }];
}

#pragma mark - Private Method

// Take photo
- (void)_takePhoto:(id)sender
{
  if (! [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    [[[UIAlertView alloc] initWithTitle:@"Camera Unavailable"
                                message:@"Sorry, camera unavailable for the current device."
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:nil, nil] show];
    return;
  }
  
  // Generate picker
  UIImagePickerController * picker = [[UIImagePickerController alloc] init];
  picker.delegate = self;
  picker.sourceType = UIImagePickerControllerSourceTypeCamera;
  
  // Displays a control that allows the user to choose picture or
  //   movie capture, if both are available:
  //picker.mediaTypes =
  //  [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
  picker.mediaTypes = @[(NSString *)kUTTypeImage];
  
  // Hides the controls for moving & scaling pictures, or for
  //   trimming movies. To instead show the controls, use YES.
  picker.allowsEditing = NO;
  
  [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate

// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [picker dismissViewControllerAnimated:YES completion:nil];
  picker.delegate = nil;
}

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  // Dismiss image picker view
  [self imagePickerControllerDidCancel:picker];
  
  // Manage the media (photo)
  NSString * mediaType = info[UIImagePickerControllerMediaType];
  // Handle a still image capture
  CFStringRef mediaTypeRef = (__bridge CFStringRef)mediaType;
  if (CFStringCompare(mediaTypeRef,
                      kUTTypeImage,
                      kCFCompareCaseInsensitive) != kCFCompareEqualTo)
  {
    CFRelease(mediaTypeRef);
    return;
  }
  CFRelease(mediaTypeRef);
  
  // Manage tasks in background thread
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    UIImage * editedImage = (UIImage *)info[UIImagePickerControllerEditedImage];
    UIImage * imageToSave = (editedImage ?: (UIImage *)info[UIImagePickerControllerOriginalImage]);
    
    UIImage * finalImageToSave = nil;
    /* Modify image's size before save it to photos album
     *
     *  CGSize sizeToSave = CGSizeMake(imageToSave.size.width, imageToSave.size.height);
     *  UIGraphicsBeginImageContextWithOptions(sizeToSave, NO, 0.f);
     *  [imageToSave drawInRect:CGRectMake(0.f, 0.f, sizeToSave.width, sizeToSave.height)];
     *  finalImageToSave = UIGraphicsGetImageFromCurrentImageContext();
     *  UIGraphicsEndImageContext();
     */
    finalImageToSave = imageToSave;
    
    // The completion block to be executed after image taking action process done
    void (^completion)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
      if (error) {
        NSLog(@"%s: Write the image data to the assets library (camera roll): %@",
              __PRETTY_FUNCTION__, [error localizedDescription]);
      }
      
      NSLog(@"%s: Save image with asset url %@ (absolute path: %@), type: %@", __PRETTY_FUNCTION__,
            assetURL, [assetURL absoluteString], [assetURL class]);
      // Add new item to |photos_| & table view appropriately
      NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.photoURLs.count
                                                   inSection:0];
      [self.photoURLs addObject:assetURL];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView insertRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
      });
    };
    
    void (^failure)(NSError *) = ^(NSError *error) {
      if (error) NSLog(@"%s: Failed to add the asset to the custom photo album: %@",
                       __PRETTY_FUNCTION__, [error localizedDescription]);
    };
    
    // Save image to custom photo album
    // The lifetimes of objects you get back from a library instance are tied to
    //   the lifetime of the library instance.
    [self.assetsLibrary saveImage:finalImageToSave
                          toAlbum:kKYCustomPhotoAlbumName_
                       completion:completion
                          failure:failure];
  });
}

#pragma mark - PhotoViewControllerDelegate

- (void)shouldDismissPhotoViewController:(PhotoViewController *)controller
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
