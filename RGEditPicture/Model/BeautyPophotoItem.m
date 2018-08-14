//
//  BeautyPophotoItem.m
//  RGEditPicture
//
//  Created by 泥红 on 14/8/18.
//  Copyright © 2018年 RoyGao. All rights reserved.
//

#import "BeautyPophotoItem.h"

@implementation BeautyPophotoItem
/*
-(instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        NSDictionary *pidConfig = [dict safeObjectForKey:@"pidConfig"];
        if ([pidConfig isAbsoluteValid]) {
            self.brandPid = [[pidConfig safeObjectForKey:@"brandPid"] integerValue];
            self.effectPid = [[pidConfig safeObjectForKey:@"effectPid"] integerValue];
        }
        
        self.hotBrandArray = [NSMutableArray new];
        NSArray *hotBrands = [dict safeObjectForKey:@"hotBrands"];
        if ([hotBrands isAbsoluteValid]) {
            for (NSDictionary *dictionary in hotBrands) {
                BeautyPophotoTagItem *item = [[BeautyPophotoTagItem alloc] initWithDict:dictionary];
                [self.hotBrandArray addObject:item];
            }
        }
        
        self.hotEffectsArray = [NSMutableArray new];
        NSArray *hotEffects = [dict safeObjectForKey:@"hotEffects"];
        if ([hotEffects isAbsoluteValid]) {
            for (NSDictionary *dictionary in hotEffects) {
                BeautyPophotoTagItem *item = [[BeautyPophotoTagItem alloc] initWithDict:dictionary];
                [self.hotEffectsArray addObject:item];
            }
        }
        
        self.stickersArray = [NSMutableArray new];
        NSArray *stickers = [dict objectForKey:@"stickers"];
        if ([stickers isAbsoluteValid]) {
            for (NSDictionary *dictionary in stickers) {
                BeautyPophotoTagItem *item = [[BeautyPophotoTagItem alloc] initWithDict:dictionary];
                [self.stickersArray addObject:item];
            }
        }
        
        self.defaultContent = [dict safeObjectForKey:@"initContent"];
        //默认文字
        [UserInfoModel setPoPhotoDefaultContent:self.defaultContent];
        
        self.addProductTips = [dict safeObjectForKey:@"addProductTips"];
        self.summaryTips = [dict safeObjectForKey:@"summaryTips"];
        [SaveTempDataManager sharedInstance].addProductTips = self.addProductTips;
        [SaveTempDataManager sharedInstance].summaryTips = self.summaryTips;
        
        
    }
    return self;
}
*/
@end

