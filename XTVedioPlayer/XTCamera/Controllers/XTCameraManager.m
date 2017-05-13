//
//  XTCameraManager.m
//  XTVideoPlayer
//
//  Created by Admin on 2017/5/13.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import "XTCameraManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSFileManager+XTAdditions.h"
#import <UIKit/UIKit.h>
NSString *const XTThumbnailCreatedNotification = @"XTThumbnailCreated";
@interface XTCameraManager () <AVCaptureFileOutputRecordingDelegate>

@property (strong, nonatomic) dispatch_queue_t videoQueue;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (weak, nonatomic) AVCaptureDeviceInput *activeVideoInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *imageOutput;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieOutput;
@property (strong, nonatomic) NSURL *outputURL;

@end

@implementation XTCameraManager

- (BOOL)setupSession:(NSError **)error {
    self.captureSession = [[AVCaptureSession alloc]init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    //AVMediaTypeAudio：麦克
    //AVMediaTypeVideo 摄像头
    //AVCaptureDevice需要包装在AVCaptureDeviceInput中
    AVCaptureDevice *videoDevice =
    [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoInput =
    [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    } else {
        return NO;
    }
    
    AVCaptureDevice *audioDevice =
    [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    AVCaptureDeviceInput *audioInput =
    [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
        }
    } else {
        return NO;
    }
    
    // 输出图片
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.imageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    
    // 输出文件
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }
    
    return YES;

}

- (void)startSession {
    if (![self.captureSession isRunning]) {
        dispatch_async([self globalQueue], ^{
            [self.captureSession startRunning];//这是一个同步调用会阻塞线程，所以放在异步执行
        });
    }
}
- (dispatch_queue_t)globalQueue {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}
- (void)stopSession {
    if ([self.captureSession isRunning]) {
        dispatch_async([self globalQueue], ^{
            [self.captureSession stopRunning];
        });
    }
}

#pragma mark - Device Configuration

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}

- (AVCaptureDevice *)inactiveCamera {
    
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}
- (BOOL)canSwitchCameras {
    return self.cameraCount > 1;
}

- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (BOOL)switchCameras {
    
    if (![self canSwitchCameras]) {
        return NO;
    }
    
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    
    AVCaptureDeviceInput *videoInput =
    [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (videoInput) {
        [self.captureSession beginConfiguration];//更改session
        
        [self.captureSession removeInput:self.activeVideoInput];
        
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
            [self.captureSession addInput:self.activeVideoInput];
        }
        
        [self.captureSession commitConfiguration];//提交更改session
        
    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
        return NO;
    }
    
    return YES;
}

#pragma mark - Focus Methods

- (BOOL)cameraSupportsTapToFocus {
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    if (device.isFocusPointOfInterestSupported &&
        [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {                         // 锁定设备准备配置
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];                                // 锁定设备准备配置
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

#pragma mark - Exposure Methods

- (BOOL)cameraSupportsTapToExpose {
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

static const NSString *THCameraAdjustingExposureContext;

- (void)exposeAtPoint:(CGPoint)point {
    
    AVCaptureDevice *device = [self activeCamera];
    
    if (device.isExposurePointOfInterestSupported &&
        [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            
            device.exposurePointOfInterest = point;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self
                         forKeyPath:@"adjustingExposure"
                            options:NSKeyValueObservingOptionNew
                            context:&THCameraAdjustingExposureContext];
            }
            
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (context == &THCameraAdjustingExposureContext) {
        
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        
        if (!device.isAdjustingExposure &&
            [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            
            [object removeObserver:self
                        forKeyPath:@"adjustingExposure"
                           context:&THCameraAdjustingExposureContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } else {
                    [self.delegate deviceConfigurationFailedWithError:error];
                }
            });
        }
        
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)resetFocusAndExposureModes {
    
    AVCaptureDevice *device = [self activeCamera];
    
    AVCaptureExposureMode exposureMode =
    AVCaptureExposureModeContinuousAutoExposure;
    
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] &&
    [device isFocusModeSupported:focusMode];
    
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] &&
    [device isExposureModeSupported:exposureMode];
    
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        
        [device unlockForConfiguration];
        
    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
    }
}




#pragma mark - Flash and Torch Modes

- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)flashMode {
    return [[self activeCamera] flashMode];
}



- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    
    AVCaptureDevice *device = [self activeCamera];
    
    if (device.flashMode != flashMode &&
        [device isFlashModeSupported:flashMode]) {
        
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}
//手电
- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    
    AVCaptureDevice *device = [self activeCamera];
    
    if (device.torchMode != torchMode &&
        [device isTorchModeSupported:torchMode]) {
        
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}



#pragma mark - Image Capture Methods


- (void)captureStillImage {
    
    AVCaptureConnection *connection =
    [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection
     completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
         if (imageDataSampleBuffer != NULL) {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             [self writeImageToAssetsLibrary:image];
         } else {
         }
     }];
}
- (AVCaptureVideoOrientation)currentVideoOrientation {
    
    AVCaptureVideoOrientation orientation;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}


- (void)writeImageToAssetsLibrary:(UIImage *)image {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusNotDetermined) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"需要访问相册" message:@"请打开访问相册的权限" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    }else{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:image.CGImage
                                  orientation:(NSInteger)image.imageOrientation
                              completionBlock:^(NSURL *assetURL, NSError *error) {
                                  if (!error) {
                                      [self postThumbnailNotifification:image];
                                  } else {
                                      id message = [error localizedDescription];
                                      NSLog(@"Error: %@", message);
                                  }
                              }];

    }
    
    
}

- (void)postThumbnailNotifification:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:XTThumbnailCreatedNotification object:image];
    });
    
}

#pragma mark - Video Capture Methods


- (BOOL)isRecording {
    return self.movieOutput.isRecording;
}

- (void)startRecording {
    
    if (![self isRecording]) {
        
        AVCaptureConnection *videoConnection =
        [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if ([videoConnection isVideoOrientationSupported]) {
            videoConnection.videoOrientation = self.currentVideoOrientation;
        }
        
        if ([videoConnection isVideoStabilizationSupported]) {
            //设置稳定拍摄
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
                videoConnection.enablesVideoStabilizationWhenAvailable = YES;
            } else {
                videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
        }
        AVCaptureDevice *device = [self activeCamera];
        //摄像头缓慢对焦，提供流畅的视觉效果
        if (device.isSmoothAutoFocusSupported) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                device.smoothAutoFocusEnabled = NO;
                [device unlockForConfiguration];
            } else {
                [self.delegate deviceConfigurationFailedWithError:error];
            }
        }
        
        self.outputURL = [self uniqueURL];
        [self.movieOutput startRecordingToOutputFileURL:self.outputURL
                                      recordingDelegate:self];
        
    }
}

- (CMTime)recordedDuration {
    return self.movieOutput.recordedDuration;
}

- (NSURL *)uniqueURL {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dirPath =
    [fileManager temporaryDirectoryWithTemplateString:@"kamera.XXXXXX"];
    
    if (dirPath) {
        NSString *filePath =
        [dirPath stringByAppendingPathComponent:@"kamera_movie.mov"];
        return [NSURL fileURLWithPath:filePath];
    }
    
    return nil;
}

- (void)stopRecording {
    if ([self isRecording]) {
        [self.movieOutput stopRecording];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error {
    if (error) {                                                            // 1
        [self.delegate mediaCaptureFailedWithError:error];
    } else {
        [self writeVideoToAssetsLibrary:[self.outputURL copy]];
    }
    self.outputURL = nil;
}

- (void)writeVideoToAssetsLibrary:(NSURL *)videoURL {
    //library提供视频写入的接口
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        //检查视频是否可以被写入
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL]) {
 
        [library writeVideoAtPathToSavedPhotosAlbum:videoURL
         completionBlock:^(NSURL *assetURL, NSError *error) {
             if (error) {
                 [self.delegate assetLibraryWriteFailedWithError:error];
             } else {
                 [self generateThumbnailForVideoAtURL:videoURL];
             }
        }];
    }
}
//生成一个缩略图
- (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL {
    
    dispatch_async([self globalQueue], ^{
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        imageGenerator.maximumSize = CGSizeMake(100.0f, 0.0f);
        imageGenerator.appliesPreferredTrackTransform = YES;
        //这是一个同步方法，所以上面才用dispatch_async
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero // 6
                                                     actualTime:NULL
                                                          error:nil];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        dispatch_async(dispatch_get_main_queue(), ^{                        // 7
            [self postThumbnailNotifification:image];
        });
    });
}


@end

