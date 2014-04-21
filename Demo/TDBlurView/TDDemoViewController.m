//
//  TDDemoViewController.m
//  TDBlurView
//
//  Created by timominous on 4/10/14.
//  Copyright (c) 2014 timominous. All rights reserved.
//

#import "TDDemoViewController.h"
#import "TDBlurView.h"

@interface TDDemoViewController ()

@property (strong, nonatomic) TDBlurView *blurView;

@end

@implementation TDDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.blurView = [[TDBlurView alloc] initWithBlurredView:self.view];
}

- (IBAction)didTapButton:(UIButton *)sender {
  if ([_blurView.excludedViews containsObject:sender]) {
    [self didTapRemoveBlur:sender];
    return;
  }
  _blurView.excludedViews = @[sender];
  [_blurView blur];
}

- (IBAction)didTapRemoveBlur:(UIButton *)sender {
  [_blurView removeBlur];
  _blurView.excludedViews = @[];
}

@end
