//
//  M2Item3DataNView.m
//  M2Common
//
//  Created by Chen Meisong on 14-6-16.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "M2Cell3DataNPagingEnabledView.h"

#define M2C3DNPEV_MaxItemCount 3

@interface M2Cell3DataNPagingEnabledView()<UIScrollViewDelegate>
@property (nonatomic) UIScrollView      *scrollView;
@property (nonatomic) NSMutableArray    *cells;
@property (nonatomic) NSInteger         cellCount;
@property (nonatomic) NSInteger         dataCount;
@property (nonatomic) BOOL              isCodeMakeScroll;
@property (nonatomic) NSInteger         curCellIndex;
@property (nonatomic) NSInteger         curDataIndex;
@end

@implementation M2Cell3DataNPagingEnabledView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _cells = [NSMutableArray array];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    return self;
}

#pragma mark - setter
- (void)setDataSource:(id<M2Cell3DataNPagingEnabledViewDataSource>)dataSource{
    _dataSource = dataSource;
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0];
}

#pragma mark - reloadData
- (void)reloadData{
    UIView *oldCell = nil;
    for (oldCell in _cells) {
        [oldCell removeFromSuperview];
    }
    [_cells removeAllObjects];
    
    if (!_dataSource
        || ![_dataSource respondsToSelector:@selector(cellForPagingEnabledView:)]
        || ![_dataSource respondsToSelector:@selector(numberOfDatasForPagingEnabledView:)]
        || ![_dataSource respondsToSelector:@selector(pagingEnabledView:wantsReloadDataAtIndex:forCell:)]) {
        return;
    }
    
    _dataCount = [_dataSource numberOfDatasForPagingEnabledView:self];
    if (_dataCount <= 0) {
        return;
    }
    _cellCount  = MIN(_dataCount, M2C3DNPEV_MaxItemCount);
    UIView *cell = nil;
    CGFloat cellWidth = CGRectGetWidth(_scrollView.bounds);
    CGFloat cellHeight = CGRectGetHeight(_scrollView.bounds);
    for (NSInteger i = 0; i < _cellCount; i++) {
        cell = [_dataSource cellForPagingEnabledView:self];
        cell.frame = CGRectMake(cellWidth * i, 0, cellWidth, cellHeight);
        [_cells addObject:cell];
        [_scrollView addSubview:cell];
    }
    _scrollView.contentSize = CGSizeMake(cellWidth * _cellCount, cellHeight);
    
    _curDataIndex = [_dataSource curDataIndexForPagingEnabledView:self];
    if (_curDataIndex == 0) {
        for (NSInteger i = 0; i < _cellCount; i++) {
            cell = [_cells objectAtIndex:i];
            [_dataSource pagingEnabledView:self wantsReloadDataAtIndex:i forCell:cell];
        }
        _curCellIndex = 0;
        [_scrollView setContentOffset:CGPointZero];
    }else if (_curDataIndex == _dataCount - 1){
        float countDelta = _dataCount - _cellCount;
        for (NSInteger i = _cellCount - 1; i >= 0; i--) {
            cell = [_cells objectAtIndex:i];
            [_dataSource pagingEnabledView:self wantsReloadDataAtIndex:i + countDelta forCell:cell];
        }
        _curCellIndex = _cellCount - 1;
        [_scrollView setContentOffset:CGPointMake(cellWidth * (_cellCount - 1), 0)];
    }else{
        for (NSInteger i = 0; i < _cellCount; i++) {
            cell = [_cells objectAtIndex:i];
            [_dataSource pagingEnabledView:self wantsReloadDataAtIndex:_curDataIndex - 1 + i forCell:cell];
        }
        _curCellIndex = 1;
        [_scrollView setContentOffset:CGPointMake(cellWidth, 0)];
    }
}

#pragma mark - UIScrollViewDelegate
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_dataCount <= M2C3DNPEV_MaxItemCount) {
        return;
    }
    if (_isCodeMakeScroll) {
        _isCodeMakeScroll = NO;
        return;
    }
    float itemWidth = CGRectGetWidth(scrollView.bounds);
    int nextItemIndex = (scrollView.contentOffset.x + itemWidth / 2) / itemWidth;
    if (nextItemIndex != _curCellIndex) {
//        NSLog(@"itemIndex change(%d->%d)  @@%s", _curCellIndex, nextItemIndex, __func__);
        if (nextItemIndex > _curCellIndex) {
            _curDataIndex++;
        }else if (nextItemIndex < _curCellIndex){
            _curDataIndex--;
        }
        // 在中间
        if (nextItemIndex == 1) {
//            NSLog(@"在中间，不需要调整  @@%s", __func__);
            _curCellIndex = nextItemIndex;
        }
        // 在右边
        else if (nextItemIndex == 2){
            if (_curDataIndex + 1 >= _dataCount) {
//                NSLog(@"到达数据右边界， 不需要调整  @@%s", __func__);
                _curCellIndex = nextItemIndex;
            }else{
                CGRect lastItemFrame = ((UIView *)[_cells lastObject]).frame;
                int count = [_cells count];
                for (int i = count - 1; i > 0; i--) {
                    ((UIView *)[_cells objectAtIndex:i]).frame = ((UIView *)[_cells objectAtIndex:i - 1]).frame;
                }
                UIView *firstItem = [_cells firstObject];
                firstItem.frame = lastItemFrame;
                [_dataSource pagingEnabledView:self wantsReloadDataAtIndex:_curDataIndex + 1 forCell:firstItem];
                [_cells removeObject:firstItem];
                [_cells addObject:firstItem];
                _isCodeMakeScroll = YES;
                [_scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x - itemWidth, 0)];
            }
        }
        // 在左边
        else if (nextItemIndex == 0){
            if (_curDataIndex - 1 < 0) {
//                NSLog(@"到达数据左边界， 不需要调整  @@%s", __func__);
                _curCellIndex = nextItemIndex;
            }else{
                CGRect firstItemFrame = ((UIView *)[_cells firstObject]).frame;
                int count = [_cells count];
                for (int i = 0; i < count - 1; i++) {
                    ((UIView *)[_cells objectAtIndex:i]).frame = ((UIView *)[_cells objectAtIndex:i + 1]).frame;
                }
                UIView *lastItem = [_cells lastObject];
                lastItem.frame = firstItemFrame;
                [_dataSource pagingEnabledView:self wantsReloadDataAtIndex:_curDataIndex - 1 forCell:lastItem];
                [_cells removeObject:lastItem];
                [_cells insertObject:lastItem atIndex:0];
                _isCodeMakeScroll = YES;
                [_scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x + itemWidth, 0)];
            }
        }
    }
}

@end
