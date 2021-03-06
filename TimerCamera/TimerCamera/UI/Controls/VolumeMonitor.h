//
//  VolumeMonitor.h
//  TimerCamera
//
//  Created by Lee Justin on 12-11-27.
//
//

#import <UIKit/UIKit.h>
#import "CommonAnimationButton.h"
#import "SliderTouchCoverView.h"

#define VOLUME_ANIMATION_INTERVAL (0.1)

@interface VolumeMonitor : UIStateAnimationView <UIStateAnimation,SliderTouchCoverViewDelegate>
{
    CommonAnimationButton* _barButton;
    CommonAnimationButton* _stopButton;
    SliderTouchCoverView* _slideCover;
    UIImageView* _backGroudView;
    UIImageView* _volumeView;
    UIImageView* _reachedPeakView;
    UIImageView* _mouthView;
    UIImageView* _puchedPointView;
    UIView* _containerView;
    CGRect _lastFrame;
    float _currentVolume;
    float _peakVolume;
    float _minPeakVolume;
    BOOL _draging;
    BOOL _isShowNow;
}

@property (nonatomic,retain) CommonAnimationButton* barButton;
@property (nonatomic,retain) CommonAnimationButton* stopButton;
@property (nonatomic,assign) float currentVolume; //0-1.0
@property (nonatomic,assign) float peakVolume;  //0-1.0
@property (nonatomic,assign) float minPeakVolume;  //0-1.0
@property (nonatomic,assign) BOOL isShowNow;


- (id)initWithFrame:(CGRect)frame
      withBarButton:(CommonAnimationButton*)barButton
     withStopButton:(CommonAnimationButton*)stopButton
    backGroundImage:(UIImage*)bgi
        volumeImage:(UIImage*)vi
   reachedPeakImage:(UIImage*)ri
  punchedPointImage:(UIImage*)ppi
         mouthImage:(UIImage*)mi;

+ (VolumeMonitor*)monitorWithBarButton:(CommonAnimationButton*)barButton
                        withStopButton:(CommonAnimationButton*)stopButton
                       backGroundImage:(UIImage*)bgi
                           volumeImage:(UIImage*)vi
                      reachedPeakImage:(UIImage*)ri
                     punchedPointImage:(UIImage*)ppi
                            mouthImage:(UIImage*)mi;

- (void)showMonitor:(BOOL)animated;
- (void)hideMonitor:(BOOL)animated;
- (BOOL)isDragingBar;
- (void)transToMonitorState;
- (void)transToHoldingState;
- (BOOL)isMonitorState;
- (BOOL)isHoldingState;

@end
