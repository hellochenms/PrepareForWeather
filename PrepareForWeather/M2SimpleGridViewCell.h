//
//  M2SimpleGridViewCell.h
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-12.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class M2SimpleGridViewCell;

typedef void (^TapDeleteHandler)(M2SimpleGridViewCell *);

@interface M2SimpleGridViewCell : UIView
// 添加子view时要加到contentView上；
@property (nonatomic, readonly) UIView *contentView;
#pragma mark - M2SimpleGridView使用的属性与方法，请勿访问；
@property (nonatomic, copy) TapDeleteHandler tapDeleteHandler;
- (void)showDeleteButton:(BOOL)toShow;
#pragma mark - Need Override
- (CGSize)buildDeleteButtonSize;
@end
