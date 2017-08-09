//
//  DPVideoMerger.m
//  DPVideoMerger
//
//  Created by datt on 7/10/17.
//  Copyright © 2017 datt. All rights reserved.
//

#import "DPVideoMerger.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@implementation DPVideoMerger
+ (void)mergeVideosWithFileURLs:(NSArray *)videoFileURLs
                     completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion
{
    
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSMutableArray *instructions = [NSMutableArray new];
    
    __block BOOL isError = NO;
    __block CMTime currentTime = kCMTimeZero;
    __block CGSize videoSize = CGSizeZero;
    __block int32_t highestFrameRate = 0;
    [videoFileURLs enumerateObjectsUsingBlock:^(NSURL *videoFileURL, NSUInteger idx, BOOL *stop) {
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoFileURL options:options];
        AVAssetTrack *videoAsset = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        if (CGSizeEqualToSize(videoSize, CGSizeZero)) {
            videoSize = videoAsset.naturalSize;
        }
        if (videoSize.height < videoAsset.naturalSize.height){
            videoSize.height = videoAsset.naturalSize.height;
        }
        if (videoSize.width < videoAsset.naturalSize.width){
            videoSize.width = videoAsset.naturalSize.width;
        }
    }];
    [videoFileURLs enumerateObjectsUsingBlock:^(NSURL *videoFileURL, NSUInteger idx, BOOL *stop) {
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoFileURL options:options];
        AVAssetTrack *videoAsset = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        AVAssetTrack *audioAsset = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        
        
        int32_t currentFrameRate = (int)roundf(videoAsset.nominalFrameRate);
        highestFrameRate = (currentFrameRate > highestFrameRate) ? currentFrameRate : highestFrameRate;
        
        
        CMTime trimmingTime = CMTimeMake(lround(videoAsset.naturalTimeScale / videoAsset.nominalFrameRate), videoAsset.naturalTimeScale);
        CMTimeRange timeRange = CMTimeRangeMake(trimmingTime, CMTimeSubtract(videoAsset.timeRange.duration, trimmingTime));
        
        
        NSError *videoError,*audioError;
        BOOL videoResult = [videoTrack insertTimeRange:timeRange ofTrack:videoAsset atTime:currentTime error:&videoError];
        BOOL audioResult = [audioTrack insertTimeRange:timeRange ofTrack:audioAsset atTime:currentTime error:&audioError];
        if (!audioResult || audioError){
            DLog(@"%@", audioError);
        }
        if(!videoResult || videoError) {
            if (completion){
                completion(nil, videoError);}
            isError = YES;
            *stop = YES;
        } else {
            AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            videoCompositionInstruction.timeRange = CMTimeRangeMake(currentTime, timeRange.duration);
            
            AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            //Magic 😜
            int tx = 0;
            if (videoSize.width-videoAsset.naturalSize.width != 0)
            {
                tx = (videoSize.width-videoAsset.naturalSize.width)/2;
            }
            int ty = 0;
            if (videoSize.height-videoAsset.naturalSize.height != 0)
            {
                ty = (videoSize.height-videoAsset.naturalSize.height)/2;
            }
            CGAffineTransform Scale = CGAffineTransformMakeScale(1,1);
            
            if (tx != 0 && ty!=0)
            {
                if (tx <= ty) {
                    float factor = videoSize.width/videoAsset.naturalSize.width;
                    Scale = CGAffineTransformMakeScale(factor,factor);
                    tx = 0;
                    ty = (videoSize.height-videoAsset.naturalSize.height*factor)/2;
                }
                if (tx > ty) {
                    float factor = videoSize.height/ videoAsset.naturalSize.height;
                    Scale = CGAffineTransformMakeScale(factor,factor);
                    ty = 0;
                    tx = (videoSize.width-videoAsset.naturalSize.width*factor)/2;
                }
            }
            CGAffineTransform Move = CGAffineTransformMakeTranslation(tx,ty);
            
            [layerInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
            videoCompositionInstruction.layerInstructions = @[layerInstruction];
            
            [instructions addObject:videoCompositionInstruction];
            currentTime = CMTimeAdd(currentTime, timeRange.duration);
        }
    }];
    
    if (isError == NO) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
        NSString *strFilePath = [DPVideoMerger generateMergedVideoFilePath];
        exportSession.outputURL = [NSURL fileURLWithPath:strFilePath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
        mutableVideoComposition.instructions = instructions;
        mutableVideoComposition.frameDuration = CMTimeMake(1, highestFrameRate);
        mutableVideoComposition.renderSize = videoSize;
        exportSession.videoComposition = mutableVideoComposition;
        
        DLog(@"Composition Duration: %ld s", lround(CMTimeGetSeconds(composition.duration)));
        DLog(@"Composition Framerate: %d fps", highestFrameRate);
        
        void(^exportCompletion)(void) = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(exportSession.outputURL, exportSession.error);
            });
        };
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch (exportSession.status) {
                case AVAssetExportSessionStatusCompleted: {
                    DLog(@"Successfully merged: %@", strFilePath);
                    exportCompletion();
                    break;
                }
                case AVAssetExportSessionStatusFailed:{
                    DLog(@"Failed");
                    exportCompletion();
                    break;
                }
                case AVAssetExportSessionStatusCancelled:{
                    DLog(@"Cancelled");
                    exportCompletion();
                    break;
                }
                case AVAssetExportSessionStatusUnknown: {
                    DLog(@"Unknown");
                }
                case AVAssetExportSessionStatusExporting : {
                    DLog(@"Exporting");
                }
                case AVAssetExportSessionStatusWaiting: {
                    DLog(@"Wating");
                }
            };
        }];
    }
}


+ (NSString *)generateMergedVideoFilePath{
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-mergedVideo.mp4", [[NSUUID UUID] UUIDString]]];
}
@end
