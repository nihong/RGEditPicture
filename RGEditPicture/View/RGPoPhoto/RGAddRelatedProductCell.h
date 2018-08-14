//
//  RGAddRelatedProductCell.h
//  Vmei
//
//  Created by ios-02 on 2018/6/11.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGAddRelatedProductCell : UICollectionViewCell

@end



@interface RGPoPhotoTextViewCell:UICollectionViewCell

@property(nonatomic,strong) YYTextView *textView;


@end



@interface RGAddCustomPicCell:UICollectionViewCell

@property(nonatomic,strong) UIImageView *customPicIV;

@property(nonatomic,assign) BOOL hideCancelBtn;

@property(nonatomic,assign) BOOL showVideoStartBtn;

@property(nonatomic,copy) void(^cancelBtnClickedBlock)(void);

- (UIView *)snapshotView;

@end





@interface RGPoPhotoDescribleCell:UICollectionViewCell

@end


@interface RGPoPhotoLocationCell:UICollectionViewCell

@property(nonatomic,strong)UILabel *locationLB;
@property(nonatomic,strong) UIImageView *indicationIV;


@property(nonatomic,strong) NSString *location;
@property(nonatomic,strong) UIImageView *leadIV;
@end


@interface RGPoPhotoBottomView:UIView

@property(nonatomic,strong) UIButton *albumBtn;
@property(nonatomic,strong) UIButton *atBtn;
@property(nonatomic,strong) UIButton *locationBtn;
@property(nonatomic,strong) UIButton *addImgBtn;


@end
