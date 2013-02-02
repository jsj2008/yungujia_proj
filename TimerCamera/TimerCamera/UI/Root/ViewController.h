//
//  ViewController.h
//  TimerCamera
//
//  Created by lijinxin on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraOptions.h"
#import "AudioUtility.h"
#import "LoadingAnimateImageView.h"
#import "ShotTimer.h"
#import "CameraCoverViewController.h"

@interface ViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, AudioUtilityPlaybackDelegate, AudioUtilityVolumeDetectDelegate, LoadingAnimateImageViewDelegate, ShotTimerDelegate>
{
    NSTimer* timer;
    
    UIImageView* _picutureView;
    UIButton* _shotBtn;
    UIButton* _flashBtn;
    UIButton* _positionBtn;
    UIButton* _optionBtn;
    UIImageView* _bottomBar;
    
    NSMutableArray* _imageSaveQueue;
    
    UITapGestureRecognizer* _tapGesture;
    UIPinchGestureRecognizer* _pinchGesture;
    
    CGFloat _lastScale;
    
    CGFloat _currentScale;
    
    
    UIView* _peakView;
    UIView* _volView;
    
    LoadingAnimateImageView* _laiv;
    
    UILabel* _tipLabel;
    
    ShotTimer* _timer;
    
    CameraCoverViewController* _coverController;
}

@property (nonatomic,retain) IBOutlet CameraCoverViewController* coverController;
@property (nonatomic,retain) IBOutlet UIImageView* picutureView;
@property (nonatomic,retain) IBOutlet UIButton* shotBtn;
@property (nonatomic,retain) IBOutlet UIButton* flashBtn;
@property (nonatomic,retain) IBOutlet UIButton* positionBtn;
@property (nonatomic,retain) IBOutlet UIButton* optionBtn;
@property (nonatomic,retain) IBOutlet UIImageView* bottomBar;
@property (nonatomic,retain) IBOutlet UILabel* tipLabel;
@property (nonatomic,retain) IBOutlet UITapGestureRecognizer* tapGesture;
@property (nonatomic,retain) IBOutlet UIPinchGestureRecognizer* pinchGesture;

@property (nonatomic,retain) NSMutableArray* imageSaveQueue;
@property (nonatomic,assign) CGFloat currentScale;


@property (nonatomic,retain) IBOutlet UIView* peakView;
@property (nonatomic,retain) IBOutlet UIView* volView;



- (IBAction)OnClickedShot:(id)sender;
- (IBAction)OnClickedLight:(id)sender;
- (IBAction)OnClickedTorch:(id)sender;
- (IBAction)OnClickedFront:(id)sender;

-(IBAction)handleTapGesture:(UIGestureRecognizer*)gestureRecognizer;
-(IBAction)handlePinchGesture:(UIPinchGestureRecognizer*)gestureRecognizer;

//test Button
- (IBAction)OnClickedVolume:(id)sender;
- (IBAction)OnClickedSound:(id)sender;

//loading Animation
- (void)PrepareLoadingAnimation;
- (void)ShowLoadingAnimation;

@end