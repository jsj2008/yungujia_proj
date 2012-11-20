//
//  CommonAnimationButton.h
//  TimerCamera
//
//  Created by Lee Justin on 12-11-20.
//
//

#import <UIKit/UIKit.h>
#import "AlphaAnimationView.h"

@interface CommonAnimationButton : UIStateAnimationView
{
    UIButton* _button;
    AlphaAnimationView* _normalView;
    AlphaAnimationView* _enabledView;
    UIImageView* _pressedView;
    BOOL _buttonEnabled;
}

@property (nonatomic,assign,readonly) UIButton* button;
@property (nonatomic,assign) BOOL buttonEnabled;

- (id)initWithFrame:(CGRect)frame
    forNormalImage1:(UIImage*)ni1
    forNormalImage2:(UIImage*)ni2
    forPressedImage:(UIImage*)pi
   forEnabledImage1:(UIImage*)ei1
   forEnabledImage2:(UIImage*)ei2;

+ (CommonAnimationButton*)buttonWithPressedImageSizeforNormalImage1:(UIImage*)ni1
                                                    forNormalImage2:(UIImage*)ni2
                                                    forPressedImage:(UIImage*)pi
                                                   forEnabledImage1:(UIImage*)ei1
                                                   forEnabledImage2:(UIImage*)ei2;

@end