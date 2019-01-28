//
//  ViewController.h
//  DPVideoMerger
//
//  Created by datt on 7/10/17.
//  Copyright © 2017 datt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *videoImgCV;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)btnMergeVideosAction:(id)sender;
- (IBAction)btnGridMergeVideosAction:(UIButton *)sender;

@end

