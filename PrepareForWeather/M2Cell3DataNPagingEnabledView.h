//
//  M2Item3DataNView.h
//  M2Common
//
//  Created by Chen Meisong on 14-6-16.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol M2Cell3DataNPagingEnabledViewDataSource;

@interface M2Cell3DataNPagingEnabledView : UIView
@property (nonatomic, weak) id<M2Cell3DataNPagingEnabledViewDataSource> dataSource;
- (void)reloadData;
@end

@protocol M2Cell3DataNPagingEnabledViewDataSource <NSObject>
@required
- (NSString *)cellClassNameForPagingEnabledView:(M2Cell3DataNPagingEnabledView *)view;
- (NSInteger)numberOfDatasForPagingEnabledView:(M2Cell3DataNPagingEnabledView *)view;
- (NSInteger)curDataIndexForPagingEnabledView:(M2Cell3DataNPagingEnabledView *)view;
- (void)pagingEnabledView:(M2Cell3DataNPagingEnabledView *)view wantsReloadDataAtIndex:(NSInteger)index forCell:(UIView *)cell;
@end