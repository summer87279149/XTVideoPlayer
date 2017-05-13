//
//  XTFlashControl.h
//  XTVideoPlayer
//
//  Created by Admin on 2017/5/13.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XTFlashControlDelegate <NSObject>

@optional
- (void)flashControlWillExpand;
- (void)flashControlDidExpand;
- (void)flashControlWillCollapse;
- (void)flashControlDidCollapse;

@end

@interface XTFlashControl : UIControl

@property (nonatomic) NSInteger selectedMode;
@property (weak, nonatomic) id<XTFlashControlDelegate> delegate;

@end
