//
//  AVAsset+XTAdditions.m
//  XTVedioPlayer
//
//  Created by Admin on 2017/5/10.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import "AVAsset+XTAdditions.h"

@implementation AVAsset (XTAdditions)

- (NSString *)title {

    AVKeyValueStatus status =
        [self statusOfValueForKey:@"commonMetadata" error:nil];
    if (status == AVKeyValueStatusLoaded) {
        NSArray *items =
            [AVMetadataItem metadataItemsFromArray:self.commonMetadata
                                           withKey:AVMetadataCommonKeyTitle
                                          keySpace:AVMetadataKeySpaceCommon];
        if (items.count > 0) {
            AVMetadataItem *titleItem = [items firstObject];
            return (NSString *)titleItem.value;
        }
    }
    
    return nil;
}

@end
