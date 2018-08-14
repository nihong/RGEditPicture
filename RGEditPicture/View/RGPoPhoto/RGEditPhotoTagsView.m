//
//  RGEditPhotoTagsView.m
//  Vmei
//
//  Created by ios-02 on 2018/8/2.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "RGEditPhotoTagsView.h"


@interface RGEditPhotoTagsHeader()



@end
@implementation RGEditPhotoTagsHeader

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mainTitleLB = [[UILabel alloc]init];
        [self addSubview:_mainTitleLB];
        self.mainTitleLB.font = SP13Font;
        self.mainTitleLB.textColor = HEXCOLOR(0xb2b2b2);
        [self.mainTitleLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.left.mas_equalTo(kRGPhotoTagOutMagin);
        }];
        
        
        self.rightIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 44.f, 40.f)];
        [self addSubview:self.rightIV];
        self.rightIV.contentMode = UIViewContentModeCenter;
//        self.rightIV.hidden = YES;
        self.rightIV.image = [UIImage imageNamed:@"rg_editPhoto_delete"];
        [self.rightIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_right).offset(-kRGPhotoTagOutMagin-20.f);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(44.f, 40.f));
        }];
    }
    return self;
}


@end




@interface RGEditPhotoTagCell()

//@property(nonatomic,strong)UIButton *tagBtn;

@end
@implementation RGEditPhotoTagCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = HEXCOLORAL(0xffffff, 0.1);
        
        self.tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.tagBtn.userInteractionEnabled = NO;
        [self.tagBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
        self.tagBtn.titleLabel.font = SP13Font;
        [self.contentView addSubview:self.tagBtn];
        [self.tagBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 5, 0, 5));
        }];
    }
    return self;
}

@end




//品牌cell
@interface RGEditPhotoBrandCell()

@end
@implementation RGEditPhotoBrandCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = HEXCOLORAL(0xffffff, 0.1);
        
        self.brandIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 36, 36)];
        ViewRadius(self.brandIV, 5.f);
        [self.contentView addSubview:self.brandIV];
        [self.brandIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(36.f, 36.f));
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.left.mas_equalTo(self).offset(12.f);
        }];
        
        
        self.brandNameLB = [[UILabel alloc]init];
        self.brandNameLB.font = SP15Font;
        self.brandNameLB.textColor = HEXCOLOR(0xffffff);
        [self.contentView addSubview:self.brandNameLB];
        [self.brandNameLB mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.brandIV.mas_top).offset(2.f);
            make.bottom.mas_equalTo(self.mas_centerY).offset(-1.5f);
            make.left.mas_equalTo(self.brandIV.mas_right).offset(10.f);
            make.width.mas_lessThanOrEqualTo(200);
        }];
        
        
        self.starNumCount = [[UILabel alloc]init];
        self.starNumCount.font = SP12Font;
        self.starNumCount.textColor = HEXCOLOR(0x999999);
        [self.contentView addSubview:self.starNumCount];
        [self.starNumCount mas_makeConstraints:^(MASConstraintMaker *make) {

            make.top.mas_equalTo(self.mas_centerY).offset(1.5f);
            make.left.mas_equalTo(self.brandIV.mas_right).offset(10.f);
            make.width.mas_lessThanOrEqualTo(200);
        }];
        
        
        self.creatTipLB = [[UILabel alloc]init];
        self.creatTipLB.text = @"点击创建";
        self.creatTipLB.font = SP12Font;
        self.creatTipLB.textColor = HEXCOLOR(0x999999);
        [self.contentView addSubview:self.creatTipLB];
        [self.creatTipLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-12.f);
        }];
        
    }
    return self;
}

@end

//品牌footer
@interface RGEditPhotoBrandFooter()

@end
@implementation RGEditPhotoBrandFooter

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UILabel *tipLB = [[UILabel alloc]initWithFrame:self.bounds];
        [self addSubview:tipLB];
        tipLB.textAlignment = NSTextAlignmentCenter;
        tipLB.textColor = HEXCOLOR(0x999999);
        tipLB.font = SP13Font;
        tipLB.text = @"没有想要的？输入关键字搜索试试...";
    }
    return self;
}

@end



//搜索结果
@interface RGEditPhotoSearchTagCell()

//@property(nonatomic,strong)UILabel *searchedTagLB;//搜索出的关键字
@end
@implementation RGEditPhotoSearchTagCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        self.searchedTagLB = [[UILabel alloc]init];
        self.searchedTagLB.font = SP14Font;
        self.searchedTagLB.textColor = HEXCOLOR(0xffffff);
        [self.contentView addSubview:self.searchedTagLB];
        [self.searchedTagLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(8.f);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.height-0.5, self.width, 0.5)];
        bottomLine.backgroundColor = HEXCOLORAL(0xffffff, 0.1);
        [self.contentView addSubview:bottomLine];
    }
    return self;
}

@end
























