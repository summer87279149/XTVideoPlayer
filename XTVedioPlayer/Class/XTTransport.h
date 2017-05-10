//
//  XTTransport.h
//  XTVedioPlayer
//
//  Created by Admin on 2017/5/10.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@protocol XTTransportDelegate <NSObject>

- (void)play;
- (void)pause;
- (void)stop;

- (void)scrubbingDidStart;
- (void)scrubbedToTime:(NSTimeInterval)time;
- (void)scrubbingDidEnd;

- (void)jumpedToTime:(NSTimeInterval)time;

@optional
- (void)subtitleSelected:(NSString *)subtitle;

@end

@protocol XTTransport <NSObject>

@property (weak, nonatomic) id <XTTransportDelegate> delegate;

- (void)setTitle:(NSString *)title;
- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;
- (void)setScrubbingTime:(NSTimeInterval)time;
- (void)playbackComplete;
- (void)setSubtitles:(NSArray *)subtitles;

@end
