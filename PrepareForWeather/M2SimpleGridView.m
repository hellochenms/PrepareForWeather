//
//  M2SimpleGridView.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-13.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "M2SimpleGridView.h"

#define M2SGV_Tag_TypeContentItem   6000
#define M2SGV_Tag_TypeAddItem       6001

@interface M2SimpleGridView()
@property (nonatomic) NSMutableArray                *items;
@property (nonatomic) NSInteger                     maxItemCount;
@property (nonatomic) CGSize                        itemContainerSize;

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
    UIView *item = nil;
    for (item in _items) {
        [item removeFromSuperview];
    }
    [_items removeAllObjects];
    
    if (!_dataSource
        || ![_dataSource respondsToSelector:@selector(numberOfCellsInGridView:)]
        || ![_dataSource respondsToSelector:@selector(gridView:cellAtIndex:)]
        || ![_dataSource respondsToSelector:@selector(addItemViewForGridView:)]) {
        return;
    }
    
    NSInteger count = [_dataSource numberOfCellsInGridView:self];
    if (count <= 0) {
        return;
    }
    
    _containerView.frame = CGRectMake(_paddingInsets.left, _paddingInsets.top, CGRectGetWidth(self.bounds) - _paddingInsets.left - _paddingInsets.right, CGRectGetHeight(self.bounds) - _paddingInsets.top - _paddingInsets.bottom);
    if (_itemSize.width <= 0 || _itemSize.height <= 0) {
        return;
    }
    if (_itemCountInRow <= 0 || _rowCount <= 0){
        return;
    }
    
    NSAssert((_itemSize.width * _itemCountInRow <= CGRectGetWidth(_containerView.bounds)), @"itemSize与itemCountInRow设置冲突，一行放不下指定个数的item。");
    NSAssert((_itemSize.height * _rowCount <= CGRectGetHeight(_containerView.bounds)), @"itemSize与rowCount设置冲突，一列放不下指定个数的item。");
    
    _itemContainerSize = CGSizeMake(floor(CGRectGetWidth(_containerView.bounds) / _itemCountInRow), floor(CGRectGetHeight(_containerView.bounds) / _rowCount));
    _maxItemCount = _itemCountInRow * _rowCount;
    
    // build new
    M2SimpleGridViewItemContainer *itemContainer = nil;
    CGSize deleteButtonSize = CGSizeMake(15, 15);
    if ([_dataSource respondsToSelector:@selector(deleteButtonSizeOfItemForGridView:)]) {
        deleteButtonSize = [_dataSource deleteButtonSizeOfItemForGridView:self];
    }
    UIImage *deleteButtonImage = nil;
    if ([_dataSource respondsToSelector:@selector(deleteButtonImageOfItemForGridView:)]) {
        deleteButtonImage = [_dataSource deleteButtonImageOfItemForGridView:self];
    }
    for (NSInteger i = 0; i < count; i++) {
        itemContainer = [[M2SimpleGridViewItemContainer alloc] initWithFrame:[self buildItemContainerFrameWithIndex: i]];
        itemContainer.tag = M2SGV_Tag_TypeContentItem;
        itemContainer.tapDeleteHandler = [self buildTapDeleteHandler];
        [_containerView addSubview:itemContainer];
        [_items addObject:itemContainer];
        item = [_dataSource gridView:self cellAtIndex:i];
        item.frame = CGRectMake((_itemContainerSize.width - _itemSize.width) / 2,
                                (_itemContainerSize.height - _itemSize.height) / 2,
                                _itemSize.width,
                                _itemSize.height);
        [itemContainer insertSubview:item atIndex:0];
        itemContainer.deleteButton.frame = CGRectMake(0, 0, deleteButtonSize.width, deleteButtonSize.height);
        itemContainer.deleteButton.center = item.frame.origin;
        if (deleteButtonImage) {
            [itemContainer.deleteButton setImage:deleteButtonImage forState:UIControlStateNormal];
        }else{
            itemContainer.deleteButton.backgroundColor = [UIColor redColor];
        }
    }
    if (count < _maxItemCount) {
        itemContainer = [[M2SimpleGridViewItemContainer alloc] initWithFrame:[self buildItemContainerFrameWithIndex: count]];
        itemContainer.tag = M2SGV_Tag_TypeAddItem;
        [_containerView addSubview:itemContainer];
        [_items addObject:itemContainer];
        UIView *addItemView = [self buildAddItemView];
        addItemView.frame = item.frame = CGRectMake((_itemContainerSize.width - _itemSize.width) / 2,
                                                    (_itemContainerSize.height - _itemSize.height) / 2,
                                                    _itemSize.width,
                                                    _itemSize.height);;
        [itemContainer insertSubview:addItemView atIndex:0];
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
    M2SimpleGridViewItemContainer *item = nil;
    for (item in _items) {
        if (item.tag == M2SGV_Tag_TypeContentItem) {
            [item showDeleteButton:isEditing];
        }else{
            item.hidden = isEditing;
        }
    }
    _panRec.enabled = _isEditing;
    _tapRec.enabled = _isEditing;
}

#pragma mark - 删除元素
- (M2SGVIC_TapDeleteHandler)buildTapDeleteHandler{
    if (!_delegate || ![_delegate respondsToSelector:@selector(gridView:wantsDeleteCellAtIndex:)]) {
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    M2SGVIC_TapDeleteHandler tapDeleteHandler = ^(M2SimpleGridViewItemContainer * deleteItem){
        NSInteger deleteItemIndex = [weakSelf.items indexOfObject:deleteItem];
        for (NSInteger i = [weakSelf.items count] - 1; i > deleteItemIndex; i--) {
            ((UIView *)[weakSelf.items objectAtIndex:i]).center = ((UIView *)[weakSelf.items objectAtIndex:i - 1]).center;
        }
        [deleteItem removeFromSuperview];
        [weakSelf.items removeObject:deleteItem];
        
        [weakSelf.delegate gridView:weakSelf wantsDeleteCellAtIndex:deleteItemIndex];
        
        if ([weakSelf.dataSource numberOfCellsInGridView:weakSelf] == weakSelf.maxItemCount - 1) {
            M2SimpleGridViewItemContainer *itemContainer = [[M2SimpleGridViewItemContainer alloc] initWithFrame:[self buildItemContainerFrameWithIndex: weakSelf.maxItemCount - 1]];
            itemContainer.tag = M2SGV_Tag_TypeAddItem;
            [_containerView addSubview:itemContainer];
            [_items addObject:itemContainer];
            UIView *addItemView = [self buildAddItemView];
            addItemView.frame = CGRectMake((_itemContainerSize.width - _itemSize.width) / 2,
                                                        (_itemContainerSize.height - _itemSize.height) / 2,
                                                        _itemSize.width,
                                                        _itemSize.height);;
            [itemContainer insertSubview:addItemView atIndex:0];
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
    UIView *item = nil;
    BOOL isTouchOnItem = NO;
    for (item in _items) {
        if (item.tag == M2SGV_Tag_TypeContentItem  && CGRectContainsPoint(item.frame, point)) {
            isTouchOnItem = YES;
            _touchedItem = item;
            [_containerView bringSubviewToFront:_touchedItem];
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
    
    UIView *item = nil;
    int curTouchIndex = -1;
    int targetIndex = -1;
    BOOL isAtValidArea = NO;
    for (item in _items) {
        if (item.tag == M2SGV_Tag_TypeAddItem) {
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
        if ([_dataSource numberOfCellsInGridView:self] == _maxItemCount) {
            return;
        }
        CGRect frame = CGRectZero;
        for (NSInteger i = [_items count] - 1; i < _maxItemCount; i++) {
            frame = [self buildItemContainerFrameWithIndex:i];
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
    
    CGPoint nextDestTouchItemCenter =  ((UIView *)[_items objectAtIndex:targetIndex]).center;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         if (curTouchIndex > targetIndex) {
                             for (int i = targetIndex; i <= curTouchIndex - 2; i++) {
                                 ((UIView *)[_items objectAtIndex:i]).center = ((UIView *)[_items objectAtIndex:i + 1]).center;
                             }
                             ((UIView *)[_items objectAtIndex:curTouchIndex - 1]).center = _destTouchItemCenter;
                         }else{
                             for (int i = targetIndex; i >= curTouchIndex + 2; i--) {
                                 ((UIView *)[_items objectAtIndex:i]).center = ((UIView *)[_items objectAtIndex:i - 1]).center;
                             }
                             ((UIView *)[_items objectAtIndex:curTouchIndex + 1]).center = _destTouchItemCenter;
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
    [self changeEditing:NO];
}

#pragma mark - tools
- (UIView *)buildAddItemView{
    UIView *addItemView = [self.dataSource addItemViewForGridView:self];
    NSAssert(addItemView != nil, @"您需要实现M2SimpleGridViewDataSource协议的addItemViewForGridView:方法，且返回值不能为nil。");
    addItemView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapAddItemRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAddItem)];
    [addItemView addGestureRecognizer:tapAddItemRec];
    addItemView.hidden = self.isEditing;
    
    return addItemView;
}

- (CGRect)buildItemContainerFrameWithIndex:(NSInteger)index{
    return CGRectMake(_itemContainerSize.width * (index % _itemCountInRow),
                      _itemContainerSize.height * (index / _itemCountInRow),
                      _itemContainerSize.width,
                      _itemContainerSize.height);
}

@end

@implementation M2SimpleGridViewItemContainer
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = randomColor;
        // Initialization code
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton addTarget:self action:@selector(onTapDeleteButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        _deleteButton.hidden = YES;
    }
    return self;
}

#pragma mark -
- (void)showDeleteButton:(BOOL)toShow{
    _deleteButton.hidden = !toShow;
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform"];
    shake.duration = 0.13;
    shake.autoreverses = YES;
    shake.repeatCount  = MAXFLOAT;
    shake.removedOnCompletion = NO;//TODO:!
    shake.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-M_PI / 90, 0, 0, 1)];
    shake.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI / 90, 0, 0, 1)];
    if (toShow) {
        [self.layer addAnimation:shake forKey:@"shake"];
    }else{
        [self.layer removeAnimationForKey:@"shake"];
    }
}

- (void)onTapDeleteButton{
    if (_tapDeleteHandler) {
        _tapDeleteHandler(self);
    }
}

@end
