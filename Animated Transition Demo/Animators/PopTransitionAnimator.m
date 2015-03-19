//
// Created by Joshua Sullivan on 3/19/15.
// Copyright (c) 2015 Joshua Sullivan. All rights reserved.
//

#import "PopTransitionAnimator.h"

@interface PopTransitionAnimator ()

@end

@implementation PopTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // Get the to and from view controllers and their views.
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromController.view;
    UIView *toView = toViewController.view;

    // Get the duration for the animation.
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    // We'll give half of the overall animation duration to each of the views.
    NSTimeInterval halfDuration = duration / 2.0;

    // Set up the 3D rotation transforms
    CATransform3D fromTransform = CATransform3DMakeRotation((CGFloat)M_PI_2, 0.0f, 1.0f, 0.0f);
    CATransform3D toTransform = CATransform3DMakeRotation((CGFloat)-M_PI_2, 0.0f, 1.0f, 0.0f);

    // Ensure that the view we're transitioning to is the same size as the one we're leaving.
    toView.frame = fromView.frame;
    toView.layer.transform = toTransform;
    toView.hidden = YES;
    
    // IMPORTANT STEP!
    // Add the destination view to the context's containerView.
    [transitionContext.containerView addSubview:toView];

    // Animate the old view out.
    [UIView animateWithDuration:halfDuration
                     animations:^{
                        fromView.layer.transform = fromTransform;
                     }
                     completion:^(BOOL finished) {
                         [fromView removeFromSuperview];
                         fromView.layer.transform = CATransform3DIdentity;
                         toView.hidden = NO;
                     }];

    // Animate the new view in.
    [UIView animateKeyframesWithDuration:halfDuration
                                   delay:halfDuration
                                 options:0
                              animations:^{
                                  toView.layer.transform = CATransform3DIdentity;
                              }
                              completion:^(BOOL finished) {
                                  // IMPORTANT STEP!
                                  // When all the animation is complete, indicate that the transition is complete.
                                  [transitionContext completeTransition:YES];
                              }];
}


@end