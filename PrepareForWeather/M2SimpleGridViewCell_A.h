//
//  M2SimpleGridViewCell.h
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-12.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class M2SimpleGridViewCell_A;

typedef void (^TapDeleteHandler_A)(M2SimpleGridViewCell_A *);

@interface M2SimpleGridViewCell_A : UIView
// 添加子view时要加到contentView上；
@property (nonatomic, readonly) UIView *contentView;
#pragma mark - M2SimpleGridView使用的属性与方法，请勿访问；
@property (nonatomic, copy) TapDeleteHandler_A tapDeleteHandler;
- (void)showDeleteButton:(BOOL)toShow;
#pragma mark - Need Override
- (CGSize)buildDeleteButtonSize;
@end
