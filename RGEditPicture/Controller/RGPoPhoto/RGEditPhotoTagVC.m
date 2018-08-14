//
//  RGEditPhotoTagVC.m
//  Vmei
//
//  Created by ios-02 on 2018/8/3.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "RGEditPhotoTagVC.h"
#import "RGEditPhotoTagsView.h"
#import "BaseNetworkViewController+NetRequestManager.h"
#import "RGEditPhotosModel.h"
#import "AppPropertiesInitialize.h"

#define kEditPhotoOutMagin 15.f
#define kTagHistory @"LocalTagHistroy"

static NSString *const kRGEditPhotoTagsHeaderID = @"kRGEditPhotoTagsHeaderID";
static NSString *const kRGEditPhotoTagCellID = @"kRGEditPhotoTagCellID";
static NSString *const kRGEditPhotoTagCell_HistoryID = @"kRGEditPhotoTagCell_HistoryID";
static NSString *const kRGEditPhotoBrandCellID = @"kRGEditPhotoBrandCellID";
static NSString *const kRGEditPhotoSearchTagCellID = @"kRGEditPhotoSearchTagCellID";
static NSString *const kRGEditPhotoBrandFooterID = @"kRGEditPhotoBrandFooterID";

//section 类型
typedef NS_ENUM(NSInteger,RGEditPhotoSectionType) {
    RGEditPhotoSectionType_History      =0,
    RGEditPhotoSectionType_Function     =1,
    RGEditPhotoSectionType_Brand        =2,
    RGEditPhotoSectionType_Related      =3,
};


@interface RGEditPhotoTagVC ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UISearchBarDelegate>

@property(nonatomic,strong)UICollectionView *collectionView;

@property(nonatomic,strong)UISearchBar *searchBar;

@property(nonatomic,strong)NSMutableArray <RGEditPhotoTagModel *>* historyList;

@property(nonatomic,strong)RGEditPhotoTagListModel *tagsModel;
@property(nonatomic,strong)RGEditPhotoTagListModel *searchedTagsModel;

@end

@implementation RGEditPhotoTagVC

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [AppPropertiesInitialize setBackgroundColorToStatusBar:[UIColor clearColor]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
      [AppPropertiesInitialize setBackgroundColorToStatusBar:[UIColor clearColor]];
    
    [self saveHistoryList];
}

- (void)viewDidLoad { 
    [super viewDidLoad];
    
    UIVisualEffectView *visulView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    visulView.frame  = self.view.bounds;
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:visulView];
    
    [self.view addSubview:self.collectionView];
        
    [self.view addSubview:self.searchBar];
    
    [self requestRecommentData];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)deleteHistory
{
    [self.historyList removeAllObjects];
    [self saveHistoryList];
    [self.collectionView reloadData];
}

-(NSMutableArray *)historyList
{
    if (!_historyList) {
        _historyList = [NSMutableArray array];
        
        //从本地读取历史记录
        NSArray *savedTags = [[NSUserDefaults standardUserDefaults] objectForKey:kTagHistory];
        if ([savedTags isAbsoluteValid]) {
            for (NSDictionary *dic in savedTags) {
                RGEditPhotoTagModel *model = [[RGEditPhotoTagModel alloc]init];
                
                model.name = [dic objectForKey:@"name"];
                model.pid = [[dic objectForKey:@"pid"] integerValue];
                if ([[dic objectForKey:@"type"] isEqualToString:@"brand"]) {
                    model.type = RGEditPhotoTagType_Brand;
                }else if ([[dic objectForKey:@"type"] isEqualToString:@"custom"]){
                    model.type = RGEditPhotoTagType_Custom;
                }else{
                    model.type = RGEditPhotoTagType_Effect;
                }
                
                [_historyList addObject:model];
            }
        }
        
    }
    return _historyList;
}


#pragma mark  Setter
-(UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, StatusBarHeight, kScreenWidth, 44.f)];
        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
        _searchBar.backgroundColor = [UIColor clearColor];
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:HEXCOLORAL(0x000000, 0.4) size:CGSizeMake(1.f, 32.f)] forState:UIControlStateNormal];
        [_searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(1.f, 32.f)]];
        
        
        _searchBar.delegate  = self;
        _searchBar.placeholder = @"搜索或输入想要的标签";
        _searchBar.showsCancelButton = YES;
        
        UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
        // 输入文本颜色
        searchField.textColor = [UIColor whiteColor];
        searchField.layer.cornerRadius = 16.f;
        searchField.layer.masksToBounds = YES;
        
        
        UIButton *cancelBtn = [_searchBar valueForKeyPath:@"cancelButton"];
        cancelBtn.userInteractionEnabled = NO;
        cancelBtn.enabled = NO;
        [cancelBtn setTitle:@"   " forState:UIControlStateNormal];
        [cancelBtn setTitle:@"   " forState:UIControlStateDisabled];
//        [cancelBtn setImage:[UIImage imageNamed:@"rg_editPhot_whiteCancel"] forState:UIControlStateNormal];
        
        [cancelBtn addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton *customCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [customCancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [customCancelBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
        customCancelBtn.titleLabel.font = SP13Font;
        [_searchBar addSubview:customCancelBtn];
        [customCancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44.f, 44.f));
            make.right.and.centerY.mas_equalTo(_searchBar);
        }];
        [customCancelBtn addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchBar;
}

-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, kRGPhotoTagOutMagin, 10, kRGPhotoTagOutMagin);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, StatusBarHeight+44.f, kScreenWidth, kScreenHeight-StatusBarHeight-44.f) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[RGEditPhotoBrandCell class] forCellWithReuseIdentifier:kRGEditPhotoBrandCellID];
        [_collectionView registerClass:[RGEditPhotoTagCell class] forCellWithReuseIdentifier:kRGEditPhotoTagCellID];
        [_collectionView registerClass:[RGEditPhotoTagCell class] forCellWithReuseIdentifier:kRGEditPhotoTagCell_HistoryID];
        [_collectionView registerClass:[RGEditPhotoSearchTagCell class] forCellWithReuseIdentifier:kRGEditPhotoSearchTagCellID];
        [_collectionView registerClass:[RGEditPhotoTagsHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kRGEditPhotoTagsHeaderID];
        [_collectionView registerClass:[RGEditPhotoBrandFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kRGEditPhotoBrandFooterID];
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _collectionView;
}


#pragma mark  - Delegate
#pragma mark  Searchbar delegate


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isAbsoluteValid]) {
        [self requestResultWithSearchKey:searchBar.text];
    }else{
        [self.collectionView reloadData];
    }
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{

    [self requestResultWithSearchKey:searchBar.text];
    
    [searchBar resignFirstResponder];

}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;
{
    [searchBar resignFirstResponder];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar __TVOS_PROHIBITED   // called when cancel button pressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark  Collection delegate datasource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 4;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == RGEditPhotoSectionType_History) {
        
        return [_searchBar.text isAbsoluteValid] ? 0: self.historyList.count;
        
    }else if (section == RGEditPhotoSectionType_Function){
        
        return [_searchBar.text isAbsoluteValid] ? 0: self.tagsModel.effectTags.count;
        
    }else if(section == RGEditPhotoSectionType_Brand){
        //品牌session 中cell的个数：根据是否在搜索，以及搜索关键词与搜索结果是否重复决定
        NSInteger searchedBrandCellCount = [self showCustomTag]? self.searchedTagsModel.brandTags.count+1:self.searchedTagsModel.brandTags.count;
        
        return [_searchBar.text isAbsoluteValid] ? searchedBrandCellCount: self.tagsModel.brandTags.count;
        
    }else if(section == RGEditPhotoSectionType_Related){
        
        return [_searchBar.text isAbsoluteValid] ? self.searchedTagsModel.effectTags.count: 0;
        
    }else{
        
        return 0;
    }
    
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == RGEditPhotoSectionType_History) {
        RGEditPhotoTagCell *historyCell = (RGEditPhotoTagCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kRGEditPhotoTagCell_HistoryID forIndexPath:indexPath];
        
        historyCell.contentView.backgroundColor = HEXCOLORAL(0x000000, 0.4);
        ViewRadius(historyCell, 12.f);
        
        
        RGEditPhotoTagModel *historyModel = self.historyList[indexPath.item];
        
        if (historyModel.type == RGEditPhotoTagType_Custom) {//自定义
            [historyCell.tagBtn setImage:[UIImage imageNamed:@"rg_editPhoto_customTag"] forState:UIControlStateNormal];
            [historyCell.tagBtn setTitle:[NSString stringWithFormat:@" %@",historyModel.name]  forState:UIControlStateNormal];
        }else if (historyModel.type == RGEditPhotoTagType_Brand){//品牌
            [historyCell.tagBtn setImage:[UIImage imageNamed:@"rg_editPhoto_brand"] forState:UIControlStateNormal];
            [historyCell.tagBtn setTitle:[NSString stringWithFormat:@" %@",historyModel.name]  forState:UIControlStateNormal];
        }else{//RGEditPhotoTagType_Effect 功效
            [historyCell.tagBtn setImage:nil forState:UIControlStateNormal];
            [historyCell.tagBtn setTitle:historyModel.name  forState:UIControlStateNormal];
        }
        
        return historyCell;
        
    }else if (indexPath.section == RGEditPhotoSectionType_Function){
        RGEditPhotoTagCell *tagCell = (RGEditPhotoTagCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kRGEditPhotoTagCellID forIndexPath:indexPath];
        
        tagCell.contentView.backgroundColor = HEXCOLORAL(0xffffff, 0.1);
        ViewRadius(tagCell, 3.f);
        
        if (![self.searchBar.text isAbsoluteValid]) {
            RGEditPhotoTagModel *tagItem = self.tagsModel.effectTags[indexPath.item];
            [tagCell.tagBtn setTitle:tagItem.name forState:UIControlStateNormal];
        }
        
        return tagCell;
        
        
    }else if(indexPath.section == RGEditPhotoSectionType_Brand){
        RGEditPhotoBrandCell *brandCell = (RGEditPhotoBrandCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kRGEditPhotoBrandCellID forIndexPath:indexPath];
        brandCell.contentView.backgroundColor = HEXCOLORAL(0xffffff, 0.1);
        ViewRadius(brandCell, 3.f);
        
        if (![self.searchBar.text isAbsoluteValid]) {//展示推荐的热门品牌
            RGEditPhotoTagModel *tagModel = self.tagsModel.brandTags[indexPath.item];
            [self configBrandCell:brandCell model:tagModel];
            

        }else{
            if (![self showCustomTag]) {//不需要展示 custom brand cell
                RGEditPhotoTagModel *tagModel = self.searchedTagsModel.brandTags[indexPath.item];
                [self configBrandCell:brandCell model:tagModel];
            }else{//需要展示 custom brand cell
                if (indexPath.item != 0 ) {
                    RGEditPhotoTagModel *tagModel = self.searchedTagsModel.brandTags[indexPath.item-1];
                    [self configBrandCell:brandCell model:tagModel];
                }else{
                    [self configBrandCell:brandCell model:nil];
                }
            }

        }
        
        return brandCell;
        
    }else if(indexPath.section == RGEditPhotoSectionType_Related){
        
        RGEditPhotoSearchTagCell *resultTagCell = (RGEditPhotoSearchTagCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kRGEditPhotoSearchTagCellID forIndexPath:indexPath];
        RGEditPhotoTagModel *tagItem = self.searchedTagsModel.effectTags[indexPath.item];
        resultTagCell.searchedTagLB.text = tagItem.name;
        return resultTagCell;
        
    }else{
        
        return [UICollectionViewCell new];
    }
    
}




-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == RGEditPhotoSectionType_History) {
        RGEditPhotoTagModel *tagModel = self.historyList[indexPath.item];
        CGRect bounds = [tagModel.name boundingRectWithSize:CGSizeMake(MAXFLOAT, 25.f) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SP13Font} context:nil];
        if (tagModel.type == RGEditPhotoTagType_Effect) {
            return CGSizeMake(bounds.size.width+25, 25.f);
        }else{
            return CGSizeMake(bounds.size.width+32, 25.f);
        }
        
    }else if (indexPath.section == RGEditPhotoSectionType_Function){
        
        return CGSizeMake(55.f, 25.f);
        
    }else if(indexPath.section == RGEditPhotoSectionType_Brand){

        return CGSizeMake(kScreenWidth-kEditPhotoOutMagin*2, 60.f);
        
    }else if(indexPath.section == RGEditPhotoSectionType_Related){
        
        return CGSizeMake(kScreenWidth-kEditPhotoOutMagin*2, 44.f);
        
    }else{
        
        return CGSizeZero;
    }
    
}



-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (section == RGEditPhotoSectionType_History) {
        
        return 17.f;
        
    }else if (section == RGEditPhotoSectionType_Function){
        
        return 17.f;
        
    }else if(section == RGEditPhotoSectionType_Brand){
        
        return 10;
        
    }else if(section == RGEditPhotoSectionType_Related){
        
        return 0;
        
    }else{
        
        return 0;
    }

}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (section == RGEditPhotoSectionType_History) {
        
        return 1.f;
        
    }else if (section == RGEditPhotoSectionType_Function){
        
        return (kScreenWidth-kEditPhotoOutMagin*2-4*55.f-3)/3;
        
    }else if(section == RGEditPhotoSectionType_Brand){
        
        return 0;
        
    }else if(section == RGEditPhotoSectionType_Related){
        
        return 0;
        
    }else{
        
        return 0;
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        RGEditPhotoTagsHeader *header = (RGEditPhotoTagsHeader *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kRGEditPhotoTagsHeaderID forIndexPath:indexPath];
        
        header.rightIV.hidden = (indexPath.section != RGEditPhotoSectionType_History);
        
        if (indexPath.section == RGEditPhotoSectionType_History) {
            
            header.mainTitleLB.text = @"历史标签";
            header.rightIV.image = [UIImage imageNamed:@"rg_editPhoto_delete"];
            [header.rightIV addTarget:self action:@selector(deleteHistory)];
            
        }else if (indexPath.section == RGEditPhotoSectionType_Function){
            
            header.mainTitleLB.text = @"功效";
            
        }else if(indexPath.section == RGEditPhotoSectionType_Brand){
            
            header.mainTitleLB.text = [self.searchBar.text isAbsoluteValid]?@"标签结果":@"热门品牌";
            
        }else if(indexPath.section == RGEditPhotoSectionType_Related){
            
            header.mainTitleLB.text = nil;
            
        }else{
            
            
        }
        
        return header;
    }else{
        RGEditPhotoBrandFooter *brandFooter = (RGEditPhotoBrandFooter *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kRGEditPhotoBrandFooterID forIndexPath:indexPath];
        return brandFooter;
    }
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == RGEditPhotoSectionType_History) {
        
        return ([self.searchBar.text isAbsoluteValid] || self.historyList.count == 0 ) ?CGSizeZero:CGSizeMake(kScreenWidth, 30.f);
    }else if(section == RGEditPhotoSectionType_Function){
        
        return [self.searchBar.text isAbsoluteValid] ?CGSizeZero:CGSizeMake(kScreenWidth, 30.f);
        
    }else if(section == RGEditPhotoSectionType_Brand){
        
        return CGSizeMake(kScreenWidth, 30.f);
        
    }else if(section == RGEditPhotoSectionType_Related){
        
        return CGSizeZero;
        
    }else{
        
        return CGSizeZero;
    }
    
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section == RGEditPhotoSectionType_Brand && ![self.searchBar.text isAbsoluteValid]) {
        
        return CGSizeMake(kScreenWidth, 66.f);
        
    }else{
        return CGSizeZero;
    }
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == RGEditPhotoSectionType_History) {
        
        RGEditPhotoTagModel *tagModel = self.historyList[indexPath.item];
//        NSString *tagName =
//        tagModel.name = tagName;

        [self configSelectedBlock:tagModel];
        [self insertTag:self.historyList[indexPath.item]];
        
    }else if(indexPath.section == RGEditPhotoSectionType_Function){
        
        RGEditPhotoTagModel *tagItem = self.tagsModel.effectTags[indexPath.item];
        
        [self configSelectedBlock:tagItem];
        [self insertTag:tagItem];
        
                
    }else if(indexPath.section == RGEditPhotoSectionType_Brand){
        
        if (![self.searchBar.text isAbsoluteValid]) {//推荐的热门品牌cell
            RGEditPhotoTagModel *tagItem = self.tagsModel.brandTags[indexPath.item];
            [self configSelectedBlock:tagItem];
            [self insertTag:tagItem];
            
        }else{//搜索的品牌
            [self searchedBrandCellClicked:indexPath];

        }
        
        
    }else if(indexPath.section == RGEditPhotoSectionType_Related){
        
        RGEditPhotoTagModel *tagItem = self.searchedTagsModel.effectTags[indexPath.item];
        [self configSelectedBlock:tagItem];
        [self insertTag:tagItem];
    }
    

    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
//    [self.searchBar endEditing:YES];
}

//滑动收起键盘
//-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//    [self.searchBar endEditing:YES];
//}



#pragma mark  Network

- (void)setNetworkRequestStatusBlocks
{
    WEAKSELF
    self.startedBlock = ^(NetRequest *request)
    {
        [weakSelf showHUDInfoByType:HUDInfoType_Loading];
    };
    [self setNetSuccessBlock:^(NetRequest *request, id successInfoObj) {
        if (successInfoObj && [successInfoObj isKindOfClass:[NSDictionary class]])
        {
            STRONGSELF
            switch (request.tag) {
                case NetBeautyRquestType_EditPhotoTags:
                {
                    if ([successInfoObj isAbsoluteValid])
                    {
                        strongSelf.tagsModel = [RGEditPhotoTagListModel modelWithJSON:successInfoObj];
                        [strongSelf.collectionView reloadData];
                    }
                }
                    break;
                case NetBeautyRquestType_EditPhotoSearchTag:
                {
                    if ([successInfoObj isAbsoluteValid]) {
                        strongSelf.searchedTagsModel = [RGEditPhotoTagListModel modelWithJSON:successInfoObj];
                        [strongSelf.collectionView reloadData];
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
             case NetBeautyRquestType_EditPhotoTags:
             {
             }
                 break;
             case NetBeautyRquestType_EditPhotoSearchTag:
             {
             }
                 break;
             default:
                 break;
         }
     }];
}


-(void)requestRecommentData
{
    [self sendRequest:[[self class] getRequestURLStr:NetBeautyRquestType_EditPhotoTags]
         parameterDic:nil
       requestHeaders:nil
    requestMethodType:RequestMethodType_GET
           requestTag:NetBeautyRquestType_EditPhotoTags
             delegate:self
             userInfo:nil];
    
}

-(void)requestResultWithSearchKey:(NSString *)key
{
    [self sendRequest:[[self class] getRequestURLStr:NetBeautyRquestType_EditPhotoSearchTag]
         parameterDic:@{@"keyword":key}
       requestHeaders:nil
    requestMethodType:RequestMethodType_GET
           requestTag:NetBeautyRquestType_EditPhotoSearchTag
             delegate:self
             userInfo:nil];
}


#pragma mark Private Method

-(void)cancelButtonClicked:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//执行block
-(void)configSelectedBlock:(RGEditPhotoTagModel *)tagModel
{
    if (self.selectTagComplete) {
        self.selectTagComplete(tagModel);
    }
}


//插入更行历史记录
-(void)insertTag:(RGEditPhotoTagModel *)tag
{
    if (![self.historyList containsObject:tag]) {
        [self.historyList  insertObject:tag atIndex:0];
        if (self.historyList.count>10) {
            [self.historyList removeLastObject];
        }
    }else{
        [self.historyList removeObject:tag];
        [self.historyList insertObject:tag atIndex:0];
    }
}


//是否显示创建自定义标签
-(BOOL)showCustomTag
{
    BOOL show = YES;
    if ([self.searchBar.text isAbsoluteValid] && [self.searchedTagsModel.brandTags isAbsoluteValid]) {
        for (RGEditPhotoTagModel *brandModel in self.searchedTagsModel.brandTags) {
            if ([brandModel.name isEqualToString:self.searchBar.text]) {
                show = NO;
            }
        }
    }
    return show;
}


//搜索的品牌cell被点击
-(void)searchedBrandCellClicked:(NSIndexPath *)index
{
    if (![self showCustomTag]) {//不需要展示自定义 brand cell
        RGEditPhotoTagModel *tagItem = self.searchedTagsModel.brandTags[index.item];
        [self configSelectedBlock:tagItem];
        [self insertTag:tagItem];
        
    }else{//需要展示自定义 brand cell
        if (index.item == 0) {
            
            RGEditPhotoTagModel *tagModel = [[RGEditPhotoTagModel alloc]init];
            tagModel.name = self.searchBar.text;
            tagModel.type = RGEditPhotoTagType_Custom;
            tagModel.pid = kCustomTagPID;
            [self configSelectedBlock:tagModel];
            [self insertTag:tagModel];
            
        }else{
            
            RGEditPhotoTagModel *tagItem = self.searchedTagsModel.brandTags[index.item-1];
            [self configSelectedBlock:tagItem];
            [self insertTag:tagItem];
        }
    }
}

//如果tagmodel 为nil ，则说明为根据搜索关键字自定义的brandCell
-(void)configBrandCell:(RGEditPhotoBrandCell*)brandCell model:(RGEditPhotoTagModel *)tagModel
{
    if (!tagModel) {
        brandCell.brandIV.backgroundColor = [UIColor whiteColor];
        brandCell.brandIV.image = [UIImage imageNamed:@"rg_editPhoto_jing"];
        brandCell.brandNameLB.text = self.searchBar.text;
        brandCell.starNumCount.text = @"自定义标签";
        brandCell.creatTipLB.hidden = NO;
    }else{
        brandCell.brandIV.backgroundColor = [UIColor whiteColor];
        [brandCell.brandIV sd_setImageWithURL:[NSURL URLWithString:tagModel.logoUrl]];
        brandCell.brandIV.contentMode = UIViewContentModeScaleAspectFit;
        brandCell.brandNameLB.text = tagModel.name;
        brandCell.starNumCount.text = [NSString stringWithFormat:@"品牌·%ld关注",tagModel.follow];
        brandCell.creatTipLB.hidden = YES;
    }
}


-(void)saveHistoryList
{
    NSMutableArray *tagArray = [NSMutableArray arrayWithCapacity:10.f];
    for (RGEditPhotoTagModel *tagModel in self.historyList) {
        NSString *tagType;
        if (tagModel.type == RGEditPhotoTagType_Custom) {
            tagType = @"custom";
        }else if(tagModel.type == RGEditPhotoTagType_Brand){
            tagType = @"brand";
        }else{
            tagType = @"effect";
        }
        
        NSDictionary *tagDic = @{@"name":tagModel.name,@"type":tagType,@"pid":@(tagModel.pid)};
        [tagArray addObject:tagDic];
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:tagArray forKey:kTagHistory];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


















