//
//  M2Item3DataNView.h
//  M2Common
//
//  Created by Chen Meisong on 14-6-16.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//
//  3个cell显示N个数据；当然，数据如果小于3个，cell也会减少；

#import <UIKit/UIKit.h>

@protocol M2Cell3DataNPagingEnabledViewDataSource;

@interface M2Cell3DataNPagingEnabledView : UIView
@property (nonatomic, weak)     id<M2Cell3DataNPagingEnabledViewDataSource> dataSource;
// 调用方不应该修改操作cells的array操作，只能修改里面具体元素的属性
@property (nonatomic, readonly) NSMutableArray *cells;
- (void)reloadData;
@end

@protocol M2Cell3DataNPagingEnabledViewDataSource <NSObject>
@required
- (UIView *)cellForPagingEnabledView:(M2Cell3DataNPagingEnabledView *)view;
- (NSInteger)numberOfDatasForPagingEnabledView:(M2Cell3DataNPagingEnabledView *)view;
- (NSInteger)curDataIndexForPagingEnabledView:(M2Cell3DataNPagingEnabledView *)view;
- (void)pagingEnabledView:(M2Cell3DataNPagingEnabledView *)view wantsReloadDataAtIndex:(NSInteger)index forCell:(UIView *)cell;
- (void)pagingEnabledView:(M2Cell3DataNPagingEnabledView *)view changeCurrentDataIndex:(NSInteger)index;
@end