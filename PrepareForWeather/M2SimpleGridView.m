//
//  M2SimpleGridView.m
//  M2Common
//
//  Created by Chen Meisong on 14-6-12.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "M2SimpleGridView.h"

@interface M2SimpleGridView()
@property (nonatomic) NSMutableArray                *items;
@property (nonatomic) NSInteger                     itemCountInRow;
@property (nonatomic) NSInteger                     maxItemCount;

@property (nonatomic) UIView                        *containerView;
@property (nonatomic) BOOL                          isEditing;

@property (nonatomic) UILongPressGestureRecognizer  *longPressRec;
@property (nonatomic) UIPanGestureRecognizer        *panRec;
@property (nonatomic) UITapGestureRecognizer        *tapRec;
@property (nonatomic) UIView                        *touchedItem;
@property (nonatomic) CGPoint                       srcTouchPoint;
@property (nonatomic) CGPoint                       srcTouchItemCenter;
@property (nonatomic) CGPoint                       destTouchItemCenter;
@end

@implementation M2SimpleGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _items = [NSMutableArray array];
        
        //
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
        _containerView.clipsToBounds = YES;
        [self addSubview:_containerView];
        
        // 长按：进入编辑模式，不松手可拖动排序；
        _longPressRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
        [_containerView addGestureRecognizer:_longPressRec];
        // 拖动：只在编辑模式可用，拖动排序；
        _panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        _panRec.enabled = NO;
        [_containerView addGestureRecognizer:_panRec];
        // 单击：单击空白区域退出编辑模式；
        _tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        _tapRec.enabled = NO;
        [_containerView addGestureRecognizer:_tapRec];
        
        // 初始样式
        _paddingInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        _itemSize = CGSizeMake(CGRectGetWidth(self.bounds) - _paddingInsets.left - _paddingInsets.right, 50);
        _itemHorizontalSpacing = 0;
        _itemVerticalSpacing = 0;
    }
    return self;
}

#pragma mark - setter: dataSource
- (void)setDataSource:(id<M2SimpleGridViewDataSource>)dataSource{
    _dataSource = dataSource;
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0];
}

#pragma mark - setter: delegate
- (void)setDelegate:(id<M2SimpleGridViewDelegate>)delegate{
    _delegate = delegate;
    if (_delegate) {
        _longPressRec.enabled = YES;
    }else{
        _longPressRec.enabled = NO;
    }
}

#pragma mark - 刷新数据
- (void)reloadData{
    // clear old
    M2SimpleGridViewCell *item = nil;
    for (item in _items) {
        [item removeFromSuperview];
    }
    [_items removeAllObjects];
    
    if (!_dataSource) {
        return;
    }
    
    NSInteger count = 0;
    if (![_dataSource respondsToSelector:@selector(numberOfCellsInGridView:)]) {
        return;
    }
    count = [_dataSource numberOfCellsInGridView:self];
    if (count <= 0) {
        return;
    }

    CGFloat contentAreaWidth = CGRectGetWidth(self.bounds) - _paddingInsets.left - _paddingInsets.right;
    CGFloat contentAreaWidthForCalc = contentAreaWidth + _itemHorizontalSpacing;
    CGFloat itemWidthForCalc = _itemSize.width + _itemHorizontalSpacing;
    if (itemWidthForCalc <= 0) {
        return;
    }
    _itemCountInRow = contentAreaWidthForCalc / itemWidthForCalc;
    if (_itemCountInRow <= 0){
        return;
    }
    CGFloat contentAreaHeight = CGRectGetHeight(self.bounds) - _paddingInsets.top - _paddingInsets.bottom;
    CGFloat contentAreaHeightForCalc = contentAreaHeight + _itemVerticalSpacing;
    CGFloat itemHeightForCalc = _itemSize.height + _itemVerticalSpacing;
    if (itemHeightForCalc <= 0) {
        return;
    }
    NSInteger rowCount = contentAreaHeightForCalc / itemHeightForCalc;
    if (rowCount <= 0) {
        return;
    }
    _maxItemCount = _itemCountInRow * rowCount;
    
    if (![_dataSource respondsToSelector:@selector(gridView:cellAtIndex:)]) {
        return;
    }
    
    // build new
    NSInteger i = 0;
    for (; i < count; i++) {
        item = [_dataSource gridView:self cellAtIndex:i];
        item.frame = [self buildItemFrameWithIndex:i];
        [_containerView addSubview:item];
        [_items addObject:item];
        item.tapDeleteHandler = [self buildTapDeleteHandler];
    }
    if (count < _maxItemCount) {
        UIView *addItemView = [self buildAddItemView];
        addItemView.frame = [self buildItemFrameWithIndex:count];
        [self.items addObject:addItemView];
        [self.containerView addSubview:addItemView];
    }
}

#pragma mark - 添加元素
- (void)onTapAddItem{
    if (_delegate && [_delegate respondsToSelector:@selector(wantsAddNewItemByGridView:)]) {
        [_delegate wantsAddNewItemByGridView:self];
    }
}

#pragma mark - 编辑模式
- (void)changeEditing:(BOOL)isEditing{
    if (!_delegate) {
        return;
    }
    if (_isEditing == isEditing) {
        return;
    }
    _isEditing = isEditing;
    M2SimpleGridViewCell *item = nil;
    for (item in _items) {
        if ([item isKindOfClass:[M2SimpleGridViewCell class]]) {
            [item showDeleteButton:isEditing];
        }else{
            item.hidden = isEditing;
        }
    }
    _panRec.enabled = _isEditing;
    _tapRec.enabled = _isEditing;
}

#pragma mark - 删除元素
- (TapDeleteHandler)buildTapDeleteHandler{
    if (!_delegate || ![_delegate respondsToSelector:@selector(gridView:wantsDeleteCellAtIndex:)]) {
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    TapDeleteHandler tapDeleteHandler = ^(M2SimpleGridViewCell * deleteItem){
        NSInteger deleteItemIndex = [weakSelf.items indexOfObject:deleteItem];
        for (NSInteger i = [weakSelf.items count] - 1; i > deleteItemIndex; i--) {
            ((M2SimpleGridViewCell *)[weakSelf.items objectAtIndex:i]).center = ((M2SimpleGridViewCell *)[weakSelf.items objectAtIndex:i - 1]).center;
        }
        [deleteItem removeFromSuperview];
        [weakSelf.items removeObject:deleteItem];
        
        [weakSelf.delegate gridView:weakSelf wantsDeleteCellAtIndex:deleteItemIndex];
        
        if ([weakSelf.dataSource numberOfCellsInGridView:weakSelf] == weakSelf.maxItemCount - 1) {
            UIView *addItemView = [weakSelf buildAddItemView];
            addItemView.frame = [weakSelf buildItemFrameWithIndex:weakSelf.maxItemCount - 1];
            [weakSelf.items addObject:addItemView];
            [weakSelf.containerView addSubview:addItemView];
        }
    };
    
    return tapDeleteHandler;
}

#pragma mark - 长按item：进入编辑模式，长按时拖动调整item排序；
- (void)onLongPress:(UILongPressGestureRecognizer *)rec{
    switch (rec.state) {
        case UIGestureRecognizerStateBegan:{
            if (_isEditing) {
                return;
            }
            [self beginMove:rec];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [self keepMove:rec];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:{
            [self endMove:rec];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - 编辑模式下拖动：调整item排序；
- (void)onPan:(UIPanGestureRecognizer *)rec{
    switch (rec.state) {
        case UIGestureRecognizerStateBegan:{
            [self beginMove:rec];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [self keepMove:rec];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:{
            [self endMove:rec];
            break;
        }
        default:
            break;
    }
}

- (void)beginMove:(UIGestureRecognizer *)rec{
    _touchedItem = nil;
    _srcTouchPoint = CGPointZero;
    _srcTouchItemCenter = CGPointZero;
    _destTouchItemCenter = CGPointZero;
    
    CGPoint point = [rec locationInView:rec.view];
    M2SimpleGridViewCell *item = nil;
    BOOL isTouchOnItem = NO;
    for (item in _items) {
        if ([item isKindOfClass:[M2SimpleGridViewCell class]] && CGRectContainsPoint(item.frame, point)) {
            isTouchOnItem = YES;
            _touchedItem = item;
            _srcTouchPoint = point;
            _srcTouchItemCenter = item.center;
            _destTouchItemCenter = item.center;
            break;
        }
    }
    if (isTouchOnItem) {
        [self changeEditing:YES];
    }
}
- (void)keepMove:(UIGestureRecognizer *)rec{
    if (!_touchedItem) {
        return;
    }
    CGPoint curTouchPoint = [rec locationInView:rec.view];
    float offsetX = curTouchPoint.x - _srcTouchPoint.x;
    float offsetY = curTouchPoint.y - _srcTouchPoint.y;
    CGPoint curCenter = CGPointMake(_srcTouchItemCenter.x + offsetX, _srcTouchItemCenter.y + offsetY);
    _touchedItem.center = curCenter;
    
    M2SimpleGridViewCell *item = nil;
    int curTouchIndex = -1;
    int targetIndex = -1;
    BOOL isAtValidArea = NO;
    for (item in _items) {
        if (![item isKindOfClass:[M2SimpleGridViewCell class]]) {
            continue;
        }
        if (item != _touchedItem && CGRectContainsPoint(item.frame, curCenter)) {
            isAtValidArea = YES;
            curTouchIndex = [_items indexOfObject:_touchedItem];
            targetIndex = [_items indexOfObject:item];
            break;
        }
    }
    if (!isAtValidArea) {
        NSLog(@"进入非法区  @@%s", __func__);
        if ([_dataSource numberOfCellsInGridView:self] == _maxItemCount) {
            return;
        }
        CGRect frame = CGRectZero;
        for (NSInteger i = [_items count] - 1; i < _maxItemCount; i++) {
            frame = [self buildItemFrameWithIndex:i];
            if (CGRectContainsPoint(frame, curCenter)) {
                curTouchIndex = [_items indexOfObject:_touchedItem];
                targetIndex = [_items count] - 2;
                break;
            }
        }
    }
    
    if (curTouchIndex == -1 || targetIndex == -1 || curTouchIndex == targetIndex) {
        return;
    }
    
    CGPoint nextDestTouchItemCenter =  ((M2SimpleGridViewCell *)[_items objectAtIndex:targetIndex]).center;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         if (curTouchIndex > targetIndex) {
                             for (int i = targetIndex; i <= curTouchIndex - 2; i++) {
                                 ((M2SimpleGridViewCell *)[_items objectAtIndex:i]).center = ((M2SimpleGridViewCell *)[_items objectAtIndex:i + 1]).center;
                             }
                             ((M2SimpleGridViewCell *)[_items objectAtIndex:curTouchIndex - 1]).center = _destTouchItemCenter;
                         }else{
                             for (int i = targetIndex; i >= curTouchIndex + 2; i--) {
                                 ((M2SimpleGridViewCell *)[_items objectAtIndex:i]).center = ((M2SimpleGridViewCell *)[_items objectAtIndex:i - 1]).center;
                             }
                             NSLog(@"curTouchIndex(%d)  @@%s", curTouchIndex, __func__);
                             ((M2SimpleGridViewCell *)[_items objectAtIndex:curTouchIndex + 1]).center = _destTouchItemCenter;
                         }
                         [_items removeObject:_touchedItem];
                         [_items insertObject:_touchedItem atIndex:targetIndex];
                         _destTouchItemCenter = nextDestTouchItemCenter;
                         
                         [_delegate gridView:self wantsMoveCellFromIndex:curTouchIndex toIndex:targetIndex];
                     }];
}

- (void)endMove:(UIGestureRecognizer *)rec{
    if (!_touchedItem) {
        return;
    }
    _touchedItem.center = _destTouchItemCenter;
}

- (void)onTap:(UITapGestureRecognizer *)tapRec{
    if (!_isEditing) {
        return;
    }
    CGPoint point = [tapRec locationInView:tapRec.view];
    M2SimpleGridViewCell *item = nil;
    BOOL isTouchOnItem = NO;
    for (item in _items) {
        if ([item isKindOfClass:[M2SimpleGridViewCell class]] && CGRectContainsPoint(item.frame, point)) {
            isTouchOnItem = YES;
            break;
        }
    }
    if (!isTouchOnItem) {
        [self changeEditing:NO];
    }
}

#pragma mark - tools
- (UIView *)buildAddItemView{
    UIView *addItemView = [self.dataSource addItemViewForGridView:self];
    NSAssert(addItemView != nil, @"您需要实现M2SimpleGridViewDataSource协议的addItemViewForGridView:方法，且返回值不能为nil。");
    NSAssert(![addItemView isKindOfClass:[M2SimpleGridViewCell class]], @"M2SimpleGridViewDataSource协议的addItemViewForGridView:方法返回值不能是M2SimpleGridViewCell。");
    addItemView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapAddItemRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAddItem)];
    [addItemView addGestureRecognizer:tapAddItemRec];
    addItemView.hidden = self.isEditing;
    
    return addItemView;
}
- (CGRect)buildItemFrameWithIndex:(NSInteger)index{
    return CGRectMake(_paddingInsets.left + (_itemSize.width + _itemHorizontalSpacing) * (index % _itemCountInRow),
                      _paddingInsets.top + (_itemSize.height + _itemVerticalSpacing) * (index / _itemCountInRow),
                      _itemSize.width,
                      _itemSize.height);
}

@end
