//
//  DPVideoMerger.h
//  DPVideoMerger
//
//  Created by datt on 7/10/17.
//  Copyright © 2017 datt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#ifdef DEBUG
#define DLog(s, ...) NSLog(s, ##__VA_ARGS__)
#else
#define DLog(s, ...)
#endif

@interface DPVideoMerger : NSObject
+ (void)mergeVideosWithFileURLs:(NSArray *)videoFileURLs
             completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;
+ (void)gridMergeVideosWithFileURLs:(NSArray *)videoFileURLs
                 andVideoResolution:(CGSize)resolution
                         completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;
@end
