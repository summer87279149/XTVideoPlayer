//
//  XTCameraManager.h
//  XTVideoPlayer
//
//  Created by Admin on 2017/5/13.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
//订阅这个通知，当创建缩略图的时候响应
extern NSString *const XTThumbnailCreatedNotification;
/**有错误时回调*/
@protocol XTCameraManagerDelegate <NSObject>
- (void)deviceConfigurationFailedWithError:(NSError *)error;
- (void)mediaCaptureFailedWithError:(NSError *)error;
- (void)assetLibraryWriteFailedWithError:(NSError *)error;
@end

@interface XTCameraManager : NSObject

@property (weak, nonatomic) id<XTCameraManagerDelegate> delegate;
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;
/**配置、控制session*/
- (BOOL)setupSession:(NSError **)error;
- (void)startSession;
- (void)stopSession;
/**切换摄像头*/
- (BOOL)switchCameras;
- (BOOL)canSwitchCameras;
@property (nonatomic, readonly) NSUInteger cameraCount;
@property (nonatomic, readonly) BOOL cameraHasTorch;
@property (nonatomic, readonly) BOOL cameraHasFlash;
@property (nonatomic, readonly) BOOL cameraSupportsTapToFocus;
@property (nonatomic, readonly) BOOL cameraSupportsTapToExpose;
@property (nonatomic) AVCaptureTorchMode torchMode;
@property (nonatomic) AVCaptureFlashMode flashMode;
/**对焦*/
- (void)focusAtPoint:(CGPoint)point;
/**曝光*/
- (void)exposeAtPoint:(CGPoint)point;
/**重置对焦和曝光*/
- (void)resetFocusAndExposureModes;

/** 拍照 **/
- (void)captureStillImage;
/**开始录制*/
- (void)startRecording;
/**停止录制*/
- (void)stopRecording;
/**是否在录制中*/
- (BOOL)isRecording;
/**录制时间*/
- (CMTime)recordedDuration;

@end
