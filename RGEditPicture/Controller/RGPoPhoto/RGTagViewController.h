//
//  RGTagViewController.h
//  Vmei
//
//  Created by ios-02 on 2018/7/12.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "BaseNetworkViewController.h"

@interface RGTagViewController : BaseNetworkViewController

@property (nonatomic,strong) BeautyPophotoItem       *item;

//选中标签后，点击完成的回调
@property (nonatomic,copy) void(^finishChooseTagCallBack)(BeautyPophotoTagItem *item, NSMutableArray <BeautyPophotoTagItem *> *array);

@property (nonatomic,copy) void(^cancelChooseTagCallBack)(void);

@end
