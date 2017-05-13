//
//  XTStatusView.h
//  XTVideoPlayer
//
//  Created by Admin on 2017/5/13.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "XTFlashControl.h"

@interface XTStatusView : UIView <XTFlashControlDelegate>

@property (strong, nonatomic)  XTFlashControl *flashControl;
@property (strong, nonatomic)  UILabel *elapsedTimeLabel;
@end
