//
// Created by Joshua Sullivan on 3/19/15.
// Copyright (c) 2015 Joshua Sullivan. All rights reserved.
//

#import "ExtraFancyTransitionAnimator.h"
@import CoreImage;
@import GLKit;
#import "JTSTweener.h"
#import "JTSEaseQuadratic.h"

@interface ExtraFancyTransitionAnimator ()

@property (strong, nonatomic) CIContext *context;
@property (strong, nonatomic) CIFilter *modFilter;

@end

@implementation ExtraFancyTransitionAnimator

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.context = [CIContext contextWithEAGLContext:eaglContext];
    self.modFilter = [CIFilter filterWithName:@"CIModTransition"];
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = fromController.view;

    // Draw a bitmap of the view.
    UIGraphicsBeginImageContextWithOptions(fromView.bounds.size, NO, 0);
    [fromView drawViewHierarchyInRect:fromView.bounds afterScreenUpdates:YES];
    UIImage *fromImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Create the from CIImage and add it to the filter
    CIImage *ciFromImage = [CIImage imageWithCGImage:fromImage.CGImage];
    [self.modFilter setValue:ciFromImage forKey:kCIInputImageKey];

    // Calculate the center point of the effect and set it to the filter.
    CGFloat centerX = CGRectGetMidX(fromView.bounds);
    CGFloat centerY = CGRectGetMidY(fromView.bounds);
    [self.modFilter setValue:[CIVector vectorWithX:centerX Y:centerY] forKey:kCIInputCenterKey];

    // This is a hack, but if we don't wait until the next run loop, the toView will always be empty.
    [self performSelector:@selector(actuallyDoTransition:) withObject:transitionContext afterDelay:0.0];
}

- (void)actuallyDoTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // Get the view controllers and their views from the transitionContext.
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toViewController.view;
    
    // Set up the toView
    toView.frame = fromController.view.frame;
    
    // Get the duration for the animation.
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    // Draw the toView to a bitmap.
    UIGraphicsBeginImageContextWithOptions(toView.bounds.size, NO, 0);
    [toView drawViewHierarchyInRect:toView.bounds afterScreenUpdates:YES];
    UIImage *toImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Create CIImage for toView and set it on the filter
    CIImage *ciToImage = [CIImage imageWithCGImage:toImage.CGImage];
    [self.modFilter setValue:ciToImage forKey:kCIInputTargetImageKey];

    // Store the bounds of the effect.
    CGRect rect = [ciToImage extent];

    // Create and add the UIImageView which will display the intermediate animation frames.
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = toView.frame;
    [transitionContext.containerView addSubview:imageView];
    
    // Remove the fromView since it is no longer needed.
    [fromController.view removeFromSuperview];

    // Let the wild rumpus begin!
    [JTSTweener tweenerWithDuration:duration
                      startingValue:0.0f
                        endingValue:1.0f
                        easingCurve:[JTSEaseQuadratic easeInOut]
                            options:nil
                      progressBlock:^(JTSTweener *tween, CGFloat value, NSTimeInterval elapsedTime) {
                          
                          // Set the current time to the filter
                          [self.modFilter setValue:@(value) forKey:kCIInputTimeKey];
                          
                          // Render the output of the filter and set it to the image view.
                          CGImageRef imageRef = [self.context createCGImage:self.modFilter.outputImage fromRect:rect];
                          imageView.image = [UIImage imageWithCGImage:imageRef];
                          
                          // Clean up the CGImageRef or we'll have a memory leak.
                          CGImageRelease(imageRef);
                      }
                    completionBlock:^(JTSTweener *tween, BOOL completedSuccessfully) {
                        // Add the to view and remove the image view.
                        [transitionContext.containerView addSubview:toView];
                        [imageView removeFromSuperview];
                        
                        // Complete the transition.
                        [transitionContext completeTransition:YES];
                    }];
}


@end