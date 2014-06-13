//
//  M2SimpleGridView.h
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-13.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol M2SimpleGridViewDataSource;
@protocol M2SimpleGridViewDelegate;

@interface M2SimpleGridView : UIView
@property (nonatomic, weak) id<M2SimpleGridViewDataSource>  dataSource;
@property (nonatomic, weak) id<M2SimpleGridViewDelegate>    delegate;
@property (nonatomic)       UIEdgeInsets                    paddingInsets;
@property (nonatomic)       CGSize                          itemSize;
@property (nonatomic)       NSInteger                       itemCountInRow;
@property (nonatomic)       NSInteger                       rowCount;
@property (nonatomic, readonly)       BOOL                  isEditing;
- (void)reloadData;
// delegate非nil时changeEditing方法才有效；
- (void)changeEditing:(BOOL)isEditing;
@end

@protocol M2SimpleGridViewDataSource <NSObject>
@required
- (NSInteger)numberOfCellsInGridView:(M2SimpleGridView *)gridView;
- (UIView *)gridView:(M2SimpleGridView *)gridView cellAtIndex:(NSInteger)index;
- (UIView *)addItemViewForGridView:(M2SimpleGridView *)gridView;
- (CGSize)deleteButtonSizeOfItemForGridView:(M2SimpleGridView *)gridView;
- (UIImage *)deleteButtonImageOfItemForGridView:(M2SimpleGridView *)gridView;
@end

@protocol M2SimpleGridViewDelegate <NSObject>
- (void)wantsAddNewItemByGridView:(M2SimpleGridView *)gridView;
- (void)gridView:(M2SimpleGridView *)gridView wantsDeleteCellAtIndex:(NSInteger)index;
- (void)gridView:(M2SimpleGridView *)gridView wantsMoveCellFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
@end

@class M2SimpleGridViewItemContainer;
typedef void (^M2SGVIC_TapDeleteHandler)(M2SimpleGridViewItemContainer *);

@interface M2SimpleGridViewItemContainer : UIView
@property (nonatomic) UIView    *contentView;
@property (nonatomic) UIButton  *deleteButton;
@property (nonatomic, copy) M2SGVIC_TapDeleteHandler tapDeleteHandler;
- (void)showDeleteButton:(BOOL)toShow;
@end
