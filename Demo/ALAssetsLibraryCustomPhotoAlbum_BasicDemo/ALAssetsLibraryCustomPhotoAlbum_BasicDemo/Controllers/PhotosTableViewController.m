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
  NSMutableArray  * photos_;
}

@property (nonatomic, retain) ALAssetsLibrary * assetsLibrary;
@property (nonatomic, copy)   NSMutableArray  * photos;

- (void)_releaseSubviews;
- (void)_takePhoto:(id)sender;
- (BOOL)_startCameraControllerFromViewController:(UIViewController *)controller
                                   usingDelegate:(id <UIImagePickerControllerDelegate,
                                                  UINavigationControllerDelegate>)delegate;

@end


@implementation PhotosTableViewController

@synthesize assetsLibrary = assetsLibrary_;
@synthesize photos        = photos_;

- (void)dealloc {
  self.assetsLibrary = nil;
  [self _releaseSubviews];
  [super dealloc];
}

- (void)_releaseSubviews {
  self.photos = nil;
}

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
    [self setTitle:@"Demo"];
    photos_ = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
 
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
  // Right bar button (Take Photo) on navigation bar
  UIBarButtonItem * takePhotoButton = [UIBarButtonItem alloc];
  [takePhotoButton initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                        target:self
                                        action:@selector(_takePhoto:)];
  [takePhotoButton initWithTitle:@"Take"
                           style:UIBarButtonItemStyleBordered
                          target:self
                          action:@selector(_takePhoto:)];
  [takePhotoButton setStyle:UIBarButtonItemStyleBordered];
  //  [navigationController_.navigationItem setRightBarButtonItem:takePhotoButton];
  [self.navigationItem setRightBarButtonItem:takePhotoButton];
  [takePhotoButton release];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  [self _releaseSubviews];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

// Return the number of sections.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString * cellIdentifier = @"cell";
  UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier] autorelease];
  
  // Configure the cell...
  [cell.textLabel setText:[self.photos objectAtIndex:indexPath.row]];
  return cell;
}

#pragma mark - Table view delegate

- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  __block PhotoViewController * photoViewController = [[PhotoViewController alloc] init];
  [self.navigationController pushViewController:photoViewController animated:YES];
  // Get image from Custom Photo Album for the selected photo url.
  [self.assetsLibrary assetForURL:[NSURL URLWithString:[self.photos objectAtIndex:indexPath.row]]
                      resultBlock:^(ALAsset *asset) {
                        //
                        //  thumbnail: asset.thumbnail
                        //             asset.aspectRatioThumbnail
                        // fullscreen: asset.defaultRepresentation.fullScreenImage
                        //             asset.defaultRepresentation.fullResolutionImage
                        //
                        [photoViewController updateWithImage:
                          [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage]];
                        [photoViewController release];
                      }
                     failureBlock:^(NSError *error) {
                       NSLog(@"!!!ERROR: cannot get image: %@", [error description]);
                     }];
}

#pragma mark - Private Method

// Take photo
- (void)_takePhoto:(id)sender {
  if (! [self _startCameraControllerFromViewController:self
                                         usingDelegate:self]) {
    UIAlertView * alertView = [UIAlertView alloc];
    [alertView initWithTitle:@"Camera Unavailable"
                     message:@"Sorry, camera unavailable for the current device."
                    delegate:self
           cancelButtonTitle:@"Cancel"
           otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
  }
  return;
}

// verifies the prerequisites are satisfied by way of its method signature
//   and a conditional test, and goes on to instantiate, configure,
//   and asynchronously present the camera user interface full screen
- (BOOL)_startCameraControllerFromViewController:(UIViewController *)controller
                                   usingDelegate:(id <UIImagePickerControllerDelegate,
                                                  UINavigationControllerDelegate>)delegate {
  if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
      || delegate == nil
      || controller == nil) return NO;
  
  UIImagePickerController * picker = [[UIImagePickerController alloc] init];
  picker.sourceType = UIImagePickerControllerSourceTypeCamera;
  
  // Displays a control that allows the user to choose picture or
  //   movie capture, if both are available:
  //picker.mediaTypes =
  //  [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
  picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
  
  // Hides the controls for moving & scaling pictures, or for
  //   trimming movies. To instead show the controls, use YES.
  picker.allowsEditing = NO;
  picker.delegate      = delegate;
  
  [controller presentModalViewController:picker animated:YES];
  
  // No need to release here, as it'll be released after camera action done
  //   in |imagePickerControllerDidCancel:| method
  // [picker release];
  return YES;
}

#pragma mark - UIImagePickerController Delegate

// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  // Prior to iOS 5.0, if a view did not have a parent view controller
  //   and was being presented modally, the view controller that was presenting
  //   it would be returned.
  // This is no longer the case. You can get the presenting view controller
  //   using the presentingViewController property.
  //
  // Guess |parentViewController| is nil on iOS 5 and that is why the controller
  //   will not dismiss.
  // Replacing |parentViewController| with |presentingViewController| will fix
  //   this issue.
  //
  // However, you'll have to check for the existence of presentingViewController
  //   on UIViewController to provide behavior for iOS versions < 5.0
  if ([picker respondsToSelector:@selector(presentingViewController)])
    [[picker presentingViewController] dismissModalViewControllerAnimated:YES];
  else
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
  [picker release];
}

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
  // dismiss image picker view
  [self dismissModalViewControllerAnimated:YES];
  [picker release];
  
  // manage the media (photo)
  NSString * mediaType = [info objectForKey:UIImagePickerControllerMediaType];
  
  // Handle a still image capture
  if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
    // manage tasks in background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      UIImage * originalImage, * editedImage, * imageToSave, * finalImageToSave;
      editedImage   = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
      originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
      
      if (editedImage) imageToSave = editedImage;
      else             imageToSave = originalImage;
      
      // modify image's size before save it to photos album
      CGSize sizeToSave = CGSizeMake(imageToSave.size.width, imageToSave.size.height);
      UIGraphicsBeginImageContextWithOptions(sizeToSave, NO, 0.0);
      [imageToSave drawInRect:CGRectMake(0, 0, sizeToSave.width, sizeToSave.height)];
      finalImageToSave = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();
      
      /*/ Get the image metadata
      UIImagePickerControllerSourceType pickerType = picker.sourceType;
      if (pickerType == UIImagePickerControllerSourceTypeCamera) {
        NSDictionary * imageMetadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
        NSLog(@"%@", imageMetadata);
        
        // Get the assets library
        ALAssetsLibrary * library = [[ALAssetsLibrary alloc] init];
        ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock =
        ^(NSURL *newURL, NSError *error) {
          if (error) {
            NSLog( @"Error writing image with metadata to Photo Library: %@", error );
          } else {
            NSLog( @"Wrote image with metadata to Photo Library");
          }
        };
        
        // Save the new image (original or edited) to the Camera Roll
        [library writeImageToSavedPhotosAlbum:[finalImageToSave CGImage]
                                     metadata:imageMetadata
                              completionBlock:imageWriteCompletionBlock];
      }*/
      
      // The completion block to be executed after image taking action process done
      void (^completion)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
        if (error) NSLog(@"!!!ERROR,  write the image data to the assets library (camera roll): %@",
                         [error description]);
        NSLog(@"*** URL %@ | %@ || type: %@ ***", assetURL, [assetURL absoluteString], [assetURL class]);
        // Add new one to |photos_|
        [self.photos addObject:[assetURL absoluteString]];
        // Reload tableview data
        [self.tableView reloadData];
      };
      
      void (^failure)(NSError *) = ^(NSError *error) {
        if (error == nil) return;
        NSLog(@"!!!ERROR, failed to add the asset to the custom photo album: %@", [error description]);
      };
      
      // save image to custom photo album
      if (! self.assetsLibrary) assetsLibrary_ = [[ALAssetsLibrary alloc] init];
      [self.assetsLibrary saveImage:finalImageToSave
                            toAlbum:kKYCustomPhotoAlbumName_
                         completion:completion
                            failure:failure];
    });
  }
}

@end
