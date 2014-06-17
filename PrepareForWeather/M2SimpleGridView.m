//
//  M2SimpleGridView.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-13.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "M2SimpleGridView.h"

#define M2SGV_Tag_TypeContentCell   6000
#define M2SGV_Tag_TypeAddCell       6001

@interface M2SimpleGridView()
@property (nonatomic) NSMutableArray                *cells;
@property (nonatomic) NSInteger                     maxCellCount;
@property (nonatomic) CGSize                        cellContainerSize;
@property (nonatomic) CGSize                        cellSize;
@property (nonatomic) NSInteger                     cellCountInRow;
@property (nonatomic) NSInteger                     rowCount;
@property (nonatomic) UIEdgeInsets                  paddingInsets;

@property (nonatomic) UIView                        *containerView;
@property (nonatomic) BOOL                          isEditing;

@property (nonatomic) UILongPressGestureRecognizer  *longPressRec;
@property (nonatomic) UIPanGestureRecognizer        *panRec;
@property (nonatomic) UITapGestureRecognizer        *tapRec;
@property (nonatomic) UIView                        *touchedCell;
@property (nonatomic) CGPoint                       srcTouchPoint;
@property (nonatomic) CGPoint                       srcTouchCellCenter;
@property (nonatomic) CGPoint                       destTouchCellCenter;
@end

@implementation M2SimpleGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _cells = [NSMutableArray array];
        
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
    UIView *cell = nil;
    for (cell in _cells) {
        [cell removeFromSuperview];
    }
    [_cells removeAllObjects];
    
    if (!_dataSource
        || ![_dataSource respondsToSelector:@selector(numberOfCellsInGridView:)]
        || ![_dataSource respondsToSelector:@selector(gridView:cellAtIndex:)]
        || ![_dataSource respondsToSelector:@selector(sizeOfCellForGridView:)]
        || ![_dataSource respondsToSelector:@selector(cellCountInRowForGridView:)]
        || ![_dataSource respondsToSelector:@selector(rowCountForGridView:)]
        || ![_dataSource respondsToSelector:@selector(addCellForGridView:)]
        || ![_dataSource respondsToSelector:@selector(imageOfDeleteCellForGridView:)]
        || ![_dataSource respondsToSelector:@selector(sizeOfDeleteCellForGridView:)]) {
        return;
    }
    
    NSInteger count = [_dataSource numberOfCellsInGridView:self];
    if (count <= 0) {
        return;
    }
    
    if ([_dataSource respondsToSelector:@selector(paddingInsetsForGridView:)]) {
        _paddingInsets = [_dataSource paddingInsetsForGridView:self];
    }
    _containerView.frame = CGRectMake(_paddingInsets.left, _paddingInsets.top, CGRectGetWidth(self.bounds) - _paddingInsets.left - _paddingInsets.right, CGRectGetHeight(self.bounds) - _paddingInsets.top - _paddingInsets.bottom);
    _cellSize = [_dataSource sizeOfCellForGridView:self];
    _cellCountInRow = [_dataSource cellCountInRowForGridView:self];
    _rowCount = [_dataSource rowCountForGridView:self];
    if (_cellSize.width <= 0 || _cellSize.height <= 0) {
        return;
    }
    if (_cellCountInRow <= 0 || _rowCount <= 0){
        return;
    }
    
    NSAssert((_cellSize.width * _cellCountInRow <= CGRectGetWidth(_containerView.bounds)), @"cellSize与cellCountInRow设置冲突，一行放不下指定个数的cell。");
    NSAssert((_cellSize.height * _rowCount <= CGRectGetHeight(_containerView.bounds)), @"cellSize与rowCount设置冲突，一列放不下指定个数的cell。");
    
    _cellContainerSize = CGSizeMake(floor(CGRectGetWidth(_containerView.bounds) / _cellCountInRow), floor(CGRectGetHeight(_containerView.bounds) / _rowCount));
    _maxCellCount = _cellCountInRow * _rowCount;
    
    // build new
    M2SimpleGridViewCellContainer *cellContainer = nil;
    CGSize deleteButtonSize = CGSizeMake(15, 15);
    if ([_dataSource respondsToSelector:@selector(sizeOfDeleteCellForGridView:)]) {
        deleteButtonSize = [_dataSource sizeOfDeleteCellForGridView:self];
    }
    UIImage *deleteButtonImage = nil;
    if ([_dataSource respondsToSelector:@selector(imageOfDeleteCellForGridView:)]) {
        deleteButtonImage = [_dataSource imageOfDeleteCellForGridView:self];
    }
    for (NSInteger i = 0; i < count; i++) {
        cellContainer = [[M2SimpleGridViewCellContainer alloc] initWithFrame:[self buildCellContainerFrameWithIndex: i]];
        cellContainer.tag = M2SGV_Tag_TypeContentCell;
        cellContainer.tapDeleteHandler = [self buildTapDeleteHandler];
        [_containerView addSubview:cellContainer];
        [_cells addObject:cellContainer];
        cell = [_dataSource gridView:self cellAtIndex:i];
        cell.frame = CGRectMake((_cellContainerSize.width - _cellSize.width) / 2,
                                (_cellContainerSize.height - _cellSize.height) / 2,
                                _cellSize.width,
                                _cellSize.height);
        [cellContainer insertSubview:cell atIndex:0];
        cellContainer.deleteButton.frame = CGRectMake(0, 0, deleteButtonSize.width, deleteButtonSize.height);
        cellContainer.deleteButton.center = cell.frame.origin;
        if (deleteButtonImage) {
            [cellContainer.deleteButton setImage:deleteButtonImage forState:UIControlStateNormal];
        }else{
            cellContainer.deleteButton.backgroundColor = [UIColor redColor];
        }
    }
    if (count < _maxCellCount) {
        cellContainer = [[M2SimpleGridViewCellContainer alloc] initWithFrame:[self buildCellContainerFrameWithIndex: count]];
        cellContainer.tag = M2SGV_Tag_TypeAddCell;
        cellContainer.hidden = _isEditing;
        [_containerView addSubview:cellContainer];
        [_cells addObject:cellContainer];
        UIView *addCell = [self buildAddCellView];
        addCell.frame = CGRectMake((_cellContainerSize.width - _cellSize.width) / 2,
                                                    (_cellContainerSize.height - _cellSize.height) / 2,
                                                    _cellSize.width,
                                                    _cellSize.height);;
        [cellContainer insertSubview:addCell atIndex:0];
    }
}

#pragma mark - 添加元素
- (void)onTapAddCell{
    if (_delegate && [_delegate respondsToSelector:@selector(wantsAddNewCellByGridView:)]) {
        [_delegate wantsAddNewCellByGridView:self];
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
    M2SimpleGridViewCellContainer *cellContainer = nil;
    for (cellContainer in _cells) {
        if (cellContainer.tag == M2SGV_Tag_TypeContentCell) {
            [cellContainer showDeleteButton:isEditing];
        }else{
            cellContainer.hidden = isEditing;
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
    M2SGVIC_TapDeleteHandler tapDeleteHandler = ^(M2SimpleGridViewCellContainer * deleteCell){
        NSInteger deleteCellIndex = [weakSelf.cells indexOfObject:deleteCell];
        for (NSInteger i = [weakSelf.cells count] - 1; i > deleteCellIndex; i--) {
            ((UIView *)[weakSelf.cells objectAtIndex:i]).center = ((UIView *)[weakSelf.cells objectAtIndex:i - 1]).center;
        }
        [deleteCell removeFromSuperview];
        [weakSelf.cells removeObject:deleteCell];
        
        [weakSelf.delegate gridView:weakSelf wantsDeleteCellAtIndex:deleteCellIndex];
        
        if ([weakSelf.dataSource numberOfCellsInGridView:weakSelf] == weakSelf.maxCellCount - 1) {
            M2SimpleGridViewCellContainer *cellContainer = [[M2SimpleGridViewCellContainer alloc] initWithFrame:[self buildCellContainerFrameWithIndex: weakSelf.maxCellCount - 1]];
            cellContainer.tag = M2SGV_Tag_TypeAddCell;
            cellContainer.hidden = _isEditing;
            [_containerView addSubview:cellContainer];
            [_cells addObject:cellContainer];
            UIView *addCellView = [self buildAddCellView];
            addCellView.frame = CGRectMake((_cellContainerSize.width - _cellSize.width) / 2,
                                                        (_cellContainerSize.height - _cellSize.height) / 2,
                                                        _cellSize.width,
                                                        _cellSize.height);;
            [cellContainer insertSubview:addCellView atIndex:0];
        }
    };
    
    return tapDeleteHandler;
}

#pragma mark - 长按Cell：进入编辑模式，长按时拖动调整Cell排序；
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

#pragma mark - 编辑模式下拖动：调整cell排序；
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
    _touchedCell = nil;
    _srcTouchPoint = CGPointZero;
    _srcTouchCellCenter = CGPointZero;
    _destTouchCellCenter = CGPointZero;
    
    CGPoint point = [rec locationInView:rec.view];
    UIView *cellContainer = nil;
    BOOL isTouchOnCell = NO;
    for (cellContainer in _cells) {
        if (cellContainer.tag == M2SGV_Tag_TypeContentCell  && CGRectContainsPoint(cellContainer.frame, point)) {
            isTouchOnCell = YES;
            _touchedCell = cellContainer;
            [_containerView bringSubviewToFront:_touchedCell];
            _srcTouchPoint = point;
            _srcTouchCellCenter = cellContainer.center;
            _destTouchCellCenter = cellContainer.center;
            break;
        }
    }
    if (isTouchOnCell) {
        [self changeEditing:YES];
    }
}
- (void)keepMove:(UIGestureRecognizer *)rec{
    if (!_touchedCell) {
        return;
    }
    CGPoint curTouchPoint = [rec locationInView:rec.view];
    float offsetX = curTouchPoint.x - _srcTouchPoint.x;
    float offsetY = curTouchPoint.y - _srcTouchPoint.y;
    CGPoint curCenter = CGPointMake(_srcTouchCellCenter.x + offsetX, _srcTouchCellCenter.y + offsetY);
    _touchedCell.center = curCenter;
    
    UIView *cellContainer = nil;
    int curTouchIndex = -1;
    int targetIndex = -1;
    BOOL isAtValidArea = NO;
    for (cellContainer in _cells) {
        if (cellContainer.tag == M2SGV_Tag_TypeAddCell) {
            continue;
        }
        if (cellContainer != _touchedCell && CGRectContainsPoint(cellContainer.frame, curCenter)) {
            isAtValidArea = YES;
            curTouchIndex = [_cells indexOfObject:_touchedCell];
            targetIndex = [_cells indexOfObject:cellContainer];
            break;
        }
    }
    if (!isAtValidArea) {
        if ([_dataSource numberOfCellsInGridView:self] == _maxCellCount) {
            return;
        }
        CGRect frame = CGRectZero;
        for (NSInteger i = [_cells count] - 1; i < _maxCellCount; i++) {
            frame = [self buildCellContainerFrameWithIndex:i];
            if (CGRectContainsPoint(frame, curCenter)) {
                curTouchIndex = [_cells indexOfObject:_touchedCell];
                targetIndex = [_cells count] - 2;
                break;
            }
        }
    }
    
    if (curTouchIndex == -1 || targetIndex == -1 || curTouchIndex == targetIndex) {
        return;
    }
    
    CGPoint nextDestTouchCellCenter =  ((UIView *)[_cells objectAtIndex:targetIndex]).center;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         if (curTouchIndex > targetIndex) {
                             for (int i = targetIndex; i <= curTouchIndex - 2; i++) {
                                 ((UIView *)[_cells objectAtIndex:i]).center = ((UIView *)[_cells objectAtIndex:i + 1]).center;
                             }
                             ((UIView *)[_cells objectAtIndex:curTouchIndex - 1]).center = _destTouchCellCenter;
                         }else{
                             for (int i = targetIndex; i >= curTouchIndex + 2; i--) {
                                 ((UIView *)[_cells objectAtIndex:i]).center = ((UIView *)[_cells objectAtIndex:i - 1]).center;
                             }
                             ((UIView *)[_cells objectAtIndex:curTouchIndex + 1]).center = _destTouchCellCenter;
                         }
                         [_cells removeObject:_touchedCell];
                         [_cells insertObject:_touchedCell atIndex:targetIndex];
                         _destTouchCellCenter = nextDestTouchCellCenter;
                         
                         [_delegate gridView:self wantsMoveCellFromIndex:curTouchIndex toIndex:targetIndex];
                     }];
}

- (void)endMove:(UIGestureRecognizer *)rec{
    if (!_touchedCell) {
        return;
    }
    _touchedCell.center = _destTouchCellCenter;
}

- (void)onTap:(UITapGestureRecognizer *)tapRec{
    if (!_isEditing) {
        return;
    }
    [self changeEditing:NO];
}

#pragma mark - tools
- (UIView *)buildAddCellView{
    UIView *addCell = [self.dataSource addCellForGridView:self];
    NSAssert(addCell != nil, @"您需要实现M2SimpleGridViewDataSource协议的addCellViewForGridView:方法，且返回值不能为nil。");
    addCell.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapAddCellRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAddCell)];
    [addCell addGestureRecognizer:tapAddCellRec];
    
    return addCell;
}

- (CGRect)buildCellContainerFrameWithIndex:(NSInteger)index{
    return CGRectMake(_cellContainerSize.width * (index % _cellCountInRow),
                      _cellContainerSize.height * (index / _cellCountInRow),
                      _cellContainerSize.width,
                      _cellContainerSize.height);
}

@end

@implementation M2SimpleGridViewCellContainer
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
