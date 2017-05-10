//
//  XTPlayerManager.h
//  XTVedioPlayer
//
//  Created by Admin on 2017/5/10.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface XTPlayerManager : NSObject
- (id)initWithURL:(NSURL *)assetURL;
//这个属性就是是调用者能把播放器view添加到他自己的控制器中的一个只读属性
//其实是THPlyaerView实例，这里用UIView隐藏它
@property (strong, nonatomic, readonly) UIView *view;

@end
