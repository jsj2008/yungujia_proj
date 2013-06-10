//
//  ViewController.h
//  VideoEffectDemo
//
//  Created by lijinxin on 13-6-1.
//  Copyright (c) 2013年 lijinxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@class EffectUIWarpper;

@interface ViewController : UIViewController
{
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *overlayImageFilter;
    GPUImageOutput<GPUImageInput> *motionDetectorFilter;
    GPUImageOutput<GPUImageInput> *effectUIFilter;
    GPUImageOutput<GPUImageInput> *startImageFilter;
    EffectUIWarpper* effectUIWarpper;
    GPUImageUIElement* uiElementInput;
    GPUImageAlphaBlendFilter *blendFilter;
    GPUImageMovieWriter *movieWriter;
    GPUImageOutput<GPUImageInput> *lastOutputFilter;
    
    BOOL _isSavingMovie;
    NSString* _movieDocPath;
    UIButton* _saveBtn;
}

- (IBAction)startSaveMovie:(id)sender;
- (IBAction)endSaveMovie:(id)sender;

@end
