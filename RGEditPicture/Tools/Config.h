//
//  Config.h
//  RGEditPicture
//
//  Created by 泥红 on 14/8/18.
//  Copyright © 2018年 RoyGao. All rights reserved.
//

#ifndef Config_h
#define Config_h


// 设置颜色
#define HEXCOLOR(rgbValue)          [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// 设置颜色与透明度
#define HEXCOLORAL(rgbValue, al)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:al]

// block self
#define WEAKSELF                    typeof(self) __weak weakSelf = self;
#define STRONGSELF                  typeof(weakSelf) __strong strongSelf = weakSelf;

#define TABBAR_HEIGHT           ((iPhoneX) ? (83.f) : (49.f))
#define StatusBarHeight         ((iPhoneX) ? (44.f) : (20.f))
#define iPhoneX                ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125,2436), [[UIScreen mainScreen] currentMode].size) : NO)


// 字体大小（动态大小）


#define SP24Font                            [UIFont systemFontOfSize:24]
#define SP23Font                            [UIFont systemFontOfSize:23]
#define SP22Font                            [UIFont systemFontOfSize:22]
#define SP21Font                            [UIFont systemFontOfSize:21]
#define SP20Font                            [UIFont systemFontOfSize:20]
#define SP19Font                            [UIFont systemFontOfSize:19]
#define SP18Font                            [UIFont systemFontOfSize:18]
#define SP17Font                            [UIFont systemFontOfSize:17]
#define SP16Font                            [UIFont systemFontOfSize:16]
#define SP15Font                            [UIFont systemFontOfSize:15]
#define SP14Font                            [UIFont systemFontOfSize:14]
#define SP13Font                            [UIFont systemFontOfSize:13]
#define SP12Font                            [UIFont systemFontOfSize:12]
#define SP11Font                            [UIFont systemFontOfSize:11]
#define SP10Font                            [UIFont systemFontOfSize:10]
#define SP9Font                             [UIFont systemFontOfSize:9]
#define SP8Font                             [UIFont systemFontOfSize:8]



#endif /* Config_h */
