//
//  XTPlayerView.h
//  XTVedioPlayer
//
//  Created by Admin on 2017/5/10.
//  Copyright © 2017年 Summer. All rights reserved.
//
#import "XTTransport.h"
#import <UIKit/UIKit.h>
@class AVPlayer;
@interface XTPlayerView : UIView
- (id)initWithPlayer:(AVPlayer *)player;
//transport就是播放暂停快进等操作的view
@property (nonatomic, readonly) id <XTTransport> transport;

@end
