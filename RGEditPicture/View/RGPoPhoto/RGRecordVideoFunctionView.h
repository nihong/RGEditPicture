//
//  RGRecordVideoFunctionView.h
//  Vmei
//
//  Created by ios-02 on 2018/7/4.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RGRecordVideoFunctionView:UIView

@property(nonatomic,strong)UIButton *quitBtn;
@property(nonatomic,strong)UIButton *nextBtn;

@property(nonatomic,strong)UIButton *deletelastBtn;
@property(nonatomic,strong)UIButton *recordBtn;
@property(nonatomic,strong)UIButton *rotateCameraBtn;

@end


@interface RGTakePicBottomView:UIView

@property(nonatomic,strong)UIButton *navLeftBtn;
@property(nonatomic,strong)UIButton *navRightBtn;

@property(nonatomic,strong)UIButton *leftBtn;
@property(nonatomic,strong)UIButton *centerBtn;
@property(nonatomic,strong)UIButton *rightBtn;

@end



@interface RGRecordViewProgressView :UIView

@property(nonatomic,assign)CGFloat percent;//白分比

@end

