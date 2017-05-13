//
//  XTOverlayView.h
//  XTVideoPlayer
//
//  Created by Admin on 2017/5/13.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTCameraModeView.h"
#import "XTStatusView.h"

@interface XTOverlayView : UIView

@property (strong, nonatomic)  XTCameraModeView *modeView;
@property (strong, nonatomic)  XTStatusView *statusView;
@property (nonatomic) BOOL flashControlHidden;

@end
