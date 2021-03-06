//
//  CameraOptions.m
//  TimerCamera
//
//  Created by Lee Justin on 12-9-10.
//
//

#import "CameraOptions.h"

#pragma mark - UIImagePickerController Debugger

@interface DebugImagePickerController : UIImagePickerController

@end

@implementation DebugImagePickerController

- (id)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end

#pragma mark - CameraOptions

#define ConfigurableDevicePosition AVCaptureDevicePositionBack//AVCaptureDevicePositionFront

static CameraOptions* gSI = nil;

@implementation CameraOptions

@synthesize imagePicker = _imagePicker;
@synthesize light = _light;
@synthesize flash = _flash;
@synthesize focus = _focus;
@synthesize enableHDR = _enableHDR;
@synthesize exposureMode = _exposureMode;
@synthesize exporePoint = _exporePoint;
@synthesize focusPoint = _focusPoint;
@synthesize isFlashAndLightAvailible = _isFlashAndLightAvailible;
@synthesize maxScale = _maxScale;
@synthesize minScale = _minScale;

#pragma mark - NSObject

- (id)init
{
    self = [super init];
    if (self) {
        //
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]
            || [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
        {
            UIImagePickerController *ipc = [[[DebugImagePickerController alloc] init] autorelease];
            ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
            ipc.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            ipc.showsCameraControls = NO;
            
            self.imagePicker = ipc;
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        }
        
        _maxScale = 50.f;
        _minScale = 1.f;
    }
    return self;
}

- (void)dealloc
{
    [self removeAllObservers];
    [self.imagePicker.view removeFromSuperview];
    self.imagePicker = nil;
    [super dealloc];
}

#pragma mark - CameraOptions

+(CameraOptions*)sharedInstance
{
    if (gSI == nil)
    {
        gSI = [[CameraOptions alloc] init];
        [gSI restoreState];
    }
    return gSI;
}

+(void)resetSharedInstance
{
    if (gSI)
    {
        ReleaseAndNil(gSI);
    }
}

-(void)restoreState
{
    //gSI.light = getConfigForInt(kLight);
    //gSI.flash = getConfigForInt(kFlashMode);
    //gSI.focus = getConfigForInt(kFocus);
    gSI.enableHDR = getConfigForInt(kHDR);
    //gSI.exposureMode = getConfigForInt(kExposure);
}

- (AVCaptureDevice*)configurableDevice
{
    AVCaptureDevice* d = nil;
    NSArray* allDevices = [AVCaptureDevice devices];
    for (AVCaptureDevice* currentDevice in allDevices) {
        if (currentDevice.position == ConfigurableDevicePosition)
        {
            d = currentDevice;
        }
    }
    
    return d;
}

-(AVCaptureDevice*)currentDevice
{
    AVCaptureDevice* d = nil;
    
    // find a device by position
    NSArray* allDevices = [AVCaptureDevice devices];
    AVCaptureDevicePosition pos = UIImagePickerControllerCameraDeviceFront;
    if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceRear)
    {
        pos = AVCaptureDevicePositionBack;
    }
    if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        pos = AVCaptureDevicePositionFront;
    }
    for (AVCaptureDevice* currentDevice in allDevices) {
        if (currentDevice.position == pos)
        {
            d = currentDevice;
        }
    }
    
    return d;
}

- (void)setValuesForExporePoint:(CGPoint)exporePoint focusPoint:(CGPoint)focusPoint
{
    AVCaptureDevice* d = [self currentDevice];
    
    NSError* err = nil;
    BOOL lockAcquired = [d lockForConfiguration:&err];
    
    if (!lockAcquired) {
        // log err and handle...
    } else {
        
        [self setFocusPointWithoutLock:focusPoint device:d];
        [self setExporePointWithoutLock:exporePoint device:d];
        
        [d unlockForConfiguration];
    }
}

#pragma mark - Property Re-defines

- (BOOL)isFlashAndLightAvailible
{
    if ([self currentDevice] != [self configurableDevice])
    {
        _isFlashAndLightAvailible = NO;
    }
    else
    {
        _isFlashAndLightAvailible = YES;
    }
    return _isFlashAndLightAvailible;
}

- (AVCaptureTorchMode)light
{
    AVCaptureDevice* d = nil;
    if (self.isFlashAndLightAvailible)
    {
        d = [self currentDevice];
    }
    else
    {
        d = [self configurableDevice];
    }
    _light = d.torchMode;
    return _light;
}

- (void)setLight:(AVCaptureTorchMode)mode
{
    AVCaptureDevice* d = nil;
    if (self.isFlashAndLightAvailible)
    {
        d = [self currentDevice];
    }
    else
    {
        mode = AVCaptureTorchModeOff;
        d = [self configurableDevice];
    }
    
    NSError* err = nil;
    BOOL lockAcquired = [d lockForConfiguration:&err];
    
    if (!lockAcquired) {
        // log err and handle...
    } else {
        // set the torch mode
        if ([d hasTorch])
        {
            [d setTorchMode:mode];
        }
        
        [d unlockForConfiguration];
    }
    _light = d.torchMode;
    
    setAndSaveConfigForInt(kLight, _light);
}

- (AVCaptureFlashMode)flash
{
    AVCaptureDevice* d = nil;
    if (self.isFlashAndLightAvailible)
    {
        d = [self currentDevice];
    }
    else
    {
        d = [self configurableDevice];
    }
    _flash = d.flashMode;
    return _flash;
}

- (void)setFlash:(AVCaptureFlashMode)flash
{
    AVCaptureDevice* d = nil;
    if (self.isFlashAndLightAvailible)
    {
        d = [self currentDevice];
    }
    else
    {
        flash = AVCaptureFlashModeOff;
        d = [self configurableDevice];
    }
    
    //BOOL avaliable = d.connected;
    
    NSError* err = nil;
    BOOL lockAcquired = [d lockForConfiguration:&err];
    
    if (!lockAcquired) {
        // log err and handle...
    } else {
        // set the flash mode
        if ([d hasFlash])
        {
            [d setFlashMode:flash];
        }
        
        [d unlockForConfiguration];
    }
    _flash = d.flashMode;
    
    setAndSaveConfigForInt(kFlashMode, _flash);
}


- (void)setFocus:(AVCaptureFocusMode)focus
{
    AVCaptureDevice* d = [self currentDevice];
    
    if (_lastDeviceObserverForFocusMode)
    {
        [_lastDeviceObserverForFocusMode removeObserver:self forKeyPath:@"focusMode"];
    }
    _lastDeviceObserverForFocusMode = d;
    [d addObserver:self forKeyPath:@"focusMode" options:(NSKeyValueObservingOptionNew |
                                                         NSKeyValueObservingOptionOld) context:self];
    
    NSError* err = nil;
    BOOL lockAcquired = [d lockForConfiguration:&err];
    
    if (!lockAcquired) {
        // log err and handle...
    } else {
        if ([d isFocusModeSupported:focus])
        {
            [d setFocusMode:focus];
        }
        
        [d unlockForConfiguration];
    }
    _focus = d.focusMode;
    
    //setAndSaveConfigForInt(kFocus, _focus);
}

- (void)setExposureMode:(AVCaptureExposureMode)exposureMode
{
    AVCaptureDevice* d = [self currentDevice];
    
    if (_lastDeviceObserverForExpoureMode)
    {
        [_lastDeviceObserverForExpoureMode removeObserver:self forKeyPath:@"exposureMode"];
    }
    _lastDeviceObserverForExpoureMode = d;
    [d addObserver:self forKeyPath:@"exposureMode" options:(NSKeyValueObservingOptionNew |
                                                            NSKeyValueObservingOptionOld) context:self];
    
    
    NSError* err = nil;
    BOOL lockAcquired = [d lockForConfiguration:&err];
    
    if (!lockAcquired) {
        // log err and handle...
    } else {
        if ([d isExposureModeSupported:exposureMode])
        {
            [d setExposureMode:exposureMode];
        }
        
        [d unlockForConfiguration];
    }
    _exposureMode = d.exposureMode;
    
    //setAndSaveConfigForInt(kExposure, _light);
}

- (void)setExporePoint:(CGPoint)exporePoint
{
    [self setExposureMode:AVCaptureExposureModeLocked];
    AVCaptureDevice* d = [self currentDevice];
    
    NSError* err = nil;
    BOOL lockAcquired = [d lockForConfiguration:&err];
    
    if (!lockAcquired) {
        // log err and handle...
    } else {
        
        [self setExporePointWithoutLock:exporePoint device:d];
        
        [d unlockForConfiguration];
    }
}

- (void)setFocusPoint:(CGPoint)focusPoint
{
    [self setFocus:AVCaptureFocusModeAutoFocus];
    AVCaptureDevice* d = [self currentDevice];
    
    NSError* err = nil;
    BOOL lockAcquired = [d lockForConfiguration:&err];
    
    if (!lockAcquired) {
        // log err and handle...
    } else {
        
        [self setFocusPointWithoutLock:focusPoint device:d];
        
        [d unlockForConfiguration];
    }
}

-(void)setEnableHDR:(BOOL)enableHDR
{
    AVCaptureDevice* d = [self currentDevice];
    
    NSError* err = nil;
    BOOL lockAcquired = [d lockForConfiguration:&err];
    
    if (!lockAcquired) {
        // log err and handle...
    } else {
        if (!enableHDR)
        {
            [d setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
        }
        else
        {
            if ([d isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
            {
                [d setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            }
            else if ([d isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance])
            {
                [d setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
            }
            else
            {
                enableHDR = NO;
            }
        }
        
        _enableHDR = enableHDR;
        
        [d unlockForConfiguration];
    }
    
    setAndSaveConfigForInt(kHDR, _enableHDR);
}

#pragma mark Private Methods

- (void)removeAllObservers
{
    if (_lastDeviceObserverForFocusMode)
    {
        [_lastDeviceObserverForFocusMode removeObserver:self forKeyPath:@"focusMode"];
        _lastDeviceObserverForFocusMode = nil;
    }
    if (_lastDeviceObserverForExpoureMode)
    {
        [_lastDeviceObserverForExpoureMode removeObserver:self forKeyPath:@"exposureMode"];
        _lastDeviceObserverForExpoureMode = nil;
    }
}

- (void)setExporePointWithoutLock:(CGPoint)exporePoint device:(AVCaptureDevice*)d
{
    if (d.exposurePointOfInterestSupported)
    {
        _exporePoint = exporePoint;
        d.exposurePointOfInterest = _exporePoint;
        if([d isExposureModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        {
            d.exposureMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        else if ([d isExposureModeSupported:AVCaptureFocusModeAutoFocus])
        {
            d.exposureMode = AVCaptureFocusModeAutoFocus;
        }
        else if ([d isExposureModeSupported:AVCaptureFocusModeLocked])
        {
            d.exposureMode = AVCaptureFocusModeLocked;
        }
            
    }
}

- (void)setFocusPointWithoutLock:(CGPoint)focusPoint device:(AVCaptureDevice*)d
{
    if (d.focusPointOfInterestSupported && !d.adjustingFocus)
    {
        _focusPoint = focusPoint;
        d.focusPointOfInterest = _focusPoint;
        if ([d isFocusModeSupported:AVCaptureFocusModeAutoFocus])
        {
            d.focusMode = AVCaptureFocusModeAutoFocus;
        }
        else if ([d isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        {
            d.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        else if ([d isFocusModeSupported:AVCaptureFocusModeLocked])
        {
            d.focusMode = AVCaptureFocusModeLocked;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == self)
    {
        if ([keyPath isEqualToString:@"exposureMode"])
        {
            NSNumber* newExposureMode = [change objectForKey:NSKeyValueChangeNewKey];
            NSNumber* oldExposureMode = [change objectForKey:NSKeyValueChangeOldKey];
            NSLog(@"(*)ExposureMode changed %d to %d(*)",[oldExposureMode intValue],[newExposureMode intValue]);
        }
        else if ([keyPath isEqualToString:@"focusMode"])
        {
            NSNumber* newFocusMode = [change objectForKey:NSKeyValueChangeNewKey];
            NSNumber* oldFocusMode = [change objectForKey:NSKeyValueChangeOldKey];
            NSLog(@"(0|0)FocusMode changed %d to %d(0|0)",[oldFocusMode intValue],[newFocusMode intValue]);
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
