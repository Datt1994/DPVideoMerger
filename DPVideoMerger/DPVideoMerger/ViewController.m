//
//  ViewController.m
//  DPVideoMerger
//
//  Created by datt on 7/10/17.
//  Copyright © 2017 datt. All rights reserved.
//

#import "ViewController.h"
#import "DPVideoMerger.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _activityIndicator.hidden = YES;
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnMergeVideosAction:(id)sender {
    _activityIndicator.hidden = false;
    [_activityIndicator startAnimating];
    self.view.userInteractionEnabled=false;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp4"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"mp4"];
    NSURL *fileURL1 = [NSURL fileURLWithPath:filePath1];
    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"3" ofType:@"MOV"];
    NSURL *fileURL2 = [NSURL fileURLWithPath:filePath2];
    NSString *filePath3 = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"mp4"];
    NSURL *fileURL3 = [NSURL fileURLWithPath:filePath3];
    
    NSArray *fileURLs = @[fileURL, fileURL1,fileURL2,fileURL3];
    
    [DPVideoMerger mergeVideosWithFileURLs:fileURLs completion:^(NSURL *mergedVideoURL, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.view.userInteractionEnabled=true;
        self.activityIndicator.hidden = true;
        if (error) {
            
            NSString *errorMessage = [NSString stringWithFormat:@"Could not merge videos: %@", [error localizedDescription]];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        AVPlayerViewController *objAVPlayerVC = [[AVPlayerViewController alloc] init];
        objAVPlayerVC.player = [AVPlayer playerWithURL:mergedVideoURL];
        [self presentViewController:objAVPlayerVC animated:YES completion:^{
            [objAVPlayerVC.player play];
        }];
    }];

    
}

- (IBAction)btnGridMergeVideosAction:(UIButton *)sender {
    _activityIndicator.hidden = false;
    [_activityIndicator startAnimating];
    self.view.userInteractionEnabled=false;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp4"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"mp4"];
    NSURL *fileURL1 = [NSURL fileURLWithPath:filePath1];
    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"3" ofType:@"MOV"];
    NSURL *fileURL2 = [NSURL fileURLWithPath:filePath2];
    NSString *filePath3 = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"mp4"];
    NSURL *fileURL3 = [NSURL fileURLWithPath:filePath3];
    
    NSArray *fileURLs = @[fileURL, fileURL1,fileURL2,fileURL3];
    
    [DPVideoMerger gridMergeVideosWithFileURLs:fileURLs andVideoResolution:CGSizeMake(1920, 1080) completion:^(NSURL *mergedVideoURL, NSError *error) {

        [self.activityIndicator stopAnimating];
        self.view.userInteractionEnabled=true;
        self.activityIndicator.hidden = true;
        if (error) {
            
            NSString *errorMessage = [NSString stringWithFormat:@"Could not merge videos: %@", [error localizedDescription]];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        AVPlayerViewController *objAVPlayerVC = [[AVPlayerViewController alloc] init];
        objAVPlayerVC.player = [AVPlayer playerWithURL:mergedVideoURL];
        [self presentViewController:objAVPlayerVC animated:YES completion:^{
            [objAVPlayerVC.player play];
        }];
    }];
}
@end
