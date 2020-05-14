## DPVideoMerger

**For Swift** :- [DPVideoMerger-Swift](https://github.com/Datt1994/DPVideoMerger-Swift)


## Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C. You can install it with the following command:

```bash
$ gem install cocoapods
```
#### Podfile

To integrate DPVideoMerger into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'TargetName' do
pod 'DPVideoMerger'
end
```

Then, run the following command:

```bash
$ pod install
```


## Add Manually 
  
  Download Project and copy-paste `DPVideoMerger.h` & `DPVideoMerger.m` files into your project 

## Usage 

```objc
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
    
    [DPVideoMerger gridMergeVideosWithFileURLs:fileURLs andVideoResolution:CGSizeMake(2000, 2000) andRepeatVideo:true completion:^(NSURL *mergedVideoURL, NSError *error) {
        if (error) {
            NSString *errorMessage = [NSString stringWithFormat:@"Could not merge videos: %@", [error localizedDescription]];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        AVPlayerViewController *objAVPlayerVC = [[AVPlayerViewController alloc] init];
        objAVPlayerVC.player = [AVPlayer playerWithURL:mergedVideoURL];
        [self presentViewController:objAVPlayerVC animated:YES completion:^{
            [objAVPlayerVC.player play];
        }];
    }];
```
