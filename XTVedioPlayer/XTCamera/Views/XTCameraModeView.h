//
//  XTCameraModeView.h
//  XTVideoPlayer
//
//  Created by Admin on 2017/5/13.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XTCameraMode) {
    XTCameraModePhoto = 0, // default
    XTCameraModeVideo = 1
};

@interface XTCameraModeView : UIControl
@property (nonatomic) XTCameraMode cameraMode;

@end
