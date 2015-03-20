//
//  ViewController.m
//  Animated Transition Demo
//
//  Created by Joshua Sullivan on 3/19/15.
//  Copyright (c) 2015 Joshua Sullivan. All rights reserved.
//

#import "RootViewController.h"
#import "PushTransitionAnimator.h"
#import "PopTransitionAnimator.h"
#import "ExtraFancyTransitionAnimator.h"

static NSString * const kContainmentSegueIdentifier = @"kContainmentSegueIdentifier";

@interface RootViewController () <UINavigationControllerDelegate>

@property (strong, nonatomic) PushTransitionAnimator *pushAnimator;
@property (strong, nonatomic) PopTransitionAnimator *popAnimator;
@property (strong, nonatomic) ExtraFancyTransitionAnimator *fancyAnimator;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Animators can be reused, so we'll just create them up front.
    self.pushAnimator = [PushTransitionAnimator new];
    self.popAnimator = [PopTransitionAnimator new];
    self.fancyAnimator = [ExtraFancyTransitionAnimator new];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Use the embed segue to add this class as the Navigation Controller's delegate.
    if ([segue.identifier isEqualToString:kContainmentSegueIdentifier]) {
        ((UINavigationController *)segue.destinationViewController).delegate = self;
    }
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    // Check if this is a push or a pop and return the appropriate animator.
    if (operation == UINavigationControllerOperationPush) {
        // You can return self.fancyAnimator here instead. WARNING: Don't try that in the simulator.
        return self.pushAnimator;
    } else if (operation == UINavigationControllerOperationPop) {
        return self.popAnimator;
    }
    // Returning nil invokes the default animation, which is what we'll do
    // if we aren't doing a push or pop.
    return nil;
}


@end
