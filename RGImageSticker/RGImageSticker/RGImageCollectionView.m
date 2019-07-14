//
//  RGImageCollectionView.m
//  RGImageSticker
//
//  Created by 泥红 on 30/8/18.
//  Copyright © 2018年 RoyGao. All rights reserved.
//

#import "RGImageCollectionView.h"

//@implementation RGImageCollectionView
//
//
//
//@end

//#import <AudioToolbox/AudioToolbox.h>

#define kDuesbinTag 888

static NSString *const kRGEditPhotoTopPicCell_id = @"kRGEditPhotoTopPicCell_id";
static NSString *const kRGEditPhotoBottomCell_id = @"kRGEditPhotoBottomCell_id";
static NSString *const kRGEditPhotoFilterCell_id = @"kRGEditPhotoFilterCell_id";




//////////////////////////////RGEditPhotoPicsView//////////////////////////////
@interface RGImageCollectionView()<UICollectionViewDataSource>

//创建数据盛放所有的cell，避免被销毁重用，同时肯定也就不能使用ReuseIdentifier了
@property(nonatomic,strong,readwrite)NSMutableDictionary *allCellsDic;

//贴纸是否能scale --> 为贴纸的缩小放大设置的锁
@property(nonatomic,assign)BOOL stickerCanScale;


@end
@implementation RGImageCollectionView
-(void)dealloc
{
    NSLog(@"");
}

-(instancetype)initWithFrame:(CGRect)frame
{
    UICollectionViewFlowLayout *flowLaout = [[UICollectionViewFlowLayout alloc]init];
    flowLaout.itemSize = frame.size;
    flowLaout.minimumLineSpacing = 0.f;
    flowLaout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self =  [super initWithFrame:frame collectionViewLayout:flowLaout];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.dataSource = self;
        self.showsHorizontalScrollIndicator = NO;
        
    }
    return self;
}
-(NSMutableDictionary *)allCellsDic
{
    if (!_allCellsDic) {
        _allCellsDic = [NSMutableDictionary dictionary];
    }
    return _allCellsDic;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pictures.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    RGEditPhotoCell *cell;
    if (self.allCellsDic[@(indexPath.item)]) {
        cell = self.allCellsDic[@(indexPath.item)];
    }else{
        cell = (RGEditPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"%@_%ld",kRGEditPhotoTopPicCell_id,(long)indexPath.item] forIndexPath:indexPath];
        //不让销毁！
        [self.allCellsDic setObject:cell forKey:@(indexPath.item)];
    }
    
    //    RGEditPhotoCell *cell = (RGEditPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"%@_%ld",kRGEditPhotoTopPicCell_id,(long)indexPath.item] forIndexPath:indexPath];
    
    
    
    UIImage *image = self.pictures[indexPath.item];
    cell.photoIV.image = image;
    
    CGSize imageSize = [self scalePicSize:image];
    cell.photoIV.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    cell.photoIV.center = cell.contentView.center;
    cell.dustbinIV.frame = CGRectMake(imageSize.width/2.f-22.f, imageSize.height-44.f-20.f, 44.f, 44.f);
    
    
    cell.photoIV.tag = indexPath.item;
//    cell.transformBtn.tag = indexPath.item;
    __weak typeof(cell.photoIV) weakIV = cell.photoIV;
    cell.gestureAction = ^(UIGestureRecognizer *gesture) {
        [self recoginizeGesture:gesture InPic:weakIV];
    };
    //    UITapGestureRecognizer *photoIVGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoIVClicked:)];
    //    [cell.photoIV addGestureRecognizer:photoIVGesture];
    
    
//    [cell.transformBtn addTarget:self action:@selector(transformBtnClicked:)];
    
    
    return cell;
    
}

-(CGSize)scalePicSize:(UIImage *)pic
{
    //collectionView的宽高比
    CGFloat contentRatio = self.frame.size.width/self.frame.size.height;
    //image2的宽高比
    CGFloat picRatio = pic.size.width/pic.size.height;
    
    CGSize newPicSize;
    if (contentRatio>= picRatio) {//image2比容器“长”
        /*
         *      *************
         *      *   *    *  *
         *      *   *    *  *
         *      *   *    *  *
         *      *   *    *  *
         *      *   *    *  *
         *      *   *    *  *
         *      *************
         */
        newPicSize = CGSizeMake(picRatio*self.frame.size.height, self.frame.size.height);
        
        
    }else {
        /*
         *      *************
         *      *           *
         *      *************
         *      *           *
         *      *           *
         *      *************
         *      *           *
         *      *************
         */
        newPicSize = CGSizeMake(self.frame.size.width, self.frame.size.width/picRatio);
    }
    return newPicSize;
    
}

-(void)setPictures:(NSArray <UIImage *>*)pictures
{
    _pictures = pictures;
    [self.allCellsDic removeAllObjects];
    for (int i = 0 ; i<_pictures.count; i++) {
        [self registerClass:[RGEditPhotoCell class] forCellWithReuseIdentifier:[NSString stringWithFormat:@"%@_%d",kRGEditPhotoTopPicCell_id,i]];
    }
    
    [self reloadData];
}



-(void)transformBtnClicked:(UITapGestureRecognizer *)tap
{
    
    if (self.rotateBtnClickBlock) {
        self.rotateBtnClickBlock([NSIndexPath indexPathForItem:tap.view.tag inSection:0]);
    }
}


-(void)photoIVClicked:(UITapGestureRecognizer *)tap
{
    
    if (self.photoTaped) {
        CGPoint tapPoint = [tap locationInView:tap.view];
        self.photoTaped([NSIndexPath indexPathForItem:tap.view.tag inSection:0], tapPoint);
    }
}


/*
 被编辑的照片UIImageView 识别三种手势
 1.点击添加tag
 2.捏合缩放贴纸
 3.两根手指旋转贴纸
 
 */
-(void)recoginizeGesture:(UIGestureRecognizer *)gesture InPic:(UIImageView *)pic
{
    
    if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {//点击
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gesture;
        if (self.photoTaped) {
            CGPoint tapPoint = [tap locationInView:tap.view];
            self.photoTaped([NSIndexPath indexPathForItem:tap.view.tag inSection:0], tapPoint);
        }
        
        
    }else if ([pic.subviews.lastObject isKindOfClass:[UIImageView class]]) {
        
        UIImageView *frontStickerIV = pic.subviews.lastObject;
        
        if ([gesture isKindOfClass:[UIRotationGestureRecognizer class]]){//旋转
            UIRotationGestureRecognizer *rotation = (UIRotationGestureRecognizer *)gesture;
            
            frontStickerIV.transform = CGAffineTransformRotate(frontStickerIV.transform, rotation.rotation);
            rotation.rotation = 0;
            
            
        }else if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]]){//捏合
            UIPinchGestureRecognizer *pinch = (UIPinchGestureRecognizer *)gesture;
            
            //通过 transform(改变) 进行视图的视图的捏合
            frontStickerIV.transform = CGAffineTransformScale(frontStickerIV.transform, pinch.scale, pinch.scale);
            //设置比例 为 1
            pinch.scale = 1.f;
            
            
        }
    }
}


-(void)addSticker:(UIImage *)stickerImg inCell:(NSInteger)page
{
    RGEditPhotoCell *currentCell = self.allCellsDic[@(page)];
    
    UIImageView *stickerIV = [[UIImageView alloc]initWithImage:stickerImg];
    stickerIV.userInteractionEnabled = YES;
    
    stickerIV.center = CGPointMake(currentCell.photoIV.frame.size.width/2.f, currentCell.photoIV.frame.size.height/2.f);
    
//    __weak typeof(stickerIV) weakIV = stickerIV;
    
    
    
    UIPanGestureRecognizer *stickerPanGuesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(stickerPanGesture:)];
    [stickerIV addGestureRecognizer:stickerPanGuesture];
    
    UITapGestureRecognizer *stickerTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stickerTapGesture:)];
    [stickerIV addGestureRecognizer:stickerTapGesture];
    
//    //点击添加跳跃动画
//    [stickerIV addTapGestureRecognizer:^(UITapGestureRecognizer *recognizer, NSString *gestureId) {
//
//        [currentCell.photoIV bringSubviewToFront:weakIV];
//
//        CGFloat originalScale = CGAffineTransformGetScaleX(weakIV.transform);
//
//        CAKeyframeAnimation *jumpAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
//        jumpAnimation.values =   @[@(1.0f*originalScale), @(0.8f*originalScale), @(1.0f*originalScale), @(1.2*originalScale), @(1.f*originalScale)];
//        jumpAnimation.repeatCount = NO;
//        jumpAnimation.duration = .5f;
//        [weakIV.layer addAnimation:jumpAnimation forKey:@"jumpAnimation"];
//
//    }];
    [currentCell.photoIV addSubview:stickerIV];
    
}

//贴纸上的拖动手势
-(void)stickerPanGesture:(UIPanGestureRecognizer *)panGuesture
{
    //寻找垃圾桶
    UIView *duesbinView = [panGuesture.view.superview viewWithTag:kDuesbinTag];
    if (!duesbinView) {
        return;
    }
    
    CGPoint tapPoint = [panGuesture locationInView:panGuesture.view.superview];
    
    
    if (panGuesture.state == UIGestureRecognizerStateBegan) {
        duesbinView.hidden = NO;
        _stickerCanScale = YES;
        
    }else if (panGuesture.state == UIGestureRecognizerStateChanged){
        
        
        //根据拖动手势挪动贴纸的位置
        CGPoint translatedPoint = [panGuesture translationInView:panGuesture.view];
        panGuesture.view.transform = CGAffineTransformTranslate(panGuesture.view.transform, translatedPoint.x, translatedPoint.y);
        [panGuesture setTranslation:CGPointZero inView:panGuesture.view];
        
        //是否将贴纸拖动到垃圾桶中
        BOOL panToDustbin = CGRectContainsPoint(duesbinView.frame, tapPoint);
        
        if (panToDustbin == YES && _stickerCanScale == YES) {//第一次将贴纸拖到垃圾桶中,则缩小sticker，然后设置 _stickerCanScale = NO;
            
            //震动反馈 http://ios.jobbole.com/92573/
            UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleMedium];
            [generator prepare];
            [generator impactOccurred];
            
            
            _stickerCanScale = NO;
            
            
            panGuesture.view.transform = CGAffineTransformScale(panGuesture.view.transform, 0.001, 0.001f);
            [UIView animateWithDuration:0.4f animations:^{
                duesbinView.transform = CGAffineTransformMakeScale(1.1, 1.1);
            }];
            
        }else if(panToDustbin == NO && _stickerCanScale == NO){//第一次将贴纸拖出垃圾桶中,则恢复sticker，然后设置 _stickerCanScale = yes;
            
            _stickerCanScale = YES;
            panGuesture.view.transform = CGAffineTransformScale(panGuesture.view.transform, 1000.f, 1000.f);
            [UIView animateWithDuration:0.4f animations:^{
                duesbinView.transform = CGAffineTransformIdentity;
            }];
            
        }
        
        
        
    }else if (panGuesture.state == UIGestureRecognizerStateEnded){
        duesbinView.hidden = YES;
        if (_stickerCanScale == NO) {
            [panGuesture.view removeFromSuperview];
            NSLog(@"移除该sticker");
        }else{
            NSLog(@"不用移除sticker");
        }
    }
    
    
}


-(void)stickerTapGesture:(UITapGestureRecognizer *)tap
{
    UIView *tapedView = tap.view;
    [tapedView.superview bringSubviewToFront:tapedView];
    
    
//    [currentCell.photoIV bringSubviewToFront:weakIV];
    
    CGFloat originalScale = 1.f;
//    CGFloat originalScale = CGAffineTransformGetScaleX();
    
    CAKeyframeAnimation *jumpAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    jumpAnimation.values =   @[@(1.0f*originalScale), @(0.8f*originalScale), @(1.0f*originalScale), @(1.2*originalScale), @(1.f*originalScale)];
    jumpAnimation.repeatCount = NO;
    jumpAnimation.duration = .5f;
    [tapedView.layer addAnimation:jumpAnimation forKey:@"jumpAnimation"];
}

@end





@interface RGEditPhotoCell()<UIGestureRecognizerDelegate>
{
    UIImageView *_activityIV;
}

@property(nonatomic,assign) CGFloat lastRotation;

@end
@implementation RGEditPhotoCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        _photoIV = [[UIImageView alloc]initWithFrame:self.bounds];
        [self.contentView addSubview:_photoIV];
        _photoIV.layer.masksToBounds = YES;
        _photoIV.contentMode = UIViewContentModeScaleAspectFit;
        _photoIV.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureAction:)];
        [_photoIV addGestureRecognizer:tapGesture];
        
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(gestureAction:)];
        [_photoIV addGestureRecognizer:rotationGesture];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(gestureAction:)];
        [_photoIV addGestureRecognizer:pinchGesture];
        
        
//        _transformBtn = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"rg_editPic_rotate"]];
//        [self.contentView addSubview:_transformBtn];
//        [_transformBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
//            make.right.mas_equalTo(self.contentView).offset(-20.f);
//            make.bottom.mas_equalTo(self.contentView).offset(-20.f);
//        }];
        
        self.dustbinIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"rg_editPhoto_dustbin"]];
        self.dustbinIV.tag = kDuesbinTag;
        self.dustbinIV.hidden= YES;
        self.dustbinIV.frame = CGRectMake(self.frame.size.width/2-22, self.frame.size.height-44-22, 44.f, 44.f);
        
        [_photoIV addSubview:self.dustbinIV];
        //        [self.dustbinIV mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
        //            make.bottom.and.centerX.mas_equalTo(self.photoIV);
        //        }];
        
    }
    return self;
}

-(void)gestureAction:(UIGestureRecognizer *)gesture
{
    if (self.gestureAction) {
        self.gestureAction(gesture);
    }
}

@end
