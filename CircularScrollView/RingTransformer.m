//
//  RingScrollView.m
//  MTV-EMAs
//
//  Created by Oli Griffiths on 28/07/2014.
//  Copyright (c) 2014 MTV. All rights reserved.
//

#import "RingScrollView.h"

@implementation RingScrollView


-(void)adjustPages
{
    [super adjustPages];
    
    if(!self.slides.count) return;
    
    NSInteger currentIndex = self.currentIndex;
    
    //Scale active slide
    CGFloat scroll = self.contentOffset.x;
    CGFloat halfWidth = self.frame.size.width / 2;
    CGFloat centerPoint = halfWidth + scroll;
    CGFloat threshold = self.bounds.size.width / 2;
    
    //Loop the pages, and size/position the slide according to its position
    for(int i = 0; i < self.pages.count; i++){
        
        //Calculate the index for the slide, if current index is 4, the first slide will be 2, as there are 5 pages
        NSInteger index = (currentIndex - self.centerPageIndex + i);
        if(index < 0) index = self.slides.count + index;
        index = index % self.slides.count;
        
        //Get the slide and page for the current index
        UIView *slide  = self.slides[index];
        UIView *page = self.pages[i];
        
        //Calculate the pages position from the center point
        CGFloat diff = centerPoint - page.center.x;
        
        //Determine if the direction is left or right
        CGFloat isRight = diff < 0;
        
        //Calculate the percentage difference the page is between the center point and the edge (threshold)
        CGFloat percentage = (isRight ? diff * -1 : diff) / (threshold*2);
        
        //Calculate the scale based on the above percentage
        CGFloat scale = self.slideScale + ((1 - self.slideScale) * (1 - percentage));
        CGAffineTransform scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        
        //Move transform moves the slide to make it appear that it's going in a circular motion
        CGAffineTransform moveTransform;
        
        //Move by up to 1/2 the scroll view with, and use a multiplier to modify, 1.3 is a trial an error value
        CGFloat moveAmount = self.bounds.size.width / 2 * 1.3;
        
        //If the slide is beyond the threshold (the edge) then we move it back towards the center
        if(diff > threshold || diff < -threshold){
            
            percentage = ((isRight ? diff * -1 : diff) - threshold) / threshold;
            moveTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, percentage * (isRight ? -moveAmount :moveAmount), 0);
        }else{
            //Else clear the transform, the slide is in the middle
            moveTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
            [self bringSubviewToFront:page];
        }
        
        //Set the slide alpha relative to scale
        slide.alpha = scale;
        
        //Apply scale and move transform
        slide.transform = CGAffineTransformConcat(scaleTransform, moveTransform);
    }
}
@end
