//
//  ScrollViewExtended.m
//  MTV-EMAs
//
//  Created by Oli Griffiths on 15/07/2014.
//  Copyright (c) 2014 MTV. All rights reserved.
//

#import "CircularScrollView.h"

@interface CircularScrollView ()

@property (nonatomic) NSInteger prevPage;

@end

@implementation CircularScrollView

-(id)init
{
    self = [super init];
    [self setup];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

-(void)setup
{
    _pages = [NSMutableArray new];
    self.contentSize = self.contentSize;
    [self buildPages];
    [self positionSlides];
    
    [self.panGestureRecognizer setMinimumNumberOfTouches:1];
    [self.panGestureRecognizer setMaximumNumberOfTouches:1];
}

//Enable dragging on buttons
-(BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}

//Make touch area available outside of scroll view
- (BOOL)pointInside:(CGPoint) point withEvent:(UIEvent *) event
{
    return CGRectContainsPoint(CGRectMake(-self.frame.origin.x,0, self.contentSize.width + self.frame.origin.x*2, self.frame.size.height), point);
}

-(NSInteger)currentPage
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.frame.size.width;
    int page = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    return page;
}

-(void)setCurrentIndex:(NSInteger)currentIndex
{
    BOOL isNew = currentIndex != self.currentIndex;
    
    _currentIndex = currentIndex;
    
    if(isNew){
        [self positionSlides];
    }
}

-(NSInteger)centerPageIndex
{
    return floor(self.pages.count/2);
}

-(void)nextSlide
{
    [self nextSlide: YES];
}

-(void)nextSlide: (BOOL)animated
{
    [self setContentOffset:CGPointMake(self.contentOffset.x + self.bounds.size.width, self.contentOffset.y) animated:animated];
}

-(void)prevSlide
{
    [self prevSlide: YES];
}

-(void)prevSlide: (BOOL)animated
{
    [self setContentOffset:CGPointMake(self.contentOffset.x - self.bounds.size.width, self.contentOffset.y) animated:animated];
}

//Builds the page containers
-(void)buildPages
{
    for(int i = 0; i < 5; i++)
    {
        UIView *page = [[UIView alloc] initWithFrame:CGRectMake(i * self.bounds.size.width,0,self.bounds.size.width, self.bounds.size.height)];
        page.tag = i+1;
        page.clipsToBounds = NO;

        [self addSubview:page];
        [((NSMutableArray*) _pages) addObject:page];
    }
    
    [self bringSubviewToFront: self.pages[self.centerPageIndex-1]];
    [self bringSubviewToFront: self.pages[self.centerPageIndex+1]];
    [self bringSubviewToFront: self.pages[self.centerPageIndex]];
    
    [self setContentOffset:CGPointMake([self offsetForPage:2], 0)];
}

//Resizes pages
-(void)resizePages
{
    int i = 0;
    for(UIView *page in self.pages)
    {
        page.frame = CGRectMake(i * self.bounds.size.width,0,self.bounds.size.width, self.bounds.size.height);
        i++;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self resizePages];
}

//When setting new slides, reset the view
-(void)setSlides:(NSArray *)slides
{
    _slides = slides;
    [self reset];
    [self positionSlides];
    [self setContentOffset:CGPointMake([self offsetForPage:2], 0)];
}

//Force content size to always be 5 pages worth
-(CGSize)contentSize
{
    return CGSizeMake(self.frame.size.width * 5, self.frame.size.height);
}

-(void)setContentSize:(CGSize)contentSize
{
    [super setContentSize: CGSizeMake(self.frame.size.width * 5, self.frame.size.height)];
}

//Resets to the center page
-(void)reset
{
    if(self.currentIndex != 0){
        self.currentIndex = 0;
        [self setContentOffset:CGPointMake([self offsetForPage:2], 0)];
    }
    
    [self setContentOffset: self.contentOffset];
}

//Positions slides in the correct page according to the current index
-(void)positionSlides
{
    if(self.slides.count == 0) return;
    
    [self.slides makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for(int i = 0; i < 5; i++)
    {
        NSInteger index = i + self.currentIndex - self.centerPageIndex;
        if(index < 0) index = self.slides.count + index;
        
        index = index % self.slides.count;
        
        UIView *page = self.pages[i];
        UIView *slide = self.slides[index];
        
        [page addSubview:slide];
    }
}

//Returns the slide index for the given page
-(NSInteger)indexForPage: (NSInteger)page
{
    if(!self.slides.count) return 0;
    
    NSInteger index = page + self.currentIndex - self.centerPageIndex;
    if(index < 0) index = self.slides.count + index;
    
    return index % self.slides.count;
}

//Returns the offset for the given page
-(CGFloat)offsetForPage:(NSInteger)page
{
    return page * self.frame.size.width;
}

//Return the normalized index
-(NSInteger)normalizeIndex: (NSInteger)index
{
    if(!self.slides.count) return 0;
    
    index = index % self.slides.count;
    return index < 0 ? index + self.slides.count : index;
}

//When setting frame, ensure we re-position on center page
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self setContentOffset:CGPointMake([self offsetForPage:self.centerPageIndex], 0)];
}

//Overridden setContentOffset to re-position the offset as it crosses the center page boundry either left or right to always be positioned on the center page
-(void)setContentOffset:(CGPoint)contentOffset
{
    //Only change the offset if it's to page 1-3
    if(contentOffset.x < self.bounds.size.width*(self.centerPageIndex-1) || contentOffset.x > self.bounds.size.width*(self.centerPageIndex+1)) return;
    
    //Set super
    [super setContentOffset:contentOffset];
    
    //Adjust the pages to ensure we're on the center
    [self adjustPages];
}

//Adjusts the content offset whilst scrolling to keep the center slide always in the center
-(void)adjustPages
{
    if(self.prevPage == self.currentPage) return;
    
    //If transitioning to previous or next page, reposition pages
    if(self.currentPage == (self.centerPageIndex-1) || self.currentPage == (self.centerPageIndex+1)){
        
        //Set the new index and reposition slides according to that index
        self.currentIndex = [self indexForPage:self.currentPage];
        
        //Move the current offset to the current plus or minus a page width depending upon direction
        CGFloat width = self.bounds.size.width;
        CGFloat newOffset = self.contentOffset.x + (self.currentPage == self.centerPageIndex-1 ? width : -width);
        
        self.contentOffset = CGPointMake(newOffset, self.contentOffset.y);
    }
    
    self.prevPage = self.currentPage;
}

@end
