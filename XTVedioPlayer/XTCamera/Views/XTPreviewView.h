//
//  XTPreviewView.h
//  XTVideoPlayer
//
//  Created by Admin on 2017/5/13.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol XTPreviewViewDelegate <NSObject>

- (void)tappedToFocusAtPoint:(CGPoint)point;
- (void)tappedToExposeAtPoint:(CGPoint)point;
- (void)tappedToResetFocusAndExposure;

@end

@interface XTPreviewView : UIView

@property (strong, nonatomic) AVCaptureSession *session;
@property (weak, nonatomic) id<XTPreviewViewDelegate> delegate;

@property (nonatomic) BOOL tapToFocusEnabled;
@property (nonatomic) BOOL tapToExposeEnabled;

@end
