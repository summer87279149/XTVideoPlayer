//
//  XTPlayerManager.m
//  XTVedioPlayer
//
//  Created by Admin on 2017/5/10.
//  Copyright © 2017年 Summer. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "XTTransport.h"
#import "XTPlayerView.h"
#import "AVAsset+XTAdditions.h"
#import "UIAlertView+XTAdditions.h"
#import "XTPlayerManager.h"

#define STATUS_KEYPATH @"status"
#define REFRESH_INTERVAL 0.5f

static const NSString *PlayerItemStatusContext;
@interface XTPlayerManager () <XTTransportDelegate>

@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) XTPlayerView *playerView;

@property (weak, nonatomic) id <XTTransport> transport;
@property (strong, nonatomic) id timeObserver;
@property (strong, nonatomic) id itemEndObserver;
@property (assign, nonatomic) float lastPlaybackRate;

@end

@implementation XTPlayerManager
#pragma mark - Setup
- (id)initWithURL:(NSURL *)assetURL {
    self = [super init];
    if (self) {
        _asset = [AVAsset assetWithURL:assetURL];
        [self prepareToPlay];
    }
    return self;
}
- (void)prepareToPlay {
    NSArray *keys = @[
                      @"tracks",
                      @"duration",
                      @"commonMetadata",
                      @"availableMediaCharacteristicsWithMediaSelectionOptions"
                      ];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset
                           automaticallyLoadedAssetKeys:keys];
    
    [self.playerItem addObserver:self
                      forKeyPath:STATUS_KEYPATH
                         options:0
                         context:&PlayerItemStatusContext];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerView = [[XTPlayerView alloc] initWithPlayer:self.player];
    self.transport = self.playerView.transport;
    self.transport.delegate = self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (context == &PlayerItemStatusContext) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.playerItem removeObserver:self forKeyPath:STATUS_KEYPATH];
            
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                
                [self addPlayerItemTimeObserver];
                [self addItemEndObserverForPlayerItem];
                
                CMTime duration = self.playerItem.duration;
                
                [self.transport setCurrentTime:CMTimeGetSeconds(kCMTimeZero)
                                      duration:CMTimeGetSeconds(duration)];
                
                [self.transport setTitle:self.asset.title];
                
                [self.player play];
                
                [self loadMediaOptions];
                
            } else {
                NSLog(@"无法加载video");
            }
        });
    }
}
- (void)loadMediaOptions {
    NSString *mc = AVMediaCharacteristicLegible;
    AVMediaSelectionGroup *group =
    [self.asset mediaSelectionGroupForMediaCharacteristic:mc];
    if (group) {
        NSMutableArray *subtitles = [NSMutableArray array];
        for (AVMediaSelectionOption *option in group.options) {
            [subtitles addObject:option.displayName];
        }
        [self.transport setSubtitles:subtitles];
    } else {
        [self.transport setSubtitles:nil];
    }
}

- (void)subtitleSelected:(NSString *)subtitle {
    NSString *mc = AVMediaCharacteristicLegible;
    AVMediaSelectionGroup *group =
    [self.asset mediaSelectionGroupForMediaCharacteristic:mc];
    BOOL selected = NO;
    for (AVMediaSelectionOption *option in group.options) {
        if ([option.displayName isEqualToString:subtitle]) {
            [self.playerItem selectMediaOption:option                                                inMediaSelectionGroup:group];
            selected = YES;
        }
    }
    if (!selected) {
        [self.playerItem selectMediaOption:nil
                     inMediaSelectionGroup:group];
    }
}


#pragma mark - Time Observers

- (void)addPlayerItemTimeObserver {
    CMTime interval = CMTimeMakeWithSeconds(REFRESH_INTERVAL, NSEC_PER_SEC);
    dispatch_queue_t queue = dispatch_get_main_queue();
    __weak XTPlayerManager *weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:^(CMTime time) {
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(weakSelf.playerItem.duration);
        [weakSelf.transport setCurrentTime:currentTime duration:duration];
    }];
}

- (void)addItemEndObserverForPlayerItem {
    NSString *name = AVPlayerItemDidPlayToEndTimeNotification;
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    __weak XTPlayerManager *weakSelf = self;
    self.itemEndObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:name object:self.playerItem queue:queue usingBlock:^(NSNotification * _Nonnull note){
        [weakSelf.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf.transport playbackComplete];
        }];
    }];
}
#pragma mark - THTransportDelegate Methods

- (void)play {
    [self.player play];
}

- (void)pause {
    self.lastPlaybackRate = self.player.rate;
    [self.player pause];
}

- (void)stop {
    [self.player setRate:0.0f];
    [self.transport playbackComplete];
}

- (void)jumpedToTime:(NSTimeInterval)time {
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
}

- (void)scrubbingDidStart {
    self.lastPlaybackRate = self.player.rate;
    [self.player pause];
    [self.player removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
}

- (void)scrubbedToTime:(NSTimeInterval)time {
    [self.playerItem cancelPendingSeeks];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)scrubbingDidEnd {
    [self addPlayerItemTimeObserver];
    if (self.lastPlaybackRate > 0.0f) {
        [self.player play];
    }
}


#pragma mark - Housekeeping

- (UIView *)view {
    return self.playerView;
}

- (void)dealloc {
    if (self.itemEndObserver) {                                             // 5
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self.itemEndObserver
                      name:AVPlayerItemDidPlayToEndTimeNotification
                    object:self.player.currentItem];
        self.itemEndObserver = nil;
    }
}








@end
