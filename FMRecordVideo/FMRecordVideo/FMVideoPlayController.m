//
//  FMVideoPlayController.m
//  fmvideo
//
//  Created by qianjn on 2016/12/30.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "FMVideoPlayController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface FMVideoPlayController ()
@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;
@property (nonatomic, strong) NSString *from;

@property (nonatomic, strong) UIImage *videoCover;
@property (nonatomic, assign) NSTimeInterval enterTime;
@property (nonatomic, assign) BOOL hasRecordEvent;

@end

@implementation FMVideoPlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.videoPlayer = [[MPMoviePlayerController alloc] init];
    [self.videoPlayer.view setFrame:self.view.bounds];
    self.videoPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.videoPlayer.view];
    [self.videoPlayer prepareToPlay];
    self.videoPlayer.controlStyle = MPMovieControlStyleNone;
    self.videoPlayer.shouldAutoplay = YES;
    self.videoPlayer.repeatMode = MPMovieRepeatModeOne;
    self.title = NSLocalizedString(@"PreView", nil);
    
    
    self.videoPlayer.contentURL = self.videoUrl;
    [self.videoPlayer play];
    
    
    _enterTime = [[NSDate date] timeIntervalSince1970];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureFinished:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChanged) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.videoPlayer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    
}

- (void)commit
{
    }

#pragma mark - notification
#pragma state
- (void)stateChanged
{
    switch (self.videoPlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            [self trackPreloadingTime];
            break;
        case MPMoviePlaybackStatePaused:
            break;
        case MPMoviePlaybackStateStopped:
            break;
        default:
            break;
    }
}

-(void)videoFinished:(NSNotification*)aNotification{
    int value = [[aNotification.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (value == MPMovieFinishReasonPlaybackEnded) {   // 视频播放结束
      
    }
}


- (void)trackPreloadingTime
{
    
}

- (void)dismissAction
{
    [self.videoPlayer stop];
    self.videoPlayer = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.videoPlayer stop];
    self.videoPlayer = nil;
}


- (void)captureImageAtTime:(float)time
{
    [self.videoPlayer requestThumbnailImagesAtTimes:@[@(time)] timeOption:MPMovieTimeOptionNearestKeyFrame];
}

- (void)captureFinished:(NSNotification *)notification
{
    self.videoCover = notification.userInfo[MPMoviePlayerThumbnailImageKey];
    if (self.videoCover == nil) {
        self.videoCover = [self coverIamgeAtTime:1];
    }
}


- (UIImage*)coverIamgeAtTime:(NSTimeInterval)time {
    
    
    [self.videoPlayer requestThumbnailImagesAtTimes:@[@(time)] timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoUrl options:nil];
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : [UIImage new];
    
    return thumbnailImage;
}



@end