//
//  RGTagViewController.m
//  Vmei
//
//  Created by ios-02 on 2018/7/12.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "RGTagViewController.h"
#import "PopPhotoTagMainView.h"
#import "BaseNetworkViewController+NetRequestManager.h"
#import "PopPhotoAssemblyTagView.h"

@interface RGTagViewController ()

@property (nonatomic,strong ) RGPopPhotoTagMainView     *tagView;



@property (nonatomic, strong) NSMutableArray          *keyBrandsArray;
@property (nonatomic, strong) NSMutableArray          *brandsArray;

@end

@implementation RGTagViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addLabel];
    [self getTagBrand];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    NSLog(@"");
}

-(NSMutableArray *)keyBrandsArray
{
    if (!_keyBrandsArray) {
        _keyBrandsArray = [NSMutableArray array];
    }
    return _keyBrandsArray;
}

-(NSMutableArray *)brandsArray
{
    if (!_brandsArray) {
        _brandsArray = [NSMutableArray array];
    }
    return _brandsArray;
}

/**
 *  点击添加标签
 *
 *  @param sender
 */
- (void)addLabel
{
    
    [self initTagView];
    [self.tagView show];
    self.tagView.currentSearchBar = self.tagView.tableHeaderView.brandSearchBar;
    self.tagView.tableHeaderView.currentSearchBar = self.tagView.tableHeaderView.brandSearchBar;
    self.tagView.isHaveBrand = YES;
    [self.tagView setBrandsData];
    [self.tagView.tableView reloadData];
    
}

-(void)initTagView {
    
    self.tagView = [[RGPopPhotoTagMainView alloc] init];
    [self.view addSubview:self.tagView];
    [self.tagView setItem:self.item];
    [self.tagView setKeyBrandArray:self.keyBrandsArray brandsArray:self.brandsArray];
    WEAKSELF
    [self.tagView setSearchBarShouldBeginEditing:^(UISearchBar *searchBar) {
        
    }];
    [self.tagView setSearchBarTextDidChange:^(UISearchBar *searchBar) {
        if (searchBar.tag == 80000) {
            [weakSelf getTagSearch:searchBar.text propertyId:[NSString stringWithFormat:@"%li",(long)weakSelf.item.brandPid]];
        }else if (searchBar.tag > 90000) {
            [weakSelf getTagSearch:searchBar.text propertyId:[NSString stringWithFormat:@"%li",(long)weakSelf.item.effectPid]];
        }
    }];
    
    [self.tagView setTagSuccess:^(BeautyPophotoTagItem *item, NSMutableArray<BeautyPophotoTagItem*> *array) {
        STRONGSELF
        if (!strongSelf) {
            return ;
        }
        if (strongSelf.finishChooseTagCallBack) {
            strongSelf.finishChooseTagCallBack(item, array);
        }
        
        /*
        PopPhotoAssemblyTagView *assemblyView = [PopPhotoAssemblyTagView initWithBrandTag:item effectTagArray:array];
        assemblyView.tag = weakSelf.filterImage.tag;
        CGPoint imageCenter;
        if (weakSelf.imageWidthRatio == 0&&weakSelf.imageHeightRatio == 0)
        {
            imageCenter = weakSelf.filterImage.center;
        }
        else
        {
            imageCenter = CGPointMake(weakSelf.filterImage.width*weakSelf.imageWidthRatio, weakSelf.filterImage.height*weakSelf.imageHeightRatio);
        }
        
        assemblyView.center = imageCenter;
        weakSelf.filterImage.clipsToBounds = YES;
        [weakSelf.filterImage addSubview:assemblyView];
        
        
        if (weakSelf.currentAssemblyTagView) {
            if ([weakSelf.tagViewArray containsObject:weakSelf.currentAssemblyTagView]) {
                [weakSelf.currentAssemblyTagView removeFromSuperview];
                [weakSelf.tagViewArray removeObject:weakSelf.currentAssemblyTagView];
                [weakSelf.tagViewArray addObject:assemblyView];
            }else{
                [weakSelf.tagViewArray addObject:assemblyView];
            }
        }else{
            [weakSelf.tagViewArray addObject:assemblyView];
        }
        
        [assemblyView setAssemblyBlock:^(PopPhotoAssemblyTagView * view) {
            weakSelf.currentAssemblyTagView = view;
            [weakSelf.tagView setBrand:view.brandItem effectTagsArray:[NSMutableArray arrayWithArray:view.effectArray]];
            [weakSelf.tagView show];
        }];
        [assemblyView setDeleteAssemblyBlock:^(PopPhotoAssemblyTagView *view) {
            if ([weakSelf.tagViewArray containsObject:view]) {
                [weakSelf.tagViewArray removeObject:view];
                [view removeFromSuperview];
            }
        }];
        */
        [weakSelf backButtonClicked];
    }];
    
    [self.tagView.backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)backButtonClicked
{
    if (self.cancelChooseTagCallBack) {
        self.cancelChooseTagCallBack();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)successButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - request


/*!
 *  @author DT
 *
 *  @brief  标签搜索关联
 *
 *  @param keyword    关键字
 *  @param propertyId 属性id
 */
-(void)getTagSearch:(NSString*)keyword propertyId:(NSString*)propertyId {
    [self sendRequest:[[self class] getRequestURLStr:NetBeautyRquestType_BeautySearch]
         parameterDic:@{@"keyword":keyword,@"propertyId":propertyId}
       requestHeaders:nil
    requestMethodType:RequestMethodType_GET
           requestTag:NetBeautyRquestType_BeautySearch
             delegate:self
             userInfo:nil
       netCachePolicy:NetUseCacheFirstWhenCacheValidAndAskServerAgain
         cacheSeconds:CacheNetDataTimeType_Forever];
}

/*!
 *  @author DT
 *
 *  @brief  获取标签品牌
 */
-(void)getTagBrand {
    
    [self sendRequest:[[self class] getRequestURLStr:NetBeautyRquestType_BeautyBrands]
         parameterDic:nil
       requestHeaders:nil
    requestMethodType:RequestMethodType_GET
           requestTag:NetBeautyRquestType_BeautyBrands
             delegate:self
             userInfo:nil
       netCachePolicy:NetUseCacheFirstWhenCacheValidAndAskServerAgain
         cacheSeconds:CacheNetDataTimeType_Forever];
}

- (void)setNetworkRequestStatusBlocks
{
    WEAKSELF
    self.startedBlock = ^(NetRequest *request)
    {
        //        STRONGSELF
        //        if( _brandChooseTableView == nil)
        //        {
        //            [strongSelf showHUDInfoByType:HUDInfoType_Loading];
        //
        //        }
    };
    [self setNetSuccessBlock:^(NetRequest *request, id successInfoObj) {
        if (successInfoObj && [successInfoObj isKindOfClass:[NSDictionary class]])
        {
            switch (request.tag) {

                case NetBeautyRquestType_BeautySearch:
                {
                    NSMutableArray *tempArray = [NSMutableArray new];
                    for (NSDictionary *dict in [successInfoObj objectForKey:@"tags"]) {
                        BeautyPophotoTagItem *item = [[BeautyPophotoTagItem alloc] initWithDict:dict];
                        [tempArray addObject:item];
                    }
                    if (weakSelf.tagView) {
                        [weakSelf.tagView setSearchItem:tempArray];
                    }
                }
                    break;
                case NetBeautyRquestType_BeautyBrands:
                {
                    NSMutableArray *tempArray = [NSMutableArray new];
                    NSDictionary *dictionary = [successInfoObj objectForKey:@"brands"];
                    NSMutableArray *allKeys = [[NSMutableArray alloc] initWithArray:[dictionary allKeys]];
                    NSArray *resultArray = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        return [obj1 compare:obj2 options:NSNumericSearch];
                    }];
                    NSMutableArray *keyArray = [NSMutableArray new];
                    [keyArray addObject:@" "];
                    if ([resultArray isAbsoluteValid]) {
                        for (NSString *key in resultArray) {
                            if (![key isEqualToString:@"#"]) {
                                [keyArray addObject:key];
                            }
                        }
                        [keyArray addObject:@"#"];
                    }
                    for (NSString *key in keyArray) {
                        NSArray *arr = [dictionary objectForKey:key];
                        NSMutableArray *mutableArr = [NSMutableArray new];
                        for (NSDictionary *dict in arr) {
                            [mutableArr addObject:[[BeautyPophotoTagItem alloc] initWithDict:dict]];
                        }
                        [tempArray addObject:mutableArr];
                    }
                    weakSelf.keyBrandsArray = keyArray;
                    weakSelf.brandsArray = tempArray;
                    
                    [weakSelf.tagView setKeyBrandArray:keyArray brandsArray:tempArray];
                    
                }
                    break;
                default:
                    break;
            }
        }
    } failedBlock:^(NetRequest *request, NSError *error)
     {
         switch (request.tag) {
             case NetProductRequestType_GetAllCategorys:
                 break;
         }
     }];
}


@end
