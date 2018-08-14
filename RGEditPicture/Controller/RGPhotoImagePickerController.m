//
//  RGPhotoImagePickerController.m
//  Vmei
//
//  Created by ios-02 on 2018/7/3.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "RGPhotoImagePickerController.h"
#import "HUDManager.h"
#import "RGRecordVideoFunctionView.h"
#import "TZImagePickerController.h"
#import "TZPhotoPickerController.h"

#import <Photos/Photos.h>
#import <SCRecorder/SCRecorder.h>
#import "SCRecordSessionManager.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "DTVideoEngine.h"
#import "RGEditPhotosVC.h"




@interface RGPhotoImagePickerController ()<SCRecorderDelegate, UIImagePickerControllerDelegate>
{
    
    SCRecorder *_recorder;
    UIImage *_photo;
    SCRecordSession *_recordSession;
    
}

@property(nonatomic,strong)SCRecorderToolsView *focusView;
@property(nonatomic,strong)UIButton *quitBtn;
@property(nonatomic,strong)UIButton *flashBtn;
@property(nonatomic,strong)UIButton *recordBtn;
@property(nonatomic,strong)UIButton *rotateCameraBtn;
@property(nonatomic,strong)UIView *toolBarBackgroundView;

@end

@implementation RGPhotoImagePickerController

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
    

    [self prepareSession];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.tabBarController.tabBar.hidden = NO;
    
    
    //底部工具栏动画
    _toolBarBackgroundView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight-self.tabBarController.tabBar.height-100.f);
    [UIView animateWithDuration:.6f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _toolBarBackgroundView.frame = CGRectMake(0, kScreenHeight-self.tabBarController.tabBar.height-100.f, kScreenWidth, self.tabBarController.tabBar.height+100.f);
    }];
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
    _recorder.delegate = self;
    _recorder.captureSessionPreset = AVCaptureSessionPresetPhoto;
    _recorder.keepMirroringOnWrite = YES;    
    _recorder.initializeSessionLazily = NO;
    
    
    UIView *previewView = [[UIView alloc]initWithFrame:self.view.bounds];
    previewView.backgroundColor = HEXCOLOR(0x000000);
    
    
    self.focusView = [[SCRecorderToolsView alloc] initWithFrame:previewView.bounds];
    self.focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.focusView.recorder = _recorder;
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"WechatShortVideo_scan_focus"];
    //    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"WechatShortVideo_scan_focus"];
    [previewView addSubview:self.focusView];
    
    
    _recorder.previewView = previewView;
    [self.view addSubview:previewView];
    
    
    NSError *error;
    if (![_recorder prepare:&error]) {
        NSLog(@"Prepare error: %@", error.localizedDescription);
    }
    
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




//闪光灯设置
-(void)flashBtnClick:(UIButton *)flashBtn
{
    
    if ([_recorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        NSString *imageName ;
        switch (_recorder.flashMode) {
            case SCFlashModeAuto:
                imageName = @"rg_flashOff";
                _recorder.flashMode = SCFlashModeOff;
                break;
            case SCFlashModeOff:
                imageName = @"rg_flashOn";
                _recorder.flashMode = SCFlashModeOn;
                break;
            case SCFlashModeOn:
                imageName = @"rg_flashOn";
                _recorder.flashMode = SCFlashModeAuto;
                break;
            default:
                break;
        }
        
        [flashBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }

}
//录制视频|停止录制
- (void)handleTouchDetected:(UIButton*)btn
{
    WEAKSELF
    [_recorder capturePhoto:^(NSError *error, UIImage *image) {
        if (image != nil) {
            RGEditPhotosVC *vc = [[RGEditPhotosVC alloc]initWithPhotos:@[image]];
            STRONGSELF
            [strongSelf.navigationController pushViewController:vc animated:YES];
        } else {
            [HUDManager showAutoHideHUDWithToShowStr:@"拍照失败，请重试" HUDMode:MBProgressHUDModeText];
        }
    }];
}

//前置 后置
-(void)rightBtnClick
{
    [_recorder switchCaptureDevices];
}



#pragma mark - Other Method



- (void)prepareSession {
    if (_recorder.session == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.session = session;
    }
}


-(void)configUI
{
    
    _quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _quitBtn.frame = CGRectMake(0, 0, 44, 44);
    [_quitBtn setImage:[UIImage imageNamed:@"rg_editPic_back"] forState:UIControlStateNormal];
    [_quitBtn addTarget:self action:@selector(navLeftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_quitBtn];
    
    [_quitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
        make.top.mas_equalTo(self.view.mas_top).offset(20.f);
        make.left.mas_equalTo(self.view.mas_left).offset(12.f);
    }];
    
    
    
    _toolBarBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 0)];
    _toolBarBackgroundView.backgroundColor = HEXCOLOR(0xffffff);
    [self.view addSubview:_toolBarBackgroundView];
    
    
    _flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _flashBtn.frame = CGRectMake(0, 0, 44, 44);
    //自动（normal）-> 关闭（heightLight）-> 开启（selected）
    [_flashBtn setImage:[UIImage imageNamed:@"rg_flashAuto"] forState:UIControlStateNormal];
    [self.view addSubview:_flashBtn];
    [_flashBtn addTarget:self action:@selector(flashBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
        make.centerY.mas_equalTo(self.view.mas_bottom).offset(-self.tabBarController.tabBar.height-50.f);
        make.left.mas_equalTo(self.view.mas_left).offset(44.f);
    }];
    
    
    _recordBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    [_recordBtn setImage:[UIImage imageNamed:@"rg_takePhoto_red"] forState:UIControlStateNormal];
    [self.recordBtn addTarget:self action:@selector(handleTouchDetected:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recordBtn];
    
    [_recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(88.f, 88.f));
        make.centerY.mas_equalTo(_flashBtn);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    _rotateCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rotateCameraBtn.frame = CGRectMake(0, 0, 44, 44);
    [_rotateCameraBtn setImage:[UIImage imageNamed:@"rg_grayCamera"] forState:UIControlStateNormal];
    [self.view addSubview:_rotateCameraBtn];
    [_rotateCameraBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_rotateCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
        make.centerY.mas_equalTo(_flashBtn);
        make.right.mas_equalTo(self.view.mas_right).offset(-44.f);
    }];
    
    
    
}


@end




