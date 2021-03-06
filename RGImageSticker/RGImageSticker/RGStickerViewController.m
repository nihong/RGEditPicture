//
//  RGStickerViewController.m
//  RGImageSticker
//
//  Created by 泥红 on 31/8/18.
//  Copyright © 2018年 RoyGao. All rights reserved.
//

#import "RGStickerViewController.h"



//贴纸
@interface RGPhotoStickerCell:UICollectionViewCell

@property(nonatomic,strong)UIImageView *stickerIV;

@end

@implementation RGPhotoStickerCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.stickerIV = [[UIImageView alloc]init];
        [self.contentView addSubview:self.stickerIV];
        self.stickerIV.contentMode = UIViewContentModeScaleAspectFit;
        self.stickerIV.frame = CGRectMake(20, 20, frame.size.width-40, frame.size.height-40);

    }
    return self;
}

@end




static NSString *const kRGPhotoStickerCellID = @"kRGPhotoStickerCellID";

@interface RGStickerViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIGestureRecognizerDelegate>

@property(nonatomic,strong)UIView *topGuestureView;

@property(nonatomic,strong)UIVisualEffectView *visualEffectView;


@property(nonatomic,strong)UICollectionView *collectionView;

//自动显示或者隐藏贴纸板
-(void)outoChangeStickerState;

-(void)moveToTop;

-(void)moveToCenter;

-(void)moveToBottom;

//@property(nonatomic,copy)void(^stickerCellClicked)(NSIndexPath *index,UIImage *sticker);

@end

@implementation RGStickerViewController
-(void)dealloc
{
    NSLog(@"-----------xiaohuile-----------");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    
    [self.view addSubview:self.visualEffectView];
    [self moveToCenter];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackgroundView:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

-(void)tapBackgroundView:(UIGestureRecognizer *)tap
{
    [self moveToBottom];
    
}

#pragma mark- --点击手势代理，为了去除手势冲突--
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([touch.view isDescendantOfView:self.collectionView]){
        return NO;
    }
    return YES;
}




-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout  = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = 0.f;
        flowLayout.minimumInteritemSpacing = 0.f;
        
        CGSize size = _visualEffectView.bounds.size;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 30, size.width, size.height-30) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.2]; //HEXCOLORAL(0x000000, 0.2f);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[RGPhotoStickerCell class] forCellWithReuseIdentifier:kRGPhotoStickerCellID];
        
        
    }
    return _collectionView;
}

-(UIVisualEffectView *)visualEffectView
{
    if (!_visualEffectView) {
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _visualEffectView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height*0.9);
        
        
        UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30.f)];
        [_visualEffectView.contentView addSubview:header];
        
        header.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        //点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerClicked)];
        [header addGestureRecognizer:tap];
        
        //向上拖动事件
        UISwipeGestureRecognizer *upSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(headerSwiped:)];
        upSwipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
        [header addGestureRecognizer:upSwipeGesture];
        
        //向下拖动
        UISwipeGestureRecognizer *downSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(headerSwiped:)];
        downSwipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
        [header addGestureRecognizer:downSwipeGesture];
        
        //header中的横线
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 66.f, 5.f)];
        lineView.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
        lineView.layer.cornerRadius = 2.f;
        
//        ViewRadius(lineView, 2.f);
        lineView.center = header.center;
//        lineView.backgroundColor = [UIColor darkGrayColor];
        [header addSubview:lineView];
        
        //切割上面圆角
        CGRect rect = _visualEffectView.bounds;
        CGSize cornerSize = CGSizeMake(12.f, 12.f);
        UIRectCorner corner = UIRectCornerTopLeft|UIRectCornerTopRight;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:cornerSize];
        
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc]init];
        shapeLayer.path = path.CGPath;
        shapeLayer.frame  = rect;
        _visualEffectView.layer.mask = shapeLayer;
        
        
        
        [_visualEffectView.contentView addSubview:self.collectionView];

    }
    return _visualEffectView;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return self.stickerArray.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    RGPhotoStickerCell *cell = (RGPhotoStickerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kRGPhotoStickerCellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor  clearColor];
    cell.stickerIV.image = self.stickerArray[indexPath.item];
//    BeautyPophotoTagItem *stickerItem = self.stickerArray[indexPath.item];
//    cell.userInteractionEnabled = NO;
//    [cell.stickerIV sd_setImageWithURL:[NSURL URLWithString:stickerItem.icon] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        cell.userInteractionEnabled = YES;
//    }];
    
    return cell;
    
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.stickerCellClicked) {
        RGPhotoStickerCell *cell = (RGPhotoStickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
        self.stickerCellClicked(indexPath,cell.stickerIV.image);
    }
    [self moveToBottom];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(self.view.frame.size.width/3.f-1.f, self.view.frame.size.width/3.f);
    
}


-(void)outoChangeStickerState
{
    if (_visualEffectView.frame.origin.y<= self.view.frame.size.height ) {//之前隐藏->弹出
        [self moveToCenter];
    }
    else //之前显示->隐藏
    {
        [self moveToBottom];
        
    }
    [self.collectionView reloadData];
}

//header被点击
-(void)headerClicked{
    
    if (_visualEffectView.frame.size.height > self.view.frame.size.height*0.55 && _visualEffectView.frame.size.height<= 0.65*self.view.frame.size.height) {//中间->顶部
        [self moveToTop];
    }
    else //顶部->隐藏
    {
        [self moveToBottom];
    }
    [self.collectionView reloadData];
}

//header被上下滑动
-(void)headerSwiped:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionUp) {
        [self moveToTop];
    }else if (gesture.direction  == UISwipeGestureRecognizerDirectionDown){
        [self moveToBottom];
    }
}


-(void)setStickerArray:(NSArray<UIImage *> *)stickerArray
{
    if (_stickerArray !=stickerArray) {
        _stickerArray = stickerArray;
        [self.collectionView reloadData];
    }
}

-(void)moveToTop
{

    [UIView animateWithDuration:0.4 animations:^{
        self.visualEffectView.frame = CGRectMake(0, 0.1*self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height*0.9);
    }];
}

-(void)moveToCenter
{
    [UIView animateWithDuration:0.4 animations:^{
        self.visualEffectView.frame = CGRectMake(0, 0.4*self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height*0.6);
    }];
}

-(void)moveToBottom
{
    
    [UIView animateWithDuration:0.4f animations:^{
        self.visualEffectView.frame = CGRectMake(0,self.view.frame.size.height, self.view.frame.size.width, 0);
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

@end

