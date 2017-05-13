
//
//  XTOverlayView.m
//  XTVideoPlayer
//
//  Created by Admin on 2017/5/13.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import "XTOverlayView.h"

@interface XTOverlayView ()

@end

@implementation XTOverlayView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.modeView = [[XTCameraModeView alloc]initWithFrame:CGRectMake(0, frame.origin.y+frame.size.height-110, frame.size.width, 110)];
        [self addSubview:self.modeView];
        [self.modeView addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
        self.statusView = [[XTStatusView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 64)];
        [self addSubview:self.statusView];
    }
    return self;
}
//- (void)awakeFromNib {
//    self.backgroundColor = [UIColor clearColor];
//    [self.modeView addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
//}

- (void)modeChanged:(XTCameraModeView *)modeView {
    BOOL photoModeEnabled = modeView.cameraMode == XTCameraModePhoto;
    UIColor *toColor = photoModeEnabled ? [UIColor blackColor] : [UIColor colorWithWhite:0.0f alpha:0.5f];
    CGFloat toOpacity = photoModeEnabled ? 0.0f : 1.0f;
    self.statusView.layer.backgroundColor = toColor.CGColor;
    self.statusView.elapsedTimeLabel.layer.opacity = toOpacity;
}
//拦截当前页面的事件，如果事件在statusView或者modeView范围内，就拦截returnYES，否则传递下去
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self.statusView pointInside:[self convertPoint:point toView:self.statusView] withEvent:event] ||
        [self.modeView pointInside:[self convertPoint:point toView:self.modeView] withEvent:event]) {
        return YES;
    }
    return NO;
}

- (void)setFlashControlHidden:(BOOL)state {
    if (_flashControlHidden != state) {
        _flashControlHidden = state;
        self.statusView.flashControl.hidden = state;
    }
}


@end
