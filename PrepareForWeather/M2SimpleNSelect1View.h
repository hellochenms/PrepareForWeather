//
//  M2NSelect1View.h
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-7-22.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//
//  version: 1.3
//  1.1: 支持NSAttributedString。
//  1.2: 支持竖直布局，竖直布局时underlineViewAnimationDisabled字段无效，始终无动画。
//  1.3: 支持重新设置颜色，一个应用场景是App更换主题，控件的颜色由主题决定。

#import <UIKit/UIKit.h>
@protocol M2SimpleNSelect1ViewDelegate;

@interface M2SimpleNSelect1View : UIView
@property (nonatomic) BOOL underlineViewAnimationDisabled;
@property (nonatomic) BOOL isVerticalLayout;
@property (nonatomic, weak) id<M2SimpleNSelect1ViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame
             titles:(NSArray *)titles
        normalColor:(UIColor *)normalColor
         normalFont:(UIFont *)normalFont
      selectedColor:(UIColor *)selectedColor
       selectedFont:(UIFont *)selectedFont;
- (id)initWithFrame:(CGRect)frame
   attributedTitles:(NSArray *)attributedTitles
        normalColor:(UIColor *)normalColor
      selectedColor:(UIColor *)selectedColor;
- (void)selectIndex:(NSInteger)index;
- (void)setNormalColor:(UIColor *)normalColor
         selectedColor:(UIColor *)selectedColor;
@end

@protocol M2SimpleNSelect1ViewDelegate <NSObject>
- (void)nSelect1View:(M2SimpleNSelect1View *)nSelect1View didSelectIndex:(NSInteger)index;
@end

