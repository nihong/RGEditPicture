//
//  RGEditPhotoView.m
//  Vmei
//
//  Created by ios-02 on 2018/6/26.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "RGEditPhotoView.h"
#import "DTFilterImageEngine.h"
#import "PopPhotoAssemblyTagView.h"
//#import <AudioToolbox/AudioToolbox.h>

#define kDuesbinTag 888

static NSString *const kRGEditPhotoTopPicCell_id = @"kRGEditPhotoTopPicCell_id";
static NSString *const kRGEditPhotoBottomCell_id = @"kRGEditPhotoBottomCell_id";
static NSString *const kRGEditPhotoFilterCell_id = @"kRGEditPhotoFilterCell_id";

@implementation RGEditPhotoView



@end


//////////////////////////////RGEditPhotoPicsView//////////////////////////////
@interface RGEditPhotoPicsView()<UICollectionViewDataSource>

//创建数据盛放所有的cell，避免被销毁重用，同时肯定也就不能使用ReuseIdentifier了
@property(nonatomic,strong,readwrite)NSMutableDictionary *allCellsDic;

//贴纸是否能scale --> 为贴纸的缩小放大设置的锁
@property(nonatomic,assign)BOOL stickerCanScale;


@end
@implementation RGEditPhotoPicsView
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
        
        self.backgroundColor = HEXCOLOR(0xffffff);
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
    

    
    RGEditPhotoModel *model = self.pictures[indexPath.item];
    cell.photoIV.image = model.editedImage;
    cell.photoIV.size = [self scalePicSize:model.editedImage];
    cell.photoIV.center = cell.contentView.center;
    cell.dustbinIV.frame = CGRectMake(cell.photoIV.size.width/2.f-22.f, cell.photoIV.size.height-44.f-20.f, 44.f, 44.f);
        
    
    cell.photoIV.tag = indexPath.item;
    cell.transformBtn.tag = indexPath.item;
    __weak typeof(cell.photoIV) weakIV = cell.photoIV;
    cell.gestureAction = ^(UIGestureRecognizer *gesture) {
        [self recoginizeGesture:gesture InPic:weakIV];
    };
//    UITapGestureRecognizer *photoIVGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoIVClicked:)];
//    [cell.photoIV addGestureRecognizer:photoIVGesture];
    
    
    [cell.transformBtn addTarget:self action:@selector(transformBtnClicked:)];
    
    
    return cell;
    
}

-(CGSize)scalePicSize:(UIImage *)pic
{
    //collectionView的宽高比
    CGFloat contentRatio = self.width/self.height;
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
        newPicSize = CGSizeMake(picRatio*self.height, self.height);
        
        
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
        newPicSize = CGSizeMake(self.width, self.width/picRatio);
    }
    return newPicSize;
    
}

-(void)setPictures:(NSArray <RGEditPhotoModel *>*)pictures
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

    stickerIV.center = CGPointMake(currentCell.photoIV.width/2.f, currentCell.photoIV.height/2.f);
    
    __weak typeof(stickerIV) weakIV = stickerIV;


    
    UIPanGestureRecognizer *stickerPanGuesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(stickerPanGesture:)];
    [stickerIV addGestureRecognizer:stickerPanGuesture];

    
    //点击添加跳跃动画
    [stickerIV addTapGestureRecognizer:^(UITapGestureRecognizer *recognizer, NSString *gestureId) {
        
        [currentCell.photoIV bringSubviewToFront:weakIV];
        
        CGFloat originalScale = CGAffineTransformGetScaleX(weakIV.transform);
        
        CAKeyframeAnimation *jumpAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        jumpAnimation.values =   @[@(1.0f*originalScale), @(0.8f*originalScale), @(1.0f*originalScale), @(1.2*originalScale), @(1.f*originalScale)];
        jumpAnimation.repeatCount = NO;
        jumpAnimation.duration = .5f;
        [weakIV.layer addAnimation:jumpAnimation forKey:@"jumpAnimation"];
        
    }];
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

@end







//////////////////////////////RGEditPhotoFilterView//////////////////////////////
@interface RGEditPhotoFilterView ()<UICollectionViewDataSource>

@end
@implementation RGEditPhotoFilterView

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    
    self =  [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.selectedIndex = -1;
        self.backgroundColor = HEXCOLOR(0xffffff);
        self.dataSource = self;
        self.showsHorizontalScrollIndicator = NO;
        [self registerClass:[RGEditPhotoFilterCell class] forCellWithReuseIdentifier:kRGEditPhotoFilterCell_id];
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.filterModels.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RGEditPhotoFilterCell *cell = (RGEditPhotoFilterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kRGEditPhotoFilterCell_id forIndexPath:indexPath];
    if (self.filterModels.count>indexPath.item) {
        RGEditPhotoFilterModel *model = self.filterModels[indexPath.item];
        if (model.pic) {
            cell.topIV.image = model.pic;
        }else if ([model.picUrlStr isAbsoluteValid]){
            [cell.topIV sd_setImageWithURL:[NSURL URLWithString:model.picUrlStr]];
        }
        
        cell.bottomLB.text = model.title;
        
    }
    
    if (indexPath.item == self.selectedIndex) {
        cell.bottomLB.textColor = HEXCOLOR(0xff2642);
    }else{
        cell.bottomLB.textColor = HEXCOLOR(0x999999);
    }
    
    
    
    return cell;
}

-(void)setFilterModels:(NSArray *)models
{
    _filterModels = models;
    if (!_filterModels) {
        UILabel *tagTipLB =[[UILabel alloc]initWithFrame:self.bounds];
        tagTipLB.text = @"点击图片任意位置添加标签";
        tagTipLB.textColor = HEXCOLOR(0x333333);
        tagTipLB.font = SP13Font;
        tagTipLB.textAlignment = NSTextAlignmentCenter;
        self.backgroundView = tagTipLB;
    }else{
        self.backgroundView = nil;
    }
    [self reloadData];
}



-(void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    if (_selectedIndex>=0 && _selectedIndex<self.filterModels.count) {
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}


@end











//////////////////////////////RGEditPhotoBottomView//////////////////////////////
@interface RGEditPhotoBottomView ()<UICollectionViewDataSource>

@property(nonatomic,strong)NSArray *titles;
@property(nonatomic,strong)NSArray *pictures;
@property(nonatomic,strong)NSArray *selectedPictures;

@end
@implementation RGEditPhotoBottomView
-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self =  [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = HEXCOLOR(0xffffff);
        self.dataSource = self;
        self.showsHorizontalScrollIndicator = NO;
        [self registerClass:[RGEditPhotoBarItemCell class] forCellWithReuseIdentifier:kRGEditPhotoBottomCell_id];
        
        
        UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5f)];
        topLine.backgroundColor = HEXCOLOR(0x999999);
        [self addSubview:topLine];
    }
    return self;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.titles.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RGEditPhotoBarItemCell *cell = (RGEditPhotoBarItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kRGEditPhotoBottomCell_id forIndexPath:indexPath];
    
    cell.bottomLB.text = self.titles[indexPath.item];
    cell.bottomLB.font = [UIFont boldSystemFontOfSize:11.f];
    if (indexPath.item == self.selectedIndex) {
        cell.bottomLB.textColor = HEXCOLOR(0x333333);
        cell.topIV.image = [UIImage imageNamed:self.selectedPictures[indexPath.item]];
    }else{
        cell.bottomLB.textColor = HEXCOLOR(0x999999);
        cell.topIV.image = [UIImage imageNamed:self.pictures[indexPath.item]];
    }
    return cell;
}



-(void)configTitles:(NSArray *)titles pictures:(NSArray *)pictures selectedPics:(NSArray *)selectedPics
{
    _pictures = pictures;
    _titles = titles;
    _selectedPictures = selectedPics;
    [self reloadData];
}

-(void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    [self reloadData];
}



@end











//////////////////////////////RGEditPhotoBarItemCell//////////////////////////////
@interface RGEditPhotoBarItemCell()

@end
@implementation RGEditPhotoBarItemCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        _topIV = [[UIImageView alloc]init];
        [self.contentView addSubview:_topIV];
        [_topIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView);
            make.width.and.height.mas_equalTo(24.f);
            make.top.mas_equalTo(self.contentView).offset(5.f);
        }];
        
        
        
        _bottomLB = [[UILabel alloc]init];
        [self.contentView addSubview:_bottomLB];
        [_bottomLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView);
            make.top.mas_equalTo(_topIV.mas_bottom).offset(5.f);
        }];
        _bottomLB.font = SP11Font;
        _bottomLB.textColor = HEXCOLOR(0x999999);
        
    }
    return self;
}

@end



//////////////////////////////RGEditPhotoFilterCell//////////////////////////////
@interface RGEditPhotoFilterCell()

@end
@implementation RGEditPhotoFilterCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        
        _topIV = [[UIImageView alloc]init];
        [self.contentView addSubview:_topIV];
        _topIV.contentMode = UIViewContentModeScaleAspectFill;
        _topIV.backgroundColor = HEXCOLOR(0x000000);
        [_topIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(76.f, 76.f));
            make.top.mas_equalTo(self.contentView).offset(10.f);
        }];
        
        ViewRadius(_topIV, 5.f);
        
        _bottomLB = [[UILabel alloc]init];
        [self.contentView addSubview:_bottomLB];
        [_bottomLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView);
            make.centerY.mas_equalTo(self.contentView.mas_bottom).offset(-16.f);
        }];
        _bottomLB.font = SP11Font;
        _bottomLB.textColor = HEXCOLOR(0x999999);
        
    }
    return self;
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
        
        
        _transformBtn = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"rg_editPic_rotate"]];
        [self.contentView addSubview:_transformBtn];
        [_transformBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
            make.right.mas_equalTo(self.contentView).offset(-20.f);
            make.bottom.mas_equalTo(self.contentView).offset(-20.f);
        }];
        
        self.dustbinIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"rg_editPhoto_dustbin"]];
        self.dustbinIV.tag = kDuesbinTag;
        self.dustbinIV.hidden= YES;
        self.dustbinIV.frame = CGRectMake(0, 0, 44.f, 44.f);
        self.dustbinIV.centerX = self.centerX;
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










