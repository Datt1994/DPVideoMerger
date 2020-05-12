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

//videoQuality : AVAssetExportPresetMediumQuality(default) , AVAssetExportPresetLowQuality , AVAssetExportPresetHighestQuality


@interface DPVideoMerger : NSObject
+ (void)mergeVideosWithFileURLs:(NSArray *)videoFileURLs
                     completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;
+ (void)mergeVideosWithFileURLs:(NSArray *)videoFileURLs
                   andVideoSize:(CGSize)finalVideoSize
                     completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;
+ (void)mergeVideosWithFileURLs:(NSArray *)videoFileURLs
                andVideoQuality:(NSString *)videoQuality
                     completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;
+ (void)mergeVideosWithFileURLs:(NSArray *)videoFileURLs
                   andVideoSize:(CGSize)finalVideoSize
                andVideoQuality:(NSString *)videoQuality  //AVAssetExportPresetMediumQuality(default) , AVAssetExportPresetLowQuality , AVAssetExportPresetHighestQuality
                     completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;

+ (void)gridMergeVideosWithFileURLs:(NSArray *)videoFileURLs
                 andVideoResolution:(CGSize)resolution
                         completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;
+ (void)gridMergeVideosWithFileURLs:(NSArray *)videoFileURLs
                 andVideoResolution:(CGSize)resolution
                     andRepeatVideo:(BOOL)isRepeatVideo
                         completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;
+ (void)gridMergeVideosWithFileURLs:(NSArray *)videoFileURLs
                 andVideoResolution:(CGSize)resolution
                   andVideoDuration:(NSInteger)videoDuration
                         completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;
+ (void)gridMergeVideosWithFileURLs:(NSArray *)videoFileURLs
                 andVideoResolution:(CGSize)resolution
                    andVideoQuality:(NSString *)videoQuality
                         completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;
+ (void)gridMergeVideosWithFileURLs:(NSArray *)videoFileURLs
                 andVideoResolution:(CGSize)resolution
                     andRepeatVideo:(BOOL)isRepeatVideo
                    andVideoQuality:(NSString *)videoQuality
                         completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;
+ (void)gridMergeVideosWithFileURLs:(NSArray *)videoFileURLs
                 andVideoResolution:(CGSize)resolution
                     andRepeatVideo:(BOOL)isRepeatVideo
                   andVideoDuration:(NSInteger)videoDuration
                         completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;
+ (void)gridMergeVideosWithFileURLs:(NSArray *)videoFileURLs
                 andVideoResolution:(CGSize)resolution
                     andRepeatVideo:(BOOL)isRepeatVideo
                   andVideoDuration:(NSInteger)videoDuration
                    andVideoQuality:(NSString *)videoQuality  //AVAssetExportPresetMediumQuality(default) , AVAssetExportPresetLowQuality , AVAssetExportPresetHighestQuality
                         completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;
@end
