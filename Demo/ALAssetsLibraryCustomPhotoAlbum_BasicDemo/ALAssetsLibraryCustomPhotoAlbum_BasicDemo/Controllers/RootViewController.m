//
//  RootViewController.m
//  ALAssetsLibraryCustomPhotoAlbum_BasicDemo
//
//  Created by Kjuly on 1/7/13.
//  Copyright (c) 2013 Kjuly. All rights reserved.
//

#import "RootViewController.h"

#import "PhotosTableViewController.h"

@interface RootViewController () {
 @private
  UINavigationController * navigationController_;
}

@property (nonatomic, strong) UINavigationController * navigationController;

@end


@implementation RootViewController

@synthesize navigationController = navigationController_;


- (id)init
{
  return (self = [super init]);
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Photos table view controller
  PhotosTableViewController * photosTableViewController = [PhotosTableViewController alloc];
  (void)[photosTableViewController initWithStyle:UITableViewStylePlain];
  
  // Main navigation controller
  navigationController_ = [UINavigationController alloc];
  (void)[navigationController_ initWithRootViewController:photosTableViewController];
  [navigationController_.view setFrame:(CGRect){CGPointZero, {kKYViewWidth, kKYViewHeight}}];
  [self addChildViewController:navigationController_];
  [self.view addSubview:navigationController_.view];
  [navigationController_ willMoveToParentViewController:self];
}

@end
