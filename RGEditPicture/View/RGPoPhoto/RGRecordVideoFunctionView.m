//
//  RGRecordVideoFunctionView.m
//  Vmei
//
//  Created by ios-02 on 2018/7/4.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "RGRecordVideoFunctionView.h"

@implementation RGRecordVideoFunctionView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _quitBtn.frame = CGRectMake(0, 0, 44, 44);
        [_quitBtn setImage:[UIImage imageNamed:@"rg_editPic_back"] forState:UIControlStateNormal];
        
        
        [self addSubview:_quitBtn];
        
        [_quitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
            make.top.mas_equalTo(self.mas_top).offset(20.f);
            make.left.mas_equalTo(self.mas_left).offset(12.f);
        }];
        
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextBtn.frame = CGRectMake(0, 0, 44, 44);
        [_nextBtn setImage:[UIImage imageNamed:@"rg_editVideo"] forState:UIControlStateNormal];
        [self addSubview:_nextBtn];
        
        [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
            make.top.mas_equalTo(self.mas_top).offset(20.f);
            make.right.mas_equalTo(self.mas_right).offset(-12.f);
        }];
        
        
        
        UIView *bottomView = [[UIView alloc]init];
        bottomView.backgroundColor = [UIColor clearColor];
        [self addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kScreenWidth, 100.f+49.f));
            make.bottom.mas_equalTo(self.mas_bottom);
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
        
        _deletelastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deletelastBtn.frame = CGRectMake(0, 0, 44, 44);
        //自动（normal）-> 关闭（heightLight）-> 开启（selected）
        [_deletelastBtn setImage:[UIImage imageNamed:@"rg_deleteVideo"] forState:UIControlStateNormal];
        [bottomView addSubview:_deletelastBtn];
        
        [_deletelastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
            make.centerY.mas_equalTo(bottomView.mas_centerY).offset(-49/2.f);
            make.left.mas_equalTo(bottomView.mas_left).offset(44.f);
        }];
        
        
        
        _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordBtn.frame = CGRectMake(0, 0, 88, 88);
        [_recordBtn setImage:[UIImage imageNamed:@"rg_video_white"] forState:UIControlStateNormal];
        [_recordBtn setImage:[UIImage imageNamed:@"rg_videoing_white"] forState:UIControlStateSelected];
        [bottomView addSubview:_recordBtn];
        
        [_recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(88.f, 88.f));
            make.centerY.mas_equalTo(bottomView.mas_centerY).offset(-49/2.f);
            make.centerX.mas_equalTo(bottomView);
        }];
        
        _rotateCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rotateCameraBtn.frame = CGRectMake(0, 0, 44, 44);
        [_rotateCameraBtn setImage:[UIImage imageNamed:@"rg_whiteCamera"] forState:UIControlStateNormal];
        [bottomView addSubview:_rotateCameraBtn];
        
        [_rotateCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
            make.centerY.mas_equalTo(bottomView.mas_centerY).offset(-49/2.f);
            make.right.mas_equalTo(bottomView.mas_right).offset(-44.f);
        }];
        
    }
    return self;
}


@end





@implementation RGTakePicBottomView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _navLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _navLeftBtn.frame = CGRectMake(0, 0, 44, 44);
        [_navLeftBtn setImage:[UIImage imageNamed:@"RGFaceQuit"] forState:UIControlStateNormal];
        
        
        [self addSubview:_navLeftBtn];
        
        [_navLeftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
            make.top.mas_equalTo(self.mas_top).offset(20.f);
            make.left.mas_equalTo(self.mas_left).offset(12.f);
        }];
        
        _navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _navRightBtn.frame = CGRectMake(0, 0, 44, 44);
        [_navRightBtn setImage:[UIImage imageNamed:@"rg_editPicd_net"] forState:UIControlStateNormal];
        [self addSubview:_navRightBtn];
        
        [_navRightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
            make.top.mas_equalTo(self.mas_top).offset(20.f);
            make.right.mas_equalTo(self.mas_right).offset(-12.f);
        }];
        
        
        
        UIView *bottomView = [[UIView alloc]init];
        bottomView.backgroundColor = HEXCOLOR(0xffffff);
        [self addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kScreenWidth, 100.f+49.f));
            make.bottom.mas_equalTo(self.mas_bottom);
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
        
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(0, 0, 44, 44);
        //自动（normal）-> 关闭（heightLight）-> 开启（selected）
        [_leftBtn setImage:[UIImage imageNamed:@"rg_flashAuto"] forState:UIControlStateNormal];
        [_leftBtn setImage:[UIImage imageNamed:@"rg_flashOn"] forState:UIControlStateSelected];
        [_leftBtn setImage:[UIImage imageNamed:@"rg_flashOff"] forState:UIControlStateHighlighted | UIControlStateSelected];
        [bottomView addSubview:_leftBtn];
        
        [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
            make.centerY.mas_equalTo(bottomView.mas_centerY).offset(-49/2.f);
            make.left.mas_equalTo(bottomView.mas_left).offset(44.f);
        }];
        
        _centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _centerBtn.frame = CGRectMake(0, 0, 88, 88);
        [_centerBtn setImage:[UIImage imageNamed:@"rg_takePhoto_red"] forState:UIControlStateNormal];
        [bottomView addSubview:_centerBtn];
        
        [_centerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(88.f, 88.f));
            make.centerY.mas_equalTo(bottomView.mas_centerY).offset(-49/2.f);
            make.centerX.mas_equalTo(bottomView);
        }];
        
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(0, 0, 44, 44);
        [_rightBtn setImage:[UIImage imageNamed:@"rg_grayCamera"] forState:UIControlStateNormal];
        [bottomView addSubview:_rightBtn];
        
        [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
            make.centerY.mas_equalTo(bottomView.mas_centerY).offset(-49/2.f);
            make.right.mas_equalTo(bottomView.mas_right).offset(-44.f);
        }];
        
    }
    return self;
}


@end



@interface RGRecordViewProgressView()

@property(nonatomic,strong)UIView *completedView;

@end
@implementation RGRecordViewProgressView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HEXCOLORAL(0x333333, 0.7);
        
        self.completedView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, self.height)];
        self.completedView.backgroundColor = HEXCOLOR(0xff0000);
        [self addSubview:self.completedView];
        
        
        UIView *minLine = [[UIView alloc]initWithFrame:CGRectMake(self.width*3.f/120.f, 0, 1, self.height)];
        minLine.backgroundColor = HEXCOLOR(0xffffff);
        [self addSubview:minLine];
        
    }
    return self;
}

-(void)setPercent:(CGFloat)percent
{
    _percent = percent<=1?percent:1;

    self.completedView.width = self.width*percent;
}

@end



















