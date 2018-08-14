//
//  ZYTagView.h
//  ZYTagViewDemo
//
//  Created by ripper on 2016/9/28.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYTagInfo.h"


@interface ZYTagView : UIView



/** 标记信息 */
@property (nonatomic, strong, readonly) ZYTagInfo *tagInfo;

/** 是否可编辑 default is YES */
@property (nonatomic, assign) BOOL isEditEnabled;

//移动后的point
@property (nonatomic,copy)void(^tagViewEndMove)(CGPoint tapedPoint);

//删除tag的回调
@property (nonatomic,copy)void(^tagViewDeleted)(void);
//tag内容被点击
@property (nonatomic,copy)void(^tagLinkClicked)(void);

/** 初始化 */
- (instancetype)initWithTagInfo:(ZYTagInfo *)tagInfo;
/** 更新标题 */
- (void)updateTitle:(NSString *)title;
/** 显示动画 */
- (void)showAnimationWithRepeatCount:(float)repeatCount;
/** 移除动画 */
- (void)removeAnimation;
/** 显示删除按钮 */
- (void)showDeleteBtn;
/** 隐藏删除按钮 */
- (void)hiddenDeleteBtn;
/** 切换删除按钮状态 */
- (void)switchDeleteState;

@end
