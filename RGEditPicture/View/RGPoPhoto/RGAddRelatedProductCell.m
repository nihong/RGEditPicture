//
//  RGAddRelatedProductCell.m
//  Vmei
//
//  Created by ios-02 on 2018/6/11.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "RGAddRelatedProductCell.h"
@interface RGAddRelatedProductCell()

@property(nonatomic,strong) UIButton *addPicBtn;

@end
@implementation RGAddRelatedProductCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _addPicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addPicBtn.userInteractionEnabled = NO;
        [self.contentView addSubview:_addPicBtn];
       // [_addPicBtn setImage:[UIImage imageNamed:@"rg_PoPhoto_addProduct"] forState:UIControlStateNormal];
        [_addPicBtn setTitle:@" + 选择种草商品" forState:UIControlStateNormal];
        [_addPicBtn setTitleColor:HEXCOLOR(0x666666) forState:UIControlStateNormal];
        _addPicBtn.backgroundColor = HEXCOLOR(0xf5f5fa);
        _addPicBtn.titleLabel.font = SP16Font;
        _addPicBtn.frame = CGRectMake(0,0, frame.size.width, frame.size.height);
        ViewRadius(_addPicBtn, 5.f);
        
        [_addPicBtn setTitleEdgeInsets:UIEdgeInsetsMake(-10, 0, 0, 0)];
        
        UILabel  * tips = [UILabel  new];
        tips.font =SP11Font;
        tips.textColor= HEXCOLOR(0x999999);
        tips.textAlignment= NSTextAlignmentCenter;
        tips.text = @"选择你要种草的商品，如无可不选择";
        [self.contentView addSubview:tips];
        [tips mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_addPicBtn.mas_centerY).equalTo(10);
            make.centerX.equalTo(self.contentView);
            make.height.equalTo(13);
            make.width.equalTo(200);
        }];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end





@interface RGPoPhotoTextViewCell()<YYTextViewDelegate>

@end
@implementation RGPoPhotoTextViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _textView = [[YYTextView alloc]initWithFrame:self.bounds];
        _textView.delegate = self;
        [self.contentView addSubview:_textView];
        _textView.placeholderText = @"点这里，分享你的心得...";//@"宝贝满足你的期待吗？说说你的使用心得，分享给想买的他们吧！";
        _textView.placeholderFont = SP16Font;
        _textView.placeholderTextColor = HEXCOLOR(0x969696);
        _textView.font = SP16Font;
        _textView.textColor =  Common_InkBlackColor2;//HEXCOLOR(0x999999);
        
        
    }
    return self;
}




@end




@interface RGAddCustomPicCell()
@property(nonatomic,strong) UIButton *cancelBtn;
@property(nonatomic,strong) UIImageView *videoTagIV;

@end
@implementation RGAddCustomPicCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        
        self.customPicIV = [[UIImageView alloc]initWithFrame:self.bounds];
        [self.contentView addSubview:self.customPicIV];
        
        self.customPicIV.layer.masksToBounds = YES;
        self.customPicIV.contentMode = UIViewContentModeScaleAspectFill;
        self.customPicIV.size = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
        [self.customPicIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];

        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setImage:[UIImage imageNamed:@"rg_poPost_quit"] forState:UIControlStateNormal];
//        _cancelBtn.frame = CGRectMake(frame.size.width-44, 0, 44.f, 44.f);
        [self.contentView addSubview:_cancelBtn];
        [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
            make.right.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.contentView).offset(-10.f);
        }];
        [_cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        _videoTagIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pophoto_play"]];
        [self.contentView addSubview:_videoTagIV];
        [_videoTagIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.and.centerY.mas_equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
        }];
        _videoTagIV.hidden = YES;
    }
    return self;
}

-(void)cancelBtnClicked
{    
    self.cancelBtnClickedBlock();
}

-(void)setHideCancelBtn:(BOOL)hideCancelBtn
{
    _hideCancelBtn = hideCancelBtn;
    self.cancelBtn.hidden = hideCancelBtn;
}

-(void)setShowVideoStartBtn:(BOOL)showVideoStartBtn
{
    _showVideoStartBtn = showVideoStartBtn;
    _videoTagIV.hidden = !showVideoStartBtn;
}

- (UIView *)snapshotView {
    UIView *snapshotView = [[UIView alloc]init];
    
    UIView *cellSnapshotView = nil;
    
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]) {
        cellSnapshotView = [self snapshotViewAfterScreenUpdates:NO];
    } else {
        CGSize size = CGSizeMake(self.bounds.size.width + 20, self.bounds.size.height + 20);
        UIGraphicsBeginImageContextWithOptions(size, self.opaque, 0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * cellSnapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cellSnapshotView = [[UIImageView alloc]initWithImage:cellSnapshotImage];
    }
    
    snapshotView.frame = CGRectMake(0, 0, cellSnapshotView.frame.size.width, cellSnapshotView.frame.size.height);
    cellSnapshotView.frame = CGRectMake(0, 0, cellSnapshotView.frame.size.width, cellSnapshotView.frame.size.height);
    
    [snapshotView addSubview:cellSnapshotView];
    return snapshotView;
}

@end



@interface RGPoPhotoDescribleCell()

@end
@implementation RGPoPhotoDescribleCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *textLB = [[UILabel alloc]initWithFrame:self.bounds];
        textLB.text = @"如何写出一篇优质心得？";
        textLB.font = SP13Font;
        textLB.textColor = HEXCOLOR(0x999999);
        textLB.textAlignment = NSTextAlignmentLeft;
        textLB.backgroundColor = HEXCOLOR(0xffffff);
        [self.contentView addSubview:textLB];
    }
    return self;
}

@end




@interface RGPoPhotoLocationCell()

@end
@implementation RGPoPhotoLocationCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _leadIV = [[UIImageView alloc]initWithFrame:CGRectMake(2, 0, 15, 15*1.2)];
        [self.contentView addSubview:_leadIV];
        _leadIV.centerY = self.contentView.centerY;
        _leadIV.image = [UIImage imageNamed:@"rg_poPhoto_location"];
      //  _leadIV.contentMode = UIViewContentModeLeft;
        
        _locationLB  = [[UILabel alloc]init];
        [self.contentView addSubview:_locationLB];
        _locationLB.font = SP14Font;
        _locationLB.textColor = HEXCOLOR(0x969696);
        [_locationLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView);
            make.left.mas_equalTo(_leadIV.mas_right).offset(8);
            make.right.mas_equalTo(self.contentView);
        }];
        
        self.indicationIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"RGIndicate"]];
        [self.contentView addSubview:self.indicationIV];
        [self.indicationIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-10);
            make.centerY.mas_equalTo(self.contentView);
            make.size.equalTo(CGSizeMake(8, 8*1.58)); //13 *1.58
        }];
        
    }
    return self;
}

-(void)setLocation:(NSString *)location
{
    _location = location;
    _locationLB.text = location;
}

@end


@interface RGPoPhotoBottomView()

@end
@implementation RGPoPhotoBottomView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor =[UIColor whiteColor];
        
        
        
        CGFloat btnWidth = 49;
        CGFloat space =  0;//(IPHONE_WIDTH - 3* btnWidth) /4;

        
        //##
        _addImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        //_albumBtn.backgroundColor= Common_PinkColor;
        [_addImgBtn setImage:[UIImage imageNamed:@"poPhoto_addimg"] forState:UIControlStateNormal];
        [self addSubview:_addImgBtn];
        [_addImgBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(btnWidth *1.3, btnWidth));
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(space);
        }];
        
        
        //##
        _albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
       //_albumBtn.backgroundColor= Common_PinkColor;
        [_albumBtn setImage:[UIImage imageNamed:@"poPhoto_addAlbum"] forState:UIControlStateNormal];
        [self addSubview:_albumBtn];
        [_albumBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(btnWidth *1.3, btnWidth));
            make.centerY.equalTo(self);
            make.left.equalTo(_addImgBtn.mas_right).offset(space);
        }];
        
        //@
        _atBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_atBtn setImage:[UIImage imageNamed:@"poPhoto_user"] forState:UIControlStateNormal];
        [self addSubview:_atBtn];
        [_atBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(btnWidth*1.3, btnWidth));
            make.centerY.equalTo(self);
            make.left.equalTo(_albumBtn.mas_right).offset(space);
        }];
        
        //定位
        _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_locationBtn setImage:[UIImage imageNamed:@"poPhoto_addLocation"] forState:UIControlStateNormal];
        [_locationBtn setImage:[UIImage imageNamed:@"poPhoto_addLocation_sel"] forState:UIControlStateSelected];
        [self addSubview:_locationBtn];
        [_locationBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(btnWidth*1.3, btnWidth));
            make.centerY.equalTo(self);
            make.left.equalTo(_atBtn.mas_right).offset(space);
        }];
        _locationBtn.hidden= YES;
        UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, .5f)];
        [self addSubview:topLine];
        topLine.backgroundColor = HEXCOLOR(0xe9e9e9);
        
        
        //
    }
    return self;
}


@end










