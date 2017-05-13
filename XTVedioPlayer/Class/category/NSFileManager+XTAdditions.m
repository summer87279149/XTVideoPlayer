//
//  NSFileManager+XTAdditions.m
//  XTVideoPlayer
//
//  Created by Admin on 2017/5/13.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import "NSFileManager+XTAdditions.h"

@implementation NSFileManager (XTAdditions)
- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString {
    
    NSString *mkdTemplate =
    [NSTemporaryDirectory() stringByAppendingPathComponent:templateString];
    
    const char *templateCString = [mkdTemplate fileSystemRepresentation];
    char *buffer = (char *)malloc(strlen(templateCString) + 1);
    strcpy(buffer, templateCString);
    
    NSString *directoryPath = nil;
    
    char *result = mkdtemp(buffer);
    if (result) {
        directoryPath = [self stringWithFileSystemRepresentation:buffer
                                                          length:strlen(result)];
    }
    free(buffer);
    return directoryPath;
}

@end
