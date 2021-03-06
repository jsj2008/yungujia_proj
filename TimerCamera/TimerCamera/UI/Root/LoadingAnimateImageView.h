//
//  LoadingAnimateImageView.h
//  TimerCamera
//
//  Created by lijinxin on 12-11-5.
//
//

#import <UIKit/UIKit.h>

@class LoadingAnimateImageView;

@protocol LoadingAnimateImageViewDelegate <NSObject>

- (void)onFinishedLoadingAnimation:(LoadingAnimateImageView*)view;

@end

@interface LoadingAnimateImageView : UIImageView
{
    id<LoadingAnimateImageViewDelegate> _loadingDelegate;
    float _animateInterval;
    float _animateScale;
    CGRect _rawFrame;
    UIImageView* _preloadView;
    float _preloadAnimateInterval;
}

@property (nonatomic,assign) id<LoadingAnimateImageViewDelegate> loadingDelegate;
@property (nonatomic,assign) float animateInterval;
@property (nonatomic,assign) float animateScale;
@property (nonatomic,assign) float preloadAnimateInterval;

+ (LoadingAnimateImageView*)viewWithDelegate:(id<LoadingAnimateImageViewDelegate>)del
                                       image:(UIImage*)img
                             forTimeInterval:(float)seconds
                                preLoadImage:(UIImage*)pimg
                   forPreloadAnimateInterval:(float)pSeconds;

- (void)startPreloadingAnimation;
- (void)startLoadingAnimation;


@end
