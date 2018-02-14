# DPVideoMerger

Step 1:-  Copy & paste DPVideoMerger.h & DPVideoMerger.m files into your project 

Step 2:-  Usage 

    #import "DPVideoMerger.h"
    #import <AVKit/AVKit.h>
    #import <AVFoundation/AVFoundation.h>

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp4"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"mp4"];
    NSURL *fileURL1 = [NSURL fileURLWithPath:filePath1];
    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"3" ofType:@"MOV"];
    NSURL *fileURL2 = [NSURL fileURLWithPath:filePath2];
    NSString *filePath3 = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"mp4"];
    NSURL *fileURL3 = [NSURL fileURLWithPath:filePath3];
    
    NSArray *fileURLs = @[fileURL, fileURL1,fileURL2,fileURL3];
    
    [DPVideoMerger mergeVideosWithFileURLs:fileURLs completion:^(NSURL *mergedVideoFile, NSError *error) {
        if (error) {
            NSString *errorMessage = [NSString stringWithFormat:@"Could not merge videos: %@", [error localizedDescription]];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        AVPlayerViewController *objAVPlayerVC = [[AVPlayerViewController alloc] init];
        objAVPlayerVC.player = [AVPlayer playerWithURL:mergedVideoFile];
        [self presentViewController:objAVPlayerVC animated:YES completion:^{
            [objAVPlayerVC.player play];
        }];
    }];
