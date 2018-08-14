//
//  RGEditPhotoStickerVC.h
//  Vmei
//
//  Created by ios-02 on 2018/8/9.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "BaseNetworkViewController.h"

//贴纸
@interface RGEditPhotoStickerVC : BaseNetworkViewController

@property(nonatomic,strong)NSArray <BeautyPophotoTagItem *>*stickerArray;

@property(nonatomic,copy)void(^stickerCellClicked)(NSIndexPath *index,UIImage *sticker);

@end
