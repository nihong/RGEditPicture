//
//  BeautyPophotoItem.h
//  RGEditPicture
//
//  Created by 泥红 on 14/8/18.
//  Copyright © 2018年 RoyGao. All rights reserved.
//

#import <Foundation/Foundation.h>

//pophoto初始化数据
@interface BeautyPophotoItem : NSObject
-(instancetype)initWithDict:(NSDictionary *)dict;

@property (nonatomic,assign) NSInteger      brandPid;//品牌id
@property (nonatomic,assign) NSInteger      effectPid;//功效id
@property (nonatomic,strong) NSMutableArray *hotBrandArray;//热门品牌标签集合
@property (nonatomic,strong) NSMutableArray *hotEffectsArray;//热门功效标签集合
@property (nonatomic,strong) NSMutableArray *stickersArray;//贴纸集合(value:BeautyPophotoTagItem)

@property (nonatomic,strong ) NSString      *defaultContent;//发帖默认文字描述
@property (nonatomic,strong ) NSString      *addProductTips;//关联妆品描述
@property (nonatomic,strong ) NSString      *summaryTips;//发帖底部默认文字描述
@end
