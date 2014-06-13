//
//  M2SimpleGridView.h
//  M2Common
//
//  Created by Chen Meisong on 14-6-12.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M2SimpleGridViewCell_A.h"

@protocol M2SimpleGridViewDataSource;
@protocol M2SimpleGridViewDelegate;

@interface M2SimpleGridView_A : UIView
@property (nonatomic, weak) id<M2SimpleGridViewDataSource>  dataSource;
@property (nonatomic, weak) id<M2SimpleGridViewDelegate>    delegate;
@property (nonatomic)       UIEdgeInsets                    paddingInsets;
@property (nonatomic)       CGSize                          itemSize;
@property (nonatomic)       CGFloat                         itemHorizontalSpacing;
@property (nonatomic)       CGFloat                         itemVerticalSpacing;
@property (nonatomic, readonly)       BOOL                  isEditing;
- (void)reloadData;
// delegate非nil时changeEditing方法才有效；
- (void)changeEditing:(BOOL)isEditing;
@end

@protocol M2SimpleGridViewDataSource <NSObject>
@required
- (NSInteger)numberOfCellsInGridView:(M2SimpleGridView_A *)gridView;
- (M2SimpleGridViewCell_A *)gridView:(M2SimpleGridView_A *)gridView cellAtIndex:(NSInteger)index;
- (UIView *)addItemViewForGridView:(M2SimpleGridView_A *)gridView;
@end

@protocol M2SimpleGridViewDelegate <NSObject>
- (void)wantsAddNewItemByGridView:(M2SimpleGridView_A *)gridView;
- (void)gridView:(M2SimpleGridView_A *)gridView wantsDeleteCellAtIndex:(NSInteger)index;
- (void)gridView:(M2SimpleGridView_A *)gridView wantsMoveCellFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
@end