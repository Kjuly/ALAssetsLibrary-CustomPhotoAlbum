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

@property (nonatomic, retain) UIImageView * photoView;

- (void)_releaseSubviews;
- (void)_back:(id)sender;

@end


@implementation PhotoViewController

@synthesize photoView = photoView_;

- (void)dealloc {
  [self _releaseSubviews];
  [super dealloc];
}

- (void)_releaseSubviews {
  self.photoView = nil;
}

- (id)init {
  self = [super init];
  if (self) {
    
  }
  return self;
}

- (void)loadView {
  UIView * view = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {kKYViewWidth, kKYViewHeight}}];
  self.view = view;
  [view release];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  
  // Photo view
  photoView_ = [[UIImageView alloc] initWithFrame:self.view.frame];
  [photoView_ setContentMode:UIViewContentModeScaleAspectFill];
  [photoView_ setUserInteractionEnabled:YES];
  [self.view addSubview:photoView_];
  
  // Tap gesture on view
  UITapGestureRecognizer * tapGestureRecognizer = [UITapGestureRecognizer alloc];
  [tapGestureRecognizer initWithTarget:self action:@selector(_back:)];
  [tapGestureRecognizer setNumberOfTapsRequired:1];
  [tapGestureRecognizer setNumberOfTouchesRequired:1];
  [self.view addGestureRecognizer:tapGestureRecognizer];
  [tapGestureRecognizer release];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  [self _releaseSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method

// Back to previous view
- (void)_back:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Public Method

// Update with image get from Custom Photo Album
- (void)updateWithImage:(UIImage *)image {
  [self.photoView setImage:image];
}

@end
