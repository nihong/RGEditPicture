//
//  ViewController.m
//  RGImageSticker
//
//  Created by 泥红 on 30/8/18.
//  Copyright © 2018年 RoyGao. All rights reserved.
//

#import "ViewController.h"
#import "RGImageCollectionView.h"
#import "RGStickerViewController.h"

@interface ViewController ()<UICollectionViewDelegateFlowLayout>

//待编辑图片的容器
@property(nonatomic,strong)RGImageCollectionView *photoCollectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //origin master change
    //origin master change2
    // Do any additional2
    // Do any additional3


    // Do any additional2



    
    //1
    [self.view addSubview:self.photoCollectionView];
    self.photoCollectionView.pictures = @[[UIImage imageNamed:@"girl_0"],
                                          [UIImage imageNamed:@"girl_1"],
                                          [UIImage imageNamed:@"girl_2"],
                                          [UIImage imageNamed:@"girl_3"],
                                          [UIImage imageNamed:@"girl_4"],
                                          [UIImage imageNamed:@"girl_5"]];
    if (@available(iOS 11.0, *)) {
        self.photoCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    UIButton *sticker = [UIButton buttonWithType:UIButtonTypeCustom];
    sticker.frame = CGRectMake(self.view.frame.size.width-44, 40, 44, 44);
    [self.view addSubview:sticker];
    [sticker setTitle:@"Sticker" forState:UIControlStateNormal];
    [sticker addTarget:self action:@selector(stickerShowUp) forControlEvents:UIControlEventTouchUpInside];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark Setter && Getter
-(RGImageCollectionView *)photoCollectionView
{
    if (!_photoCollectionView) {
        
        _photoCollectionView = [[RGImageCollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _photoCollectionView.delegate = self;
        _photoCollectionView.pagingEnabled = YES;
        
        
    }
    return _photoCollectionView;
}

-(void)stickerShowUp
{
    
    RGStickerViewController *stickerVC = [[RGStickerViewController alloc]init];
    stickerVC.stickerArray = @[[UIImage imageNamed:@"girl_0"],
                               [UIImage imageNamed:@"girl_1"],
                               [UIImage imageNamed:@"girl_2"],
                               [UIImage imageNamed:@"girl_3"],
                               [UIImage imageNamed:@"girl_4"],
                               [UIImage imageNamed:@"girl_5"]];
    
    [stickerVC setStickerCellClicked:^(NSIndexPath *index,UIImage *sticker) {

        [self.photoCollectionView addSticker:sticker inCell:[self currentPicturePage]];
//        [self addStickerImage:sticker withIndex:index];
        
    }];
    stickerVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.definesPresentationContext = YES;
    [self presentViewController:stickerVC animated:YES completion:nil];
}


-(NSInteger)currentPicturePage
{
    return lroundf(self.photoCollectionView.contentOffset.x/self.photoCollectionView.frame.size.width);
}

@end
//master 加代码
/*
 -(NSInteger)currentPicturePage
 {
 return lroundf(self.photoCollectionView.contentOffset.x/self.photoCollectionView.frame.size.width);
 }
 */
