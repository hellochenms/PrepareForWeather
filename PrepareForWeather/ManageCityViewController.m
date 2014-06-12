//
//  ManageCityViewController.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-10.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "ManageCityViewController.h"
#import "CityItem.h"
#import "SelectCityViewController.h"

#define MCVCItemMaxCount 9
#define MCVCItemCountInRow 3

@interface ManageCityViewController ()
@property (nonatomic) NSMutableArray    *datas;
@property (nonatomic) NSMutableArray    *items;
@property (nonatomic) UIView            *containerView;
@property (nonatomic) BOOL              isEditing;

@property (nonatomic) UILongPressGestureRecognizer  *longPressRec;
@property (nonatomic) UIPanGestureRecognizer        *panRec;
@property (nonatomic) UITapGestureRecognizer        *tapRec;
@property (nonatomic) UIButton                      *editButton;

@property (nonatomic) CityItem                      *touchedItem;
@property (nonatomic) CGPoint                       srcTouchPoint;
@property (nonatomic) CGPoint                       srcTouchItemCenter;
@property (nonatomic) CGPoint                       destTouchItemCenter;
@end

@implementation ManageCityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _datas = [NSMutableArray array];
        for (int i = 0; i < 5; i++) {
            [_datas addObject:[NSString stringWithFormat:@"%d", i]];
        }
        
        _items = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    if (isIOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 300)];
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_containerView];
    [self refreshUI];
    
    _longPressRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [_containerView addGestureRecognizer:_longPressRec];
    
    _panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    _panRec.enabled = NO;
    [_containerView addGestureRecognizer:_panRec];
    
    _tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [_containerView addGestureRecognizer:_tapRec];
    
    _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _editButton.frame = CGRectMake(60, CGRectGetMaxY(_containerView.frame) + 10, 200, 60);
    _editButton.backgroundColor = [UIColor redColor];
    [_editButton setTitle:@"edit" forState:UIControlStateNormal];
    [_editButton addTarget:self action:@selector(onTapEdit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_editButton];
}

- (void)refreshUI{
    int count = [_datas count];
    CityItem *item = nil;
    float itemWidth = 90;
    float itemHeight = 90;
    float distance = 15;
    int i = 0;
    for (; i < count; i++) {
        item = [[CityItem alloc] initWithFrame:CGRectMake((itemWidth + distance) * (i % MCVCItemCountInRow),
                                                         (itemHeight + distance) * (i / MCVCItemCountInRow),
                                                         itemWidth,
                                                         itemHeight)];
        item.tapDeleteHandler = [self buildTapDeleteHandler];
        [item reloadData:[_datas objectAtIndex:i]];
        [_containerView addSubview:item];
        [_items addObject:item];
    }
    if (count < MCVCItemMaxCount) {
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.frame = CGRectMake((itemWidth + distance) * (i % MCVCItemCountInRow),
                                     (itemHeight + distance) * (i / MCVCItemCountInRow),
                                     itemWidth,
                                     itemHeight);
        [addButton setTitle:@"Add" forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(onTapAddCityItem) forControlEvents:UIControlEventTouchUpInside];
        [_items addObject:addButton];
        [_containerView addSubview:addButton];
    }
}

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
    CityItem *item = nil;
    BOOL isTouchOnItem = NO;
    for (item in _items) {
        if ([item isKindOfClass:[CityItem class]] && CGRectContainsPoint(item.frame, point)) {
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
    
    CityItem *item = nil;
    int curTouchIndex = -1;
    int targetIndex = -1;
    for (item in _items) {
        if ([item isKindOfClass:[CityItem class]] && item != _touchedItem && CGRectContainsPoint(item.frame, curCenter)) {
            curTouchIndex = [_items indexOfObject:_touchedItem];
            targetIndex = [_items indexOfObject:item];
            break;
        }
    }
    
    if (curTouchIndex == -1 || targetIndex == -1) {
        return;
    }
    NSLog(@"_datas(%@)  @@%s", _datas, __func__);
    
    CGPoint nextDestTouchItemCenter =  ((CityItem *)[_items objectAtIndex:targetIndex]).center;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         if (curTouchIndex > targetIndex) {
                             for (int i = targetIndex; i <= curTouchIndex - 2; i++) {
                                 ((CityItem *)[_items objectAtIndex:i]).center = ((CityItem *)[_items objectAtIndex:i + 1]).center;
                             }
                             ((CityItem *)[_items objectAtIndex:curTouchIndex - 1]).center = _destTouchItemCenter;
                         }else{
                             for (int i = targetIndex; i >= curTouchIndex + 2; i--) {
                                 ((CityItem *)[_items objectAtIndex:i]).center = ((CityItem *)[_items objectAtIndex:i - 1]).center;
                             }
                             NSLog(@"curTouchIndex(%d)  @@%s", curTouchIndex, __func__);
                             ((CityItem *)[_items objectAtIndex:curTouchIndex + 1]).center = _destTouchItemCenter;
                         }
                         [_items removeObject:_touchedItem];
                         [_items insertObject:_touchedItem atIndex:targetIndex];
                         NSString *curTouchData = [_datas objectAtIndex:curTouchIndex];
                         _destTouchItemCenter = nextDestTouchItemCenter;
                         [_datas removeObject:curTouchData];
                         [_datas insertObject:curTouchData atIndex:targetIndex];
//                         NSLog(@"_datas(%@)  @@%s", _datas, __func__);
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
        return;//TODO:!
    }
    CGPoint point = [tapRec locationInView:tapRec.view];
    CityItem *item = nil;
    BOOL isTouchOnItem = NO;
    for (item in _items) {
        if ([item isKindOfClass:[CityItem class]] && CGRectContainsPoint(item.frame, point)) {
            isTouchOnItem = YES;
            break;
        }
    }
    if (!isTouchOnItem) {
        [self changeEditing:NO];
    }
}

- (void)onTapEdit{
    [self changeEditing:!_isEditing];
}

- (void)changeEditing:(BOOL)isEditing{
    if (_isEditing == isEditing) {
        return;
    }
    _isEditing = isEditing;
    CityItem *item = nil;
    for (item in _items) {
        if ([item isKindOfClass:[CityItem class]]) {
            [item showDeleteButton:isEditing];
        }else{
            item.hidden = isEditing;
        }
    }
    _panRec.enabled = _isEditing;
}

- (void)onTapAddCityItem{
    SelectCityViewController *subViewController = [SelectCityViewController new];
    __weak typeof(self) weakSelf = self;
    subViewController.tapFinishHandler = ^{
        [weakSelf.datas addObject:[NSString stringWithFormat:@"new%.0f", [[NSDate date] timeIntervalSince1970]]];
        int i = [weakSelf.datas count] - 1;
        float itemWidth = 90;
        float itemHeight = 90;
        float distance = 15;
        CityItem *item = [[CityItem alloc] initWithFrame:CGRectMake((itemWidth + distance) * (i % MCVCItemCountInRow),
                                                          (itemHeight + distance) * (i / MCVCItemCountInRow),
                                                          itemWidth,
                                                          itemHeight)];
        item.tapDeleteHandler = [self buildTapDeleteHandler];
        [item reloadData:[weakSelf.datas lastObject]];
        [weakSelf.containerView addSubview:item];
        UIButton *addButton = [weakSelf.items lastObject];
        if (i == MCVCItemMaxCount - 1) {
            [addButton removeFromSuperview];
            [weakSelf.items removeObject:addButton];
            [weakSelf.items addObject:item];
        }else{
            addButton.frame = CGRectMake((itemWidth + distance) * ((i + 1) % MCVCItemCountInRow),
                                         (itemHeight + distance) * ((i + 1) / MCVCItemCountInRow),
                                         itemWidth,
                                         itemHeight);
            [weakSelf.items insertObject:item atIndex:i];
        }
    };
    [self.navigationController pushViewController:subViewController animated:YES];
}

- (TapDeleteHandler)buildTapDeleteHandler{
    __weak typeof(self) weakSelf = self;
    TapDeleteHandler tapDeleteHandler = ^(CityItem * deleteItem){
        int deleteItemIndex = [weakSelf.items indexOfObject:deleteItem];
        for (int i = [weakSelf.items count] - 1; i > deleteItemIndex; i--) {
            ((CityItem *)[weakSelf.items objectAtIndex:i]).center = ((CityItem *)[weakSelf.items objectAtIndex:i - 1]).center;
        }
        [deleteItem removeFromSuperview];
        [weakSelf.items removeObject:deleteItem];
        [weakSelf.datas removeObjectAtIndex:deleteItemIndex];
        NSLog(@"weakSelf.datas(%@)  @@%s", weakSelf.datas, __func__);
        
        if ([weakSelf.datas count] == MCVCItemMaxCount - 1) {
            float itemWidth = 90;
            float itemHeight = 90;
            float distance = 15;
            UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
            addButton.frame = CGRectMake((itemWidth + distance) * ((MCVCItemMaxCount - 1) % MCVCItemCountInRow),
                                         (itemHeight + distance) * ((MCVCItemMaxCount - 1) / MCVCItemCountInRow),
                                         itemWidth,
                                         itemHeight);
            [addButton setTitle:@"Add" forState:UIControlStateNormal];
            [addButton addTarget:self action:@selector(onTapAddCityItem) forControlEvents:UIControlEventTouchUpInside];
            addButton.hidden = _isEditing;
            [_items addObject:addButton];
            [_containerView addSubview:addButton];
        }
    };
    
    return tapDeleteHandler;
}

@end
