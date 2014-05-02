//
//  TDBlurView.m
//  TDBlurView
//
//  Created by timominous on 4/10/14.
//  Copyright (c) 2014 timominous. All rights reserved.
//

#import "TDBlurView.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface TDBlurView ()

@property (strong, nonatomic) UIView *blurOverlay;
@property (strong, nonatomic) UIImageView *blurImageView;
@property (strong, nonatomic) UIImage *blurredImage;

@property (nonatomic) BOOL blurred;

@property (strong, nonatomic) NSMutableArray *excludedProps;

@end

@implementation TDBlurView

- (id)initWithBlurredView:(UIView *)blurredView {
  if ((self = [super init])) {
    self.blurredView = blurredView;
  }
  return self;
}

- (void)setBlurredView:(UIView *)blurredView {
  _blurredView = blurredView;
  self.excludedViews = @[];
  _size = blurredView.bounds.size;
  
  if (!_blurOverlay) {
    self.blurOverlay = [[UIView alloc] init];
    _blurOverlay.backgroundColor = UIColor.clearColor;
  }
  _blurOverlay.frame = _blurredView.bounds;
  _blurOverlay.alpha = 0.f;
  
  if (!_blurImageView) {
    self.blurImageView = [[UIImageView alloc] initWithFrame:_blurOverlay.bounds];
    _blurImageView.backgroundColor = UIColor.clearColor;
  }
  _blurImageView.image = nil;
  [_blurOverlay addSubview:_blurImageView];
}

- (void)setExcludedViews:(NSArray *)excludedViews {
  _excludedViews = excludedViews;
  [_excludedProps removeAllObjects];
}

- (void)setSize:(CGSize)size {
  _size = size;
  
  CGRect rect = _blurOverlay.frame;
  rect.size = size;
  _blurOverlay.frame = rect;
  
  rect = _blurImageView.frame;
  rect.size = size;
  _blurImageView.frame = rect;
}

- (void)blur {
  if (_blurred)
    return;

  self.excludedProps = [NSMutableArray array];
  for (UIView *v in _excludedViews) {
    [_excludedProps addObject:@{@"frame": [NSValue valueWithCGRect:v.frame],
                                @"superview": v.superview}];
    [v removeFromSuperview];
  }
  
  UIImage *viewImage = [self generateImageForView:_blurredView];
  
  CIContext *context = [CIContext contextWithOptions:nil];
  CIImage *inputImage = [CIImage imageWithCGImage:viewImage.CGImage];
  
  CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
  [filter setValue:inputImage forKey:kCIInputImageKey];
  [filter setValue:@5.f forKey:@"inputRadius"];
  
  CIImage *result = [filter valueForKey:kCIOutputImageKey];
  CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
  
  self.blurredImage = [UIImage imageWithCGImage:cgImage];
  CGImageRelease(cgImage);
  
  self.blurImageView.image = _blurredImage;
  
  [_blurredView addSubview:_blurOverlay];
  
  [_excludedViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIView *superview = _excludedProps[idx][@"superview"];
    CGRect frame = [_excludedProps[idx][@"frame"] CGRectValue];
    UIView *v = (UIView *)obj;
    v.frame = [superview convertRect:frame toView:_blurredView];
    [_blurOverlay addSubview:v];
  }];
  
  [UIView animateWithDuration:0.3 animations:^{
    _blurOverlay.alpha = 1.f;
  }];
  
  self.blurred = YES;
}

- (void)removeBlur {
  if (!_blurred)
    return;
  [_excludedViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIView *v = (UIView *)obj;
    v.alpha = 1.f;
    UIView *superview = _excludedProps[idx][@"superview"];
    v.frame = [_excludedProps[idx][@"frame"] CGRectValue];
    [superview addSubview:v];
  }];
  [UIView animateWithDuration:0.3 animations:^{
    _blurOverlay.alpha = 0.f;
  } completion:^(BOOL finished) {
    [_blurOverlay removeFromSuperview];
    self.blurred = NO;
  }];
}

- (UIImage *)generateImageForView:(UIView *)view {
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
  else
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

@end
