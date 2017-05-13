//
//  NSFileManager+XTAdditions.h
//  XTVideoPlayer
//
//  Created by Admin on 2017/5/13.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (XTAdditions)
- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString;
@end
