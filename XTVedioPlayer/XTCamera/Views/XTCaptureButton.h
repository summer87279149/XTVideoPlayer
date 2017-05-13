//
//  XTCaptureButton.h
//  XTVideoPlayer
//
//  Created by Admin on 2017/5/13.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XTCaptureButtonMode) {
    XTCaptureButtonModePhoto = 0, // default
    XTCaptureButtonModeVideo = 1
};

@interface XTCaptureButton : UIButton

+ (instancetype)captureButton;
+ (instancetype)captureButtonWithMode:(XTCaptureButtonMode)captureButtonMode;

@property (nonatomic) XTCaptureButtonMode captureButtonMode;


@end
