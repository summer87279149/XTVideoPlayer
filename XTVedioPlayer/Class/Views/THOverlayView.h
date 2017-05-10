//
//  THOverlayView.h
//  XTVedioPlayer
//
//  Created by Admin on 2017/5/10.
//  Copyright © 2017年 Summer. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "XTTransport.h"

@interface THOverlayView : UIView <XTTransport>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIView *toolbar;

@property (weak, nonatomic) IBOutlet UIButton *filmstripToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *togglePlaybackButton;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *scrubberSlider;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *scrubbingTimeLabel;


@property (weak, nonatomic) id <XTTransportDelegate> delegate;

- (IBAction)toggleFilmstrip:(id)sender;
- (IBAction)toggleControls:(id)sender;
- (IBAction)togglePlayback:(UIButton *)sender;
- (IBAction)closeWindow:(id)sender;
- (void)setCurrentTime:(NSTimeInterval)time;

@end
