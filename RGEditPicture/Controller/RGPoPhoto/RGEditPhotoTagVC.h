//
//  RGEditPhotoTagVC.h
//  Vmei
//
//  Created by ios-02 on 2018/8/3.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "BaseNetworkViewController.h"

@class RGEditPhotoTagModel;
@interface RGEditPhotoTagVC : BaseNetworkViewController

@property(nonatomic,copy)void(^selectTagComplete)(RGEditPhotoTagModel *tagModel);



@end
