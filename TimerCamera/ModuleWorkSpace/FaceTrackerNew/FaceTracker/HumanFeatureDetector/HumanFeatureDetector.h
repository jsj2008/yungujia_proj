//
//  HumanFeatureDetecor.h
//  FaceTracker
//
//  Created by lijinxin on 13-4-5.
//
//

#import <Foundation/Foundation.h>
#import "DetectedHumanFeatures.h"

@class HumanFeatureDetector;

@protocol HumanFeatureDetectorDelegate <NSObject>

- (void)onDetectedFeature:(DetectedHumanFeatures*)feature
              forDetector:(HumanFeatureDetector*)detector;
- (void)onStarted:(HumanFeatureDetector*)detector;
- (void)onCancelledWithFeature:(DetectedHumanFeatures*)feature
                   forDetector:(HumanFeatureDetector*)detector;
- (void)onFinishedWithFeature:(DetectedHumanFeatures*)feature
                  forDetector:(HumanFeatureDetector*)detector ;

@end

@interface HumanFeatureDetector : NSObject
{
    NSOperationQueue* _queue;
    
}

+ (HumanFeatureDetector*)sharedInstance;
- (id)initWithCascadeXmlsDir:(NSString*)dir;
- (BOOL)startAsyncDetection:(UIImage*)image forDelegate:(id<HumanFeatureDetectorDelegate>)delegate;
- (void)cancelAsyncDetection;
- (BOOL)isAsyncDetecting;
- (BOOL)syncDetect:(UIImage*)image forDelegate:(id<HumanFeatureDetectorDelegate>)delegate;

@end
