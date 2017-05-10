//
//  XTPlayerView.m
//  XTVedioPlayer
//
//  Created by Admin on 2017/5/10.
//  Copyright © 2017年 Summer. All rights reserved.
//
#import "THOverlayView.h"
#import <AVFoundation/AVFoundation.h>
#import "XTPlayerView.h"
@class AVPlayer;
//该类是视频播放view，该view的layer就是AVPlayerLayer。
//然后在该view上覆盖播放暂停快进按钮的view
@interface XTPlayerView ()
@property (strong, nonatomic) THOverlayView *overlayView;                   // 1
@end
@implementation XTPlayerView
//把view的layer设置成AVPlayerLayer
+ (Class)layerClass {                                                       // 2
    return [AVPlayerLayer class];
}

- (id)initWithPlayer:(AVPlayer *)player {
    self = [super initWithFrame:CGRectZero];                                // 3
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleWidth;
        [(AVPlayerLayer *) [self layer] setPlayer:player];                  // 4
        [[NSBundle mainBundle] loadNibNamed:@"THOverlayView"                // 5
                                      owner:self
                                    options:nil];
        [self addSubview:_overlayView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.overlayView.frame = self.bounds;
}

- (id <XTTransport>)transport {
    return self.overlayView;
}



@end
