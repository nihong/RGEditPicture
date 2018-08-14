//
//  RGMediaTabBarController.m
//  Vmei
//
//  Created by ios-02 on 2018/6/22.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "RGMediaTabBarController.h"

#import "TZImagePickerController.h"
#import "RGEditPhotosVC.h"
#import "RGPhotoImagePickerController.h"
#import "RGVideoImagePickerController.h"
#import "RGEditVideoVC.h"

#define kMediaBarH 44.f
#define kMaxChoosePicCount 9


@interface RGMediaNavigationController:UINavigationController

@end
@implementation RGMediaNavigationController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end



@interface RGMediaTabBarController()<TZImagePickerControllerDelegate,UITabBarControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    TZImagePickerController *_picVC;
    RGMediaNavigationController *_navTakePhotoVC;
    RGMediaNavigationController *_navVideoVC;
    
}
@property(nonatomic,assign)NSInteger maxPicCount;

@end
@implementation RGMediaTabBarController

-(instancetype)initWithMaxSelectPicsCount:(NSInteger)maxPicCount
{
    self = [super init];
    if (self) {
        self.maxPicCount = maxPicCount;
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
    self.tabBarController.tabBar.hidden = NO;
    
    
    _picVC.maxImagesCount = self.maxPicCount;
    if (self.maxPicCount == kMaxChoosePicCount) {
        _picVC.allowPickingVideo = YES;
    }else{
        self.viewControllers = @[_picVC,_navTakePhotoVC];
        _picVC.allowPickingVideo = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = YES;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //1.
    _picVC = [[TZImagePickerController alloc]initWithMaxImagesCount:kMaxChoosePicCount columnNumber:4 delegate:self];
    _picVC.tabBarItem.title = @"照片";    
    _picVC.statusBarStyle = UIStatusBarStyleDefault;    
    _picVC.autoDismiss = NO;
    _picVC.allowTakePicture = NO;
    _picVC.allowTakeVideo = NO;
    _picVC.allowPickingVideo = YES;
    _picVC.showSelectedIndex = YES;
    _picVC.showPhotoCannotSelectLayer = YES;
    _picVC.alwaysEnableDoneBtn = NO;
    _picVC.naviBgColor = HEXCOLOR(0xffffff);
    _picVC.barItemTextFont = SP15Font;
    _picVC.barItemTextColor = HEXCOLOR(0x333333);
    _picVC.photoWidth = kScreenWidth*[UIScreen mainScreen].scale;
    
    _picVC.naviTitleFont = SP18Font;
    _picVC.naviTitleColor = HEXCOLOR(0x333333);
    WEAKSELF
    _picVC.navLeftBarButtonSettingBlock = ^(UIButton *leftButton) {
        STRONGSELF

        [leftButton setTitle:@"取消" forState:UIControlStateNormal];
        [leftButton setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
        leftButton.titleLabel.font = SP15Font;
        [leftButton addTarget:strongSelf action:@selector(navLeftBarBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    };

    
   
    //2.
    RGPhotoImagePickerController *photoVC = [[RGPhotoImagePickerController alloc]init];
    _navTakePhotoVC = [[RGMediaNavigationController alloc]initWithRootViewController:photoVC];
    _navTakePhotoVC.tabBarItem.title = @"拍照";

    
    
    //3.
    RGVideoImagePickerController *videoVC = [[RGVideoImagePickerController alloc]init];
    _navVideoVC = [[RGMediaNavigationController alloc]initWithRootViewController:videoVC];
    _navVideoVC.tabBarItem.title = @"小视频";


    

    self.viewControllers = @[_picVC,_navTakePhotoVC,_navVideoVC];
    for (UITabBarItem *item in self.tabBar.items) {
        [item setTitleTextAttributes:@{NSFontAttributeName:SP15Font,NSForegroundColorAttributeName:HEXCOLOR(0x999999)} forState:UIControlStateNormal];
        [item setTitleTextAttributes:@{NSFontAttributeName:SP15Font,NSForegroundColorAttributeName:HEXCOLOR(0x333333)} forState:UIControlStateSelected];
        item.titlePositionAdjustment = UIOffsetMake(0, -12.f);
    }
    
    self.tabBar.translucent = YES;
    self.tabBar.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
    self.tabBar.shadowImage = [[UIImage alloc]init];
    self.delegate = self;

    

}


-(void)navLeftBarBtnClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



 #pragma mark TZImagePickerControllerDelegate

 - (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
 {
     if ([photos isAbsoluteValid]) {
         RGEditPhotosVC *vc = [[RGEditPhotosVC alloc]initWithPhotos:photos];
         [picker pushViewController:vc animated:YES];
     }
 }

 - (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker
 {
     [self dismissViewControllerAnimated:YES completion:nil];
 }
 
 // If user picking a video, this callback will be called.
 // If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
 // 如果用户选择了一个视频，下面的handle会被执行
 // 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
 - (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset
 {
     
     
     
     PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
     options.version = PHImageRequestOptionsVersionCurrent;
     options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
     [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {
         SCRecordSession *recordSession = [SCRecordSession recordSession];
         NSString * sandboxExtensionTokenKey = info[@"PHImageFileSandboxExtensionTokenKey"];
         
         NSArray * arr = [sandboxExtensionTokenKey componentsSeparatedByString:@";"];
         
         NSString * filePath = [arr[arr.count - 1]substringFromIndex:9];
         
         SCRecordSessionSegment *segment = [SCRecordSessionSegment segmentWithURL:[NSURL fileURLWithPath:filePath] info:nil];
         [recordSession addSegment:segment];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             RGEditVideoVC *vc = [[RGEditVideoVC alloc]init];
             vc.recordSession = recordSession;
             [picker pushViewController:vc animated:YES];
             
         });
         

     }];

 }
 
 // If user picking a gif image, this callback will be called.
 // 如果用户选择了一个gif图片，下面的handle会被执行
 - (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset
 {

 }
 
 // Decide album show or not't
 // 决定相册显示与否 albumName:相册名字 result:相册原始数据
 - (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result
 {
     return YES;
 }
 
 // Decide asset show or not't
 // 决定照片显示与否
 - (BOOL)isAssetCanSelect:(id)asset
 {
     return YES;
 }
 

#pragma mark UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
    UIColor *selectedColor;
    if (tabBarController.selectedIndex == 2) {
        selectedColor = HEXCOLOR(0xffffff);
    }else{
        selectedColor = HEXCOLOR(0x333333);
    }
    for (UITabBarItem *item in tabBarController.tabBar.items) {
        [item setTitleTextAttributes:@{NSFontAttributeName:SP15Font,NSForegroundColorAttributeName:selectedColor} forState:UIControlStateSelected];
    }
    
}



@end




