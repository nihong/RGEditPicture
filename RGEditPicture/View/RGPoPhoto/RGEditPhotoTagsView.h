//
//  RGEditPhotoTagsView.h
//  Vmei
//
//  Created by ios-02 on 2018/8/2.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRGPhotoTagOutMagin 15.f


//历史|功效|热门品牌。。。
@interface RGEditPhotoTagsHeader:UICollectionReusableView

@property(nonatomic,strong)UILabel *mainTitleLB;

@property(nonatomic,strong)UIImageView *rightIV;

@end

//保湿|补水。。。搜索的历史记录。。。
@interface RGEditPhotoTagCell:UICollectionViewCell

@property(nonatomic,strong)UIButton *tagBtn;

@end



//品牌cell
@interface RGEditPhotoBrandCell:UICollectionViewCell

@property(nonatomic,strong)UIImageView *brandIV;//品牌图标
@property(nonatomic,strong)UILabel *brandNameLB;//品牌名称
@property(nonatomic,strong)UILabel *starNumCount;//关注人数

@property(nonatomic,strong)UILabel *creatTipLB;//点击创建
@end


//品牌footer
@interface RGEditPhotoBrandFooter:UICollectionReusableView

@end


//搜索结果
@interface RGEditPhotoSearchTagCell:UICollectionViewCell

@property(nonatomic,strong)UILabel *searchedTagLB;//搜索出的关键字


@end



