//
//  HumanFeatureDetector.m
//  FaceTracker
//
//  Created by lijinxin on 13-4-5.
//
//

#import <CoreImage/CoreImage.h>
#import "HumanFeatureDetector.h"
#import "UIImage+OpenCV.h"
#import "HaarDetectorParam.h"
#import "CIDetectorParam.h"
#include <sys/time.h>
#include <unistd.h>

static long long getTimeInMicrosecond()
{
	long long timebysec = 0;
	struct timeval tv;
	if(gettimeofday(&tv,NULL)!=0)
		return 0;
	timebysec +=  (long long)tv.tv_sec * 1000000;
	timebysec += tv.tv_usec ;
	return timebysec;
}


#define kHumanFeatureDetectionQueue @"HumanFeatureDetectionQueue"
#define kFeatureKey(x) [NSString stringWithFormat:@"%d",(x)]
#define kScaleToWidth (-1)

@interface HumanFeatureDetector (Tasks)

- (void)taskStart;
- (void)taskInitHaarcascades;
- (void)taskDoHaarDetection:(HaarDetectorParam*)param;
- (void)taskDoCIDetectorDetection:(CIDetectorParam*)param;
- (void)taskHandleDetectedResult;

@end

@interface HumanFeatureDetector (InnerMethods)

- (BOOL)detectHumanFeature:(UIImage*)image
               forDelegate:(id<HumanFeatureDetectorDelegate>)delegate
               shouldAsync:(BOOL)async;

@end

#pragma mark - HumanFeatureDetecor

static HumanFeatureDetector* gDetector = nil;
static NSMutableArray* gStatusNameTable = nil;

@implementation HumanFeatureDetector

#pragma mark Public Methods

+ (HumanFeatureDetector*)sharedInstance
{
    if (gDetector == nil)
    {
        gDetector = [[HumanFeatureDetector alloc] initWithCascadeXmlsDir:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/"]];
    }
    return gDetector;
}

- (id)initWithCascadeXmlsDir:(NSString*)dir
{
    self = [self init];
    if (self)
    {
        //
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:1];
        [_queue setName:kHumanFeatureDetectionQueue];
        _xmlDir = [dir retain];
        _statusRecords = [[NSMutableArray array] retain];
        [self changeCurrentStatusTo:kHFDStatusStopped];
    }
    return self;
}

- (void)dealloc
{
    //
    [self cancelAsyncDetection];
    [self releaseAllResources];
    ReleaseAndNil(_queue);
    ReleaseAndNil(_statusRecords);
    [super dealloc];
}

- (BOOL)startAsyncDetection:(UIImage*)image forDelegate:(id<HumanFeatureDetectorDelegate>)delegate
{
    return [self detectHumanFeature:image
                        forDelegate:delegate
                        shouldAsync:YES];
}

- (void)cancelAsyncDetection
{
    if (!_isDetecting || _isCancelled)
    {
        return;
    }
    _isCancelled = YES;
    [_queue cancelAllOperations];
}

- (BOOL)isAsyncDetecting
{
    return _isDetecting;
}

- (BOOL)syncDetect:(UIImage*)image forDelegate:(id<HumanFeatureDetectorDelegate>)delegate
{
    return [self detectHumanFeature:image
                        forDelegate:delegate
                        shouldAsync:NO];
}

- (NSString*)getStatePathString;
{
    if (gStatusNameTable == nil)
    {
#define TABLE_ADD_STATE(x) gStatusNameTable[x]=@"["#x"]"
        gStatusNameTable = [[NSMutableArray array] retain];
        TABLE_ADD_STATE(kHFDStatusStopped);
        TABLE_ADD_STATE(kHFDStatusStarting);
        TABLE_ADD_STATE(kHFDStatusTaskInited);
        TABLE_ADD_STATE(kHFDStatusUnConfirmOriginal);
        TABLE_ADD_STATE(kHFDStatusUnConfirmRotated);
        TABLE_ADD_STATE(kHFDStatusUnConfirmFliped);
        TABLE_ADD_STATE(kHFDStatusUnConfirmFlipedRotated);
        TABLE_ADD_STATE(kHFDStatusConfirmedFace);
        TABLE_ADD_STATE(kHFDStatusConfirmedUpperBody);
        TABLE_ADD_STATE(kHFDStatusConfirmedWholeBody);
        TABLE_ADD_STATE(kHFDStatusStopping);
    }
    NSString* log = @"[All begin]";
    for (NSNumber* statusIndexNumber in _statusRecords)
    {
        log = [log stringByAppendingFormat:@" =>%@",gStatusNameTable[[statusIndexNumber intValue]]];
    }
    return log;
}

#pragma mark Async Task Methods

- (void)taskStart
{
    [self performSelector:@selector(onHandledOperation:)
                 onThread:_callerThread
               withObject:_humanFeatures
            waitUntilDone:YES];
    
    [self taskInitHaarcascades];
    
    [self changeCurrentStatusTo:kHFDStatusTaskInited];
    
    [self detectFirstHumanFeature];
}

- (void)taskInitHaarcascades
{
    ReleaseAndNil(_haarParamDict);
    ReleaseAndNil(_ciParamDict);
    _haarParamDict = [[NSMutableDictionary dictionary] retain];
    _ciParamDict = [[NSMutableDictionary dictionary] retain];
    
    cv::Mat imageMat = [_scaledImage CVMat];
    
    HumanFeatureType types[kHumanFeatureTypeCount] = {
        kHumanFeatureFace,
        kHumanFeatureLeftEye,
        kHumanFeatureRightEye,
        kHumanFeatureEyePair,
        kHumanFeatureNose,
        kHumanFeatureMouth,
        kHumanFeatureUpperBody,
        kHumanFeatureLowerBody
    };
    
    //////Haarcascade Parameters Init//////
    
    // Name of face cascade resource file without xml extension
    NSString* cascadeFilenames[kHumanFeatureTypeCount] = {
        @"haarcascade_frontalface_alt2",
        @"haarcascade_lefteye_2splits",
        @"haarcascade_righteye_2splits",
        @"haarcascade_mcs_eyepair_big",
        @"haarcascade_mcs_nose",
        @"haarcascade_mcs_mouth",
        @"haarcascade_mcs_upperbody",
        @"haarcascade_lowerbody"
    };
    
    // Options for cv::CascadeClassifier::detectMultiScale
    int haarOptions[kHumanFeatureTypeCount] = {
        CV_HAAR_SCALE_IMAGE | CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH,
        CV_HAAR_SCALE_IMAGE | CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH,
        CV_HAAR_SCALE_IMAGE | CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH,
        CV_HAAR_SCALE_IMAGE | CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH,
        CV_HAAR_SCALE_IMAGE | CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH,
        CV_HAAR_SCALE_IMAGE | CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH,
        CV_HAAR_SCALE_IMAGE | CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH,
        CV_HAAR_SCALE_IMAGE | CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH
    };
    
    // Load the face Haar cascade from resources
    for (int i = 0; i < sizeof(cascadeFilenames)/sizeof(NSString*); ++i)
    {
        NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:cascadeFilenames[i] ofType:@"xml"];
        HaarDetectorParam* param = [[[HaarDetectorParam alloc] initWith:cascadeFilenames[i] filePath:faceCascadePath options:haarOptions[i]] autorelease];
        param.type = types[i];
        param.imageMat = imageMat;
        param.scale = _imageScale;
        param.imageOrientationAngle = 0.0f;
        [_haarParamDict setObject:param forKey:kFeatureKey(types[i])];
    }
    
    //////Core Image Parameters Init//////
    CIDetectorParam* faceCIParam = [[CIDetectorParam alloc] initWithImage:_scaledImage];
    [_ciParamDict setObject:faceCIParam forKey:kFeatureKey(kHumanFeatureFace)];
    
    _humanFeatures.bodyHeadOrientationAngle = 0.0f;
}

- (void)taskDoHaarDetection:(HaarDetectorParam*)param
{
    NSString* debugLog = @"";
    
    // Shrink video frame to 320X240
    cv::Mat imageMat = param.imageMat;
    
    long long debugTotalTs = getTimeInMicrosecond();
    
    // Detect faces
    std::vector<cv::Rect> faces;
    param.featureCascade.detectMultiScale(imageMat, faces, 1.1, 2, param.haarOptions,cv::Size(6, 6));
    
    debugLog = [debugLog stringByAppendingFormat:@"{{total}} all used %llu ms\n", (getTimeInMicrosecond() - debugTotalTs)/1000];
    
    NSLog(@"%@",debugLog);
    
    HumanFeature* feature = nil;
    
    if (faces.size() > 0)
    {
        feature = [[[HumanFeature alloc] init] autorelease];
        
        CGRect rect = CGRectZero;
        
        for (int i = 0; i < faces.size(); i++)
        {
            CGRect faceRect;
            faceRect.origin.x = faces[i].x;
            faceRect.origin.y = faces[i].y;
            faceRect.size.width = faces[i].width;
            faceRect.size.height = faces[i].height;
            
            if (!CGSizeEqualToSize(faceRect.size,CGSizeZero))
            {
                rect = faceRect;
                break;
            }
        }
        
        feature.rect = rect;
        feature.detected = CGSizeEqualToSize(rect.size,CGSizeZero) ? NO : YES;
        feature.type = param.type;
        feature.rawImageSize = _rawImage.size;
        
        rect.origin.x /= _imageScale;
        rect.origin.y /= _imageScale;
        rect.size.width /= _imageScale;
        rect.size.height /= _imageScale;
        
        feature.rectToRawImageHeadUp = rect;
    }
    
    [_humanFeatures setFeature:feature forType:param.type];
    
    [self taskHandleDetectedResult];
}

- (void)taskDoCIDetectorDetection:(CIDetectorParam*)param
{
    CIImage *beginImage = [CIImage imageWithCGImage:param.image.CGImage];
    //CIContext *context = [CIContext contextWithOptions:nil];
    
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    // create an array containing all the detected faces from the detector
    NSArray* features = [detector featuresInImage:beginImage];
    
    HumanFeature* feature = nil;
    
    
    // we'll iterate through every detected face. CIFaceFeature provides us
    // with the width for the entire face, and the coordinates of each eye
    // and the mouth if detected. Also provided are BOOL's for the eye's and
    // mouth so we can check if they already exist.
    if ([features count] > 0)
    {
        int maxScoreFeatureIndex = 0;
        int maxScore = 0;
        for(int i = 0; i < [features count]; ++i)
        {
            CIFaceFeature* faceFeature = [features objectAtIndex:i];
            int score = 0;
            if (faceFeature.hasLeftEyePosition)
            {
                score++;
            }
            if (faceFeature.hasRightEyePosition)
            {
                score++;
            }
            if (faceFeature.hasMouthPosition)
            {
                score++;
            }
            if (score > maxScore)
            {
                maxScore = score;
                maxScoreFeatureIndex = i;
            }
        }
        
        CIFaceFeature* faceFeature = [features objectAtIndex:maxScoreFeatureIndex];
        // get the width of the face
        CGFloat faceWidth = faceFeature.bounds.size.width;
        
        if (faceWidth > 0.f)
        {
            feature = [[[HumanFeature alloc] init] autorelease];
            feature.rect = [self flipRectByY:faceFeature.bounds forSize:param.image.size];
            feature.detected = YES;
            feature.type = kHumanFeatureFace;
            feature.rawImageSize = _rawImage.size;
            feature.rectToRawImageHeadUp = feature.rect;
        }
        [_humanFeatures setFeature:feature forType:kHumanFeatureFace];
        feature = nil;
        
        if (faceFeature.hasLeftEyePosition)
        {
            feature = [[[HumanFeature alloc] init] autorelease];
            feature.rect = [self flipRectByY:CGRectMake(faceFeature.leftEyePosition.x-faceWidth*0.15, faceFeature.leftEyePosition.y-faceWidth*0.15, faceWidth*0.3, faceWidth*0.3) forSize:param.image.size];
            feature.detected = YES;
            feature.type = kHumanFeatureLeftEye;
            feature.rawImageSize = _rawImage.size;
            feature.rectToRawImageHeadUp = feature.rect;
        }
        [_humanFeatures setFeature:feature forType:kHumanFeatureLeftEye];
        feature = nil;
        
        if (faceFeature.hasRightEyePosition)
        {
            feature = [[[HumanFeature alloc] init] autorelease];
            feature.rect = [self flipRectByY:CGRectMake(faceFeature.rightEyePosition.x-faceWidth*0.15, faceFeature.rightEyePosition.y-faceWidth*0.15, faceWidth*0.3, faceWidth*0.3) forSize:param.image.size];
            feature.detected = YES;
            feature.type = kHumanFeatureRightEye;
            feature.rawImageSize = _rawImage.size;
            feature.rectToRawImageHeadUp = feature.rect;
        }
        [_humanFeatures setFeature:feature forType:kHumanFeatureRightEye];
        feature = nil;
        
        if (faceFeature.hasMouthPosition)
        {
            feature = [[[HumanFeature alloc] init] autorelease];
            feature.rect = [self flipRectByY:CGRectMake(faceFeature.mouthPosition.x-faceWidth*0.2, faceFeature.mouthPosition.y-faceWidth*0.15, faceWidth*0.4, faceWidth*0.3) forSize:param.image.size];
            feature.detected = YES;
            feature.type = kHumanFeatureMouth;
            feature.rawImageSize = _rawImage.size;
            feature.rectToRawImageHeadUp = feature.rect;
        }
        [_humanFeatures setFeature:feature forType:kHumanFeatureMouth];
        feature = nil;
    }
    else
    {
        [_humanFeatures setFeature:nil forType:kHumanFeatureFace];
        [_humanFeatures setFeature:nil forType:kHumanFeatureLeftEye];
        [_humanFeatures setFeature:nil forType:kHumanFeatureRightEye];
        [_humanFeatures setFeature:nil forType:kHumanFeatureMouth];
    }
    
    
    [self taskHandleDetectedResult];
}

- (void)taskHandleDetectedResult
{
    BOOL checked = NO;
    SEL sels[] = {@selector(checkFaceFeature),@selector(checkUpperBodyFeature),@selector(checkWholeBodyFeature),@selector(checkFeatureIsEnd)};
    for (int i = 0; i < (sizeof(sels)/sizeof(sels[0])); ++i)
    {
        checked = [((NSNumber*)[self performSelector:sels[i] withObject:nil]) boolValue];
        if (checked)
        {
            break;
        }
    }
    
    if (!checked)
    {
        [self changeCurrentStatusTo:kHFDStatusStopping];
    }
    
    if (_isCancelled)
    {
        checked = NO;
    }
    
    [self performSelector:@selector(onHandledOperation:)
                 onThread:_callerThread
               withObject:_humanFeatures
            waitUntilDone:checked];
}


#pragma mark Handle Async Result

- (void)onHandledOperation:(DetectedHumanFeatures*)result
{
    if (_isCancelled)
    {
        [self changeCurrentStatusTo:kHFDStatusStopping];
        [_queue waitUntilAllOperationsAreFinished];
        _isCancelled = NO;
        _isDetecting = NO;
        [self changeCurrentStatusTo:kHFDStatusStopped];
        if (_notifyDelegate && [_notifyDelegate respondsToSelector:@selector(onCancelledWithFeature:forDetector:)])
        {
            [_notifyDelegate onCancelledWithFeature:_humanFeatures forDetector:self];
        }
        [self releaseAllResources];
        return;
    }
    
    
    if (_detectStatus == kHFDStatusStarting)
    {
        if (_notifyDelegate && [_notifyDelegate respondsToSelector:@selector(onStarted:)])
        {
            [_notifyDelegate onStarted:self];
        }
        return;
    }
    
    if (result.currentDetectedFeature && result.currentDetectedFeature.detected)
    {
        if (_notifyDelegate && [_notifyDelegate respondsToSelector:@selector(onDetectedFeature:forDetector:)])
        {
            [_notifyDelegate onDetectedFeature:result forDetector:self];
        }
    }
    
    if (_detectStatus == kHFDStatusStopping)
    {
        [_queue waitUntilAllOperationsAreFinished];
        _isCancelled = NO;
        _isDetecting = NO;
        [self changeCurrentStatusTo:kHFDStatusStopped];
        if (_notifyDelegate && [_notifyDelegate respondsToSelector:@selector(onFinishedWithFeature:forDetector:)])
        {
            [_notifyDelegate onFinishedWithFeature:_humanFeatures forDetector:self];
        }
        [self releaseAllResources];
    }
}

#pragma mark Inner Methods

- (void)changeCurrentStatusTo:(HumanFeatureDetectorStateType)status
{
    _detectStatus = status;
    [_statusRecords addObject:[NSNumber numberWithInt:status]];
}

- (void)releaseAllResources
{
    ReleaseAndNil(_haarParamDict);
    ReleaseAndNil(_ciParamDict);
    ReleaseAndNil(_notifyDelegate);
    ReleaseAndNil(_rawImage);
    ReleaseAndNil(_scaledImage);
    ReleaseAndNil(_xmlDir);
    ReleaseAndNil(_humanFeatures);
    ReleaseAndNil(_callerThread);
}

- (BOOL)detectHumanFeature:(UIImage*)image
               forDelegate:(id<HumanFeatureDetectorDelegate>)delegate
               shouldAsync:(BOOL)async
{
    if (_isDetecting)
    {
        return NO;
    }
    
    [self releaseAllResources];
    
    _isCancelled = NO;
    [self changeCurrentStatusTo:kHFDStatusStarting];
    
    _notifyDelegate = [delegate retain];
    _rawImage = [image retain];
    _humanFeatures = [[DetectedHumanFeatures alloc] init];
    _callerThread = [[NSThread currentThread] retain];
    
    float scale = 1.0;
    if (kScaleToWidth > 0.0)
    {
        scale = ((float)kScaleToWidth) / _rawImage.size.width;
    }
    
    _imageScale = scale;
    _scaledImage = [[UIImage imageWithCGImage:_rawImage.CGImage scale:scale orientation:UIImageOrientationUp] retain];
    
    _isDetecting = YES;
    _isAsync = async;
    _lastOrientationAngle = 0.0f;
    
    if (async)
    {
        NSInvocationOperation* op = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                         selector:@selector(taskStart)
                                                                           object:nil] autorelease];
        
        [_queue addOperation:op];
    }
    else
    {
        [self taskStart];
    }
    
    return YES;
}

- (CGRect)regulateRect:(CGRect)rect
{
    rect.origin.x = (CGFloat)((int)rect.origin.x);
    rect.origin.y = (CGFloat)((int)rect.origin.y);
    rect.size.width = (CGFloat)((int)rect.size.width);
    rect.size.height = (CGFloat)((int)rect.size.height);
    return rect;
}

- (CGRect)flipRectByY:(CGRect)rect forSize:(CGSize)size
{
    rect.origin.y = size.height - rect.origin.y - rect.size.height;
    return rect;
}

#pragma mark result checkouts

- (void)setUnconfirmed
{
    if (_lastOrientationAngle < M_PI)
    {
        <#statements#>
    }
    else
    {
        
    }
    switch (_lastOrientation)
    {
        case kBodyHeadUp:
        {
            [self changeCurrentStatusTo:kHFDStatusUnConfirmOriginal];
        }
            break;
        case kBodyHeadLeft:
        {
            [self changeCurrentStatusTo:kHFDStatusUnConfirmRotated];
        }
            break;
        case kBodyHeadDown:
        {
            [self changeCurrentStatusTo:kHFDStatusUnConfirmFliped];
        }
            break;
        case kBodyHeadRight:
        {
            [self changeCurrentStatusTo:kHFDStatusUnConfirmFlipedRotated];
        }
            break;
        default:
            break;
    }
}

- (BOOL)checkAndDoFlipAndRotation
{
    BOOL ret = YES;
    BOOL shouldRotate90Degree = NO;
    
    if (_detectStatus == kHFDStatusConfirmedWholeBody)
    {
        ret = NO;
    }
    else
    {
        switch (_lastOrientation)
        {
            case kBodyHeadUp:
            {
                if (_detectStatus == kHFDStatusUnConfirmOriginal)
                {
                    shouldRotate90Degree = YES;
                    _lastOrientation = kBodyHeadLeft;
                }
            }
                break;
            case kBodyHeadLeft:
            {
                if (_detectStatus == kHFDStatusUnConfirmRotated)
                {
                    shouldRotate90Degree = YES;
                    _lastOrientation = kBodyHeadDown;
                }
            }
                break;
            case kBodyHeadDown:
            {
                if (_detectStatus == kHFDStatusUnConfirmFliped)
                {
                    shouldRotate90Degree = YES;
                    _lastOrientation = kBodyHeadRight;
                }
            }
                break;
            default:
            {
                ret = NO;
            }
                break;
        }
    }
    
    if (shouldRotate90Degree)
    {
        cv::Mat imageMat = [_scaledImage CVMat];
        cv::transpose(imageMat, imageMat);
        for (HaarDetectorParam* param in _haarParamDict.allValues)
        {
            param.imageMat = imageMat;
            param.imageOrientation = _lastOrientation;
        }
        UIImage* rotatedUIImage = [UIImage imageWithCVMat:imageMat];
        for (CIDetectorParam* param in _ciParamDict.allValues)
        {
            param.image = rotatedUIImage;
            param.imageOrientation = _lastOrientation;
        }
        _humanFeatures.bodyOrientation = _lastOrientation;
        [self detectFirstHumanFeature];
    }
    
    return ret;
}

- (BOOL)hasNeverDetectedFace
{
    if (_detectStatus == kHFDStatusTaskInited || _detectStatus == kHFDStatusUnConfirmOriginal || _detectStatus == kHFDStatusUnConfirmRotated || _detectStatus == kHFDStatusUnConfirmFliped)
    {
        return YES;
    }
    return NO;
}

- (BOOL)checkDetectedFeatureFaceDetail
{
    BOOL ret = NO;
    
    HumanFeature* face = [_humanFeatures getFeatureByType:kHumanFeatureFace];
    HumanFeature* eyePair = [_humanFeatures getFeatureByType:kHumanFeatureEyePair];
    HumanFeature* nose = [_humanFeatures getFeatureByType:kHumanFeatureNose];
    HumanFeature* mouth = [_humanFeatures getFeatureByType:kHumanFeatureMouth];
    HumanFeature* leftEye = [_humanFeatures getFeatureByType:kHumanFeatureLeftEye];
    HumanFeature* rightEye = [_humanFeatures getFeatureByType:kHumanFeatureRightEye];
    
    if (face && face.detected)
    {
        BOOL eyesIsInside = NO;
        BOOL noseIsInside = NO;
        BOOL mouthIsInside = NO;
        
        if (eyePair && eyePair.detected)
        {
            if (CGRectContainsRect(face.rect,eyePair.rect) || CGRectIntersectsRect(face.rect,eyePair.rect))
            {
                eyesIsInside = YES;
            }
        }
        
        if ((leftEye && leftEye.detected) || (rightEye && rightEye.detected))
        {
            if (CGRectContainsRect(face.rect,leftEye.rect) || CGRectIntersectsRect(face.rect,leftEye.rect))
            {
                eyesIsInside = YES;
            }
            if (CGRectContainsRect(face.rect,rightEye.rect) || CGRectIntersectsRect(face.rect,rightEye.rect))
            {
                eyesIsInside = YES;
            }
        }
        
        if (nose && nose.detected)
        {
            if (CGRectContainsRect(face.rect,nose.rect) || CGRectIntersectsRect(face.rect,nose.rect))
            {
                noseIsInside = YES;
            }
        }
        
        if (mouth && mouth.detected)
        {
            if (CGRectContainsRect(face.rect,mouth.rect) || CGRectIntersectsRect(face.rect,mouth.rect))
            {
                mouthIsInside = YES;
            }
        }
        
        if ((eyesIsInside && noseIsInside) || (eyesIsInside && noseIsInside) || (eyesIsInside && mouthIsInside) || (noseIsInside && mouthIsInside))
        {
            ret = YES;
        }
        
    }
    
    return ret;
}

- (NSNumber*)checkFaceFeature
{
    BOOL ret = NO;
    BOOL needRedect = NO;
    
    if ([self hasNeverDetectedFace])
    {
        HaarDetectorParam* param = nil;
        
        if (_humanFeatures.currentDetectedFeatureType == kHumanFeatureFace)
        {
            HumanFeature* feature = _humanFeatures.currentDetectedFeature;
            if (feature && feature.detected)
            {
                param = [_haarParamDict objectForKey:kFeatureKey(kHumanFeatureEyePair)];
            }
            else
            {
                [self setUnconfirmed];
                needRedect = YES;
            }
        }
        
        if (_humanFeatures.currentDetectedFeatureType == kHumanFeatureEyePair)
        {
            param = [_haarParamDict objectForKey:kFeatureKey(kHumanFeatureNose)];
        }
        
        if (_humanFeatures.currentDetectedFeatureType == kHumanFeatureNose)
        {
            param = [_haarParamDict objectForKey:kFeatureKey(kHumanFeatureMouth)];
        }
        
        if (_humanFeatures.currentDetectedFeatureType == kHumanFeatureMouth)
        {
            if ([self checkDetectedFeatureFaceDetail])
            {
                param = [_haarParamDict objectForKey:kFeatureKey(kHumanFeatureUpperBody)];
                [self changeCurrentStatusTo:kHFDStatusConfirmedFace];
            }
            else
            {
                [self setUnconfirmed];
                needRedect = YES;
            }
        }
        
        if (param)
        {
            if (_isAsync)
            {
                NSInvocationOperation* op = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                                  selector:@selector(taskDoHaarDetection:)
                                                                                    object:param] autorelease];
                param.asyncOperation = op;
                [_queue addOperation:op];
            }
            else
            {
                [self taskDoHaarDetection:param];
            }
        }
        
        ret = YES;
        if (needRedect)
        {
            ret = NO;
        }
    }
    
    return [NSNumber numberWithBool:ret];
}

- (NSNumber*)checkUpperBodyFeature
{
    BOOL ret = NO;
    BOOL needRedect = NO;
    
    if (_detectStatus == kHFDStatusConfirmedFace)
    {
        HaarDetectorParam* param = nil;
        
#if 0
        if (_humanFeatures.currentDetectedFeatureType == kHumanFeatureUpperBody)
        {
            HumanFeature* upperBody = [_humanFeatures getFeatureByType:kHumanFeatureUpperBody];
            HumanFeature* face = [_humanFeatures getFeatureByType:kHumanFeatureFace];
            if (upperBody && upperBody.detected &&
                (CGRectContainsRect(upperBody.rect,face.rect) || CGRectIntersectsRect(upperBody.rect,face.rect)))
            {
                param = [_haarParamDict objectForKey:kFeatureKey(kHumanFeatureLowerBody)];
                [self changeCurrentStatusTo:kHFDStatusConfirmedUpperBody];
            }
            else
            {
                [self setUnconfirmed];
                needRedect = YES;
            }
        }
#endif
        
        param = [_haarParamDict objectForKey:kFeatureKey(kHumanFeatureLowerBody)];
        [self changeCurrentStatusTo:kHFDStatusConfirmedUpperBody];
        
        if (param)
        {
            if (_isAsync)
            {
                NSInvocationOperation* op = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                                  selector:@selector(taskDoHaarDetection:)
                                                                                    object:param] autorelease];
                param.asyncOperation = op;
                [_queue addOperation:op];
            }
            else
            {
                [self taskDoHaarDetection:param];
            }
        }
        
        ret = YES;
        if (needRedect)
        {
            ret = NO;
        }
    }
    
    return [NSNumber numberWithBool:ret];
}

- (NSNumber*)checkWholeBodyFeature
{
    BOOL ret = NO;
    
    if (_detectStatus == kHFDStatusConfirmedUpperBody)
    {
        HaarDetectorParam* param = nil;
        
        /*
        if (_humanFeatures.currentDetectedFeatureType == kHumanFeatureUpperBody)
        {
            HumanFeature* upperBody = [_humanFeatures getFeatureByType:kHumanFeatureUpperBody];
            HumanFeature* face = [_humanFeatures getFeatureByType:kHumanFeatureFace];
            if (upperBody && upperBody.detected &&
                (CGRectContainsRect(upperBody.rect,face.rect) || CGRectIntersectsRect(upperBody.rect,face.rect)))
            {
                param = [_haarParamDict objectForKey:kFeatureKey(kHumanFeatureLowerBody)];
                [self changeCurrentStatusTo:kHFDStatusConfirmedWholeBody];
            }
            else
            {
                [self setUnconfirmed];
            }
        }
         
         if (param)
         {
         if (_isAsync)
         {
         NSInvocationOperation* op = [[[NSInvocationOperation alloc] initWithTarget:self
         selector:@selector(taskDoHaarDetection:)
         object:param] autorelease];
         param.asyncOperation = op;
         [_queue addOperation:op];
         }
         else
         {
         [self taskDoHaarDetection:param];
         }
         }
         */
        [self changeCurrentStatusTo:kHFDStatusConfirmedWholeBody];
        if (_isAsync)
        {
            NSInvocationOperation* op = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                              selector:@selector(taskHandleDetectedResult)
                                                                                object:nil] autorelease];
            param.asyncOperation = op;
            [_queue addOperation:op];
        }
        else
        {
            [self taskHandleDetectedResult];
        }
        
        
        ret = YES;
    }
    
    return [NSNumber numberWithBool:ret];
}

- (NSNumber*)checkFeatureIsEnd
{
    return [NSNumber numberWithBool:[self checkAndDoFlipAndRotation]];
}

- (void)detectFirstHumanFeature
{
#if 0
    NSMutableDictionary* paramDict = _haarParamDict;
    SEL taskDoDetectionSel = @selector(taskDoHaarDetection:);
#else
    NSMutableDictionary* paramDict = _ciParamDict;
    SEL taskDoDetectionSel = @selector(taskDoCIDetectorDetection:);
#endif
    BaseDetectorParam* param = [paramDict objectForKey:kFeatureKey(kHumanFeatureFace)];
    if (_isAsync)
    {
        NSInvocationOperation* op = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                          selector:taskDoDetectionSel
                                                                            object:param] autorelease];
        param.asyncOperation = op;
        [_queue addOperation:op];
    }
    else
    {
        [self performSelector:taskDoDetectionSel withObject:param];
    }
}


@end
