//
//  RGEditPhotoView.h
//  Vmei
//
//  Created by ios-02 on 2018/6/26.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGEditPhotosModel.h"
#import "StickerView.h"


@interface RGEditPhotoView : UIView

@end

//顶部待编辑的图片
@interface RGEditPhotoPicsView :UICollectionView

@property(nonatomic,strong)NSArray <RGEditPhotoModel *>*pictures;

@property(nonatomic,copy)void(^photoTaped)(NSIndexPath *index,CGPoint tapPoint);

@property(nonatomic,copy) void(^rotateBtnClickBlock)(NSIndexPath *index);
//盛放所有cell，避免释放重用
@property(nonatomic,strong,readonly)NSMutableDictionary *allCellsDic;

//为第n个cell 添加贴纸
-(void)addSticker:(UIImage *)stick inCell:(NSInteger)page;

@end







//滤镜图片

@interface RGEditPhotoFilterView :UICollectionView

@property(nonatomic,assign)NSInteger selectedIndex;

//滤镜模型 的数组
@property(nonatomic,strong)NSArray <RGEditPhotoFilterModel *>* filterModels;


@end







//底部（滤镜+标签+活动）
@interface RGEditPhotoBottomView :UICollectionView

@property(nonatomic,assign)NSInteger selectedIndex;

-(void)configTitles:(NSArray *)titles pictures:(NSArray<NSString *> *)pictures selectedPics:(NSArray<NSString *> *)selectedPics;

@end


//上图+下文 cell
@interface RGEditPhotoBarItemCell:UICollectionViewCell

@property(nonatomic,strong)UIImageView *topIV;
@property(nonatomic,strong)UILabel *bottomLB;

@end

//上图+下文 cell
@interface RGEditPhotoFilterCell:UICollectionViewCell

@property(nonatomic,strong)UIImageView *topIV;
@property(nonatomic,strong)UILabel *bottomLB;

@end


//待编辑的图片cell
@interface RGEditPhotoCell:UICollectionViewCell

@property(nonatomic,strong)UIImageView *photoIV;

@property(nonatomic,strong)UIImageView *transformBtn;


@property(nonatomic,copy)void(^gestureAction)(UIGestureRecognizer *gesture);

@property(nonatomic,strong)UIImageView *dustbinIV;//垃圾桶

@end






