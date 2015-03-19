//
// Created by Joshua Sullivan on 3/19/15.
// Copyright (c) 2015 Joshua Sullivan. All rights reserved.
//

#import "PushTransitionAnimator.h"

@interface PushTransitionAnimator ()

@end

@implementation PushTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // You could examine the view controllers in the transitioningContext to allow different amounts of time
    // for different transition animations. For the purposes of this demo, it is a fixed duration.
    return 0.4;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // Get the view controllers and their views from the transitionContext.
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromController.view;
    UIView *toView = toViewController.view;

    // Get the duration for the animation.
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    // We'll allocate half of our time to the zoom out and the other half to the zoom in.
    NSTimeInterval halfDuration = duration / 2.0;

    // This is the transform we'll use to zoom our views.
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.1f, 0.1f);

    // Set the destination view to the same size as the starting view.
    toView.frame = fromView.frame;
    
    // Set up the destination view for animation.
    toView.alpha = 0.0f;
    toView.transform = scaleTransform;
    
    // IMPORTANT STEP!
    // Add the toView to the containerView. fromView is already in it.
    [transitionContext.containerView addSubview:toView];

    // Shrink and fade out the from view.
    [UIView animateWithDuration:halfDuration animations:^{
        fromView.alpha = 0.0f;
        fromView.transform = scaleTransform;
    } completion:^(BOOL finished) {
        // Remember to "clean up" your views afterwards or you'll get a nasty surprise
        // the next time you try to place them on screen!
        [fromView removeFromSuperview];
        fromView.alpha = 1.0f;
        fromView.transform = CGAffineTransformIdentity;
    }];

    // Expand and fade in the to view.
    [UIView animateKeyframesWithDuration:halfDuration
                                   delay:halfDuration
                                 options:0
                              animations:^{
                                  toView.alpha = 1.0f;
                                  toView.transform = CGAffineTransformIdentity;
                              }
                              completion:^(BOOL finished) {
                                  // IMPORTANT STEP!
                                  // Let the transitionContext know that we've successfully animated the transition.
                                  [transitionContext completeTransition:YES];
                              }];
}


@end