//
//  ScrollViewExtended.h
//  MTV-EMAs
//
//  Created by Oli Griffiths on 15/07/2014.
//  Copyright (c) 2014 MTV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircularScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, retain) NSArray *slides;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) CGFloat slideScale;
@property (nonatomic) CGFloat pageWidth;

@property (nonatomic, readonly) NSArray *pages;
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, readonly) NSInteger centerPageIndex;

-(void)nextSlide;
-(void)nextSlide: (BOOL)animated;
-(void)prevSlide;
-(void)prevSlide: (BOOL)animate;

-(void)adjustPages;
-(NSInteger)normalizeIndex: (NSInteger)index;

@end
