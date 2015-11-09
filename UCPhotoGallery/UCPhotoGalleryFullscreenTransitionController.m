#import "UCPhotoGalleryFullscreenTransitionController.h"
#import "UCPhotoGalleryViewController.h"

@implementation UCPhotoGalleryFullscreenTransitionController

- (void)setPresentFromRect:(CGRect)presentFromRect {
    _presentFromRect = presentFromRect;
    NSLog(@"present from rect is %@", NSStringFromCGRect(presentFromRect));
    NSLog(@"");
}

- (NSTimeInterval)transitionDuration:(__unused id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.35f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context {
    UIView *containerView = [context containerView];
    UIViewController *fromController = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *shadowboxView = ({
        UIView *view = [[UIView alloc] initWithFrame:containerView.bounds];
        [containerView addSubview:view];
        view;
    });

    const BOOL isUnwinding = [toController presentedViewController] == fromController;
    const BOOL isPresenting = !isUnwinding;

    UCPhotoGalleryViewController *fullscreenGalleryController =
        (UCPhotoGalleryViewController *)(isPresenting ? toController : fromController);

    UIImageView *transitionImageView;
    CGRect startRect, endRect;
    fullscreenGalleryController.view.alpha = 0;
    if (isPresenting) {
        [containerView addSubview:fullscreenGalleryController.view];

        shadowboxView.backgroundColor = [UIColor blackColor];
        shadowboxView.alpha = 0;

        startRect = self.presentFromRect;
        endRect = [fullscreenGalleryController imageFrameInSuperview];

        transitionImageView = [[UIImageView alloc] initWithImage:self.transitionImage];
        transitionImageView.frame = startRect;
        [containerView addSubview:transitionImageView];

        [UIView animateWithDuration:[self transitionDuration:context]
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             transitionImageView.frame = endRect;
                             shadowboxView.alpha = 1;
                         } completion:^(BOOL finished) {
                             fullscreenGalleryController.view.alpha = 1;
                             [transitionImageView removeFromSuperview];
                             [shadowboxView removeFromSuperview];
                             [context completeTransition:finished];
                         }];
    } else {
        shadowboxView.backgroundColor = [fullscreenGalleryController.view backgroundColor];

        startRect = [fullscreenGalleryController imageFrameInSuperview];
        startRect = CGRectOffset(startRect, 0, [fullscreenGalleryController visibleItem].transform.ty);
        endRect = self.presentFromRect;

        transitionImageView = [[UIImageView alloc] initWithImage:self.transitionImage];
        transitionImageView.frame = startRect;
        [containerView addSubview:transitionImageView];

        [UIView animateWithDuration:[self transitionDuration:context]
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             shadowboxView.alpha = 0;
                             transitionImageView.frame = endRect;
                         }
                         completion:^(BOOL finished) {
                             [transitionImageView removeFromSuperview];
                             [shadowboxView removeFromSuperview];
                             [context completeTransition:finished];
                         }];
    }
}

@end