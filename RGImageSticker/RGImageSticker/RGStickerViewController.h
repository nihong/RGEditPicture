//
//  RGStickerViewController.h
//  RGImageSticker
//
//  Created by 泥红 on 31/8/18.
//  Copyright © 2018年 RoyGao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGStickerViewController : UIViewController

@property(nonatomic,strong)NSArray <UIImage *>*stickerArray;

@property(nonatomic,copy)void(^stickerCellClicked)(NSIndexPath *index,UIImage *sticker);

@end
