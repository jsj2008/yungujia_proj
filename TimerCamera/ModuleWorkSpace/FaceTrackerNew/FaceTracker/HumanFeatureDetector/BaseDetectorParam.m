//
//  BaseDetectorParam.m
//  FaceTracker
//
//  Created by lijinxin on 13-4-8.
//
//

#import "BaseDetectorParam.h"

@implementation BaseDetectorParam

@synthesize featureType = _featureType;
@synthesize asyncOperation = _asyncOperation;
@synthesize imageOrientationAngle = _imageOrientationAngle;

- (void)dealloc
{
    self.asyncOperation = nil;
    [super dealloc];
}

@end
