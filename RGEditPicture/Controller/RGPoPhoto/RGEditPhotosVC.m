//
//  RGEditPhotosVC.m
//  Vmei
//
//  Created by ios-02 on 2018/6/26.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "RGEditPhotosVC.h"
#import "RGEditPhotoView.h"
#import "DTFilterImageEngine.h"
//#import "BaseNetworkViewController+NetRequestManager.h"
#import "CommonBeautyItem.h"
#import "RGTagViewController.h"
//#import "XLProgressHUD.h"
//#import "SaveTempDataManager.h"
#import "RGEditPhotoTagVC.h"
#import "ZYTagInfo.h"
#import "ZYTagView.h"
#import "RGEditPhotoStickerVC.h"

#import "Config.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import <AFNetworking/AFNetworking.h>
#import "BeautyPophotoItem.h"
#define kRGEditPhoto_BottomH 49.f
#define kRGEditPhoto_StyleH 117.f

#define filter_image @"image"
#define filter_name @"name"
#define filter_tag @"tag"



@interface RGEditPhotosVC ()<UICollectionViewDelegateFlowLayout>



@property(nonatomic,strong)RGEditPhotosModel *editPhotosModel;


//编辑的照片的序列号
@property(nonatomic,strong)UILabel *sequenceLB;

//待编辑图片的容器
@property(nonatomic,strong)RGEditPhotoPicsView *photoCollectionView;

//滤镜 | 标签 | 活动
@property(nonatomic,strong)RGEditPhotoBottomView *bottomView;

//滤镜 | 标签提示  在该view上展示
@property(nonatomic,strong)RGEditPhotoFilterView *filterCollectionView;

@property(nonatomic,strong)BeautyPophotoItem *poPhotoItem;


@end

@implementation RGEditPhotosVC

-(instancetype)initWithPhotos:(NSArray <UIImage *>*)selectedPhotos
{
    self = [super init];
    if (self) {
        
        self.editPhotosModel = [[RGEditPhotosModel alloc]initWithPics:selectedPhotos];
        
    }
    return self;
}



-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController.tabBarController.tabBar setHidden:YES];
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController.tabBarController.tabBar setHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    
    //1
    [self.view addSubview:self.photoCollectionView];
    self.photoCollectionView.pictures = self.editPhotosModel.editPhotoModels;
    if (@available(iOS 11.0, *)) {
        self.photoCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    WEAKSELF
    
    self.photoCollectionView.photoTaped = ^(NSIndexPath *index, CGPoint tapPoint) {
        STRONGSELF
        [strongSelf showTagControllerAndAddTagInPoint:tapPoint];
    };
    
    self.photoCollectionView.rotateBtnClickBlock = ^(NSIndexPath *index){
        
        STRONGSELF
        NSUInteger currentIndex = [strongSelf currentPicturePage];
        [strongSelf.editPhotosModel rotatePicLeftAtIndex:currentIndex];
        [strongSelf.photoCollectionView reloadData];
        
        if (strongSelf.bottomView.selectedIndex == 0) {
            [strongSelf reloadFilterCollectionView];
        }
        
    };
    
    //2
    [self.view addSubview:self.filterCollectionView];
    [self reloadFilterCollectionView];
    
    
    //3
    [self.view addSubview:self.bottomView];
    [self.bottomView configTitles:@[@"滤镜",@"标签",@"活动"]                  pictures:@[@"rg_editPic_filter_normal",@"rg_editPic_tag_normal",@"rg_editPic_activity_normal"] selectedPics:@[@"rg_editPic_filter_selected",@"rg_editPic_tag_selected",@"rg_editPic_activity_selected"]];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self.view);
        make.height.mas_equalTo(kRGEditPhoto_BottomH);
        make.top.mas_equalTo(self.view.mas_bottom).offset(-TABBAR_HEIGHT);
    }];
    
    
    //返回
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setImage:[UIImage imageNamed:@"rg_editPic_back"] forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(12.f, StatusBarHeight, 44.f, 44.f);
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    //序列号
    [self.view addSubview:self.sequenceLB];
    self.sequenceLB.centerY = cancelBtn.center.y;
    NSString *seq = [NSString stringWithFormat:@"1/%lu",(unsigned long)self.editPhotosModel.editPhotoModels.count];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 0.3f;
    shadow.shadowColor = HEXCOLOR(0x999999);
    shadow.shadowOffset = CGSizeMake(1, 1);
    NSAttributedString *attri = [[NSAttributedString alloc]initWithString:seq attributes:@{NSShadowAttributeName:shadow}];
    self.sequenceLB.attributedText = attri;
    
    
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishBtn setImage:[UIImage imageNamed:@"rg_editPic_selected"] forState:UIControlStateNormal];
    finishBtn.frame = CGRectMake(kScreenWidth-44.f-12.f, StatusBarHeight, 44.f, 44.f);
    [finishBtn addTarget:self action:@selector(finishBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishBtn];
    
    
    [self requestActivityLayers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"");
}


-(void)cancelBtnClicked
{
//    [self backViewController];
}

//点击完成
-(void)finishBtnClicked
{
    /*
    [MobClick event:@"PoPhoto" attributes:@{@"类型":@"选择滤镜-下一步"}];
    NSMutableArray *imageViewArray = [NSMutableArray array];
    NSMutableArray *tagNameArray = [NSMutableArray array];
    
    
    //全部编辑的照片
    for (int i = 0; i< self.editPhotosModel.editPhotoModels.count; i++) {
        
        RGEditPhotoCell *cell  =  self.photoCollectionView.allCellsDic[@(i)];
        RGEditPhotoModel *editPhotoModel = self.editPhotosModel.editPhotoModels[i];
        
        UIImage *screenshotImg;
        NSMutableArray *totalArray = [NSMutableArray array];
        
        if (!cell) {//照片没有被编辑过
            screenshotImg = editPhotoModel.originalImage;
            
        }else{//cell存在，说明在用户面前展示过该页，有被编辑的可能性
            
            //隐藏tag
            [cell.photoIV.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[ZYTagView class]]) {
                    obj.hidden = YES;
                }
            }];
            
            UIGraphicsBeginImageContextWithOptions(cell.photoIV.size, NO, 3);
            CGContextRef contextRef = UIGraphicsGetCurrentContext();
            [cell.photoIV.layer renderInContext:contextRef];
            screenshotImg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            //收集标签 与 贴纸相关
            
            if ([[self collectStickersWith:editPhotoModel] isAbsoluteValid]) {
                [totalArray addObject:[self collectStickersWith:editPhotoModel]];
            }
            if ([[self collectTagsWith:editPhotoModel] isAbsoluteValid]) {
                [totalArray addObjectsFromArray:[self collectTagsWith:editPhotoModel]];
            }
            
            //收集全部关联的话题
            [tagNameArray addObjectsFromArray: [self collectThemeWith:editPhotoModel]];
            
        }

        
        //单张照片的模型转换
        BSPostContainImageItem *editImageItem = [[BSPostContainImageItem alloc] init];
        editImageItem.originalImage = screenshotImg;
        editImageItem.tagsArray = totalArray;
        [imageViewArray addObject:editImageItem];
        
    }
    
    
    NSMutableArray *newTagNameArray = [NSMutableArray array];
    for (NSString *themeStr in tagNameArray) {
        if (![[SaveTempDataManager sharedInstance].poEditContent containsString:themeStr] && ![newTagNameArray containsObject:themeStr]) {
            [newTagNameArray addObject:themeStr];
        }
    }
    //缓存标签数组
    [SaveTempDataManager sharedInstance].tagNameArray = newTagNameArray;
    //标签数组转换成字符串
    NSString *str=[newTagNameArray componentsJoinedByString:@" "];
    if ([[SaveTempDataManager sharedInstance].poEditContent isAbsoluteValid]) {
        [SaveTempDataManager sharedInstance].poEditContent = [NSString stringWithFormat:@"%@%@",str,[SaveTempDataManager sharedInstance].poEditContent];
    }else{
        [SaveTempDataManager sharedInstance].poEditContent = str;
    }
    
                
    [[NSNotificationCenter defaultCenter] postNotificationName:kBackToVCNotificationKey object:imageViewArray];
    [self.navigationController.tabBarController dismissViewControllerAnimated:YES completion:nil];
    */
}



#pragma mark Setter && Getter
-(RGEditPhotoPicsView *)photoCollectionView
{
    if (!_photoCollectionView) {
        
        _photoCollectionView = [[RGEditPhotoPicsView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kRGEditPhoto_StyleH-TABBAR_HEIGHT)];
        _photoCollectionView.delegate = self;
        _photoCollectionView.pagingEnabled = YES;
        
        
    }
    return _photoCollectionView;
}

-(RGEditPhotoFilterView *)filterCollectionView
{
    if (!_filterCollectionView) {
        UICollectionViewFlowLayout *flowLaout = [[UICollectionViewFlowLayout alloc]init];
        flowLaout.itemSize = CGSizeMake(76.f, kRGEditPhoto_StyleH);
        flowLaout.minimumLineSpacing = 10.f;
        flowLaout.sectionInset = UIEdgeInsetsMake(0, 10.f, 0, 10.f);
        flowLaout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _filterCollectionView = [[RGEditPhotoFilterView alloc]initWithFrame:CGRectMake(0, kScreenHeight-TABBAR_HEIGHT-kRGEditPhoto_StyleH, kScreenWidth, kRGEditPhoto_StyleH) collectionViewLayout:flowLaout];
        _filterCollectionView.delegate = self;
    }
    return _filterCollectionView;
}

-(RGEditPhotoBottomView *)bottomView
{
    if (!_bottomView) {
        
        UICollectionViewFlowLayout *flowLaout = [[UICollectionViewFlowLayout alloc]init];
        flowLaout.itemSize = CGSizeMake((kScreenWidth-10*2)/3.f, kRGEditPhoto_BottomH);
        flowLaout.minimumLineSpacing = 10.f;
        flowLaout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _bottomView = [[RGEditPhotoBottomView alloc]initWithFrame:CGRectMake(0, kScreenHeight-TABBAR_HEIGHT, kScreenWidth, TABBAR_HEIGHT) collectionViewLayout:flowLaout];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

-(UILabel *)sequenceLB
{
    if (!_sequenceLB) {
        _sequenceLB = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 60, 32)];
        _sequenceLB.centerX = self.view.centerX;
        _sequenceLB.font = SP15Font;
        _sequenceLB.textAlignment = NSTextAlignmentCenter;
        _sequenceLB.textColor = HEXCOLOR(0xffffff);
        _sequenceLB.userInteractionEnabled = NO;
    }
    return _sequenceLB;
}



#pragma mark UICollectionView Delegate


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.photoCollectionView) {
        

        
    }else if (collectionView == self.filterCollectionView){
        
        //待编辑的照片模型
        RGEditPhotoModel *model = self.editPhotosModel.editPhotoModels[[self currentPicturePage]];
        model.selectedFilter = indexPath.item;
        
        [self reloadFilterCollectionView];
        [self updatePicFilter];
            


        
    }else if (collectionView == self.bottomView){
        self.bottomView.selectedIndex = indexPath.item;
        
        if (indexPath.item == 0) {//滤镜
            [self reloadFilterCollectionView];
            
        }else if (indexPath.item == 1){//标签
            self.filterCollectionView.filterModels = nil;
            
            RGEditPhotoCell *currentCell = self.photoCollectionView.allCellsDic[@([self currentPicturePage])];//
            [self showTagControllerAndAddTagInPoint:[currentCell convertPoint:currentCell.photoIV.center toView:currentCell.photoIV]];
            
        }else if (indexPath.item == 2){//活动
            

            RGEditPhotoStickerVC *stickerVC = [[RGEditPhotoStickerVC alloc]init];
            stickerVC.stickerArray = self.poPhotoItem.stickersArray;
            WEAKSELF

            [stickerVC setStickerCellClicked:^(NSIndexPath *index,UIImage *sticker) {
                STRONGSELF
                [strongSelf addStickerImage:sticker withIndex:index];

            }];
            stickerVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            self.definesPresentationContext = YES;
            [self presentViewController:stickerVC animated:YES completion:nil];
            
        }
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    if (scrollView == self.photoCollectionView) {
        
        
        NSString *seq = [NSString stringWithFormat:@"%ld/%lu",[self currentPicturePage]+1,(unsigned long)self.editPhotosModel.editPhotoModels.count];
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowBlurRadius = 0.5;
        shadow.shadowColor = HEXCOLOR(0x999999);
        shadow.shadowOffset = CGSizeMake(1, 1);
        NSAttributedString *attri = [[NSAttributedString alloc]initWithString:seq attributes:@{NSShadowAttributeName:shadow}];
        self.sequenceLB.attributedText = attri;
        
        if (self.bottomView.selectedIndex == 0) {
            [self reloadFilterCollectionView];
        }
        
    }
}


#pragma mark Network
/*
- (void)setNetworkRequestStatusBlocks
{
    WEAKSELF
    self.startedBlock = ^(NetRequest *request)
    {
        
    };
    [self setNetSuccessBlock:^(NetRequest *request, id successInfoObj) {
        if (successInfoObj && [successInfoObj isKindOfClass:[NSDictionary class]])
        {
            STRONGSELF
            switch (request.tag) {
                case NetBeautyRquestType_BeautyCreatePost:
                {
                    if ([successInfoObj isAbsoluteValid])
                    {
                        
                        strongSelf.poPhotoItem = [[BeautyPophotoItem alloc] initWithDict:successInfoObj];
                   

                    }
                }
                    break;
                default:
                    break;
            }
        }
    } failedBlock:^(NetRequest *request, NSError *error)
     {
         switch (request.tag) {
             case NetBeautyRquestType_BeautyCreatePost:
                 break;
             default:
                 break;
         }
     }];
}
*/
/*!
 *  @author DT
 *
 *  @brief  获取初始化数据
 */
- (void)requestActivityLayers {
//    [self sendRequest:[[self class] getRequestURLStr:NetBeautyRquestType_BeautyCreatePost]
//         parameterDic:nil
//       requestHeaders:nil
//    requestMethodType:RequestMethodType_GET
//           requestTag:NetBeautyRquestType_BeautyCreatePost
//             delegate:self
//             userInfo:nil
//       netCachePolicy:NetUseCacheFirstWhenCacheValidAndAskServerAgain
//         cacheSeconds:CacheNetDataTimeType_Forever];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:"https://app.vmei.com/beauty/createPost/init" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.poPhotoItem = [[BeautyPophotoItem alloc] initWithDict:successInfoObj];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"");
    }];
}

#pragma mark Private Method

-(NSInteger)currentPicturePage
{
    return lroundf(self.photoCollectionView.contentOffset.x/kScreenWidth);
}

//更新被编辑图片数组中的某个图片的滤镜
-(void)updatePicFilter
{
    NSInteger page = [self  currentPicturePage];
    RGEditPhotoCell *currentCell = self.photoCollectionView.allCellsDic[@(page)];
    RGEditPhotoModel *model = self.editPhotosModel.editPhotoModels[page];
    currentCell.photoIV.image = model.editedImage;
}

/*
 * 刷新滤镜选项中的图片
 */
-(void)reloadFilterCollectionView
{
    RGEditPhotoModel *model = self.editPhotosModel.editPhotoModels[[self currentPicturePage]];
    
    [DTFilterImageEngine getSmallFilterImages:model.originalImage block:^(NSArray *results) {
        NSMutableArray *filterModelArr = [NSMutableArray array];
        for (NSDictionary *dic in results) {
            RGEditPhotoFilterModel *model = [[RGEditPhotoFilterModel alloc]init];
            model.pic = [dic safeObjectForKey:filter_image];
            model.title = [dic safeObjectForKey:filter_tag];
            [filterModelArr addObject:model];
        }
        self.filterCollectionView.filterModels = filterModelArr;
        self.filterCollectionView.selectedIndex = model.selectedFilter;
    }];
}


//将序列号为index的贴纸贴到当前图片
-(void)addStickerImage:(UIImage *)sticker withIndex:(NSIndexPath *)indexPath {
    
    if (sticker == nil) {
        return;
    }
    
    if (self.poPhotoItem.stickersArray.count > indexPath.item) {
        //将贴纸模型赋值到新模型
        BeautyPophotoTagItem *stickerProperty = self.poPhotoItem.stickersArray[indexPath.item];
        RGEditPhotoModel *model = self.editPhotosModel.editPhotoModels[[self currentPicturePage]];
        [model.stickerPropertys addObject:stickerProperty];
        
//        [self updatePicSticker:sticker withStickerItem:stickerProperty];
        [self.photoCollectionView addSticker:sticker inCell:[self currentPicturePage]];
    }
}

//搜集单张图片的贴纸
-(NSArray *)collectStickersWith:(RGEditPhotoModel * )editPhotoModel
{
    NSMutableArray *stickerArray = [NSMutableArray array];
    
    for (BeautyPophotoTagItem *stickerProperty in editPhotoModel.stickerPropertys) {
        //贴纸 模型处理
        //        BeautyPophotoTagItem *item = stickerModel.stickerProperty;
        if (stickerProperty.propertyId == 500047) {
            BSPostContainImageTagItem *tagItem = [[BSPostContainImageTagItem alloc] init];
            tagItem.tagId = stickerProperty.kid;
            tagItem.tagName = stickerProperty.name;
            tagItem.isBrand = YES;
            tagItem.pid = stickerProperty.propertyId;
            tagItem.vid = stickerProperty.valueId;
            tagItem.xPercentage = 0.1;
            tagItem.yPercentage = 0.1;
            [stickerArray addObject:tagItem];
        }
    }
    
    return stickerArray;
    
}

//单张图片 全部贴纸 模型关联的话题 收集
-(NSArray <NSString *>*)collectThemeWith:(RGEditPhotoModel *)editPhotoModel
{
    NSMutableArray *tagNameArray = [NSMutableArray array];
    for (BeautyPophotoTagItem *stickerProperty in editPhotoModel.stickerPropertys) {
        if (stickerProperty.propertyId == 500047) {
            NSString *str = [NSString stringWithFormat:@"#%@#",stickerProperty.name];
            if (![tagNameArray containsObject:str]) {
                [tagNameArray addObject:str];
            }
            
        }
    }
    return tagNameArray;
}


-(NSArray *)collectTagsWith:(RGEditPhotoModel *)editPhotoModel
{
    NSMutableArray *tagsArray = [NSMutableArray array];
    // 单张图片 标签 收集
    for (BeautyPophotoTagItem *tagProperty in editPhotoModel.tagPropertys) {
        NSMutableArray *oneTagArray = [NSMutableArray new];
        
        //主标签
        if (tagProperty) {
            BSPostContainImageTagItem *tagItem = [[BSPostContainImageTagItem alloc] init];
            tagItem.tagId = tagProperty.kid;
            tagItem.tagName = tagProperty.name;
            tagItem.isBrand = YES;
            tagItem.pid = tagProperty.propertyId==0?self.poPhotoItem.brandPid:tagProperty.propertyId;
            tagItem.vid = tagProperty.valueId;
            tagItem.xPercentage = tagProperty.xPercent;
            tagItem.yPercentage = tagProperty.yPercent;
            
            [oneTagArray addObject:tagItem];
        }
        
        [tagsArray addObject:oneTagArray];
    }
    
    return tagsArray;
}


//图片上添加tag
-(void)showTagControllerAndAddTagInPoint:(CGPoint)tagPoint
{
    NSInteger currentPage = [self currentPicturePage];
    RGEditPhotoCell *currentCell = self.photoCollectionView.allCellsDic[@(currentPage)];//
    
    
    RGEditPhotoTagVC *tagVC = [[RGEditPhotoTagVC alloc]init];
    tagVC.selectTagComplete = ^(RGEditPhotoTagModel *tagModel) {
        
        RGEditPhotoModel *editPhotoModel = self.editPhotosModel.editPhotoModels[currentPage];
        
        BeautyPophotoTagItem *tagItem = [[BeautyPophotoTagItem alloc]init];
        tagItem.propertyId = tagModel.pid;
        tagItem.name = tagModel.name;
        tagItem.xPercent = tagPoint.x/currentCell.photoIV.width;
        tagItem.yPercent = tagPoint.y/currentCell.photoIV.height;
        
        [editPhotoModel.tagPropertys addObject:tagItem];
        
        
        ZYTagInfo *info2 = [ZYTagInfo tagInfo];
        info2.proportion = ZYPositionProportionMake(tagItem.xPercent, tagItem.yPercent);
        if (tagModel.type == RGEditPhotoTagType_Custom) {
            info2.title = [NSString stringWithFormat:@"# %@",tagItem.name];
        }else if (tagModel.type == RGEditPhotoTagType_Brand){
            info2.title = [NSString stringWithFormat:@"🏷️ %@",tagItem.name];
        }else{
            info2.title = tagItem.name;
        }                
        
        ZYTagView *tagView = [[ZYTagView alloc] initWithTagInfo:info2];
        tagView.tagViewEndMove = ^(CGPoint tapedPoint) {
            tagItem.xPercent = tapedPoint.x/currentCell.photoIV.width;
            tagItem.yPercent = tapedPoint.y/currentCell.photoIV.height;
        };
        tagView.tagViewDeleted = ^{
            [editPhotoModel.tagPropertys removeObject:tagItem];
        };
        __weak typeof(tagView) weakTagView = tagView;
        tagView.tagLinkClicked = ^{
            
            [currentCell.photoIV bringSubviewToFront:weakTagView];
        };
        [currentCell.photoIV addSubview:tagView];
        [tagView showAnimationWithRepeatCount:CGFLOAT_MAX];
    };

    
    tagVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.definesPresentationContext = YES;
    [self presentViewController:tagVC animated:YES completion:nil];
}


@end





