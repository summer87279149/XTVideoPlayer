//
//  XTCameraView.h
//  XTVideoPlayer
//
//  Created by Admin on 2017/5/13.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XTPreviewView.h"
#import "XTOverlayView.h"

@interface XTCameraView : UIView

@property (weak, nonatomic, readonly) XTPreviewView *previewView;
@property (weak, nonatomic, readonly) XTOverlayView *controlsView;

@end
