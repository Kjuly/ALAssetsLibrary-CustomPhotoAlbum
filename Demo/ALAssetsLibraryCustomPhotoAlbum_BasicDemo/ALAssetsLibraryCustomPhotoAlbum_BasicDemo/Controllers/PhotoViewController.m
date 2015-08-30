//
//  PhotoViewController.m
//  ALAssetsLibraryCustomPhotoAlbum_BasicDemo
//
//  Created by Kjuly on 1/7/13.
//  Copyright (c) 2013 Kjuly. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController () {
 @private
  UIImageView * photoView_;
}

@property (nonatomic, strong) UIImageView * photoView;

- (void)_handleTapGesture:(UITapGestureRecognizer *)recognizer;

@end


@implementation PhotoViewController

@synthesize photoView = photoView_;

- (id)init
{
  return (self = [super init]);
}

- (void)loadView
{
  // iOS 5 SDK does not defined NSFoundationVersionNumber_iOS_6_1
#ifdef NSFoundationVersionNumber_iOS_6_1
  CGFloat height = (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1
                    ?  kKYViewHeight : kKYViewHeight + kKYStatusBarHeight);
#else
  CGFloat height = kKYViewHeight;
#endif
  UIView * view = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {kKYViewWidth, height}}];
  [view setBackgroundColor:[UIColor whiteColor]];
  self.view = view;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Photo view
#ifdef NSFoundationVersionNumber_iOS_6_1
  CGFloat originY = (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1
                     ? 0.f : kKYStatusBarHeight);
#else
  CGFloat originY = 0.f;
#endif
  CGRect photoViewFrame = CGRectMake(0.f, originY, kKYViewWidth, kKYViewHeight);
  photoView_ = [[UIImageView alloc] initWithFrame:photoViewFrame];
  [photoView_ setContentMode:UIViewContentModeScaleAspectFill];
  [photoView_ setUserInteractionEnabled:YES];
  [self.view addSubview:photoView_];
  
  // Tap gesture on view
  UITapGestureRecognizer * tapGestureRecognizer = [UITapGestureRecognizer alloc];
  (void)[tapGestureRecognizer initWithTarget:self action:@selector(_handleTapGesture:)];
  [tapGestureRecognizer setNumberOfTapsRequired:1];
  [tapGestureRecognizer setNumberOfTouchesRequired:1];
  [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method

// Back to previous view
- (void)_handleTapGesture:(UITapGestureRecognizer *)recognizer
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public Method

// Update with image get from Custom Photo Album
- (void)updateWithImage:(UIImage *)image
{
  [self.photoView setImage:image];
}

@end
