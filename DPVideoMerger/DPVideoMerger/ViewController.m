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
#import <Photos/Photos.h>
#import "VideoImgCell.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
    NSMutableArray<PHAsset *>  *arrImgAssets;
    PHCachingImageManager *imageManager;
    NSMutableArray<NSIndexPath *> *arrIndex;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _activityIndicator.hidden = YES;
    imageManager = [[PHCachingImageManager alloc] init];
    arrIndex = NSMutableArray.new;
    PHFetchResult *results = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:nil];
    arrImgAssets = [NSMutableArray arrayWithCapacity:results.count];
    
    [results enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self->arrImgAssets addObject:obj];
    }];
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
    NSMutableArray *fileURLs = [NSMutableArray new];
    [arrIndex enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [self->imageManager requestAVAssetForVideo:[self->arrImgAssets objectAtIndex:indexPath.row] options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            NSURL *url = (NSURL *)[[(AVURLAsset *)asset URL] fileReferenceURL];
            NSLog(@"%@",url);
            NSLog(@"url = %@", [url absoluteString]);
            NSLog(@"url = %@", [url relativePath]);
            [fileURLs addObject:url];
            if (fileURLs.count == self->arrIndex.count) {
                [DPVideoMerger mergeVideosWithFileURLs:fileURLs completion:^(NSURL *mergedVideoURL, NSError *error) {
                    [self.activityIndicator stopAnimating];
                    self.view.userInteractionEnabled=true;
                    self.activityIndicator.hidden = true;
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
            }
        }];
    }];
   
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp4"];
//    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
//    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"mp4"];
//    NSURL *fileURL1 = [NSURL fileURLWithPath:filePath1];
//    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"5" ofType:@"mp4"];
//    NSURL *fileURL2 = [NSURL fileURLWithPath:filePath2];
//    NSString *filePath3 = [[NSBundle mainBundle] pathForResource:@"7" ofType:@"mp4"];
//    NSURL *fileURL3 = [NSURL fileURLWithPath:filePath3];
//
//    NSArray *fileURLs = @[fileURL, fileURL1,fileURL2,fileURL3];
    
   

    
}

- (IBAction)btnGridMergeVideosAction:(UIButton *)sender {
    _activityIndicator.hidden = false;
    [_activityIndicator startAnimating];
    self.view.userInteractionEnabled=false;
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp4"];
//    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
//    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"mp4"];
//    NSURL *fileURL1 = [NSURL fileURLWithPath:filePath1];
//    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"3" ofType:@"MOV"];
//    NSURL *fileURL2 = [NSURL fileURLWithPath:filePath2];
//    NSString *filePath3 = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"mp4"];
//    NSURL *fileURL3 = [NSURL fileURLWithPath:filePath3];
//
//    NSArray *fileURLs = @[fileURL, fileURL1,fileURL2,fileURL3];
    NSMutableArray *fileURLs = [NSMutableArray new];
    [arrIndex enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [self->imageManager requestAVAssetForVideo:[self->arrImgAssets objectAtIndex:indexPath.row] options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            NSURL *url = (NSURL *)[[(AVURLAsset *)asset URL] fileReferenceURL];
            NSLog(@"%@",url);
            NSLog(@"url = %@", [url absoluteString]);
            NSLog(@"url = %@", [url relativePath]);
            [fileURLs addObject:url];
            if (fileURLs.count == self->arrIndex.count) {
                [DPVideoMerger gridMergeVideosWithFileURLs:fileURLs andVideoResolution:CGSizeMake(2000, 2000) andRepeatVideo:true completion:^(NSURL *mergedVideoURL, NSError *error) {
                    
                    [self.activityIndicator stopAnimating];
                    self.view.userInteractionEnabled=true;
                    self.activityIndicator.hidden = true;
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
            }
        }];
    }];
    
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return arrImgAssets.count;
}
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    VideoImgCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoImgCell" forIndexPath:indexPath];
    [imageManager requestImageForAsset:[arrImgAssets objectAtIndex:indexPath.row] targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.img.image = result;
    }];
   
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoImgCell *cell = (VideoImgCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.img.alpha = 1;
    if ([arrIndex containsObject:indexPath]) {
        [arrIndex removeObject:indexPath];
    } else {
        [arrIndex addObject:indexPath];
        cell.img.alpha = 0.5;
    }
    
}

@end
