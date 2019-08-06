//
//  RGImageCollectionView.h
//  RGImageSticker
//
//  Created by 泥红 on 30/8/18.
//  Copyright © 2018年 RoyGao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGImageCollectionView : UICollectionView

//deveop 102
@property(nonatomic,strong)NSArray <UIImage *>*pictures;

@property(nonatomic,copy)void(^photoTaped)(NSIndexPath *index,CGPoint tapPoint);

@property(nonatomic,copy) void(^rotateBtnClickBlock)(NSIndexPath *index);
//盛放所有cell，避免释放重用
@property(nonatomic,strong,readonly)NSMutableDictionary *allCellsDic;

//为第n个cell 添加贴纸
-(void)addSticker:(UIImage *)stick inCell:(NSInteger)page;

@end




//待编辑的图片cell
@interface RGEditPhotoCell:UICollectionViewCell

@property(nonatomic,strong)UIImageView *photoIV;

//@property(nonatomic,strong)UIImageView *transformBtn;


@property(nonatomic,copy)void(^gestureAction)(UIGestureRecognizer *gesture);

@property(nonatomic,strong)UIImageView *dustbinIV;//垃圾桶

@end
