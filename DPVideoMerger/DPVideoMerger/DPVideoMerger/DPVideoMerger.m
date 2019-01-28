//
//  DPVideoMerger.m
//  DPVideoMerger
//
//  Created by datt on 7/10/17.
//  Copyright © 2017 datt. All rights reserved.
//

#import "DPVideoMerger.h"
#import <AVFoundation/AVFoundation.h>
#define degreeToRadian(x) (M_PI * x / 180.0)

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
        BOOL  isVideoAssetPortrait_  = NO;
        CGAffineTransform videoTransform = videoAsset.preferredTransform;
        
        if(videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0)  { isVideoAssetPortrait_ = YES;}
        if(videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0)  { isVideoAssetPortrait_ = YES;}

        CGFloat videoAssetWidth = videoAsset.naturalSize.width;
        CGFloat videoAssetHeight = videoAsset.naturalSize.height;
        if(isVideoAssetPortrait_) {
            videoAssetWidth = videoAsset.naturalSize.height;
            videoAssetHeight = videoAsset.naturalSize.width;
        }
        
        if (videoSize.height < videoAssetHeight){
            videoSize.height = videoAssetHeight;
        }
        if (videoSize.width < videoAssetWidth){
            videoSize.width = videoAssetWidth;
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

            BOOL  isVideoAssetPortrait_  = NO;
            CGAffineTransform videoTransform = videoAsset.preferredTransform;
            UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
            if(videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0)  { videoAssetOrientation_= UIImageOrientationRight; isVideoAssetPortrait_ = YES; }
            if(videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0)  { videoAssetOrientation_ =  UIImageOrientationLeft; isVideoAssetPortrait_ = YES; }
            if(videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0)  { videoAssetOrientation_ =  UIImageOrientationUp; }
            if(videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) { videoAssetOrientation_ = UIImageOrientationDown; }
            
            CGFloat videoAssetWidth = videoAsset.naturalSize.width;
            CGFloat videoAssetHeight = videoAsset.naturalSize.height;
            if(isVideoAssetPortrait_) {
                videoAssetWidth = videoAsset.naturalSize.height;
                videoAssetHeight = videoAsset.naturalSize.width;
            }
            
            //Magic 😜
            int tx = 0;
            if (videoSize.width-videoAssetWidth != 0)
            {
                tx = (videoSize.width-videoAssetWidth)/2;
            }
            int ty = 0;
            if (videoSize.height-videoAssetHeight != 0)
            {
                ty = (videoSize.height-videoAssetHeight)/2;
            }
            CGAffineTransform Scale = CGAffineTransformMakeScale(1,1);
            float factor = 1.0;
            if (tx != 0 && ty!=0)
            {
                if (tx <= ty) {
                    factor = videoSize.width/videoAssetWidth;
                    Scale = CGAffineTransformMakeScale(factor,factor);
                    tx = 0;
                    ty = (videoSize.height-videoAssetHeight*factor)/2;
                }
                if (tx > ty) {
                    factor = videoSize.height/ videoAssetHeight;
                    Scale = CGAffineTransformMakeScale(factor,factor);
                    ty = 0;
                    tx = (videoSize.width-videoAssetWidth*factor)/2;
                }
            }
            CGAffineTransform Move;
            CGAffineTransform transform;
            switch (videoAssetOrientation_) {
                case UIImageOrientationRight:
                    Move = CGAffineTransformMakeTranslation((videoAssetWidth*factor)+tx,ty);
                    transform = CGAffineTransformMakeRotation(degreeToRadian(90));
                    [layerInstruction setTransform:CGAffineTransformConcat(transform,CGAffineTransformConcat(Scale,Move)) atTime:kCMTimeZero];
                    break;
                case UIImageOrientationLeft:
                    Move = CGAffineTransformMakeTranslation(tx,videoSize.height-ty);
                    transform = CGAffineTransformMakeRotation(degreeToRadian(270));
                    [layerInstruction setTransform:CGAffineTransformConcat(transform,CGAffineTransformConcat(Scale,Move)) atTime:kCMTimeZero];
                    break;
                case UIImageOrientationUp:
                    Move = CGAffineTransformMakeTranslation(tx,ty);
                    [layerInstruction setTransform: CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
                    break;
                case UIImageOrientationDown:
                    Move = CGAffineTransformMakeTranslation(videoSize.width+tx,(videoAssetHeight*factor)+ty);
                    transform = CGAffineTransformMakeRotation(degreeToRadian(180));
                    [layerInstruction setTransform:CGAffineTransformConcat(transform,CGAffineTransformConcat(Scale,Move)) atTime:kCMTimeZero];
                    break;
                default:
                    break;
            }

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
+ (void)gridMergeVideosWithFileURLs:(NSArray *)videoFileURLs
                 andVideoResolution:(CGSize)resolution
                         completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion {
    
    if (videoFileURLs.count != 4) {
        NSError *error = [[NSError alloc] initWithDomain:@"DPVideoMerger" code:404 userInfo:@{NSLocalizedDescriptionKey : @"Provide 4 Videos",NSLocalizedFailureReasonErrorKey : @"error"}];
        dispatch_async(dispatch_get_main_queue(), ^{
        completion(nil,error);
        });
        return;
    }
    
    AVMutableComposition* composition = [[AVMutableComposition alloc] init];
    
    __block CMTime maxTime = [AVURLAsset URLAssetWithURL:videoFileURLs[0] options:nil].duration;
    
    [videoFileURLs enumerateObjectsUsingBlock:^(NSURL *videoFileURL, NSUInteger idx, BOOL *stop) {
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoFileURL options:options];
        if (CMTimeCompare(maxTime, asset.duration) == -1) {
            maxTime = asset.duration;
        }
        
    }];
    
    AVMutableVideoCompositionInstruction * instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, maxTime);
    
    NSMutableArray *arrAVMutableVideoCompositionLayerInstruction = [NSMutableArray new];
    
    [videoFileURLs enumerateObjectsUsingBlock:^(NSURL *videoFileURL, NSUInteger idx, BOOL *stop) {
        AVURLAsset* asset = [AVURLAsset URLAssetWithURL:videoFileURL options:nil];
        
        AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        
        
        
        AVMutableVideoCompositionLayerInstruction *subInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        CGAffineTransform Scale = CGAffineTransformMakeScale(1,1);
        CGAffineTransform Move = CGAffineTransformMakeTranslation(0,0);
        int tx = 0;
        if (resolution.width/2-videoTrack.naturalSize.width != 0)
        {
            tx = (resolution.width/2-videoTrack.naturalSize.width)/2;
        }
        int ty = 0;
        if (resolution.height/2-videoTrack.naturalSize.height != 0)
        {
            ty = (resolution.height/2-videoTrack.naturalSize.height)/2;
        }
        
        if (tx != 0 && ty!=0)
        {
            if (tx <= ty) {
                float factor = resolution.width/2/videoTrack.naturalSize.width;
                Scale = CGAffineTransformMakeScale(factor,factor);
                tx = 0;
                ty = (resolution.height/2-videoTrack.naturalSize.height*factor)/2;
            }
            if (tx > ty) {
                float factor = resolution.height/2/ videoTrack.naturalSize.height;
                Scale = CGAffineTransformMakeScale(factor,factor);
                ty = 0;
                tx = (resolution.width/2-videoTrack.naturalSize.width*factor)/2;
            }
        }
        switch (idx) {
            case 0:
                Move = CGAffineTransformMakeTranslation(0+tx,0+ty);
                break;
            case 1:
                Move = CGAffineTransformMakeTranslation(resolution.width/2+tx,0+ty);
                break;
            case 2:
                Move = CGAffineTransformMakeTranslation(0+tx,resolution.height/2+ty);
                break;
            case 3:
                Move = CGAffineTransformMakeTranslation(resolution.width/2+tx,resolution.height/2+ty);
                break;
            default:
                break;
        }
      
        [subInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
        [arrAVMutableVideoCompositionLayerInstruction addObject:subInstruction];
    }];
    
    instruction.layerInstructions = arrAVMutableVideoCompositionLayerInstruction;
    
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:instruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
    MainCompositionInst.renderSize = resolution;
    
    NSURL *url = [NSURL fileURLWithPath:[DPVideoMerger generateMergedVideoFilePath]];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=url;
    [exporter setVideoComposition:MainCompositionInst];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    
    void(^exportCompletion)(void) = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(exporter.outputURL, exporter.error);
        });
    };
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch (exporter.status) {
            case AVAssetExportSessionStatusCompleted: {
                DLog(@"Successfully merged: %@", exporter.outputURL);
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

+ (NSString *)generateMergedVideoFilePath{
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-mergedVideo.mp4", [[NSUUID UUID] UUIDString]]];
}
@end
