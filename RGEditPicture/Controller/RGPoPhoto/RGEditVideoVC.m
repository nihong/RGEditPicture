//
//  RGEditVideoVC.m
//  Vmei
//
//  Created by ios-02 on 2018/7/9.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "RGEditVideoVC.h"
#import "RGEditPhotoView.h"
#import <SCRecorder/SCVideoPlayerView.h>
#import <SCRecorder/SCAssetExportSession.h>
#import <SCRecorder/NSURL+SCSaveToCameraRoll.h>
#import <SCRecorder/SCSwipeableFilterView.h>
#import "HUDManager.h"
#import "PLSClipMovieView.h"
#import "DTVideoEngine.h"

#define kClipMovieBarH 150.f

@interface RGEditVideoVC ()<UICollectionViewDelegateFlowLayout,SCAssetExportSessionDelegate,PLSClipMovieViewDelegate,SCPlayerDelegate>

//滤镜层
//@property (strong, nonatomic)SCSwipeableFilterView *filterSwitcherView;

// @"剪裁"---剪切视频
@property (strong, nonatomic) PLSClipMovieView *clipMovieView;

// @"滤镜"---展示所有滤镜选项
//@property (strong, nonatomic) UICollectionView *filterCollectionView;


//视频输出
@property (strong, nonatomic) SCAssetExportSession *exportSession;
//轨道上左边的时间
@property (assign, nonatomic) CMTime leftTime;
//轨道上左边的时间
@property (assign, nonatomic) CMTime rightTime;


@property (strong, nonatomic) SCPlayer *player;

@end

@implementation RGEditVideoVC

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden  = YES;
    self.navigationController.tabBarController.tabBar.hidden = YES;
    //右划返回手势识别
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [_player setItemByAsset:_recordSession.assetRepresentingSegments];
    [_player play];
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [_player pause];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = HEXCOLOR(0x000000);
    
    
    //player layer
    self.leftTime = kCMTimeZero;
    self.rightTime = self.recordSession.duration;
    _player = [SCPlayer player];
    _player.delegate = self;
    _player.externalPlaybackVideoGravity = AVLayerVideoGravityResize;
    _player.loopEnabled = NO;
    
    SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
    playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-kClipMovieBarH);
    [self.view addSubview:playerView];
    __weak typeof(_player) weakPlayer = _player;
    WEAKSELF
    //监听时间进度
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:NULL usingBlock:^(CMTime time) {
        CMTime newTime = CMTimeConvertScale(time, 30, kCMTimeRoundingMethod_Default);
        if (CMTimeCompare(newTime, weakSelf.rightTime) == 0 && CMTimeGetSeconds(weakSelf.rightTime)>0) {
            [weakPlayer seekToTime:weakSelf.leftTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [weakPlayer play];
        }
        if (weakSelf.clipMovieView) {
            [weakSelf.clipMovieView setProgressBarPoisionWithSecond:CMTimeGetSeconds(time)];
        }
    }];
    
    
    //截图+进度
    AVAsset *asset = self.recordSession.assetRepresentingSegments;
    CGFloat duration = CMTimeGetSeconds(asset.duration);
    self.clipMovieView = [[PLSClipMovieView alloc] initWithMovieAsset:asset minDuration:3.0f maxDuration:duration];
    self.clipMovieView.frame = CGRectMake(0, kScreenHeight-kClipMovieBarH, kScreenWidth, kClipMovieBarH);
    self.clipMovieView.delegate = self;
    [self.view addSubview:self.clipMovieView];
    
    CGFloat barH = (iPhoneX)?44.f:20.f;
    
    //返回
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setImage:[UIImage imageNamed:@"rg_editPic_back"] forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(12.f, barH, 44.f, 44.f);
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    //完成
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishBtn setImage:[UIImage imageNamed:@"rg_editPic_selected"] forState:UIControlStateNormal];
    finishBtn.frame = CGRectMake(kScreenWidth-44.f-12.f, barH, 44.f, 44.f);
    [finishBtn addTarget:self action:@selector(finishBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishBtn];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [_player pause];
    _player = nil;
    
}




#pragma mark Important Method
-(void)cancelBtnClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)finishBtnClicked
{
    [self cropVideoAndSave];
}


#pragma mark - 裁剪视频的回调 PLSClipMovieView delegate
- (void)didStartDragView {
    [self.player pause];
}

- (void)clipFrameView:(PLSClipMovieView *)clipFrameView didEndDragLeftView:(CMTime)leftTime rightView:(CMTime)rightTime {
    
    self.leftTime = leftTime;
    self.rightTime = rightTime;
    
    [self.player seekToTime:leftTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.player play];
}

- (void)clipFrameView:(PLSClipMovieView *)clipFrameView isScrolling:(BOOL)scrolling {
    self.view.userInteractionEnabled = !scrolling;
}



#pragma mark Private Method


//截取并保存视频
-(void)cropVideoAndSave
{
    [HUDManager showHUDWithToShowStr:@"视频处理中..." HUDMode:MBProgressHUDModeText autoHide:NO afterDelay:0 userInteractionEnabled:NO];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:self.recordSession.assetRepresentingSegments presetName:AVAssetExportPresetHighestQuality] ;
    exportSession.outputURL = [NSURL fileURLWithPath:[DTVideoEngine getExportPath]];;;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.timeRange = CMTimeRangeFromTimeToTime(self.leftTime, self.rightTime);
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        BOOL status = NO;
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            status = YES;
        }
        
        if (status == YES) {
            AVURLAsset *cropedVideo = [AVURLAsset assetWithURL:exportSession.outputURL];
            [self saveVideo:cropedVideo];
        }else{
            [HUDManager showAutoHideHUDWithToShowStr:@"视频处理失败" HUDMode:MBProgressHUDModeText];
        }
    }];
    
}

//保存视频
-(void)saveVideo:(AVURLAsset *)cropedVideo
{
    [_player pause];
    
    SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:cropedVideo];
    exportSession.videoConfiguration.preset = SCPresetHighestQuality;
    exportSession.audioConfiguration.preset = SCPresetHighestQuality;
    exportSession.videoConfiguration.maxFrameRate = 600;
    exportSession.videoConfiguration.bitrate = 13000000;
    exportSession.outputUrl = [NSURL fileURLWithPath:[DTVideoEngine getExportPath]];
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.delegate = self;
    exportSession.contextType = SCContextTypeAuto;
    
    self.exportSession = exportSession;
    
    
    
    __weak typeof(self) wSelf = self;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        __strong typeof(self) strongSelf = wSelf;
        
        
        if (strongSelf != nil) {
            [strongSelf.player play];
            strongSelf.exportSession = nil;
            
        }
        
        NSError *error = exportSession.error;
        if (exportSession.cancelled) {
            [HUDManager showAutoHideHUDWithToShowStr:@"已取消操作" HUDMode:MBProgressHUDModeText];
        } else if (error == nil) {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [exportSession.outputUrl saveToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                
                if (error == nil) {
                    //视频保存（剪裁）
                    [HUDManager showAutoHideHUDWithToShowStr:@"保存成功" HUDMode:MBProgressHUDModeText];
                    BSPostContainImageItem *item = [[BSPostContainImageItem alloc] init];
                    
                    AVAsset *filterAsset = [AVAsset assetWithURL:exportSession.outputUrl];
                    item.originalImage =  [self thumbnailWithAsset:filterAsset];
                    item.resultUrl = exportSession.outputUrl.path;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPoPhotoVideoToVCNotificationKey object:item];
                    [strongSelf.navigationController.tabBarController dismissViewControllerAnimated:YES completion:nil];
                    
                } else {
                    [HUDManager showAutoHideHUDWithToShowStr:@"保存失败" HUDMode:MBProgressHUDModeText];
                }
            }];
        } else {
            if (!exportSession.cancelled) {
                [HUDManager showAutoHideHUDWithToShowStr:@"保存失败" HUDMode:MBProgressHUDModeText];
            }
        }
    }];
}



//截取asset首帧 处得图片
- (UIImage *)thumbnailWithAsset:(AVAsset *)asset {
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    NSError *error = nil;
    CGImageRef thumbnailImage = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:&error];
    
    if (error == nil) {
        return [UIImage imageWithCGImage:thumbnailImage];
    } else {
        return nil;
    }
}

@end
