//
//  XTCameraView.m
//  XTVideoPlayer
//
//  Created by Admin on 2017/5/13.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import "XTCameraView.h"

@interface XTCameraView ()

@property (weak, nonatomic)IBOutlet  XTPreviewView *previewView;
@property (weak, nonatomic) IBOutlet XTOverlayView *controlsView;

@end

@implementation XTCameraView

- (void)awakeFromNib {
    self.backgroundColor = [UIColor blackColor];
}

@end
