//
//  RGEditPhotosModel.m
//  Vmei
//
//  Created by ios-02 on 2018/6/29.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "RGEditPhotosModel.h"
#import "DTFilterImageEngine.h"
////////////////////////////////////////////////////////////////////////
@interface RGEditPhotosModel()

@property(nonatomic,strong,readwrite)NSMutableArray <RGEditPhotoModel *>*editPhotoModels;

//@property(nonatomic,strong,readwrite)NSMutableArray <UIImage *>*editedImages;

@end

@implementation RGEditPhotosModel

-(instancetype)initWithPics:(NSArray <UIImage *>*)pics
{
    self = [super init];
    if (self) {
        NSMutableArray *temp= [NSMutableArray array];
        if ([pics isAbsoluteValid]) {
            for (int i = 0; i< pics.count; i++) {
                UIImage *pic = pics[i];
                RGEditPhotoModel *model = [[RGEditPhotoModel alloc]initWithOriginalImage:pic];
                [temp addObject:model];
                
            }
        }
        self.editPhotoModels = temp;
    }
    return self;
}


-(void)rotatePicLeftAtIndex:(NSInteger)index
{
    if (index<self.editPhotoModels.count) {
        RGEditPhotoModel *model = self.editPhotoModels[index];
        
        [model rotatePicLeft];
        
        //        model.editedImage = [model.originalImage  imageByRotateLeft90];
        //        model.originalImage = [model.originalImage imageByRotateLeft90];
        
        //        [self.editPhotoModels replaceObjectAtIndex:index withObject:model];
    }
}


@end




////////////////////////////////////////////////////////////////////////
@interface RGEditPhotoModel ()
@property(nonatomic,strong,readwrite)UIImage *originalImage;
//@property(nonatomic,strong,readwrite)NSMutableArray <RGEditPhotoStickerModel *>*stickerArray;
@end

@implementation RGEditPhotoModel

-(instancetype)initWithOriginalImage:(UIImage *)originalImage
{
    self = [super init];
    if (self) {
        self.originalImage = originalImage;
        self.selectedFilter = 0;
        
        //        self.stickerArray = [NSMutableArray array];
        self.tagPropertys = [NSMutableArray array];
        self.stickerPropertys = [NSMutableArray array];
        //        self.tagArray = [NSMutableArray array];
    }
    
    return self;
}

-(void)loadFilterPicsWithCallBack:(void(^)(NSArray <RGEditPhotoFilterModel *>*filterModels))block
{
    [DTFilterImageEngine getSmallFilterImages:self.originalImage block:^(NSArray *results) {
        NSMutableArray *filterModelArr = [NSMutableArray array];
        for (NSDictionary *dic in results) {
            RGEditPhotoFilterModel *model = [[RGEditPhotoFilterModel alloc]init];
            model.pic = [dic safeObjectForKey:filter_image];
            model.title = [dic safeObjectForKey:filter_tag];
            model.picUrlStr = nil;
            [filterModelArr addObject:model];
        }
        if (block) {
            block(filterModelArr);
        }
    }];
}

//-(void)setOriginalImage:(UIImage *)originalImage
//{
//    _originalImage = originalImage;
//    [DTFilterImageEngine getSmallFilterImages:_originalImage block:^(NSArray *results) {
//        NSMutableArray *filterModelArr = [NSMutableArray array];
//        for (NSDictionary *dic in results) {
//            RGEditPhotoFilterModel *model = [[RGEditPhotoFilterModel alloc]init];
//            model.pic = [dic safeObjectForKey:filter_image];
//            model.title = [dic safeObjectForKey:filter_tag];
//            model.picUrlStr = nil;
//            [filterModelArr addObject:model];
//        }
//        self.filterModels = filterModelArr;
//        self.finishFilterImagedsBlock();
//
//    }];
//}

-(void)setSelectedFilter:(NSInteger)selectedFilter
{
    _selectedFilter = selectedFilter;
    NSDictionary *dict = [[DTFilterImageEngine getAllFilterParameter] objectAtIndex:selectedFilter];
    self.editedImage = [DTFilterImageEngine getFilterImageWithName:[dict objectForKey:filter_name] image:self.originalImage];
    if (!self.mergedImage) {
        self.mergedImage = self.editedImage;
    }
    
}


-(void)rotatePicLeft
{
    self.editedImage = [self.originalImage  imageByRotateLeft90];
    self.originalImage = [self.originalImage imageByRotateLeft90];
    
}



@end

////////////////////////////////////////////////////////////////////////
@implementation RGEditPhotoFilterModel

@end





@implementation  RGEditPhotoTagListModel

-(BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic
{
    
    self.brandTags = [NSArray modelArrayWithClass:[RGEditPhotoTagModel class] json:[dic safeObjectForKey:@"brandTags"]];
    self.effectTags = [NSArray modelArrayWithClass:[RGEditPhotoTagModel class] json:[dic safeObjectForKey:@"effectTags"]];
    return YES;
}

@end


@implementation RGEditPhotoTagModel

-(BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic
{
    if ([[dic objectForKey:@"type"] isEqualToString:@"brand"]) {
        self.type = RGEditPhotoTagType_Brand;
    }else if ([[dic objectForKey:@"type"] isEqualToString:@"custom"]){
        self.type = RGEditPhotoTagType_Custom;
    }else if ([[dic objectForKey:@"type"] isEqualToString:@"effect"]){
        self.type = RGEditPhotoTagType_Effect;
    }else{
        self.type = RGEditPhotoTagType_Effect;
    }
    return YES;
}

//-(void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeObject:self.logoUrl forKey:@"logoUrl"];
//}
//
//-(instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super init];
//    if (self) {
//        
//        _logoUrl = [aDecoder decodeObjectForKey:@"logoUrl"];
//        _follow = [aDecoder decodeObjectForKey:@"follow"];
//        _name = [aDecoder decodeObjectForKey:@"name"];
//        _type = [aDecoder decodeObjectForKey:@"type"];
//    }
//    return self;
//}

@end

