//
//  TDBlurView.h
//  TDBlurView
//
//  Created by timominous on 4/10/14.
//  Copyright (c) 2014 timominous. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDBlurView : NSObject

@property (strong, nonatomic) UIView *blurredView;
@property (strong, nonatomic) NSArray *excludedViews;
@property (nonatomic) CGSize size;

- (id)initWithBlurredView:(UIView *)blurredView;

- (void)blur;
- (void)removeBlur;

@end
