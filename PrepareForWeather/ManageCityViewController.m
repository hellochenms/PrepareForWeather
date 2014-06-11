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
@property (nonatomic) UIButton          *editButton;
@property (nonatomic) CityItem          *touchedItem;
@property (nonatomic) CGPoint           beginPoint;
@property (nonatomic) CGPoint           itemBeginCenter;
@property (nonatomic) CGPoint           itemToCenter;
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
        [item reloadData:[_datas objectAtIndex:i]];
        item.backgroundColor = [UIColor blueColor];
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
//            NSLog(@"itemCenter: %@ -> %@  @@%s", NSStringFromCGPoint(_itemBeginCenter), NSStringFromCGPoint(_touchedItem.center), __func__);
            [self endMove:rec];
            _panRec.enabled = YES;
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
//            NSLog(@"itemCenter: %@ -> %@  @@%s", NSStringFromCGPoint(_itemBeginCenter), NSStringFromCGPoint(_touchedItem.center), __func__);
            [self endMove:rec];
            break;
        }
        default:
            break;
    }
}

- (void)beginMove:(UIGestureRecognizer *)rec{
    _touchedItem = nil;
    _beginPoint = CGPointZero;
    _itemBeginCenter = CGPointZero;
    _itemToCenter = CGPointZero;
    
    CGPoint point = [rec locationInView:rec.view];
    CityItem *item = nil;
    BOOL isTouchOnItem = NO;
    for (item in _items) {
        if ([item isKindOfClass:[CityItem class]] && CGRectContainsPoint(item.frame, point)) {
            isTouchOnItem = YES;
            _touchedItem = item;
            _beginPoint = point;
            _itemBeginCenter = item.center;
            _itemToCenter = _itemBeginCenter;
            break;
        }
    }
    if (isTouchOnItem) {
        [self changeEditing:YES];
    }
}
- (void)keepMove:(UIGestureRecognizer *)rec{
    CGPoint point = [rec locationInView:rec.view];
    float offsetX = point.x - _beginPoint.x;
    float offsetY = point.y - _beginPoint.y;
    CGPoint center = CGPointMake(_itemBeginCenter.x + offsetX, _itemBeginCenter.y + offsetY);
    _touchedItem.transform = CGAffineTransformMakeTranslation(offsetX, offsetY);
    
    CityItem *item = nil;
    for (item in _items) {
        if ([item isKindOfClass:[CityItem class]] && item != _touchedItem && CGRectContainsPoint(item.frame, center)) {
            CGPoint nextCenter = item.center;
            item.center = _itemToCenter;
            _itemToCenter = nextCenter;
            break;
        }
    }
}

- (void)endMove:(UIGestureRecognizer *)rec{
    _touchedItem.center = _itemToCenter;
    _touchedItem.transform = CGAffineTransformIdentity;
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
    _isEditing = isEditing;
    CityItem *item = nil;
    for (item in _items) {
        if ([item isKindOfClass:[CityItem class]]) {
            [item showDeleteButton:isEditing];
        }else{
            item.hidden = isEditing;
        }
    }
    if (!_isEditing) {
        _panRec.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTapAddCityItem{
    SelectCityViewController *subViewController = [SelectCityViewController new];
    [self.navigationController pushViewController:subViewController animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
