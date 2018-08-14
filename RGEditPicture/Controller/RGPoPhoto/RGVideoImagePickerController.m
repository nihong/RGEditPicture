//
//  RGVideoImagePickerController.m
//  Vmei
//
//  Created by ios-02 on 2018/7/4.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "RGVideoImagePickerController.h"
#import "HUDManager.h"
#import "PoPhotoVideoVC.h"
#import "RGRecordVideoFunctionView.h"
#import "TZImagePickerController.h"
#import "TZPhotoPickerController.h"

#import <Photos/Photos.h>
#import <SCRecorder/SCRecorder.h>
#import "SCRecordSessionManager.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "WechatShortVideoConfig.h"
#import "DTVideoEngine.h"
#import "RGEditVideoVC.h"



@interface RGVideoImagePickerController ()<SCRecorderDelegate, UIImagePickerControllerDelegate>
{    
    
    SCRecorder *_recorder;
    UIImage *_photo;
//    SCRecordSession *_recordSession;
    
}

@property(nonatomic,strong)SCRecorderToolsView *focusView;


@property(nonatomic,strong)RGRecordViewProgressView *progressview;
@property(nonatomic,strong)UILabel *timeRecordedLabel;

@property(nonatomic,strong)UIButton *quitBtn;
@property(nonatomic,strong)UIButton *nextBtn;

@property(nonatomic,strong)UIButton *deletelastBtn;
@property(nonatomic,strong)UIButton *recordBtn;
@property(nonatomic,strong)UIButton *rotateCameraBtn;

@end

@implementation RGVideoImagePickerController

#pragma mark - life cycle

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    

    [self showOtherFunctionBtn:YES];
    
//    for (UITabBarItem *item in self.tabBarController.tabBar.items) {
//        [item setTitleTextAttributes:@{NSFontAttributeName:SP15Font,NSForegroundColorAttributeName:HEXCOLOR(0xffffff)} forState:UIControlStateSelected];
//    }
    
    
    [self prepareSession];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_recorder startRunning];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    

    [_recorder stopRunning];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.recordBtn.selected = NO;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    _recorder = [SCRecorder recorder];
    _recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    _recorder.maxRecordDuration = CMTimeMake(VIDEO_TIME_SCALE * VIDEO_MAX_TIME, VIDEO_TIME_SCALE);
    //    _recorder.fastRecordMethodEnabled = YES;
    
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = NO; //YES causes bad orientation for video from camera roll
//    _recorder.keepMirroringOnWrite = YES;
    
    
    
    
    UIView *previewView = [[UIView alloc]initWithFrame:self.view.bounds];
    previewView.backgroundColor = HEXCOLOR(0x000000);
    _recorder.previewView = previewView;
    
    
    self.focusView = [[SCRecorderToolsView alloc] initWithFrame:previewView.bounds];
    self.focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.focusView.recorder = _recorder;
    [previewView addSubview:self.focusView];
    
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"WechatShortVideo_scan_focus"];
//    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"WechatShortVideo_scan_focus"];
    
    _recorder.initializeSessionLazily = NO;
    
    NSError *error;
    if (![_recorder prepare:&error]) {
        NSLog(@"Prepare error: %@", error.localizedDescription);
    }
    
    [self.view addSubview:previewView];
    
    [self configUI];
    

    
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _recorder.previewView = nil;
}


#pragma mark - Important Function Method
//返回
-(void)navLeftBtnClick
{
    
    UIAlertController *tipController = [UIAlertController alertControllerWithTitle:nil message:@"尚未完成拍摄，确认退出？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *quitAlert = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    }];
    [tipController addAction:cancelAlert];
    [tipController addAction:quitAlert];
    [self presentViewController:tipController animated:YES completion:nil];
    
}

//下一步
-(void)navRightBtnClick
{
    if (_recorder.session.segments.count > 0) {
        
        [[SCRecordSessionManager sharedInstance] saveRecordSession:_recorder.session];
        WEAKSELF
        [_recorder pause:^{
            STRONGSELF
            [strongSelf pushToNewVC];
        }];
    }else{
        
    }

}

-(void)pushToNewVC
{
    if (CMTimeGetSeconds(_recorder.session.duration)>=3.f) {
        RGEditVideoVC *vc = [[RGEditVideoVC alloc]init];
        vc.recordSession = _recorder.session;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [HUDManager showAutoHideHUDWithToShowStr:@"视频至少录制3秒" HUDMode:MBProgressHUDModeText];
    }

}

//删除之前视频
-(void)leftBtnClick:(UIButton *)flashBtn
{
    if (_recorder.session.segments.count> 0 ) {
        [_recorder.session removeLastSegment];
        WEAKSELF
        [_recorder.session dispatchSyncOnSessionQueue:^{
            STRONGSELF
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateTimeRecordedLabel];
                self.nextBtn.selected = [strongSelf->_recorder.session.segments isAbsoluteValid];
                self.deletelastBtn.hidden = ![strongSelf->_recorder.session.segments isAbsoluteValid];
            });
        }];
        
    }else{
        [HUDManager showAutoHideHUDWithToShowStr:@"还未录制，无法删除上一段视频" HUDMode:MBProgressHUDModeText];
    }
}
//录制视频|停止录制
- (void)handleTouchDetected:(UIButton*)btn
{
    btn.selected = !btn.selected;
    if (btn.selected == YES) {
        [_recorder record];
        [self showOtherFunctionBtn:NO];
        self.navigationController.tabBarController.tabBar.hidden = YES;
    }else{
        [_recorder pause];
        [self showOtherFunctionBtn:YES];
        self.navigationController.tabBarController.tabBar.hidden = NO;
    }
}

//前置 后置
-(void)rightBtnClick
{
    [_recorder switchCaptureDevices];
}



#pragma mark - SCRecorder Delegate
- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    //到达最大录制时间，执行下一步
    [self navRightBtnClick];
}



- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    [self updateTimeRecordedLabel];
}

- (void)recorder:(SCRecorder *__nonnull)recorder didCompleteSegment:(SCRecordSessionSegment *__nullable)segment inSession:(SCRecordSession *__nonnull)session error:(NSError *__nullable)error
{
    if ([recorder.session.segments isAbsoluteValid]) {
        _nextBtn.selected = YES;
        _deletelastBtn.hidden = NO;
    }
}


#pragma mark - Other Method

-(void)showOtherFunctionBtn:(BOOL)show
{
    _quitBtn.hidden = !show;
    _nextBtn.hidden = !show;    
    _rotateCameraBtn.hidden = !show;
    if (show == NO) {
        _deletelastBtn.hidden = YES;
    }
}


- (void)prepareSession {
    if (_recorder.session == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.session = session;
    }
    
    [self updateTimeRecordedLabel];
    
}

- (void)updateTimeRecordedLabel {
    CMTime currentTime = kCMTimeZero;
    
    if (_recorder.session != nil) {
        currentTime = _recorder.session.duration;
    }
    
    self.timeRecordedLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)roundf(CMTimeGetSeconds(currentTime)/60) ,(NSInteger)CMTimeGetSeconds(currentTime) %60];
    self.progressview.percent = CMTimeGetSeconds(currentTime)/VIDEO_MAX_TIME;
}


-(void)configUI
{
    //    CGFloat y = IPHONEX?StatusBarHeight:0;
    CGFloat y = iPhoneX?StatusBarHeight:0;
    _progressview = [[RGRecordViewProgressView alloc]initWithFrame:CGRectMake(0, y, kScreenWidth, 6)];
    [self.view addSubview:_progressview];
    
    _quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _quitBtn.frame = CGRectMake(0, 0, 44, 44);
    [_quitBtn setImage:[UIImage imageNamed:@"rg_editPic_back"] forState:UIControlStateNormal];
    [_quitBtn addTarget:self action:@selector(navLeftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_quitBtn];
    
    [_quitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
        make.top.mas_equalTo(_progressview.mas_bottom);
        make.left.mas_equalTo(self.view.mas_left).offset(12.f);
    }];
    
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextBtn.frame = CGRectMake(0, 0, 44, 44);
    [_nextBtn setImage:[UIImage imageNamed:@"rg_editVideo"] forState:UIControlStateNormal];
    [_nextBtn setImage:[UIImage imageNamed:@"rg_editVideo_selected"] forState:UIControlStateSelected];
    [self.view addSubview:_nextBtn];
    [_nextBtn addTarget:self action:@selector(navRightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
        make.top.mas_equalTo(_progressview.mas_bottom);
        make.right.mas_equalTo(self.view.mas_right).offset(-12.f);
    }];
    
    
    
    _deletelastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _deletelastBtn.frame = CGRectMake(0, 0, 44, 44);
    //自动（normal）-> 关闭（heightLight）-> 开启（selected）
    [_deletelastBtn setImage:[UIImage imageNamed:@"rg_deleteVideo"] forState:UIControlStateNormal];
    [self.view addSubview:_deletelastBtn];
    [_deletelastBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _deletelastBtn.hidden = YES;
    
    [_deletelastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
        make.centerY.mas_equalTo(self.view.mas_bottom).offset(-self.tabBarController.tabBar.height-50);
        make.left.mas_equalTo(self.view.mas_left).offset(44.f);
    }];
    
    
    _recordBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    [_recordBtn setImage:[UIImage imageNamed:@"rg_video_white"] forState:UIControlStateNormal];
    [_recordBtn setImage:[UIImage imageNamed:@"rg_videoing_white"] forState:UIControlStateSelected];
    [self.recordBtn addTarget:self action:@selector(handleTouchDetected:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recordBtn];
    
    [_recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(88.f, 88.f));
        make.centerY.mas_equalTo(_deletelastBtn);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    _rotateCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rotateCameraBtn.frame = CGRectMake(0, 0, 44, 44);
    [_rotateCameraBtn setImage:[UIImage imageNamed:@"rg_whiteCamera"] forState:UIControlStateNormal];
    [self.view addSubview:_rotateCameraBtn];
    [_rotateCameraBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_rotateCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
        make.centerY.mas_equalTo(_deletelastBtn);
        make.right.mas_equalTo(self.view.mas_right).offset(-44.f);
    }];
    
    
    //时间
    _timeRecordedLabel = [[UILabel alloc]init];
    _timeRecordedLabel.textColor = HEXCOLOR(0xffffff);
    _timeRecordedLabel.backgroundColor = [UIColor clearColor];
    _timeRecordedLabel.font = SP12Font;
    [self.view addSubview:_timeRecordedLabel];
    [_timeRecordedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_recordBtn);
        make.centerY.mas_equalTo(_recordBtn).offset(-44-22);
    }];
    
}


@end









