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

@property (nonatomic, retain) UINavigationController * navigationController;

@end


@implementation RootViewController

@synthesize navigationController = navigationController_;

- (void)dealloc {
  self.navigationController = nil;
  [super dealloc];
}

- (id)init {
  self = [super init];
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  
  // Photos table view controller
  PhotosTableViewController * photosTableViewController;
  photosTableViewController = [PhotosTableViewController alloc];
  [photosTableViewController initWithStyle:UITableViewStylePlain];
  
  // Main navigation controller
  navigationController_ = [UINavigationController alloc];
  [navigationController_ initWithRootViewController:photosTableViewController];
  [photosTableViewController release];
  [navigationController_.view setFrame:(CGRect){CGPointZero, {kKYViewWidth, kKYViewHeight}}];
  [self.view addSubview:navigationController_.view];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
