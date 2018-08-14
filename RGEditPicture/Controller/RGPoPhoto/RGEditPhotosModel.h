//
//  RGEditPhotosModel.h
//  Vmei
//
//  Created by ios-02 on 2018/6/29.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+YYModel.h"



@class RGEditPhotoFilterModel;
@class RGEditPhotoModel;
@class RGEditPhotoStickerModel;
@class RGEditPhotoTagModel;




//编辑照片页面的模型
@interface RGEditPhotosModel : NSObject


-(instancetype)initWithPics:(NSArray <UIImage *>*)pics;


@property(nonatomic,strong,readonly)NSMutableArray <RGEditPhotoModel *>*editPhotoModels;

-(void)rotatePicLeftAtIndex:(NSInteger)index;



@end



//顶部图片的View
@interface RGEditPhotoModel:NSObject

-(instancetype)initWithOriginalImage:(UIImage *)originalImage;

//原始照片
@property(nonatomic,strong,readonly)UIImage *originalImage;
//加了滤镜之后的照片
@property(nonatomic,strong)UIImage *editedImage;
//加了滤镜与关联活动贴纸 合成的照片
@property(nonatomic,strong)UIImage *mergedImage;

@property(nonatomic,assign)NSInteger selectedFilter;

//一张图片生成多种滤镜效果的小图模型（记录 —> 标题 路径 图片 ）
-(void)loadFilterPicsWithCallBack:(void(^)(NSArray <RGEditPhotoFilterModel *>*filterModels))block;

-(void)rotatePicLeft;

//一张照片的上附加的多个标签（记录 —> 主标签 附属标签 标签位置 ）
@property(nonatomic,strong)NSMutableArray <BeautyPophotoTagItem *> *tagPropertys;

//一张照片的上附加的多张贴纸（记录 —> 图片 缩放 旋转 位置 ）
@property(nonatomic,strong)NSMutableArray <BeautyPophotoTagItem *> *stickerPropertys;

@end



//滤镜 | 活动的模型 （记录 —> 标题 路径 图片）
@interface RGEditPhotoFilterModel:NSObject

@property(nonatomic,strong)NSString * title;
@property(nonatomic,strong)NSString * picUrlStr;
@property(nonatomic,strong)UIImage  * pic;

@end





//标签页-推荐标签列表
@class RGEditPhotoTagModel;
@interface RGEditPhotoTagListModel:NSObject

@property(nonatomic,strong)NSArray <RGEditPhotoTagModel *>*brandTags;
@property(nonatomic,strong)NSArray <RGEditPhotoTagModel *>*effectTags;

@end





typedef NS_ENUM(NSInteger , RGEditPhotoTagType) {
    RGEditPhotoTagType_Custom,//自定义标签
    RGEditPhotoTagType_Brand,//品牌标签
    RGEditPhotoTagType_Effect,//功效标签
};

#define kCustomTagPID 300

//标签页-单个标签
@interface RGEditPhotoTagModel:NSObject<YYModel,NSCoding>

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *logoUrl;
@property(nonatomic,assign)NSInteger follow;
@property(nonatomic,assign)NSInteger pid;//功效为217；品牌为9
@property(nonatomic,assign)RGEditPhotoTagType type;

@end



